#!/usr/bin/env python3
"""Bit-exact golden reference for ZedBoard MAC Attack mac_test.c.

No third-party packages required. Run all tests IN THE SAME ORDER as the C file;
the C's xorshift32 PRNG state is shared across tests and is not re-seeded.

Examples:
    python mac_golden_model.py --array-size 16
    python mac_golden_model.py --array-size 16 --export-dir golden_vectors
    python mac_golden_model.py --array-size 16 --uart-log board_uart.txt
    python mac_golden_model.py --array-size 16 --uart-log board_uart.txt --require-dumps

The optional mac_test_uart_dump.c emits GOLDEN_BEGIN/GOLDEN_ROW/GOLDEN_END
records; supplying this output in --uart-log allows a truly independent,
element-by-element comparison. The unmodified C only prints summaries.
"""

from __future__ import annotations

import argparse
import csv
from dataclasses import dataclass
import json
from pathlib import Path
import re
import sys
from typing import Sequence

MASK32 = 0xFFFFFFFF
INITIAL_SEED = 0x2468ACE1
REG_DIMS = 0x08
REG_LOAD_PTR = 0x0C
REG_LOAD_DATA = 0x10
REG_CTRL = 0x00


class XorShift32:
    """Exact uint32_t xorshift of mac_test.c, including its 31-bit return mask."""

    def __init__(self, seed: int = INITIAL_SEED):
        self.state = seed & MASK32

    def next_rand(self) -> int:
        self.state = (self.state ^ ((self.state << 13) & MASK32)) & MASK32
        self.state = (self.state ^ (self.state >> 17)) & MASK32
        self.state = (self.state ^ ((self.state << 5) & MASK32)) & MASK32
        return self.state & 0x7FFFFFFF


@dataclass(frozen=True)
class TestSpec:
    index: int
    name: str
    slug: str
    kind: str
    M: int
    K: int
    N: int


TESTS = (
    TestSpec(1, "small numbers", "small_numbers", "SMALL", 4, 4, 4),
    TestSpec(2, "random INT8, 16x16", "random_int8_16x16", "RANDOM", 16, 16, 16),
    TestSpec(3, "random INT8, 64x64 folded", "random_int8_64x64_folded", "RANDOM", 64, 64, 64),
    TestSpec(4, "odd sizes (edge tiles)", "odd_sizes_edge_tiles", "RANDOM", 37, 50, 23),
    TestSpec(5, "one row of A", "one_row_of_a", "RANDOM", 1, 64, 64),
    TestSpec(6, "every input -128", "every_input_min128", "MINV", 16, 16, 16),
    TestSpec(7, "every input 127", "every_input_127", "MAXV", 16, 16, 16),
    TestSpec(8, "B = identity", "b_identity", "IDENT", 16, 16, 16),
)


@dataclass
class Vectors:
    spec: TestSpec
    A: list[list[int]]
    B: list[list[int]]
    C: list[list[int]]
    passes: int
    cycles: int
    seed_before: int
    seed_after: int


def generate_value(kind: str, is_b: bool, r: int, c: int, rng: XorShift32) -> int:
    if kind == "SMALL":
        return (rng.next_rand() % 19) - 9
    if kind == "MINV":
        return -128
    if kind == "MAXV":
        return 127
    if kind == "IDENT" and is_b:
        return int(r == c)  # Crucially: do NOT advance PRNG for B identity.
    return (rng.next_rand() % 256) - 128


def matmul_int8_int32(A: Sequence[Sequence[int]], B: Sequence[Sequence[int]]) -> list[list[int]]:
    """Reference multiply with signed INT8 inputs and signed INT32 output.

    Here K<=64, so worst-case magnitude <= 64*16384 = 1048576:
    no INT32 overflow is possible, so Python integers exactly match C int32_t.
    """
    M, K, N = len(A), len(B), len(B[0])
    assert all(len(row) == K for row in A)
    assert all(len(row) == N for row in B)
    assert all(-128 <= x <= 127 for row in A for x in row)
    assert all(-128 <= x <= 127 for row in B for x in row)
    return [
        [sum(A[i][k] * B[k][j] for k in range(K)) for j in range(N)]
        for i in range(M)
    ]


def make_all_vectors(p: int) -> list[Vectors]:
    if not (1 <= p <= 64):
        raise ValueError("Array size P must be in 1..64 for this C test application.")
    rng = XorShift32()
    vectors = []
    for spec in TESTS:
        start_seed = rng.state
        A = [[generate_value(spec.kind, False, i, k, rng) for k in range(spec.K)]
             for i in range(spec.M)]
        B = [[generate_value(spec.kind, True, k, j, rng) for j in range(spec.N)]
             for k in range(spec.K)]
        passes = ((spec.K + p - 1) // p) * ((spec.N + p - 1) // p)
        cycles = passes * (spec.M + 3 * p - 2)
        vectors.append(Vectors(spec, A, B, matmul_int8_int32(A, B),
                               passes, cycles, start_seed, rng.state))
    return vectors


def pack_little_endian_words(matrix: Sequence[Sequence[int]]) -> list[int]:
    """Mirror load_matrix(): contiguous row-major bytes, 4 per AXI write.

    Least-significant byte is first. Final partially filled word is zero padded.
    Padding is not part of the logical matrix; RTL should ignore extra bytes.
    """
    flat = [v & 0xFF for row in matrix for v in row]
    return [sum(byte << (8 * lane) for lane, byte in enumerate(flat[i:i + 4]))
            for i in range(0, len(flat), 4)]


def write_csv(path: Path, matrix: Sequence[Sequence[int]]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        csv.writer(f).writerows(matrix)


def export_vectors(vectors: Sequence[Vectors], folder: Path, p: int) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    records = []
    for v in vectors:
        s = v.spec
        prefix = f"{s.index:02d}_{s.slug}"
        for label, mat in (("A", v.A), ("B", v.B), ("C_expected", v.C)):
            write_csv(folder / f"{prefix}_{label}.csv", mat)
        # This file lists the actual AXI4-Lite register writes sent by load_matrix().
        dims = s.M | (s.K << 8) | (s.N << 16)
        writes = [(REG_DIMS, dims), (REG_LOAD_PTR, 0)]
        writes += [(REG_LOAD_DATA, word) for word in pack_little_endian_words(v.A)]
        writes += [(REG_LOAD_PTR, 1)]
        writes += [(REG_LOAD_DATA, word) for word in pack_little_endian_words(v.B)]
        writes += [(REG_CTRL, 1)]
        with (folder / f"{prefix}_axi_writes.csv").open("w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            w.writerow(("offset_hex", "value_hex"))
            w.writerows((f"0x{off:02X}", f"0x{value:08X}") for off, value in writes)
        records.append({
            "case": s.index, "name": s.name, "prefix": prefix, "kind": s.kind,
            "M": s.M, "K": s.K, "N": s.N,
            "array_size_p": p, "expected_passes": v.passes,
            "expected_cycles": v.cycles, "C00": v.C[0][0],
            "prng_seed_before": f"0x{v.seed_before:08X}",
            "prng_seed_after": f"0x{v.seed_after:08X}",
            "A_load_words": len(pack_little_endian_words(v.A)),
            "B_load_words": len(pack_little_endian_words(v.B)),
        })
    (folder / "golden_summary.json").write_text(
        json.dumps({"seed": f"0x{INITIAL_SEED:08X}", "array_size_p": p,
                    "cases": records}, indent=2) + "\n", encoding="utf-8")


# Summary line emitted by the original mac_test.c.
SUMMARY_RE = re.compile(
    r"^(PASS|FAIL)\s+(.+?)\s+(\d+)x\s*(\d+)x\s*(\d+)\s+"
    r"(\d+)/\s*(\d+)\s+correct\s+passes\s+(\d+)\s+"
    r"\(eq\s+(\d+)\)\s+cycles\s+(\d+)\s+\(eq\s+(\d+)\)\s*$"
)
BEGIN_RE = re.compile(r"^GOLDEN_BEGIN\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$")
ROW_RE = re.compile(r"^GOLDEN_ROW\s+(\d+)\s*(.*)$")
END_RE = re.compile(r"^GOLDEN_END\s+(\d+)\s*$")


def check_uart_log(vectors: Sequence[Vectors], path: Path, p: int,
                   require_dumps: bool = False) -> bool:
    """Compare summary registers; optionally every streamed C_hw element."""
    content = path.read_text(encoding="utf-8", errors="replace")
    lines = [line.strip() for line in content.splitlines()]
    expected = {v.spec.index: v for v in vectors}
    errors = []
    summary_lines = [m for line in lines if (m := SUMMARY_RE.match(line))]
    info_match = re.search(r"Found it:\s*(\d+)x(\d+) array", content)
    if info_match and (int(info_match.group(1)) != p or int(info_match.group(2)) != p):
        errors.append(f"Board INFO reports {info_match.group(1)}x{info_match.group(2)}, "
                      f"but Python was configured with P={p}.")
    if len(summary_lines) != len(vectors):
        errors.append(f"Found {len(summary_lines)} original C PASS/FAIL summaries, expected {len(vectors)}.")
    for idx, v in enumerate(vectors):
        if idx >= len(summary_lines):
            break
        match = summary_lines[idx]
        verdict, name, M, K, N, correct, total, passes, eqpasses, cycles, eqcycles = match.groups()
        s = v.spec
        actual = tuple(map(int, (M, K, N, correct, total, passes, eqpasses, cycles, eqcycles)))
        wanted = (s.M, s.K, s.N, s.M * s.N, s.M * s.N,
                  v.passes, v.passes, v.cycles, v.cycles)
        if verdict != "PASS" or name != s.name or actual != wanted:
            errors.append(f"Case {s.index} ({s.name}): board {verdict}, "
                          f"board name={name!r}, board stats={actual}, expected={wanted}.")
        else:
            print(f"  [summary OK] {s.index:02d} {s.name}")

    # C's printed hand-check validates the C generator for the first case.
    for line in lines:
        if "hand check:" in line:
            match = re.search(r"=\s*(-?\d+), hardware gave\s+(-?\d+)", line)
            if not match or (int(match.group(1)), int(match.group(2))) != (vectors[0].C[0][0],) * 2:
                errors.append(f"Small-number hand-check does not match Python C[0][0]={vectors[0].C[0][0]}.")

    # Dump format from optional mac_test_uart_dump.c.
    dumps: dict[int, list[list[int]]] = {}
    currently: int | None = None
    for line in lines:
        if (match := BEGIN_RE.match(line)):
            case, M, K, N = map(int, match.groups())
            if currently is not None or case not in expected or case in dumps:
                errors.append(f"Unexpected or duplicate GOLDEN_BEGIN: {line}")
                continue
            s = expected[case].spec
            if (M, K, N) != (s.M, s.K, s.N):
                errors.append(f"Dump dimensions wrong for case {case}: {(M, K, N)}")
            currently = case
            dumps[case] = []
        elif (match := ROW_RE.match(line)):
            if currently is None:
                errors.append(f"GOLDEN_ROW outside dump: {line[:80]}")
                continue
            row_idx = int(match.group(1))
            try:
                values = [int(v) for v in match.group(2).split()]
            except ValueError:
                errors.append(f"Non-numeric GOLDEN_ROW: {line[:80]}")
                continue
            if row_idx != len(dumps[currently]):
                errors.append(f"Case {currently}: expected row {len(dumps[currently])}, got {row_idx}.")
            dumps[currently].append(values)
        elif (match := END_RE.match(line)):
            case = int(match.group(1))
            if case != currently:
                errors.append(f"Mismatched GOLDEN_END for case {case}")
            currently = None
    if currently is not None:
        errors.append(f"Incomplete GOLDEN dump for case {currently}.")

    if require_dumps and len(dumps) != len(vectors):
        errors.append(f"Required full dumps for {len(vectors)} cases; found {len(dumps)}.")
    for idx, rows in dumps.items():
        v = expected[idx]
        s = v.spec
        if len(rows) != s.M or any(len(row) != s.N for row in rows):
            errors.append(f"Case {idx} ({s.name}): dump shape is not {s.M}x{s.N}.")
            continue
        differences = [(i, j, v.C[i][j], rows[i][j])
                       for i in range(s.M) for j in range(s.N) if rows[i][j] != v.C[i][j]]
        if differences:
            i, j, want, got = differences[0]
            errors.append(f"Case {idx} ({s.name}): {len(differences)} mismatches; "
                          f"first C[{i}][{j}]: expected {want}, board {got}.")
        else:
            print(f"  [FULL DATA OK] {idx:02d} {s.name}: {s.M * s.N} matrix entries")

    if not dumps:
        print("NOTE: Original C summary log only; no element-by-element dump was provided.")
        print("      For an independent full comparison, use mac_test_uart_dump.c and --require-dumps.")
    if errors:
        print("\nUART VERIFICATION FAILED:")
        for err in errors:
            print("  FAIL:", err)
        return False
    print("\nUART VERIFICATION PASSED: "
          + ("all streamed results match Python bit-for-bit." if len(dumps) == len(vectors)
             else "C summaries match (full data not independently checked)."))
    return True


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--array-size", "-p", type=int, default=16,
                        help="Actual P from the board's REG_INFO low byte (default: 16).")
    parser.add_argument("--export-dir", type=Path,
                        help="Write A/B/expected-C CSV and AXI load register-write traces.")
    parser.add_argument("--uart-log", type=Path,
                        help="UART text captured from the actual board; compare its results.")
    parser.add_argument("--require-dumps", action="store_true",
                        help="Require full element-by-element UART dumps, not just C PASS summaries.")
    args = parser.parse_args(argv)
    if args.require_dumps and not args.uart_log:
        parser.error("--require-dumps requires --uart-log")
    try:
        vectors = make_all_vectors(args.array_size)
    except ValueError as e:
        parser.error(str(e))
    print(f"MAC Attack golden model | P={args.array_size}x{args.array_size} | "
          f"signed INT8 -> signed INT32 | seed 0x{INITIAL_SEED:08X}")
    print("\n #  Test case                         M  K  N  Passes  Cycles      C[0][0]")
    for v in vectors:
        s = v.spec
        print(f"{s.index:2d}  {s.name:<31} {s.M:2} {s.K:2} {s.N:2} "
              f"{v.passes:7} {v.cycles:7} {v.C[0][0]:12}")
    if args.export_dir:
        export_vectors(vectors, args.export_dir, args.array_size)
        print(f"\nGolden files saved in {args.export_dir.resolve()}")
    if args.uart_log:
        try:
            return 0 if check_uart_log(vectors, args.uart_log, args.array_size,
                                       args.require_dumps) else 1
        except OSError as e:
            print(f"Cannot read UART file: {e}", file=sys.stderr)
            return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
