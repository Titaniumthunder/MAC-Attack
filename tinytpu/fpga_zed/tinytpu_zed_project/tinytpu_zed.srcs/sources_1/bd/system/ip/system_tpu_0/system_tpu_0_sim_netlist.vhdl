-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Mon Nov 16 19:07:24 2026
-- Host        : DESKTOP-VONROUT running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim {c:/Users/James
--               Manikyan/Documents/GitHub/MAC_Attack/tinytpu/fpga_zed/tinytpu_zed_project/tinytpu_zed.srcs/sources_1/bd/system/ip/system_tpu_0/system_tpu_0_sim_netlist.vhdl}
-- Design      : system_tpu_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_tpu_0_tiny_tpu_pe is
  port (
    ovf : out STD_LOGIC;
    SR : out STD_LOGIC_VECTOR ( 0 to 0 );
    B : out STD_LOGIC_VECTOR ( 3 downto 0 );
    \w_data_reg[3]\ : out STD_LOGIC;
    \w_data_reg[2]\ : out STD_LOGIC;
    D : out STD_LOGIC_VECTOR ( 3 downto 0 );
    do_write : out STD_LOGIC;
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    \result_reg[15]_0\ : out STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axi_aclk : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 9 downto 0 );
    s_axi_wdata : in STD_LOGIC_VECTOR ( 9 downto 0 );
    \result_reg[0]_0\ : in STD_LOGIC;
    aw_addr : in STD_LOGIC_VECTOR ( 1 downto 0 );
    aw_have : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 1 downto 0 );
    \cmd_word_reg[0]\ : in STD_LOGIC;
    s_axi_awvalid : in STD_LOGIC;
    \cmd_word_reg[0]_0\ : in STD_LOGIC;
    s_axi_wready : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of system_tpu_0_tiny_tpu_pe : entity is "tiny_tpu_pe";
end system_tpu_0_tiny_tpu_pe;

architecture STRUCTURE of system_tpu_0_tiny_tpu_pe is
  signal \^b\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \^d\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \^e\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^sr\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal acc : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \acc[0]_i_1_n_0\ : STD_LOGIC;
  signal \acc[10]_i_1_n_0\ : STD_LOGIC;
  signal \acc[11]_i_1_n_0\ : STD_LOGIC;
  signal \acc[12]_i_1_n_0\ : STD_LOGIC;
  signal \acc[13]_i_1_n_0\ : STD_LOGIC;
  signal \acc[14]_i_1_n_0\ : STD_LOGIC;
  signal \acc[15]_i_2_n_0\ : STD_LOGIC;
  signal \acc[1]_i_1_n_0\ : STD_LOGIC;
  signal \acc[2]_i_1_n_0\ : STD_LOGIC;
  signal \acc[3]_i_1_n_0\ : STD_LOGIC;
  signal \acc[4]_i_1_n_0\ : STD_LOGIC;
  signal \acc[5]_i_1_n_0\ : STD_LOGIC;
  signal \acc[6]_i_1_n_0\ : STD_LOGIC;
  signal \acc[7]_i_1_n_0\ : STD_LOGIC;
  signal \acc[8]_i_1_n_0\ : STD_LOGIC;
  signal \acc[9]_i_1_n_0\ : STD_LOGIC;
  signal acc_0 : STD_LOGIC;
  signal \cmd_valid__0\ : STD_LOGIC;
  signal \^do_write\ : STD_LOGIC;
  signal \^ovf\ : STD_LOGIC;
  signal ovf_i_1_n_0 : STD_LOGIC;
  signal ovf_reg_i_2_n_3 : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 7 downto 2 );
  signal \product__0_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \product__0_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \product__0_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \product__0_carry__0_n_3\ : STD_LOGIC;
  signal \product__0_carry_i_10_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_11_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_12_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_13_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_14_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_15_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_16_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_17_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_18_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_19_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_1_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_20_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_2_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_3_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_4_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_5_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_6_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_7_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_8_n_0\ : STD_LOGIC;
  signal \product__0_carry_i_9_n_0\ : STD_LOGIC;
  signal \product__0_carry_n_0\ : STD_LOGIC;
  signal \product__0_carry_n_1\ : STD_LOGIC;
  signal \product__0_carry_n_2\ : STD_LOGIC;
  signal \product__0_carry_n_3\ : STD_LOGIC;
  signal \result[15]_i_1_n_0\ : STD_LOGIC;
  signal \sum__0\ : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \sum_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \sum_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \sum_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \sum_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \sum_carry__0_n_0\ : STD_LOGIC;
  signal \sum_carry__0_n_1\ : STD_LOGIC;
  signal \sum_carry__0_n_2\ : STD_LOGIC;
  signal \sum_carry__0_n_3\ : STD_LOGIC;
  signal \sum_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \sum_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \sum_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \sum_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \sum_carry__1_i_5_n_0\ : STD_LOGIC;
  signal \sum_carry__1_n_0\ : STD_LOGIC;
  signal \sum_carry__1_n_1\ : STD_LOGIC;
  signal \sum_carry__1_n_2\ : STD_LOGIC;
  signal \sum_carry__1_n_3\ : STD_LOGIC;
  signal \sum_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \sum_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \sum_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \sum_carry__2_i_4_n_0\ : STD_LOGIC;
  signal \sum_carry__2_n_0\ : STD_LOGIC;
  signal \sum_carry__2_n_1\ : STD_LOGIC;
  signal \sum_carry__2_n_2\ : STD_LOGIC;
  signal \sum_carry__2_n_3\ : STD_LOGIC;
  signal sum_carry_i_1_n_0 : STD_LOGIC;
  signal sum_carry_i_2_n_0 : STD_LOGIC;
  signal sum_carry_i_3_n_0 : STD_LOGIC;
  signal sum_carry_i_4_n_0 : STD_LOGIC;
  signal sum_carry_i_5_n_0 : STD_LOGIC;
  signal sum_carry_n_0 : STD_LOGIC;
  signal sum_carry_n_1 : STD_LOGIC;
  signal sum_carry_n_2 : STD_LOGIC;
  signal sum_carry_n_3 : STD_LOGIC;
  signal \^w_data_reg[2]\ : STD_LOGIC;
  signal \^w_data_reg[3]\ : STD_LOGIC;
  signal NLW_ovf_reg_i_2_CO_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal NLW_ovf_reg_i_2_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_product__0_carry__0_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_product__0_carry__0_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \acc[0]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \acc[10]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \acc[11]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \acc[12]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \acc[13]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \acc[14]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \acc[15]_i_2\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \acc[1]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \acc[2]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \acc[3]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \acc[4]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \acc[5]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \acc[6]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \acc[7]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \acc[8]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \acc[9]_i_1\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \cmd_word[0]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \cmd_word[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \cmd_word[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \cmd_word[3]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \cmd_word[4]_i_1\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \cmd_word[5]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \cmd_word[6]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \cmd_word[7]_i_1\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \cmd_word[8]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \product__0_carry_i_16\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \product__0_carry_i_17\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \product__0_carry_i_18\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \product__0_carry_i_20\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of sum_carry_i_5 : label is "soft_lutpair3";
begin
  B(3 downto 0) <= \^b\(3 downto 0);
  D(3 downto 0) <= \^d\(3 downto 0);
  E(0) <= \^e\(0);
  SR(0) <= \^sr\(0);
  do_write <= \^do_write\;
  ovf <= \^ovf\;
  \w_data_reg[2]\ <= \^w_data_reg[2]\;
  \w_data_reg[3]\ <= \^w_data_reg[3]\;
\acc[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(0),
      O => \acc[0]_i_1_n_0\
    );
\acc[10]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(10),
      O => \acc[10]_i_1_n_0\
    );
\acc[11]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(11),
      O => \acc[11]_i_1_n_0\
    );
\acc[12]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(12),
      O => \acc[12]_i_1_n_0\
    );
\acc[13]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(13),
      O => \acc[13]_i_1_n_0\
    );
\acc[14]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(14),
      O => \acc[14]_i_1_n_0\
    );
\acc[15]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"220A880A22A088A0"
    )
        port map (
      I0 => \cmd_valid__0\,
      I1 => Q(9),
      I2 => s_axi_wdata(9),
      I3 => \result_reg[0]_0\,
      I4 => Q(8),
      I5 => s_axi_wdata(8),
      O => acc_0
    );
\acc[15]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(15),
      O => \acc[15]_i_2_n_0\
    );
\acc[15]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0044034700000000"
    )
        port map (
      I0 => aw_addr(1),
      I1 => aw_have,
      I2 => s_axi_awaddr(1),
      I3 => aw_addr(0),
      I4 => s_axi_awaddr(0),
      I5 => \^do_write\,
      O => \cmd_valid__0\
    );
\acc[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(1),
      O => \acc[1]_i_1_n_0\
    );
\acc[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(2),
      O => \acc[2]_i_1_n_0\
    );
\acc[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(3),
      O => \acc[3]_i_1_n_0\
    );
\acc[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(4),
      O => \acc[4]_i_1_n_0\
    );
\acc[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(5),
      O => \acc[5]_i_1_n_0\
    );
\acc[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(6),
      O => \acc[6]_i_1_n_0\
    );
\acc[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(7),
      O => \acc[7]_i_1_n_0\
    );
\acc[8]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(8),
      O => \acc[8]_i_1_n_0\
    );
\acc[9]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E400"
    )
        port map (
      I0 => \result_reg[0]_0\,
      I1 => s_axi_wdata(9),
      I2 => Q(9),
      I3 => \sum__0\(9),
      O => \acc[9]_i_1_n_0\
    );
\acc_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[0]_i_1_n_0\,
      Q => acc(0),
      R => \^sr\(0)
    );
\acc_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[10]_i_1_n_0\,
      Q => acc(10),
      R => \^sr\(0)
    );
\acc_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[11]_i_1_n_0\,
      Q => acc(11),
      R => \^sr\(0)
    );
\acc_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[12]_i_1_n_0\,
      Q => acc(12),
      R => \^sr\(0)
    );
\acc_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[13]_i_1_n_0\,
      Q => acc(13),
      R => \^sr\(0)
    );
\acc_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[14]_i_1_n_0\,
      Q => acc(14),
      R => \^sr\(0)
    );
\acc_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[15]_i_2_n_0\,
      Q => acc(15),
      R => \^sr\(0)
    );
\acc_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[1]_i_1_n_0\,
      Q => acc(1),
      R => \^sr\(0)
    );
\acc_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[2]_i_1_n_0\,
      Q => acc(2),
      R => \^sr\(0)
    );
\acc_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[3]_i_1_n_0\,
      Q => acc(3),
      R => \^sr\(0)
    );
\acc_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[4]_i_1_n_0\,
      Q => acc(4),
      R => \^sr\(0)
    );
\acc_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[5]_i_1_n_0\,
      Q => acc(5),
      R => \^sr\(0)
    );
\acc_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[6]_i_1_n_0\,
      Q => acc(6),
      R => \^sr\(0)
    );
\acc_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[7]_i_1_n_0\,
      Q => acc(7),
      R => \^sr\(0)
    );
\acc_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[8]_i_1_n_0\,
      Q => acc(8),
      R => \^sr\(0)
    );
\acc_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => acc_0,
      D => \acc[9]_i_1_n_0\,
      Q => acc(9),
      R => \^sr\(0)
    );
\cmd_word[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(0),
      I1 => s_axi_wdata(0),
      I2 => \result_reg[0]_0\,
      O => \^d\(0)
    );
\cmd_word[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(1),
      I1 => s_axi_wdata(1),
      I2 => \result_reg[0]_0\,
      O => \^d\(1)
    );
\cmd_word[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(2),
      I1 => s_axi_wdata(2),
      I2 => \result_reg[0]_0\,
      O => \^w_data_reg[2]\
    );
\cmd_word[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(3),
      I1 => s_axi_wdata(3),
      I2 => \result_reg[0]_0\,
      O => \^w_data_reg[3]\
    );
\cmd_word[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(4),
      I1 => s_axi_wdata(4),
      I2 => \result_reg[0]_0\,
      O => \^b\(0)
    );
\cmd_word[5]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(5),
      I1 => s_axi_wdata(5),
      I2 => \result_reg[0]_0\,
      O => \^b\(1)
    );
\cmd_word[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(6),
      I1 => s_axi_wdata(6),
      I2 => \result_reg[0]_0\,
      O => \^b\(2)
    );
\cmd_word[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(7),
      I1 => s_axi_wdata(7),
      I2 => \result_reg[0]_0\,
      O => \^b\(3)
    );
\cmd_word[8]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(8),
      I1 => s_axi_wdata(8),
      I2 => \result_reg[0]_0\,
      O => \^d\(2)
    );
\cmd_word[9]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => Q(9),
      I1 => s_axi_wdata(9),
      I2 => \result_reg[0]_0\,
      O => \^d\(3)
    );
ovf_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF55FFFF00008200"
    )
        port map (
      I0 => \cmd_valid__0\,
      I1 => \sum__0\(15),
      I2 => ovf_reg_i_2_n_3,
      I3 => \^d\(3),
      I4 => \^d\(2),
      I5 => \^ovf\,
      O => ovf_i_1_n_0
    );
ovf_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => ovf_i_1_n_0,
      Q => \^ovf\,
      R => \^sr\(0)
    );
ovf_reg_i_2: unisim.vcomponents.CARRY4
     port map (
      CI => \sum_carry__2_n_0\,
      CO(3 downto 1) => NLW_ovf_reg_i_2_CO_UNCONNECTED(3 downto 1),
      CO(0) => ovf_reg_i_2_n_3,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => NLW_ovf_reg_i_2_O_UNCONNECTED(3 downto 0),
      S(3 downto 0) => B"0001"
    );
\product__0_carry\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \product__0_carry_n_0\,
      CO(2) => \product__0_carry_n_1\,
      CO(1) => \product__0_carry_n_2\,
      CO(0) => \product__0_carry_n_3\,
      CYINIT => '0',
      DI(3) => \product__0_carry_i_1_n_0\,
      DI(2) => \product__0_carry_i_2_n_0\,
      DI(1) => \product__0_carry_i_3_n_0\,
      DI(0) => '0',
      O(3 downto 0) => p_0_in(5 downto 2),
      S(3) => \product__0_carry_i_4_n_0\,
      S(2) => \product__0_carry_i_5_n_0\,
      S(1) => \product__0_carry_i_6_n_0\,
      S(0) => \product__0_carry_i_7_n_0\
    );
\product__0_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => \product__0_carry_n_0\,
      CO(3 downto 1) => \NLW_product__0_carry__0_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \product__0_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => B"000",
      DI(0) => \product__0_carry__0_i_1_n_0\,
      O(3 downto 2) => \NLW_product__0_carry__0_O_UNCONNECTED\(3 downto 2),
      O(1 downto 0) => p_0_in(7 downto 6),
      S(3 downto 2) => B"00",
      S(1) => \product__0_carry__0_i_2_n_0\,
      S(0) => \product__0_carry__0_i_3_n_0\
    );
\product__0_carry__0_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00008C73C03FC03F"
    )
        port map (
      I0 => \^b\(1),
      I1 => \^b\(2),
      I2 => \^w_data_reg[3]\,
      I3 => \product__0_carry_i_13_n_0\,
      I4 => \^b\(3),
      I5 => \^w_data_reg[2]\,
      O => \product__0_carry__0_i_1_n_0\
    );
\product__0_carry__0_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7FF77FFFFFF77FF"
    )
        port map (
      I0 => \^b\(3),
      I1 => \product__0_carry_i_13_n_0\,
      I2 => \^b\(1),
      I3 => \^w_data_reg[3]\,
      I4 => \^b\(2),
      I5 => \^w_data_reg[2]\,
      O => \product__0_carry__0_i_2_n_0\
    );
\product__0_carry__0_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8F0FEDEDF7F73FBF"
    )
        port map (
      I0 => \^w_data_reg[2]\,
      I1 => \^b\(2),
      I2 => \^w_data_reg[3]\,
      I3 => \^b\(1),
      I4 => \product__0_carry_i_13_n_0\,
      I5 => \^b\(3),
      O => \product__0_carry__0_i_3_n_0\
    );
\product__0_carry_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"17E8E817"
    )
        port map (
      I0 => \product__0_carry_i_8_n_0\,
      I1 => \product__0_carry_i_9_n_0\,
      I2 => \product__0_carry_i_10_n_0\,
      I3 => \product__0_carry_i_11_n_0\,
      I4 => \product__0_carry_i_12_n_0\,
      O => \product__0_carry_i_1_n_0\
    );
\product__0_carry_i_10\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"88A8800080008000"
    )
        port map (
      I0 => \^b\(0),
      I1 => \^w_data_reg[2]\,
      I2 => \^d\(0),
      I3 => \^b\(2),
      I4 => \^d\(1),
      I5 => \^b\(1),
      O => \product__0_carry_i_10_n_0\
    );
\product__0_carry_i_11\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AC0CA00053F35FFF"
    )
        port map (
      I0 => Q(5),
      I1 => s_axi_wdata(5),
      I2 => \result_reg[0]_0\,
      I3 => Q(3),
      I4 => s_axi_wdata(3),
      I5 => \product__0_carry_i_19_n_0\,
      O => \product__0_carry_i_11_n_0\
    );
\product__0_carry_i_12\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"88A0FFFF000088A0"
    )
        port map (
      I0 => \^b\(2),
      I1 => Q(1),
      I2 => s_axi_wdata(1),
      I3 => \result_reg[0]_0\,
      I4 => \product__0_carry_i_18_n_0\,
      I5 => \product__0_carry_i_20_n_0\,
      O => \product__0_carry_i_12_n_0\
    );
\product__0_carry_i_13\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5DDF455D455D0445"
    )
        port map (
      I0 => \product__0_carry_i_11_n_0\,
      I1 => \product__0_carry_i_20_n_0\,
      I2 => \product__0_carry_i_18_n_0\,
      I3 => \product__0_carry_i_17_n_0\,
      I4 => \product__0_carry_i_10_n_0\,
      I5 => \product__0_carry_i_8_n_0\,
      O => \product__0_carry_i_13_n_0\
    );
\product__0_carry_i_14\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(3),
      I1 => Q(3),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(6),
      I4 => Q(6),
      O => \product__0_carry_i_14_n_0\
    );
\product__0_carry_i_15\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000053F35FFF"
    )
        port map (
      I0 => Q(5),
      I1 => s_axi_wdata(5),
      I2 => \result_reg[0]_0\,
      I3 => Q(3),
      I4 => s_axi_wdata(3),
      I5 => \product__0_carry_i_19_n_0\,
      O => \product__0_carry_i_15_n_0\
    );
\product__0_carry_i_16\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(1),
      I1 => Q(1),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(5),
      I4 => Q(5),
      O => \product__0_carry_i_16_n_0\
    );
\product__0_carry_i_17\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(1),
      I1 => Q(1),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(6),
      I4 => Q(6),
      O => \product__0_carry_i_17_n_0\
    );
\product__0_carry_i_18\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(2),
      I1 => Q(2),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(5),
      I4 => Q(5),
      O => \product__0_carry_i_18_n_0\
    );
\product__0_carry_i_19\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(2),
      I1 => Q(2),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(6),
      I4 => Q(6),
      O => \product__0_carry_i_19_n_0\
    );
\product__0_carry_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \product__0_carry_i_1_n_0\,
      O => \product__0_carry_i_2_n_0\
    );
\product__0_carry_i_20\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(3),
      I1 => Q(3),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(4),
      I4 => Q(4),
      O => \product__0_carry_i_20_n_0\
    );
\product__0_carry_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(0),
      I1 => Q(0),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(7),
      I4 => Q(7),
      O => \product__0_carry_i_3_n_0\
    );
\product__0_carry_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6996966996699669"
    )
        port map (
      I0 => \product__0_carry_i_1_n_0\,
      I1 => \product__0_carry_i_13_n_0\,
      I2 => \product__0_carry_i_14_n_0\,
      I3 => \product__0_carry_i_15_n_0\,
      I4 => \^w_data_reg[2]\,
      I5 => \^b\(3),
      O => \product__0_carry_i_4_n_0\
    );
\product__0_carry_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"665AAA5A66AAAAAA"
    )
        port map (
      I0 => \product__0_carry_i_1_n_0\,
      I1 => Q(7),
      I2 => s_axi_wdata(7),
      I3 => \result_reg[0]_0\,
      I4 => Q(1),
      I5 => s_axi_wdata(1),
      O => \product__0_carry_i_5_n_0\
    );
\product__0_carry_i_6\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6996"
    )
        port map (
      I0 => \product__0_carry_i_3_n_0\,
      I1 => \product__0_carry_i_9_n_0\,
      I2 => \product__0_carry_i_8_n_0\,
      I3 => \product__0_carry_i_10_n_0\,
      O => \product__0_carry_i_6_n_0\
    );
\product__0_carry_i_7\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4777B88878887888"
    )
        port map (
      I0 => \^w_data_reg[2]\,
      I1 => \^b\(0),
      I2 => \^b\(1),
      I3 => \^d\(1),
      I4 => \^b\(2),
      I5 => \^d\(0),
      O => \product__0_carry_i_7_n_0\
    );
\product__0_carry_i_8\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000AC0CA000"
    )
        port map (
      I0 => Q(6),
      I1 => s_axi_wdata(6),
      I2 => \result_reg[0]_0\,
      I3 => Q(0),
      I4 => s_axi_wdata(0),
      I5 => \product__0_carry_i_16_n_0\,
      O => \product__0_carry_i_8_n_0\
    );
\product__0_carry_i_9\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"775F88A088A0775F"
    )
        port map (
      I0 => \^b\(0),
      I1 => Q(3),
      I2 => s_axi_wdata(3),
      I3 => \result_reg[0]_0\,
      I4 => \product__0_carry_i_17_n_0\,
      I5 => \product__0_carry_i_18_n_0\,
      O => \product__0_carry_i_9_n_0\
    );
\result[15]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"88A000A088000000"
    )
        port map (
      I0 => \cmd_valid__0\,
      I1 => Q(9),
      I2 => s_axi_wdata(9),
      I3 => \result_reg[0]_0\,
      I4 => Q(8),
      I5 => s_axi_wdata(8),
      O => \result[15]_i_1_n_0\
    );
\result_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(0),
      Q => \result_reg[15]_0\(0),
      R => \^sr\(0)
    );
\result_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(10),
      Q => \result_reg[15]_0\(10),
      R => \^sr\(0)
    );
\result_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(11),
      Q => \result_reg[15]_0\(11),
      R => \^sr\(0)
    );
\result_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(12),
      Q => \result_reg[15]_0\(12),
      R => \^sr\(0)
    );
\result_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(13),
      Q => \result_reg[15]_0\(13),
      R => \^sr\(0)
    );
\result_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(14),
      Q => \result_reg[15]_0\(14),
      R => \^sr\(0)
    );
\result_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(15),
      Q => \result_reg[15]_0\(15),
      R => \^sr\(0)
    );
\result_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(1),
      Q => \result_reg[15]_0\(1),
      R => \^sr\(0)
    );
\result_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(2),
      Q => \result_reg[15]_0\(2),
      R => \^sr\(0)
    );
\result_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(3),
      Q => \result_reg[15]_0\(3),
      R => \^sr\(0)
    );
\result_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(4),
      Q => \result_reg[15]_0\(4),
      R => \^sr\(0)
    );
\result_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(5),
      Q => \result_reg[15]_0\(5),
      R => \^sr\(0)
    );
\result_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(6),
      Q => \result_reg[15]_0\(6),
      R => \^sr\(0)
    );
\result_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(7),
      Q => \result_reg[15]_0\(7),
      R => \^sr\(0)
    );
\result_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(8),
      Q => \result_reg[15]_0\(8),
      R => \^sr\(0)
    );
\result_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => \result[15]_i_1_n_0\,
      D => acc(9),
      Q => \result_reg[15]_0\(9),
      R => \^sr\(0)
    );
s_axi_awready_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => s_axi_aresetn,
      O => \^sr\(0)
    );
s_axi_bvalid_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00F800F800F80000"
    )
        port map (
      I0 => \cmd_word_reg[0]\,
      I1 => s_axi_awvalid,
      I2 => aw_have,
      I3 => \cmd_word_reg[0]_0\,
      I4 => \result_reg[0]_0\,
      I5 => \^e\(0),
      O => \^do_write\
    );
sum_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => sum_carry_n_0,
      CO(2) => sum_carry_n_1,
      CO(1) => sum_carry_n_2,
      CO(0) => sum_carry_n_3,
      CYINIT => '0',
      DI(3 downto 0) => acc(3 downto 0),
      O(3 downto 0) => \sum__0\(3 downto 0),
      S(3) => sum_carry_i_1_n_0,
      S(2) => sum_carry_i_2_n_0,
      S(1) => sum_carry_i_3_n_0,
      S(0) => sum_carry_i_4_n_0
    );
\sum_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => sum_carry_n_0,
      CO(3) => \sum_carry__0_n_0\,
      CO(2) => \sum_carry__0_n_1\,
      CO(1) => \sum_carry__0_n_2\,
      CO(0) => \sum_carry__0_n_3\,
      CYINIT => '0',
      DI(3) => p_0_in(7),
      DI(2 downto 0) => acc(6 downto 4),
      O(3 downto 0) => \sum__0\(7 downto 4),
      S(3) => \sum_carry__0_i_1_n_0\,
      S(2) => \sum_carry__0_i_2_n_0\,
      S(1) => \sum_carry__0_i_3_n_0\,
      S(0) => \sum_carry__0_i_4_n_0\
    );
\sum_carry__0_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => p_0_in(7),
      I1 => acc(7),
      O => \sum_carry__0_i_1_n_0\
    );
\sum_carry__0_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => acc(6),
      I1 => p_0_in(6),
      O => \sum_carry__0_i_2_n_0\
    );
\sum_carry__0_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => acc(5),
      I1 => p_0_in(5),
      O => \sum_carry__0_i_3_n_0\
    );
\sum_carry__0_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => acc(4),
      I1 => p_0_in(4),
      O => \sum_carry__0_i_4_n_0\
    );
\sum_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \sum_carry__0_n_0\,
      CO(3) => \sum_carry__1_n_0\,
      CO(2) => \sum_carry__1_n_1\,
      CO(1) => \sum_carry__1_n_2\,
      CO(0) => \sum_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => acc(10 downto 8),
      DI(0) => \sum_carry__1_i_1_n_0\,
      O(3 downto 0) => \sum__0\(11 downto 8),
      S(3) => \sum_carry__1_i_2_n_0\,
      S(2) => \sum_carry__1_i_3_n_0\,
      S(1) => \sum_carry__1_i_4_n_0\,
      S(0) => \sum_carry__1_i_5_n_0\
    );
\sum_carry__1_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => p_0_in(7),
      O => \sum_carry__1_i_1_n_0\
    );
\sum_carry__1_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(10),
      I1 => acc(11),
      O => \sum_carry__1_i_2_n_0\
    );
\sum_carry__1_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(9),
      I1 => acc(10),
      O => \sum_carry__1_i_3_n_0\
    );
\sum_carry__1_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(8),
      I1 => acc(9),
      O => \sum_carry__1_i_4_n_0\
    );
\sum_carry__1_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => p_0_in(7),
      I1 => acc(8),
      O => \sum_carry__1_i_5_n_0\
    );
\sum_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \sum_carry__1_n_0\,
      CO(3) => \sum_carry__2_n_0\,
      CO(2) => \sum_carry__2_n_1\,
      CO(1) => \sum_carry__2_n_2\,
      CO(0) => \sum_carry__2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => acc(14 downto 11),
      O(3 downto 0) => \sum__0\(15 downto 12),
      S(3) => \sum_carry__2_i_1_n_0\,
      S(2) => \sum_carry__2_i_2_n_0\,
      S(1) => \sum_carry__2_i_3_n_0\,
      S(0) => \sum_carry__2_i_4_n_0\
    );
\sum_carry__2_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(14),
      I1 => acc(15),
      O => \sum_carry__2_i_1_n_0\
    );
\sum_carry__2_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(13),
      I1 => acc(14),
      O => \sum_carry__2_i_2_n_0\
    );
\sum_carry__2_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(12),
      I1 => acc(13),
      O => \sum_carry__2_i_3_n_0\
    );
\sum_carry__2_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => acc(11),
      I1 => acc(12),
      O => \sum_carry__2_i_4_n_0\
    );
sum_carry_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => acc(3),
      I1 => p_0_in(3),
      O => sum_carry_i_1_n_0
    );
sum_carry_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => acc(2),
      I1 => p_0_in(2),
      O => sum_carry_i_2_n_0
    );
sum_carry_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6669969999999999"
    )
        port map (
      I0 => acc(1),
      I1 => sum_carry_i_5_n_0,
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(1),
      I4 => Q(1),
      I5 => \^b\(0),
      O => sum_carry_i_3_n_0
    );
sum_carry_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"665AAA5A66AAAAAA"
    )
        port map (
      I0 => acc(0),
      I1 => Q(4),
      I2 => s_axi_wdata(4),
      I3 => \result_reg[0]_0\,
      I4 => Q(0),
      I5 => s_axi_wdata(0),
      O => sum_carry_i_4_n_0
    );
sum_carry_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"353FF5FF"
    )
        port map (
      I0 => s_axi_wdata(0),
      I1 => Q(0),
      I2 => \result_reg[0]_0\,
      I3 => s_axi_wdata(5),
      I4 => Q(5),
      O => sum_carry_i_5_n_0
    );
\w_data[31]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_axi_wready,
      I1 => s_axi_wvalid,
      O => \^e\(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_tpu_0_tiny_tpu_axi is
  port (
    s_axi_wready : out STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_bvalid_reg_0 : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_aclk : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_arvalid : in STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_rready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of system_tpu_0_tiny_tpu_axi : entity is "tiny_tpu_axi";
end system_tpu_0_tiny_tpu_axi;

architecture STRUCTURE of system_tpu_0_tiny_tpu_axi is
  signal B : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal aw_addr : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \aw_addr[2]_i_1_n_0\ : STD_LOGIC;
  signal \aw_addr[3]_i_1_n_0\ : STD_LOGIC;
  signal aw_have : STD_LOGIC;
  signal aw_have_i_1_n_0 : STD_LOGIC;
  signal cmd : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal cmd_word : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \cmd_word[10]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[11]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[12]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[13]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[14]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[15]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[16]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[17]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[18]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[19]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[20]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[21]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[22]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[23]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[24]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[25]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[26]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[27]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[28]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[29]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[30]_i_1_n_0\ : STD_LOGIC;
  signal \cmd_word[31]_i_2_n_0\ : STD_LOGIC;
  signal cmd_word_0 : STD_LOGIC;
  signal do_write : STD_LOGIC;
  signal ovf : STD_LOGIC;
  signal result : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal rst : STD_LOGIC;
  signal \^s_axi_arready\ : STD_LOGIC;
  signal \s_axi_arready0__0\ : STD_LOGIC;
  signal \^s_axi_awready\ : STD_LOGIC;
  signal s_axi_awready0 : STD_LOGIC;
  signal s_axi_bvalid_i_1_n_0 : STD_LOGIC;
  signal \^s_axi_bvalid_reg_0\ : STD_LOGIC;
  signal \s_axi_rdata[0]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[10]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[11]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[12]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[13]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[14]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[15]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[16]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[17]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[18]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[19]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[1]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[20]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[21]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[22]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[23]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[24]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[25]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[26]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[27]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[28]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[29]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[2]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[30]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[31]_i_2_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[3]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[4]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[5]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[6]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[7]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[8]_i_1_n_0\ : STD_LOGIC;
  signal \s_axi_rdata[9]_i_1_n_0\ : STD_LOGIC;
  signal \^s_axi_rvalid\ : STD_LOGIC;
  signal s_axi_rvalid01_out : STD_LOGIC;
  signal s_axi_rvalid_i_1_n_0 : STD_LOGIC;
  signal \^s_axi_wready\ : STD_LOGIC;
  signal s_axi_wready0 : STD_LOGIC;
  signal u_pe_n_10 : STD_LOGIC;
  signal u_pe_n_11 : STD_LOGIC;
  signal u_pe_n_6 : STD_LOGIC;
  signal u_pe_n_7 : STD_LOGIC;
  signal w_data : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal w_have_i_1_n_0 : STD_LOGIC;
  signal w_have_reg_n_0 : STD_LOGIC;
  signal w_take : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \cmd_word[10]_i_1\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \cmd_word[11]_i_1\ : label is "soft_lutpair25";
  attribute SOFT_HLUTNM of \cmd_word[12]_i_1\ : label is "soft_lutpair26";
  attribute SOFT_HLUTNM of \cmd_word[13]_i_1\ : label is "soft_lutpair25";
  attribute SOFT_HLUTNM of \cmd_word[14]_i_1\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \cmd_word[15]_i_1\ : label is "soft_lutpair27";
  attribute SOFT_HLUTNM of \cmd_word[16]_i_1\ : label is "soft_lutpair26";
  attribute SOFT_HLUTNM of \cmd_word[17]_i_1\ : label is "soft_lutpair27";
  attribute SOFT_HLUTNM of \cmd_word[18]_i_1\ : label is "soft_lutpair28";
  attribute SOFT_HLUTNM of \cmd_word[19]_i_1\ : label is "soft_lutpair28";
  attribute SOFT_HLUTNM of \cmd_word[20]_i_1\ : label is "soft_lutpair29";
  attribute SOFT_HLUTNM of \cmd_word[21]_i_1\ : label is "soft_lutpair29";
  attribute SOFT_HLUTNM of \cmd_word[22]_i_1\ : label is "soft_lutpair30";
  attribute SOFT_HLUTNM of \cmd_word[23]_i_1\ : label is "soft_lutpair30";
  attribute SOFT_HLUTNM of \cmd_word[24]_i_1\ : label is "soft_lutpair31";
  attribute SOFT_HLUTNM of \cmd_word[25]_i_1\ : label is "soft_lutpair32";
  attribute SOFT_HLUTNM of \cmd_word[26]_i_1\ : label is "soft_lutpair31";
  attribute SOFT_HLUTNM of \cmd_word[27]_i_1\ : label is "soft_lutpair32";
  attribute SOFT_HLUTNM of \cmd_word[28]_i_1\ : label is "soft_lutpair33";
  attribute SOFT_HLUTNM of \cmd_word[29]_i_1\ : label is "soft_lutpair33";
  attribute SOFT_HLUTNM of \cmd_word[30]_i_1\ : label is "soft_lutpair34";
  attribute SOFT_HLUTNM of \cmd_word[31]_i_2\ : label is "soft_lutpair34";
  attribute SOFT_HLUTNM of s_axi_arready0 : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of s_axi_bvalid_i_1 : label is "soft_lutpair35";
  attribute SOFT_HLUTNM of \s_axi_rdata[15]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \s_axi_rdata[16]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \s_axi_rdata[17]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \s_axi_rdata[18]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \s_axi_rdata[19]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \s_axi_rdata[20]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \s_axi_rdata[21]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \s_axi_rdata[22]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \s_axi_rdata[23]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \s_axi_rdata[24]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \s_axi_rdata[25]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \s_axi_rdata[26]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \s_axi_rdata[27]_i_1\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \s_axi_rdata[28]_i_1\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \s_axi_rdata[29]_i_1\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of \s_axi_rdata[30]_i_1\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of s_axi_rvalid_i_1 : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of s_axi_wready_i_1 : label is "soft_lutpair35";
begin
  s_axi_arready <= \^s_axi_arready\;
  s_axi_awready <= \^s_axi_awready\;
  s_axi_bvalid_reg_0 <= \^s_axi_bvalid_reg_0\;
  s_axi_rvalid <= \^s_axi_rvalid\;
  s_axi_wready <= \^s_axi_wready\;
\aw_addr[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BF80"
    )
        port map (
      I0 => s_axi_awaddr(0),
      I1 => \^s_axi_awready\,
      I2 => s_axi_awvalid,
      I3 => aw_addr(2),
      O => \aw_addr[2]_i_1_n_0\
    );
\aw_addr[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"BF80"
    )
        port map (
      I0 => s_axi_awaddr(1),
      I1 => \^s_axi_awready\,
      I2 => s_axi_awvalid,
      I3 => aw_addr(3),
      O => \aw_addr[3]_i_1_n_0\
    );
\aw_addr_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \aw_addr[2]_i_1_n_0\,
      Q => aw_addr(2),
      R => rst
    );
\aw_addr_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \aw_addr[3]_i_1_n_0\,
      Q => aw_addr(3),
      R => rst
    );
aw_have_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000EA00"
    )
        port map (
      I0 => aw_have,
      I1 => \^s_axi_awready\,
      I2 => s_axi_awvalid,
      I3 => s_axi_aresetn,
      I4 => do_write,
      O => aw_have_i_1_n_0
    );
aw_have_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => aw_have_i_1_n_0,
      Q => aw_have,
      R => '0'
    );
\cmd_word[10]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(10),
      I1 => s_axi_wdata(10),
      I2 => w_have_reg_n_0,
      O => \cmd_word[10]_i_1_n_0\
    );
\cmd_word[11]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(11),
      I1 => s_axi_wdata(11),
      I2 => w_have_reg_n_0,
      O => \cmd_word[11]_i_1_n_0\
    );
\cmd_word[12]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(12),
      I1 => s_axi_wdata(12),
      I2 => w_have_reg_n_0,
      O => \cmd_word[12]_i_1_n_0\
    );
\cmd_word[13]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(13),
      I1 => s_axi_wdata(13),
      I2 => w_have_reg_n_0,
      O => \cmd_word[13]_i_1_n_0\
    );
\cmd_word[14]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(14),
      I1 => s_axi_wdata(14),
      I2 => w_have_reg_n_0,
      O => \cmd_word[14]_i_1_n_0\
    );
\cmd_word[15]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(15),
      I1 => s_axi_wdata(15),
      I2 => w_have_reg_n_0,
      O => \cmd_word[15]_i_1_n_0\
    );
\cmd_word[16]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(16),
      I1 => s_axi_wdata(16),
      I2 => w_have_reg_n_0,
      O => \cmd_word[16]_i_1_n_0\
    );
\cmd_word[17]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(17),
      I1 => s_axi_wdata(17),
      I2 => w_have_reg_n_0,
      O => \cmd_word[17]_i_1_n_0\
    );
\cmd_word[18]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(18),
      I1 => s_axi_wdata(18),
      I2 => w_have_reg_n_0,
      O => \cmd_word[18]_i_1_n_0\
    );
\cmd_word[19]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(19),
      I1 => s_axi_wdata(19),
      I2 => w_have_reg_n_0,
      O => \cmd_word[19]_i_1_n_0\
    );
\cmd_word[20]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(20),
      I1 => s_axi_wdata(20),
      I2 => w_have_reg_n_0,
      O => \cmd_word[20]_i_1_n_0\
    );
\cmd_word[21]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(21),
      I1 => s_axi_wdata(21),
      I2 => w_have_reg_n_0,
      O => \cmd_word[21]_i_1_n_0\
    );
\cmd_word[22]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(22),
      I1 => s_axi_wdata(22),
      I2 => w_have_reg_n_0,
      O => \cmd_word[22]_i_1_n_0\
    );
\cmd_word[23]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(23),
      I1 => s_axi_wdata(23),
      I2 => w_have_reg_n_0,
      O => \cmd_word[23]_i_1_n_0\
    );
\cmd_word[24]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(24),
      I1 => s_axi_wdata(24),
      I2 => w_have_reg_n_0,
      O => \cmd_word[24]_i_1_n_0\
    );
\cmd_word[25]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(25),
      I1 => s_axi_wdata(25),
      I2 => w_have_reg_n_0,
      O => \cmd_word[25]_i_1_n_0\
    );
\cmd_word[26]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(26),
      I1 => s_axi_wdata(26),
      I2 => w_have_reg_n_0,
      O => \cmd_word[26]_i_1_n_0\
    );
\cmd_word[27]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(27),
      I1 => s_axi_wdata(27),
      I2 => w_have_reg_n_0,
      O => \cmd_word[27]_i_1_n_0\
    );
\cmd_word[28]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(28),
      I1 => s_axi_wdata(28),
      I2 => w_have_reg_n_0,
      O => \cmd_word[28]_i_1_n_0\
    );
\cmd_word[29]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(29),
      I1 => s_axi_wdata(29),
      I2 => w_have_reg_n_0,
      O => \cmd_word[29]_i_1_n_0\
    );
\cmd_word[30]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(30),
      I1 => s_axi_wdata(30),
      I2 => w_have_reg_n_0,
      O => \cmd_word[30]_i_1_n_0\
    );
\cmd_word[31]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00002020000A202A"
    )
        port map (
      I0 => do_write,
      I1 => aw_addr(3),
      I2 => aw_have,
      I3 => s_axi_awaddr(1),
      I4 => aw_addr(2),
      I5 => s_axi_awaddr(0),
      O => cmd_word_0
    );
\cmd_word[31]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AC"
    )
        port map (
      I0 => w_data(31),
      I1 => s_axi_wdata(31),
      I2 => w_have_reg_n_0,
      O => \cmd_word[31]_i_2_n_0\
    );
\cmd_word_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => u_pe_n_11,
      Q => cmd_word(0),
      R => rst
    );
\cmd_word_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[10]_i_1_n_0\,
      Q => cmd_word(10),
      R => rst
    );
\cmd_word_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[11]_i_1_n_0\,
      Q => cmd_word(11),
      R => rst
    );
\cmd_word_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[12]_i_1_n_0\,
      Q => cmd_word(12),
      R => rst
    );
\cmd_word_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[13]_i_1_n_0\,
      Q => cmd_word(13),
      R => rst
    );
\cmd_word_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[14]_i_1_n_0\,
      Q => cmd_word(14),
      R => rst
    );
\cmd_word_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[15]_i_1_n_0\,
      Q => cmd_word(15),
      R => rst
    );
\cmd_word_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[16]_i_1_n_0\,
      Q => cmd_word(16),
      R => rst
    );
\cmd_word_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[17]_i_1_n_0\,
      Q => cmd_word(17),
      R => rst
    );
\cmd_word_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[18]_i_1_n_0\,
      Q => cmd_word(18),
      R => rst
    );
\cmd_word_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[19]_i_1_n_0\,
      Q => cmd_word(19),
      R => rst
    );
\cmd_word_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => u_pe_n_10,
      Q => cmd_word(1),
      R => rst
    );
\cmd_word_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[20]_i_1_n_0\,
      Q => cmd_word(20),
      R => rst
    );
\cmd_word_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[21]_i_1_n_0\,
      Q => cmd_word(21),
      R => rst
    );
\cmd_word_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[22]_i_1_n_0\,
      Q => cmd_word(22),
      R => rst
    );
\cmd_word_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[23]_i_1_n_0\,
      Q => cmd_word(23),
      R => rst
    );
\cmd_word_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[24]_i_1_n_0\,
      Q => cmd_word(24),
      R => rst
    );
\cmd_word_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[25]_i_1_n_0\,
      Q => cmd_word(25),
      R => rst
    );
\cmd_word_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[26]_i_1_n_0\,
      Q => cmd_word(26),
      R => rst
    );
\cmd_word_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[27]_i_1_n_0\,
      Q => cmd_word(27),
      R => rst
    );
\cmd_word_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[28]_i_1_n_0\,
      Q => cmd_word(28),
      R => rst
    );
\cmd_word_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[29]_i_1_n_0\,
      Q => cmd_word(29),
      R => rst
    );
\cmd_word_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => u_pe_n_7,
      Q => cmd_word(2),
      R => rst
    );
\cmd_word_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[30]_i_1_n_0\,
      Q => cmd_word(30),
      R => rst
    );
\cmd_word_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => \cmd_word[31]_i_2_n_0\,
      Q => cmd_word(31),
      R => rst
    );
\cmd_word_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => u_pe_n_6,
      Q => cmd_word(3),
      R => rst
    );
\cmd_word_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => B(0),
      Q => cmd_word(4),
      R => rst
    );
\cmd_word_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => B(1),
      Q => cmd_word(5),
      R => rst
    );
\cmd_word_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => B(2),
      Q => cmd_word(6),
      R => rst
    );
\cmd_word_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => B(3),
      Q => cmd_word(7),
      R => rst
    );
\cmd_word_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => cmd(0),
      Q => cmd_word(8),
      R => rst
    );
\cmd_word_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => cmd_word_0,
      D => cmd(1),
      Q => cmd_word(9),
      R => rst
    );
s_axi_arready0: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => \^s_axi_rvalid\,
      I1 => s_axi_arvalid,
      I2 => \^s_axi_arready\,
      O => \s_axi_arready0__0\
    );
s_axi_arready_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => \s_axi_arready0__0\,
      Q => \^s_axi_arready\,
      R => rst
    );
s_axi_awready_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0015"
    )
        port map (
      I0 => \^s_axi_bvalid_reg_0\,
      I1 => \^s_axi_awready\,
      I2 => s_axi_awvalid,
      I3 => aw_have,
      O => s_axi_awready0
    );
s_axi_awready_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => s_axi_awready0,
      Q => \^s_axi_awready\,
      R => rst
    );
s_axi_bvalid_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"AE"
    )
        port map (
      I0 => do_write,
      I1 => \^s_axi_bvalid_reg_0\,
      I2 => s_axi_bready,
      O => s_axi_bvalid_i_1_n_0
    );
s_axi_bvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => s_axi_bvalid_i_1_n_0,
      Q => \^s_axi_bvalid_reg_0\,
      R => rst
    );
\s_axi_rdata[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"30BB3088"
    )
        port map (
      I0 => result(0),
      I1 => s_axi_araddr(0),
      I2 => ovf,
      I3 => s_axi_araddr(1),
      I4 => cmd_word(0),
      O => \s_axi_rdata[0]_i_1_n_0\
    );
\s_axi_rdata[10]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(10),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(10),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[10]_i_1_n_0\
    );
\s_axi_rdata[11]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(11),
      I1 => s_axi_araddr(0),
      I2 => result(11),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[11]_i_1_n_0\
    );
\s_axi_rdata[12]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(12),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(12),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[12]_i_1_n_0\
    );
\s_axi_rdata[13]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(13),
      I1 => s_axi_araddr(0),
      I2 => result(13),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[13]_i_1_n_0\
    );
\s_axi_rdata[14]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(14),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(14),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[14]_i_1_n_0\
    );
\s_axi_rdata[15]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(15),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[15]_i_1_n_0\
    );
\s_axi_rdata[16]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(16),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[16]_i_1_n_0\
    );
\s_axi_rdata[17]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(17),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[17]_i_1_n_0\
    );
\s_axi_rdata[18]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(18),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[18]_i_1_n_0\
    );
\s_axi_rdata[19]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(19),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[19]_i_1_n_0\
    );
\s_axi_rdata[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(1),
      I1 => s_axi_araddr(0),
      I2 => result(1),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[1]_i_1_n_0\
    );
\s_axi_rdata[20]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(15),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(20),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[20]_i_1_n_0\
    );
\s_axi_rdata[21]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(21),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[21]_i_1_n_0\
    );
\s_axi_rdata[22]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(15),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(22),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[22]_i_1_n_0\
    );
\s_axi_rdata[23]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(23),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[23]_i_1_n_0\
    );
\s_axi_rdata[24]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(24),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[24]_i_1_n_0\
    );
\s_axi_rdata[25]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(25),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[25]_i_1_n_0\
    );
\s_axi_rdata[26]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(15),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(26),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[26]_i_1_n_0\
    );
\s_axi_rdata[27]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(27),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[27]_i_1_n_0\
    );
\s_axi_rdata[28]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(15),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(28),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[28]_i_1_n_0\
    );
\s_axi_rdata[29]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(29),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[29]_i_1_n_0\
    );
\s_axi_rdata[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(2),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(2),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[2]_i_1_n_0\
    );
\s_axi_rdata[30]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(15),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(30),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[30]_i_1_n_0\
    );
\s_axi_rdata[31]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s_axi_arvalid,
      O => s_axi_rvalid01_out
    );
\s_axi_rdata[31]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(31),
      I1 => s_axi_araddr(0),
      I2 => result(15),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[31]_i_2_n_0\
    );
\s_axi_rdata[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(3),
      I1 => s_axi_araddr(0),
      I2 => result(3),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[3]_i_1_n_0\
    );
\s_axi_rdata[4]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(4),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(4),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[4]_i_1_n_0\
    );
\s_axi_rdata[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(5),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(5),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[5]_i_1_n_0\
    );
\s_axi_rdata[6]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(6),
      I1 => s_axi_araddr(0),
      I2 => result(6),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[6]_i_1_n_0\
    );
\s_axi_rdata[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(7),
      I1 => s_axi_araddr(0),
      I2 => result(7),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[7]_i_1_n_0\
    );
\s_axi_rdata[8]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"CCB8"
    )
        port map (
      I0 => result(8),
      I1 => s_axi_araddr(0),
      I2 => cmd_word(8),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[8]_i_1_n_0\
    );
\s_axi_rdata[9]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => cmd_word(9),
      I1 => s_axi_araddr(0),
      I2 => result(9),
      I3 => s_axi_araddr(1),
      O => \s_axi_rdata[9]_i_1_n_0\
    );
\s_axi_rdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[0]_i_1_n_0\,
      Q => s_axi_rdata(0),
      R => rst
    );
\s_axi_rdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[10]_i_1_n_0\,
      Q => s_axi_rdata(10),
      R => rst
    );
\s_axi_rdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[11]_i_1_n_0\,
      Q => s_axi_rdata(11),
      R => rst
    );
\s_axi_rdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[12]_i_1_n_0\,
      Q => s_axi_rdata(12),
      R => rst
    );
\s_axi_rdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[13]_i_1_n_0\,
      Q => s_axi_rdata(13),
      R => rst
    );
\s_axi_rdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[14]_i_1_n_0\,
      Q => s_axi_rdata(14),
      R => rst
    );
\s_axi_rdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[15]_i_1_n_0\,
      Q => s_axi_rdata(15),
      R => rst
    );
\s_axi_rdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[16]_i_1_n_0\,
      Q => s_axi_rdata(16),
      R => rst
    );
\s_axi_rdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[17]_i_1_n_0\,
      Q => s_axi_rdata(17),
      R => rst
    );
\s_axi_rdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[18]_i_1_n_0\,
      Q => s_axi_rdata(18),
      R => rst
    );
\s_axi_rdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[19]_i_1_n_0\,
      Q => s_axi_rdata(19),
      R => rst
    );
\s_axi_rdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[1]_i_1_n_0\,
      Q => s_axi_rdata(1),
      R => rst
    );
\s_axi_rdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[20]_i_1_n_0\,
      Q => s_axi_rdata(20),
      R => rst
    );
\s_axi_rdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[21]_i_1_n_0\,
      Q => s_axi_rdata(21),
      R => rst
    );
\s_axi_rdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[22]_i_1_n_0\,
      Q => s_axi_rdata(22),
      R => rst
    );
\s_axi_rdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[23]_i_1_n_0\,
      Q => s_axi_rdata(23),
      R => rst
    );
\s_axi_rdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[24]_i_1_n_0\,
      Q => s_axi_rdata(24),
      R => rst
    );
\s_axi_rdata_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[25]_i_1_n_0\,
      Q => s_axi_rdata(25),
      R => rst
    );
\s_axi_rdata_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[26]_i_1_n_0\,
      Q => s_axi_rdata(26),
      R => rst
    );
\s_axi_rdata_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[27]_i_1_n_0\,
      Q => s_axi_rdata(27),
      R => rst
    );
\s_axi_rdata_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[28]_i_1_n_0\,
      Q => s_axi_rdata(28),
      R => rst
    );
\s_axi_rdata_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[29]_i_1_n_0\,
      Q => s_axi_rdata(29),
      R => rst
    );
\s_axi_rdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[2]_i_1_n_0\,
      Q => s_axi_rdata(2),
      R => rst
    );
\s_axi_rdata_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[30]_i_1_n_0\,
      Q => s_axi_rdata(30),
      R => rst
    );
\s_axi_rdata_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[31]_i_2_n_0\,
      Q => s_axi_rdata(31),
      R => rst
    );
\s_axi_rdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[3]_i_1_n_0\,
      Q => s_axi_rdata(3),
      R => rst
    );
\s_axi_rdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[4]_i_1_n_0\,
      Q => s_axi_rdata(4),
      R => rst
    );
\s_axi_rdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[5]_i_1_n_0\,
      Q => s_axi_rdata(5),
      R => rst
    );
\s_axi_rdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[6]_i_1_n_0\,
      Q => s_axi_rdata(6),
      R => rst
    );
\s_axi_rdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[7]_i_1_n_0\,
      Q => s_axi_rdata(7),
      R => rst
    );
\s_axi_rdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[8]_i_1_n_0\,
      Q => s_axi_rdata(8),
      R => rst
    );
\s_axi_rdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => s_axi_rvalid01_out,
      D => \s_axi_rdata[9]_i_1_n_0\,
      Q => s_axi_rdata(9),
      R => rst
    );
s_axi_rvalid_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"88F8"
    )
        port map (
      I0 => s_axi_arvalid,
      I1 => \^s_axi_arready\,
      I2 => \^s_axi_rvalid\,
      I3 => s_axi_rready,
      O => s_axi_rvalid_i_1_n_0
    );
s_axi_rvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => s_axi_rvalid_i_1_n_0,
      Q => \^s_axi_rvalid\,
      R => rst
    );
s_axi_wready_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => \^s_axi_bvalid_reg_0\,
      I1 => w_take,
      I2 => w_have_reg_n_0,
      O => s_axi_wready0
    );
s_axi_wready_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => s_axi_wready0,
      Q => \^s_axi_wready\,
      R => rst
    );
u_pe: entity work.system_tpu_0_tiny_tpu_pe
     port map (
      B(3 downto 0) => B(3 downto 0),
      D(3 downto 2) => cmd(1 downto 0),
      D(1) => u_pe_n_10,
      D(0) => u_pe_n_11,
      E(0) => w_take,
      Q(9 downto 0) => w_data(9 downto 0),
      SR(0) => rst,
      aw_addr(1 downto 0) => aw_addr(3 downto 2),
      aw_have => aw_have,
      \cmd_word_reg[0]\ => \^s_axi_awready\,
      \cmd_word_reg[0]_0\ => \^s_axi_bvalid_reg_0\,
      do_write => do_write,
      ovf => ovf,
      \result_reg[0]_0\ => w_have_reg_n_0,
      \result_reg[15]_0\(15 downto 0) => result(15 downto 0),
      s_axi_aclk => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_awaddr(1 downto 0) => s_axi_awaddr(1 downto 0),
      s_axi_awvalid => s_axi_awvalid,
      s_axi_wdata(9 downto 0) => s_axi_wdata(9 downto 0),
      s_axi_wready => \^s_axi_wready\,
      s_axi_wvalid => s_axi_wvalid,
      \w_data_reg[2]\ => u_pe_n_7,
      \w_data_reg[3]\ => u_pe_n_6
    );
\w_data_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(0),
      Q => w_data(0),
      R => rst
    );
\w_data_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(10),
      Q => w_data(10),
      R => rst
    );
\w_data_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(11),
      Q => w_data(11),
      R => rst
    );
\w_data_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(12),
      Q => w_data(12),
      R => rst
    );
\w_data_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(13),
      Q => w_data(13),
      R => rst
    );
\w_data_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(14),
      Q => w_data(14),
      R => rst
    );
\w_data_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(15),
      Q => w_data(15),
      R => rst
    );
\w_data_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(16),
      Q => w_data(16),
      R => rst
    );
\w_data_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(17),
      Q => w_data(17),
      R => rst
    );
\w_data_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(18),
      Q => w_data(18),
      R => rst
    );
\w_data_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(19),
      Q => w_data(19),
      R => rst
    );
\w_data_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(1),
      Q => w_data(1),
      R => rst
    );
\w_data_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(20),
      Q => w_data(20),
      R => rst
    );
\w_data_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(21),
      Q => w_data(21),
      R => rst
    );
\w_data_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(22),
      Q => w_data(22),
      R => rst
    );
\w_data_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(23),
      Q => w_data(23),
      R => rst
    );
\w_data_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(24),
      Q => w_data(24),
      R => rst
    );
\w_data_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(25),
      Q => w_data(25),
      R => rst
    );
\w_data_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(26),
      Q => w_data(26),
      R => rst
    );
\w_data_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(27),
      Q => w_data(27),
      R => rst
    );
\w_data_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(28),
      Q => w_data(28),
      R => rst
    );
\w_data_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(29),
      Q => w_data(29),
      R => rst
    );
\w_data_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(2),
      Q => w_data(2),
      R => rst
    );
\w_data_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(30),
      Q => w_data(30),
      R => rst
    );
\w_data_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(31),
      Q => w_data(31),
      R => rst
    );
\w_data_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(3),
      Q => w_data(3),
      R => rst
    );
\w_data_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(4),
      Q => w_data(4),
      R => rst
    );
\w_data_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(5),
      Q => w_data(5),
      R => rst
    );
\w_data_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(6),
      Q => w_data(6),
      R => rst
    );
\w_data_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(7),
      Q => w_data(7),
      R => rst
    );
\w_data_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(8),
      Q => w_data(8),
      R => rst
    );
\w_data_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => w_take,
      D => s_axi_wdata(9),
      Q => w_data(9),
      R => rst
    );
w_have_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000EA00"
    )
        port map (
      I0 => w_have_reg_n_0,
      I1 => \^s_axi_wready\,
      I2 => s_axi_wvalid,
      I3 => s_axi_aresetn,
      I4 => do_write,
      O => w_have_i_1_n_0
    );
w_have_reg: unisim.vcomponents.FDRE
     port map (
      C => s_axi_aclk,
      CE => '1',
      D => w_have_i_1_n_0,
      Q => w_have_reg_n_0,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity system_tpu_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of system_tpu_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of system_tpu_0 : entity is "system_tpu_0,tiny_tpu_axi,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of system_tpu_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of system_tpu_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of system_tpu_0 : entity is "tiny_tpu_axi,Vivado 2019.1";
end system_tpu_0;

architecture STRUCTURE of system_tpu_0 is
  signal \<const0>\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of s_axi_aclk : signal is "xilinx.com:signal:clock:1.0 s_axi_aclk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of s_axi_aclk : signal is "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_ps7_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_aresetn : signal is "xilinx.com:signal:reset:1.0 s_axi_aresetn RST";
  attribute X_INTERFACE_PARAMETER of s_axi_aresetn : signal is "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_arready : signal is "xilinx.com:interface:aximm:1.0 s_axi ARREADY";
  attribute X_INTERFACE_INFO of s_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi ARVALID";
  attribute X_INTERFACE_INFO of s_axi_awready : signal is "xilinx.com:interface:aximm:1.0 s_axi AWREADY";
  attribute X_INTERFACE_INFO of s_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi AWVALID";
  attribute X_INTERFACE_INFO of s_axi_bready : signal is "xilinx.com:interface:aximm:1.0 s_axi BREADY";
  attribute X_INTERFACE_INFO of s_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi BVALID";
  attribute X_INTERFACE_INFO of s_axi_rready : signal is "xilinx.com:interface:aximm:1.0 s_axi RREADY";
  attribute X_INTERFACE_PARAMETER of s_axi_rready : signal is "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 4, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN system_ps7_0_FCLK_CLK0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi RVALID";
  attribute X_INTERFACE_INFO of s_axi_wready : signal is "xilinx.com:interface:aximm:1.0 s_axi WREADY";
  attribute X_INTERFACE_INFO of s_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 s_axi WVALID";
  attribute X_INTERFACE_INFO of s_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 s_axi ARADDR";
  attribute X_INTERFACE_INFO of s_axi_arprot : signal is "xilinx.com:interface:aximm:1.0 s_axi ARPROT";
  attribute X_INTERFACE_INFO of s_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 s_axi AWADDR";
  attribute X_INTERFACE_INFO of s_axi_awprot : signal is "xilinx.com:interface:aximm:1.0 s_axi AWPROT";
  attribute X_INTERFACE_INFO of s_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 s_axi BRESP";
  attribute X_INTERFACE_INFO of s_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 s_axi RDATA";
  attribute X_INTERFACE_INFO of s_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 s_axi RRESP";
  attribute X_INTERFACE_INFO of s_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 s_axi WDATA";
  attribute X_INTERFACE_INFO of s_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 s_axi WSTRB";
begin
  s_axi_bresp(1) <= \<const0>\;
  s_axi_bresp(0) <= \<const0>\;
  s_axi_rresp(1) <= \<const0>\;
  s_axi_rresp(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.system_tpu_0_tiny_tpu_axi
     port map (
      s_axi_aclk => s_axi_aclk,
      s_axi_araddr(1 downto 0) => s_axi_araddr(3 downto 2),
      s_axi_aresetn => s_axi_aresetn,
      s_axi_arready => s_axi_arready,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_awaddr(1 downto 0) => s_axi_awaddr(3 downto 2),
      s_axi_awready => s_axi_awready,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_bready => s_axi_bready,
      s_axi_bvalid_reg_0 => s_axi_bvalid,
      s_axi_rdata(31 downto 0) => s_axi_rdata(31 downto 0),
      s_axi_rready => s_axi_rready,
      s_axi_rvalid => s_axi_rvalid,
      s_axi_wdata(31 downto 0) => s_axi_wdata(31 downto 0),
      s_axi_wready => s_axi_wready,
      s_axi_wvalid => s_axi_wvalid
    );
end STRUCTURE;
