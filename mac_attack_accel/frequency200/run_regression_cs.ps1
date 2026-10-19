param([string]$VivadoBin = 'C:\Xilinx\Vivado\2019.1\bin')
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$build = Join-Path $PSScriptRoot 'simulation_cs'
New-Item -ItemType Directory -Path $build -Force | Out-Null
Push-Location $build
try {
    $files = @(Get-ChildItem "$root\rtl_cs\*.sv" | ForEach-Object FullName)
    $files += @("$root\tb\tb_selfcheck.sv", "$root\tb\tb_extras.sv", "$root\mac_axi_fast.v", "$root\tb\tb_axi.sv", "$PSScriptRoot\tb_selfcheck3.sv", "$PSScriptRoot\tb_counter_limits.sv", "$PSScriptRoot\tb_selfcheck2.sv", "$root\tb\tb_compare.sv")
    & "$VivadoBin\xvlog.bat" -sv @files
    if ($LASTEXITCODE -ne 0) { throw 'RTL compilation failed' }
    foreach ($top in @('tb_selfcheck','tb_selfcheck2','tb_selfcheck3','tb_counter_limits','tb_axi','tb_extras','tb_compare')) {
        & "$VivadoBin\xelab.bat" "work.$top" -s $top
        if ($LASTEXITCODE -ne 0) { throw "Elaboration failed: $top" }
        & "$VivadoBin\xsim.bat" $top -runall -log "$top.log"
        if ($LASTEXITCODE -ne 0) { throw "Simulation failed: $top" }
        $log = Get-Content "$top.log" -Raw
        if ($log -match 'FAIL|ERROR:' -or $log -notmatch 'ALL (TESTS|AXI TESTS|PARTS|SIZES) PASSED') {
            throw "Test failures or missing completion: $top"
        }
    }
} finally { Pop-Location }







