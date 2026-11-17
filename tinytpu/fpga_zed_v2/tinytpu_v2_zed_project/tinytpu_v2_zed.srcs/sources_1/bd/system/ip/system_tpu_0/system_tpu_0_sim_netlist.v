// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Nov 16 16:57:13 2026
// Host        : DESKTOP-VONROUT running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim {c:/Users/James
//               Manikyan/Documents/GitHub/MAC_Attack/tinytpu/fpga_zed_v2/tinytpu_v2_zed_project/tinytpu_v2_zed.srcs/sources_1/bd/system/ip/system_tpu_0/system_tpu_0_sim_netlist.v}
// Design      : system_tpu_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_tpu_0,tiny_tpu_v2_axi,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "tiny_tpu_v2_axi,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module system_tpu_0
   (s_axi_aclk,
    s_axi_aresetn,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_araddr,
    s_axi_arprot,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_rready);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN system_ps7_0_FCLK_CLK0, INSERT_VIP 0" *) input s_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *) input [5:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *) input [2:0]s_axi_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *) input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *) output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *) input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *) input [3:0]s_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *) input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *) output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *) output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *) output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *) input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *) input [5:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *) input [2:0]s_axi_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *) input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *) output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *) output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *) output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *) output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 50000000, ID_WIDTH 0, ADDR_WIDTH 6, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN system_ps7_0_FCLK_CLK0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_rready;

  wire \<const0> ;
  wire \acc0[11]_i_10_n_0 ;
  wire \acc0[11]_i_11_n_0 ;
  wire \acc0[11]_i_12_n_0 ;
  wire \acc0[11]_i_13_n_0 ;
  wire \acc0[11]_i_14_n_0 ;
  wire \acc0[11]_i_15_n_0 ;
  wire \acc0[11]_i_8_n_0 ;
  wire \acc0[11]_i_9_n_0 ;
  wire \acc0[15]_i_10_n_0 ;
  wire \acc0[15]_i_11_n_0 ;
  wire \acc0[15]_i_12_n_0 ;
  wire \acc0[15]_i_13_n_0 ;
  wire \acc0[15]_i_14_n_0 ;
  wire \acc0[15]_i_15_n_0 ;
  wire \acc0[15]_i_16_n_0 ;
  wire \acc0[7]_i_10_n_0 ;
  wire \acc0[7]_i_11_n_0 ;
  wire \acc0[7]_i_12_n_0 ;
  wire \acc0[7]_i_13_n_0 ;
  wire \acc0[7]_i_14_n_0 ;
  wire \acc0[7]_i_8_n_0 ;
  wire \acc0[7]_i_9_n_0 ;
  wire \acc0_reg[11]_i_7_n_0 ;
  wire \acc0_reg[11]_i_7_n_1 ;
  wire \acc0_reg[11]_i_7_n_2 ;
  wire \acc0_reg[11]_i_7_n_3 ;
  wire \acc0_reg[11]_i_7_n_4 ;
  wire \acc0_reg[11]_i_7_n_5 ;
  wire \acc0_reg[11]_i_7_n_6 ;
  wire \acc0_reg[11]_i_7_n_7 ;
  wire \acc0_reg[15]_i_3_n_7 ;
  wire \acc0_reg[15]_i_8_n_0 ;
  wire \acc0_reg[15]_i_8_n_1 ;
  wire \acc0_reg[15]_i_8_n_2 ;
  wire \acc0_reg[15]_i_8_n_3 ;
  wire \acc0_reg[15]_i_8_n_4 ;
  wire \acc0_reg[15]_i_8_n_5 ;
  wire \acc0_reg[15]_i_8_n_6 ;
  wire \acc0_reg[15]_i_8_n_7 ;
  wire \acc0_reg[7]_i_7_n_0 ;
  wire \acc0_reg[7]_i_7_n_1 ;
  wire \acc0_reg[7]_i_7_n_2 ;
  wire \acc0_reg[7]_i_7_n_3 ;
  wire \acc0_reg[7]_i_7_n_4 ;
  wire \acc0_reg[7]_i_7_n_5 ;
  wire \acc0_reg[7]_i_7_n_6 ;
  wire \acc0_reg[7]_i_7_n_7 ;
  wire \acc1[11]_i_10_n_0 ;
  wire \acc1[11]_i_11_n_0 ;
  wire \acc1[11]_i_12_n_0 ;
  wire \acc1[11]_i_13_n_0 ;
  wire \acc1[11]_i_14_n_0 ;
  wire \acc1[11]_i_15_n_0 ;
  wire \acc1[11]_i_8_n_0 ;
  wire \acc1[11]_i_9_n_0 ;
  wire \acc1[15]_i_10_n_0 ;
  wire \acc1[15]_i_11_n_0 ;
  wire \acc1[15]_i_12_n_0 ;
  wire \acc1[15]_i_13_n_0 ;
  wire \acc1[15]_i_14_n_0 ;
  wire \acc1[15]_i_15_n_0 ;
  wire \acc1[15]_i_16_n_0 ;
  wire \acc1[7]_i_10_n_0 ;
  wire \acc1[7]_i_11_n_0 ;
  wire \acc1[7]_i_12_n_0 ;
  wire \acc1[7]_i_13_n_0 ;
  wire \acc1[7]_i_14_n_0 ;
  wire \acc1[7]_i_8_n_0 ;
  wire \acc1[7]_i_9_n_0 ;
  wire \acc1_reg[11]_i_7_n_0 ;
  wire \acc1_reg[11]_i_7_n_1 ;
  wire \acc1_reg[11]_i_7_n_2 ;
  wire \acc1_reg[11]_i_7_n_3 ;
  wire \acc1_reg[11]_i_7_n_4 ;
  wire \acc1_reg[11]_i_7_n_5 ;
  wire \acc1_reg[11]_i_7_n_6 ;
  wire \acc1_reg[11]_i_7_n_7 ;
  wire \acc1_reg[15]_i_3_n_7 ;
  wire \acc1_reg[15]_i_8_n_0 ;
  wire \acc1_reg[15]_i_8_n_1 ;
  wire \acc1_reg[15]_i_8_n_2 ;
  wire \acc1_reg[15]_i_8_n_3 ;
  wire \acc1_reg[15]_i_8_n_4 ;
  wire \acc1_reg[15]_i_8_n_5 ;
  wire \acc1_reg[15]_i_8_n_6 ;
  wire \acc1_reg[15]_i_8_n_7 ;
  wire \acc1_reg[7]_i_7_n_0 ;
  wire \acc1_reg[7]_i_7_n_1 ;
  wire \acc1_reg[7]_i_7_n_2 ;
  wire \acc1_reg[7]_i_7_n_3 ;
  wire \acc1_reg[7]_i_7_n_4 ;
  wire \acc1_reg[7]_i_7_n_5 ;
  wire \acc1_reg[7]_i_7_n_6 ;
  wire \acc1_reg[7]_i_7_n_7 ;
  wire inst_n_10;
  wire inst_n_11;
  wire inst_n_12;
  wire inst_n_13;
  wire inst_n_14;
  wire inst_n_15;
  wire inst_n_16;
  wire inst_n_17;
  wire inst_n_18;
  wire inst_n_19;
  wire inst_n_20;
  wire inst_n_21;
  wire inst_n_22;
  wire inst_n_23;
  wire inst_n_24;
  wire inst_n_25;
  wire inst_n_26;
  wire inst_n_27;
  wire inst_n_28;
  wire inst_n_29;
  wire inst_n_30;
  wire inst_n_31;
  wire inst_n_32;
  wire inst_n_33;
  wire inst_n_34;
  wire inst_n_35;
  wire inst_n_36;
  wire inst_n_37;
  wire inst_n_38;
  wire inst_n_39;
  wire inst_n_40;
  wire inst_n_41;
  wire inst_n_42;
  wire inst_n_43;
  wire inst_n_44;
  wire inst_n_45;
  wire inst_n_46;
  wire inst_n_47;
  wire inst_n_48;
  wire inst_n_49;
  wire inst_n_5;
  wire inst_n_50;
  wire inst_n_51;
  wire inst_n_52;
  wire inst_n_53;
  wire inst_n_54;
  wire inst_n_55;
  wire inst_n_56;
  wire inst_n_57;
  wire inst_n_58;
  wire inst_n_59;
  wire inst_n_6;
  wire inst_n_60;
  wire inst_n_61;
  wire inst_n_62;
  wire inst_n_7;
  wire inst_n_8;
  wire inst_n_9;
  wire s_axi_aclk;
  wire [5:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [5:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire s_axi_wvalid;
  wire [3:0]\NLW_acc0_reg[15]_i_3_CO_UNCONNECTED ;
  wire [3:1]\NLW_acc0_reg[15]_i_3_O_UNCONNECTED ;
  wire [3:0]\NLW_acc1_reg[15]_i_3_CO_UNCONNECTED ;
  wire [3:1]\NLW_acc1_reg[15]_i_3_O_UNCONNECTED ;

  assign s_axi_bresp[1] = \<const0> ;
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_rresp[1] = \<const0> ;
  assign s_axi_rresp[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc0[11]_i_10 
       (.I0(inst_n_26),
        .I1(inst_n_6),
        .I2(inst_n_20),
        .O(\acc0[11]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc0[11]_i_11 
       (.I0(inst_n_27),
        .I1(inst_n_7),
        .I2(inst_n_13),
        .O(\acc0[11]_i_11_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc0[11]_i_12 
       (.I0(\acc0[11]_i_8_n_0 ),
        .I1(inst_n_31),
        .I2(inst_n_10),
        .I3(inst_n_17),
        .O(\acc0[11]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc0[11]_i_13 
       (.I0(inst_n_24),
        .I1(inst_n_11),
        .I2(inst_n_18),
        .I3(\acc0[11]_i_9_n_0 ),
        .O(\acc0[11]_i_13_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc0[11]_i_14 
       (.I0(inst_n_25),
        .I1(inst_n_12),
        .I2(inst_n_19),
        .I3(\acc0[11]_i_10_n_0 ),
        .O(\acc0[11]_i_14_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc0[11]_i_15 
       (.I0(inst_n_26),
        .I1(inst_n_6),
        .I2(inst_n_20),
        .I3(\acc0[11]_i_11_n_0 ),
        .O(\acc0[11]_i_15_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc0[11]_i_8 
       (.I0(inst_n_24),
        .I1(inst_n_11),
        .I2(inst_n_18),
        .O(\acc0[11]_i_8_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc0[11]_i_9 
       (.I0(inst_n_25),
        .I1(inst_n_12),
        .I2(inst_n_19),
        .O(\acc0[11]_i_9_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_10 
       (.I0(inst_n_29),
        .I1(inst_n_22),
        .O(\acc0[15]_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_11 
       (.I0(inst_n_30),
        .I1(inst_n_23),
        .O(\acc0[15]_i_11_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc0[15]_i_12 
       (.I0(inst_n_31),
        .I1(inst_n_10),
        .I2(inst_n_17),
        .O(\acc0[15]_i_12_n_0 ));
  LUT3 #(
    .INIT(8'h78)) 
    \acc0[15]_i_13 
       (.I0(inst_n_21),
        .I1(inst_n_28),
        .I2(inst_n_33),
        .O(\acc0[15]_i_13_n_0 ));
  LUT4 #(
    .INIT(16'h8778)) 
    \acc0[15]_i_14 
       (.I0(inst_n_22),
        .I1(inst_n_29),
        .I2(inst_n_21),
        .I3(inst_n_28),
        .O(\acc0[15]_i_14_n_0 ));
  LUT4 #(
    .INIT(16'h8778)) 
    \acc0[15]_i_15 
       (.I0(inst_n_23),
        .I1(inst_n_30),
        .I2(inst_n_22),
        .I3(inst_n_29),
        .O(\acc0[15]_i_15_n_0 ));
  LUT5 #(
    .INIT(32'hE81717E8)) 
    \acc0[15]_i_16 
       (.I0(inst_n_17),
        .I1(inst_n_10),
        .I2(inst_n_31),
        .I3(inst_n_23),
        .I4(inst_n_30),
        .O(\acc0[15]_i_16_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[7]_i_10 
       (.I0(inst_n_5),
        .I1(inst_n_16),
        .O(\acc0[7]_i_10_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc0[7]_i_11 
       (.I0(inst_n_27),
        .I1(inst_n_7),
        .I2(inst_n_13),
        .I3(\acc0[7]_i_8_n_0 ),
        .O(\acc0[7]_i_11_n_0 ));
  (* HLUTNM = "lutpair0" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    \acc0[7]_i_12 
       (.I0(inst_n_14),
        .I1(inst_n_8),
        .I2(inst_n_9),
        .I3(inst_n_15),
        .O(\acc0[7]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h8778)) 
    \acc0[7]_i_13 
       (.I0(inst_n_16),
        .I1(inst_n_5),
        .I2(inst_n_9),
        .I3(inst_n_15),
        .O(\acc0[7]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[7]_i_14 
       (.I0(inst_n_5),
        .I1(inst_n_16),
        .O(\acc0[7]_i_14_n_0 ));
  (* HLUTNM = "lutpair0" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[7]_i_8 
       (.I0(inst_n_14),
        .I1(inst_n_8),
        .O(\acc0[7]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[7]_i_9 
       (.I0(inst_n_15),
        .I1(inst_n_9),
        .O(\acc0[7]_i_9_n_0 ));
  CARRY4 \acc0_reg[11]_i_7 
       (.CI(\acc0_reg[7]_i_7_n_0 ),
        .CO({\acc0_reg[11]_i_7_n_0 ,\acc0_reg[11]_i_7_n_1 ,\acc0_reg[11]_i_7_n_2 ,\acc0_reg[11]_i_7_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[11]_i_8_n_0 ,\acc0[11]_i_9_n_0 ,\acc0[11]_i_10_n_0 ,\acc0[11]_i_11_n_0 }),
        .O({\acc0_reg[11]_i_7_n_4 ,\acc0_reg[11]_i_7_n_5 ,\acc0_reg[11]_i_7_n_6 ,\acc0_reg[11]_i_7_n_7 }),
        .S({\acc0[11]_i_12_n_0 ,\acc0[11]_i_13_n_0 ,\acc0[11]_i_14_n_0 ,\acc0[11]_i_15_n_0 }));
  CARRY4 \acc0_reg[15]_i_3 
       (.CI(\acc0_reg[15]_i_8_n_0 ),
        .CO(\NLW_acc0_reg[15]_i_3_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_acc0_reg[15]_i_3_O_UNCONNECTED [3:1],\acc0_reg[15]_i_3_n_7 }),
        .S({1'b0,1'b0,1'b0,inst_n_32}));
  CARRY4 \acc0_reg[15]_i_8 
       (.CI(\acc0_reg[11]_i_7_n_0 ),
        .CO({\acc0_reg[15]_i_8_n_0 ,\acc0_reg[15]_i_8_n_1 ,\acc0_reg[15]_i_8_n_2 ,\acc0_reg[15]_i_8_n_3 }),
        .CYINIT(1'b0),
        .DI({inst_n_33,\acc0[15]_i_10_n_0 ,\acc0[15]_i_11_n_0 ,\acc0[15]_i_12_n_0 }),
        .O({\acc0_reg[15]_i_8_n_4 ,\acc0_reg[15]_i_8_n_5 ,\acc0_reg[15]_i_8_n_6 ,\acc0_reg[15]_i_8_n_7 }),
        .S({\acc0[15]_i_13_n_0 ,\acc0[15]_i_14_n_0 ,\acc0[15]_i_15_n_0 ,\acc0[15]_i_16_n_0 }));
  CARRY4 \acc0_reg[7]_i_7 
       (.CI(1'b0),
        .CO({\acc0_reg[7]_i_7_n_0 ,\acc0_reg[7]_i_7_n_1 ,\acc0_reg[7]_i_7_n_2 ,\acc0_reg[7]_i_7_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[7]_i_8_n_0 ,\acc0[7]_i_9_n_0 ,\acc0[7]_i_10_n_0 ,1'b0}),
        .O({\acc0_reg[7]_i_7_n_4 ,\acc0_reg[7]_i_7_n_5 ,\acc0_reg[7]_i_7_n_6 ,\acc0_reg[7]_i_7_n_7 }),
        .S({\acc0[7]_i_11_n_0 ,\acc0[7]_i_12_n_0 ,\acc0[7]_i_13_n_0 ,\acc0[7]_i_14_n_0 }));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc1[11]_i_10 
       (.I0(inst_n_55),
        .I1(inst_n_35),
        .I2(inst_n_49),
        .O(\acc1[11]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc1[11]_i_11 
       (.I0(inst_n_56),
        .I1(inst_n_36),
        .I2(inst_n_42),
        .O(\acc1[11]_i_11_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc1[11]_i_12 
       (.I0(\acc1[11]_i_8_n_0 ),
        .I1(inst_n_60),
        .I2(inst_n_39),
        .I3(inst_n_46),
        .O(\acc1[11]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc1[11]_i_13 
       (.I0(inst_n_53),
        .I1(inst_n_40),
        .I2(inst_n_47),
        .I3(\acc1[11]_i_9_n_0 ),
        .O(\acc1[11]_i_13_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc1[11]_i_14 
       (.I0(inst_n_54),
        .I1(inst_n_41),
        .I2(inst_n_48),
        .I3(\acc1[11]_i_10_n_0 ),
        .O(\acc1[11]_i_14_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc1[11]_i_15 
       (.I0(inst_n_55),
        .I1(inst_n_35),
        .I2(inst_n_49),
        .I3(\acc1[11]_i_11_n_0 ),
        .O(\acc1[11]_i_15_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc1[11]_i_8 
       (.I0(inst_n_53),
        .I1(inst_n_40),
        .I2(inst_n_47),
        .O(\acc1[11]_i_8_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc1[11]_i_9 
       (.I0(inst_n_54),
        .I1(inst_n_41),
        .I2(inst_n_48),
        .O(\acc1[11]_i_9_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_10 
       (.I0(inst_n_58),
        .I1(inst_n_51),
        .O(\acc1[15]_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_11 
       (.I0(inst_n_59),
        .I1(inst_n_52),
        .O(\acc1[15]_i_11_n_0 ));
  LUT3 #(
    .INIT(8'hE8)) 
    \acc1[15]_i_12 
       (.I0(inst_n_60),
        .I1(inst_n_39),
        .I2(inst_n_46),
        .O(\acc1[15]_i_12_n_0 ));
  LUT3 #(
    .INIT(8'h78)) 
    \acc1[15]_i_13 
       (.I0(inst_n_50),
        .I1(inst_n_57),
        .I2(inst_n_62),
        .O(\acc1[15]_i_13_n_0 ));
  LUT4 #(
    .INIT(16'h8778)) 
    \acc1[15]_i_14 
       (.I0(inst_n_51),
        .I1(inst_n_58),
        .I2(inst_n_50),
        .I3(inst_n_57),
        .O(\acc1[15]_i_14_n_0 ));
  LUT4 #(
    .INIT(16'h8778)) 
    \acc1[15]_i_15 
       (.I0(inst_n_52),
        .I1(inst_n_59),
        .I2(inst_n_51),
        .I3(inst_n_58),
        .O(\acc1[15]_i_15_n_0 ));
  LUT5 #(
    .INIT(32'hE81717E8)) 
    \acc1[15]_i_16 
       (.I0(inst_n_46),
        .I1(inst_n_39),
        .I2(inst_n_60),
        .I3(inst_n_52),
        .I4(inst_n_59),
        .O(\acc1[15]_i_16_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[7]_i_10 
       (.I0(inst_n_34),
        .I1(inst_n_45),
        .O(\acc1[7]_i_10_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \acc1[7]_i_11 
       (.I0(inst_n_56),
        .I1(inst_n_36),
        .I2(inst_n_42),
        .I3(\acc1[7]_i_8_n_0 ),
        .O(\acc1[7]_i_11_n_0 ));
  (* HLUTNM = "lutpair1" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    \acc1[7]_i_12 
       (.I0(inst_n_43),
        .I1(inst_n_37),
        .I2(inst_n_38),
        .I3(inst_n_44),
        .O(\acc1[7]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h8778)) 
    \acc1[7]_i_13 
       (.I0(inst_n_45),
        .I1(inst_n_34),
        .I2(inst_n_38),
        .I3(inst_n_44),
        .O(\acc1[7]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[7]_i_14 
       (.I0(inst_n_34),
        .I1(inst_n_45),
        .O(\acc1[7]_i_14_n_0 ));
  (* HLUTNM = "lutpair1" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[7]_i_8 
       (.I0(inst_n_43),
        .I1(inst_n_37),
        .O(\acc1[7]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[7]_i_9 
       (.I0(inst_n_44),
        .I1(inst_n_38),
        .O(\acc1[7]_i_9_n_0 ));
  CARRY4 \acc1_reg[11]_i_7 
       (.CI(\acc1_reg[7]_i_7_n_0 ),
        .CO({\acc1_reg[11]_i_7_n_0 ,\acc1_reg[11]_i_7_n_1 ,\acc1_reg[11]_i_7_n_2 ,\acc1_reg[11]_i_7_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[11]_i_8_n_0 ,\acc1[11]_i_9_n_0 ,\acc1[11]_i_10_n_0 ,\acc1[11]_i_11_n_0 }),
        .O({\acc1_reg[11]_i_7_n_4 ,\acc1_reg[11]_i_7_n_5 ,\acc1_reg[11]_i_7_n_6 ,\acc1_reg[11]_i_7_n_7 }),
        .S({\acc1[11]_i_12_n_0 ,\acc1[11]_i_13_n_0 ,\acc1[11]_i_14_n_0 ,\acc1[11]_i_15_n_0 }));
  CARRY4 \acc1_reg[15]_i_3 
       (.CI(\acc1_reg[15]_i_8_n_0 ),
        .CO(\NLW_acc1_reg[15]_i_3_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_acc1_reg[15]_i_3_O_UNCONNECTED [3:1],\acc1_reg[15]_i_3_n_7 }),
        .S({1'b0,1'b0,1'b0,inst_n_61}));
  CARRY4 \acc1_reg[15]_i_8 
       (.CI(\acc1_reg[11]_i_7_n_0 ),
        .CO({\acc1_reg[15]_i_8_n_0 ,\acc1_reg[15]_i_8_n_1 ,\acc1_reg[15]_i_8_n_2 ,\acc1_reg[15]_i_8_n_3 }),
        .CYINIT(1'b0),
        .DI({inst_n_62,\acc1[15]_i_10_n_0 ,\acc1[15]_i_11_n_0 ,\acc1[15]_i_12_n_0 }),
        .O({\acc1_reg[15]_i_8_n_4 ,\acc1_reg[15]_i_8_n_5 ,\acc1_reg[15]_i_8_n_6 ,\acc1_reg[15]_i_8_n_7 }),
        .S({\acc1[15]_i_13_n_0 ,\acc1[15]_i_14_n_0 ,\acc1[15]_i_15_n_0 ,\acc1[15]_i_16_n_0 }));
  CARRY4 \acc1_reg[7]_i_7 
       (.CI(1'b0),
        .CO({\acc1_reg[7]_i_7_n_0 ,\acc1_reg[7]_i_7_n_1 ,\acc1_reg[7]_i_7_n_2 ,\acc1_reg[7]_i_7_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[7]_i_8_n_0 ,\acc1[7]_i_9_n_0 ,\acc1[7]_i_10_n_0 ,1'b0}),
        .O({\acc1_reg[7]_i_7_n_4 ,\acc1_reg[7]_i_7_n_5 ,\acc1_reg[7]_i_7_n_6 ,\acc1_reg[7]_i_7_n_7 }),
        .S({\acc1[7]_i_11_n_0 ,\acc1[7]_i_12_n_0 ,\acc1[7]_i_13_n_0 ,\acc1[7]_i_14_n_0 }));
  system_tpu_0_tiny_tpu_v2_axi inst
       (.CO(inst_n_10),
        .O(\acc0_reg[15]_i_3_n_7 ),
        .\acc0_reg[11]_i_2 ({\acc0_reg[11]_i_7_n_4 ,\acc0_reg[11]_i_7_n_5 ,\acc0_reg[11]_i_7_n_6 ,\acc0_reg[11]_i_7_n_7 }),
        .\acc0_reg[15]_i_2 ({\acc0_reg[15]_i_8_n_4 ,\acc0_reg[15]_i_8_n_5 ,\acc0_reg[15]_i_8_n_6 ,\acc0_reg[15]_i_8_n_7 }),
        .\acc0_reg[7]_i_2 ({\acc0_reg[7]_i_7_n_4 ,\acc0_reg[7]_i_7_n_5 ,\acc0_reg[7]_i_7_n_6 ,\acc0_reg[7]_i_7_n_7 }),
        .\acc1_reg[11]_i_2 ({\acc1_reg[11]_i_7_n_4 ,\acc1_reg[11]_i_7_n_5 ,\acc1_reg[11]_i_7_n_6 ,\acc1_reg[11]_i_7_n_7 }),
        .\acc1_reg[15] (\acc1_reg[15]_i_3_n_7 ),
        .\acc1_reg[15]_i_2 ({\acc1_reg[15]_i_8_n_4 ,\acc1_reg[15]_i_8_n_5 ,\acc1_reg[15]_i_8_n_6 ,\acc1_reg[15]_i_8_n_7 }),
        .\acc1_reg[7]_i_2 ({\acc1_reg[7]_i_7_n_4 ,\acc1_reg[7]_i_7_n_5 ,\acc1_reg[7]_i_7_n_6 ,\acc1_reg[7]_i_7_n_7 }),
        .\q_data_reg[0]_0 (inst_n_5),
        .\q_data_reg[10]_0 ({inst_n_35,inst_n_36,inst_n_37,inst_n_38}),
        .\q_data_reg[10]_1 (inst_n_39),
        .\q_data_reg[10]_2 ({inst_n_40,inst_n_41}),
        .\q_data_reg[11]_0 ({inst_n_42,inst_n_43,inst_n_44,inst_n_45}),
        .\q_data_reg[13]_0 ({inst_n_46,inst_n_47,inst_n_48,inst_n_49}),
        .\q_data_reg[13]_1 (inst_n_50),
        .\q_data_reg[13]_2 ({inst_n_51,inst_n_52}),
        .\q_data_reg[14]_0 ({inst_n_57,inst_n_58,inst_n_59,inst_n_60}),
        .\q_data_reg[15]_0 ({inst_n_53,inst_n_54,inst_n_55,inst_n_56}),
        .\q_data_reg[15]_1 ({inst_n_61,inst_n_62}),
        .\q_data_reg[2]_0 ({inst_n_6,inst_n_7,inst_n_8,inst_n_9}),
        .\q_data_reg[2]_1 ({inst_n_11,inst_n_12}),
        .\q_data_reg[3]_0 ({inst_n_13,inst_n_14,inst_n_15,inst_n_16}),
        .\q_data_reg[5]_0 ({inst_n_17,inst_n_18,inst_n_19,inst_n_20}),
        .\q_data_reg[5]_1 (inst_n_21),
        .\q_data_reg[5]_2 ({inst_n_22,inst_n_23}),
        .\q_data_reg[6]_0 ({inst_n_28,inst_n_29,inst_n_30,inst_n_31}),
        .\q_data_reg[7]_0 ({inst_n_24,inst_n_25,inst_n_26,inst_n_27}),
        .\q_data_reg[7]_1 ({inst_n_32,inst_n_33}),
        .\q_data_reg[8]_0 (inst_n_34),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr[5:2]),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_arready_reg_0(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr[5:2]),
        .s_axi_awready_reg_0(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid_reg_0(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready_reg_0(s_axi_wready),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

(* ORIG_REF_NAME = "tiny_tpu_v2_axi" *) 
module system_tpu_0_tiny_tpu_v2_axi
   (s_axi_wready_reg_0,
    s_axi_awready_reg_0,
    s_axi_arready_reg_0,
    s_axi_bvalid_reg_0,
    s_axi_rvalid,
    \q_data_reg[0]_0 ,
    \q_data_reg[2]_0 ,
    CO,
    \q_data_reg[2]_1 ,
    \q_data_reg[3]_0 ,
    \q_data_reg[5]_0 ,
    \q_data_reg[5]_1 ,
    \q_data_reg[5]_2 ,
    \q_data_reg[7]_0 ,
    \q_data_reg[6]_0 ,
    \q_data_reg[7]_1 ,
    \q_data_reg[8]_0 ,
    \q_data_reg[10]_0 ,
    \q_data_reg[10]_1 ,
    \q_data_reg[10]_2 ,
    \q_data_reg[11]_0 ,
    \q_data_reg[13]_0 ,
    \q_data_reg[13]_1 ,
    \q_data_reg[13]_2 ,
    \q_data_reg[15]_0 ,
    \q_data_reg[14]_0 ,
    \q_data_reg[15]_1 ,
    s_axi_rdata,
    s_axi_aclk,
    O,
    \acc1_reg[15] ,
    \acc0_reg[7]_i_2 ,
    \acc0_reg[11]_i_2 ,
    \acc0_reg[15]_i_2 ,
    \acc1_reg[7]_i_2 ,
    \acc1_reg[11]_i_2 ,
    \acc1_reg[15]_i_2 ,
    s_axi_arvalid,
    s_axi_rready,
    s_axi_awvalid,
    s_axi_aresetn,
    s_axi_wvalid,
    s_axi_awaddr,
    s_axi_wdata,
    s_axi_bready,
    s_axi_araddr);
  output s_axi_wready_reg_0;
  output s_axi_awready_reg_0;
  output s_axi_arready_reg_0;
  output s_axi_bvalid_reg_0;
  output s_axi_rvalid;
  output [0:0]\q_data_reg[0]_0 ;
  output [3:0]\q_data_reg[2]_0 ;
  output [0:0]CO;
  output [1:0]\q_data_reg[2]_1 ;
  output [3:0]\q_data_reg[3]_0 ;
  output [3:0]\q_data_reg[5]_0 ;
  output [0:0]\q_data_reg[5]_1 ;
  output [1:0]\q_data_reg[5]_2 ;
  output [3:0]\q_data_reg[7]_0 ;
  output [3:0]\q_data_reg[6]_0 ;
  output [1:0]\q_data_reg[7]_1 ;
  output [0:0]\q_data_reg[8]_0 ;
  output [3:0]\q_data_reg[10]_0 ;
  output [0:0]\q_data_reg[10]_1 ;
  output [1:0]\q_data_reg[10]_2 ;
  output [3:0]\q_data_reg[11]_0 ;
  output [3:0]\q_data_reg[13]_0 ;
  output [0:0]\q_data_reg[13]_1 ;
  output [1:0]\q_data_reg[13]_2 ;
  output [3:0]\q_data_reg[15]_0 ;
  output [3:0]\q_data_reg[14]_0 ;
  output [1:0]\q_data_reg[15]_1 ;
  output [31:0]s_axi_rdata;
  input s_axi_aclk;
  input [0:0]O;
  input [0:0]\acc1_reg[15] ;
  input [3:0]\acc0_reg[7]_i_2 ;
  input [3:0]\acc0_reg[11]_i_2 ;
  input [3:0]\acc0_reg[15]_i_2 ;
  input [3:0]\acc1_reg[7]_i_2 ;
  input [3:0]\acc1_reg[11]_i_2 ;
  input [3:0]\acc1_reg[15]_i_2 ;
  input s_axi_arvalid;
  input s_axi_rready;
  input s_axi_awvalid;
  input s_axi_aresetn;
  input s_axi_wvalid;
  input [3:0]s_axi_awaddr;
  input [31:0]s_axi_wdata;
  input s_axi_bready;
  input [3:0]s_axi_araddr;

  wire [0:0]CO;
  wire [0:0]O;
  wire [3:0]\acc0_reg[11]_i_2 ;
  wire [3:0]\acc0_reg[15]_i_2 ;
  wire [3:0]\acc0_reg[7]_i_2 ;
  wire [3:0]\acc1_reg[11]_i_2 ;
  wire [0:0]\acc1_reg[15] ;
  wire [3:0]\acc1_reg[15]_i_2 ;
  wire [3:0]\acc1_reg[7]_i_2 ;
  wire [5:2]aw_addr;
  wire aw_have;
  wire aw_have_i_1_n_0;
  wire aw_now__0;
  wire aw_take;
  wire b_pend;
  wire b_pend_i_1_n_0;
  wire [1:0]cool;
  wire \cool[0]_i_1_n_0 ;
  wire \cool[1]_i_1_n_0 ;
  wire [10:8]data_now__95;
  wire do_write;
  wire do_write0__0;
  wire ovf0;
  wire ovf0_i_1_n_0;
  wire ovf10_out;
  wire [2:0]p_0_in;
  wire [31:0]p_1_in;
  wire p_7_in;
  wire q_cmd;
  wire \q_cmd[0]_i_1_n_0 ;
  wire \q_cmd[0]_i_2_n_0 ;
  wire \q_cmd[1]_i_1_n_0 ;
  wire \q_cmd[2]_i_1_n_0 ;
  wire \q_cmd[2]_i_4_n_0 ;
  wire \q_cmd_reg_n_0_[0] ;
  wire \q_cmd_reg_n_0_[1] ;
  wire \q_cmd_reg_n_0_[2] ;
  wire [15:0]q_data;
  wire \q_data[0]_i_2_n_0 ;
  wire \q_data[11]_i_2_n_0 ;
  wire \q_data[12]_i_2_n_0 ;
  wire \q_data[13]_i_2_n_0 ;
  wire \q_data[14]_i_2_n_0 ;
  wire \q_data[15]_i_2_n_0 ;
  wire \q_data[1]_i_2_n_0 ;
  wire \q_data[2]_i_2_n_0 ;
  wire \q_data[31]_i_1_n_0 ;
  wire \q_data[3]_i_2_n_0 ;
  wire \q_data[4]_i_2_n_0 ;
  wire \q_data[5]_i_2_n_0 ;
  wire \q_data[6]_i_2_n_0 ;
  wire \q_data[7]_i_2_n_0 ;
  wire [0:0]\q_data_reg[0]_0 ;
  wire [3:0]\q_data_reg[10]_0 ;
  wire [0:0]\q_data_reg[10]_1 ;
  wire [1:0]\q_data_reg[10]_2 ;
  wire [3:0]\q_data_reg[11]_0 ;
  wire [3:0]\q_data_reg[13]_0 ;
  wire [0:0]\q_data_reg[13]_1 ;
  wire [1:0]\q_data_reg[13]_2 ;
  wire [3:0]\q_data_reg[14]_0 ;
  wire [3:0]\q_data_reg[15]_0 ;
  wire [1:0]\q_data_reg[15]_1 ;
  wire [3:0]\q_data_reg[2]_0 ;
  wire [1:0]\q_data_reg[2]_1 ;
  wire [3:0]\q_data_reg[3]_0 ;
  wire [3:0]\q_data_reg[5]_0 ;
  wire [0:0]\q_data_reg[5]_1 ;
  wire [1:0]\q_data_reg[5]_2 ;
  wire [3:0]\q_data_reg[6]_0 ;
  wire [3:0]\q_data_reg[7]_0 ;
  wire [1:0]\q_data_reg[7]_1 ;
  wire [0:0]\q_data_reg[8]_0 ;
  wire \q_data_reg_n_0_[16] ;
  wire \q_data_reg_n_0_[17] ;
  wire \q_data_reg_n_0_[18] ;
  wire \q_data_reg_n_0_[19] ;
  wire \q_data_reg_n_0_[20] ;
  wire \q_data_reg_n_0_[21] ;
  wire \q_data_reg_n_0_[22] ;
  wire \q_data_reg_n_0_[23] ;
  wire \q_data_reg_n_0_[24] ;
  wire \q_data_reg_n_0_[25] ;
  wire \q_data_reg_n_0_[26] ;
  wire \q_data_reg_n_0_[27] ;
  wire \q_data_reg_n_0_[28] ;
  wire \q_data_reg_n_0_[29] ;
  wire \q_data_reg_n_0_[30] ;
  wire \q_data_reg_n_0_[31] ;
  wire \q_n[0]_i_1_n_0 ;
  wire \q_n[1]_i_1_n_0 ;
  wire \q_n[2]_i_1_n_0 ;
  wire \q_n[2]_i_2_n_0 ;
  wire \q_n_reg_n_0_[0] ;
  wire \q_n_reg_n_0_[1] ;
  wire \q_n_reg_n_0_[2] ;
  wire q_pair;
  wire q_pair4_out;
  wire q_pair_i_1_n_0;
  wire rst;
  wire [21:21]s0;
  wire s_axi_aclk;
  wire [3:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_arready0;
  wire s_axi_arready_reg_0;
  wire s_axi_arvalid;
  wire [3:0]s_axi_awaddr;
  wire s_axi_awready0;
  wire s_axi_awready_reg_0;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_bvalid_i_1_n_0;
  wire s_axi_bvalid_reg_0;
  wire [31:0]s_axi_rdata;
  wire \s_axi_rdata[0]_i_3_n_0 ;
  wire \s_axi_rdata[19]_i_2_n_0 ;
  wire \s_axi_rdata[19]_i_3_n_0 ;
  wire \s_axi_rdata[19]_i_4_n_0 ;
  wire \s_axi_rdata[1]_i_3_n_0 ;
  wire \s_axi_rdata[2]_i_3_n_0 ;
  wire \s_axi_rdata[6]_i_3_n_0 ;
  wire [31:0]s_axi_rdata_70;
  wire s_axi_rready;
  wire s_axi_rvalid;
  wire s_axi_rvalid06_out;
  wire s_axi_rvalid_i_1_n_0;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready0;
  wire s_axi_wready_reg_0;
  wire s_axi_wvalid;
  wire [5:5]sel0;
  wire sel_i_1_n_0;
  wire step;
  wire \steps[0]_i_3_n_0 ;
  wire [31:0]steps_reg;
  wire \steps_reg[0]_i_2_n_0 ;
  wire \steps_reg[0]_i_2_n_1 ;
  wire \steps_reg[0]_i_2_n_2 ;
  wire \steps_reg[0]_i_2_n_3 ;
  wire \steps_reg[0]_i_2_n_4 ;
  wire \steps_reg[0]_i_2_n_5 ;
  wire \steps_reg[0]_i_2_n_6 ;
  wire \steps_reg[0]_i_2_n_7 ;
  wire \steps_reg[12]_i_1_n_0 ;
  wire \steps_reg[12]_i_1_n_1 ;
  wire \steps_reg[12]_i_1_n_2 ;
  wire \steps_reg[12]_i_1_n_3 ;
  wire \steps_reg[12]_i_1_n_4 ;
  wire \steps_reg[12]_i_1_n_5 ;
  wire \steps_reg[12]_i_1_n_6 ;
  wire \steps_reg[12]_i_1_n_7 ;
  wire \steps_reg[16]_i_1_n_0 ;
  wire \steps_reg[16]_i_1_n_1 ;
  wire \steps_reg[16]_i_1_n_2 ;
  wire \steps_reg[16]_i_1_n_3 ;
  wire \steps_reg[16]_i_1_n_4 ;
  wire \steps_reg[16]_i_1_n_5 ;
  wire \steps_reg[16]_i_1_n_6 ;
  wire \steps_reg[16]_i_1_n_7 ;
  wire \steps_reg[20]_i_1_n_0 ;
  wire \steps_reg[20]_i_1_n_1 ;
  wire \steps_reg[20]_i_1_n_2 ;
  wire \steps_reg[20]_i_1_n_3 ;
  wire \steps_reg[20]_i_1_n_4 ;
  wire \steps_reg[20]_i_1_n_5 ;
  wire \steps_reg[20]_i_1_n_6 ;
  wire \steps_reg[20]_i_1_n_7 ;
  wire \steps_reg[24]_i_1_n_0 ;
  wire \steps_reg[24]_i_1_n_1 ;
  wire \steps_reg[24]_i_1_n_2 ;
  wire \steps_reg[24]_i_1_n_3 ;
  wire \steps_reg[24]_i_1_n_4 ;
  wire \steps_reg[24]_i_1_n_5 ;
  wire \steps_reg[24]_i_1_n_6 ;
  wire \steps_reg[24]_i_1_n_7 ;
  wire \steps_reg[28]_i_1_n_1 ;
  wire \steps_reg[28]_i_1_n_2 ;
  wire \steps_reg[28]_i_1_n_3 ;
  wire \steps_reg[28]_i_1_n_4 ;
  wire \steps_reg[28]_i_1_n_5 ;
  wire \steps_reg[28]_i_1_n_6 ;
  wire \steps_reg[28]_i_1_n_7 ;
  wire \steps_reg[4]_i_1_n_0 ;
  wire \steps_reg[4]_i_1_n_1 ;
  wire \steps_reg[4]_i_1_n_2 ;
  wire \steps_reg[4]_i_1_n_3 ;
  wire \steps_reg[4]_i_1_n_4 ;
  wire \steps_reg[4]_i_1_n_5 ;
  wire \steps_reg[4]_i_1_n_6 ;
  wire \steps_reg[4]_i_1_n_7 ;
  wire \steps_reg[8]_i_1_n_0 ;
  wire \steps_reg[8]_i_1_n_1 ;
  wire \steps_reg[8]_i_1_n_2 ;
  wire \steps_reg[8]_i_1_n_3 ;
  wire \steps_reg[8]_i_1_n_4 ;
  wire \steps_reg[8]_i_1_n_5 ;
  wire \steps_reg[8]_i_1_n_6 ;
  wire \steps_reg[8]_i_1_n_7 ;
  wire u_core_n_38;
  wire u_core_n_4;
  wire u_core_n_6;
  wire u_core_n_7;
  wire [31:0]w_data;
  wire w_have_i_1_n_0;
  wire w_have_reg_n_0;
  wire w_take;
  wire [3:3]\NLW_steps_reg[28]_i_1_CO_UNCONNECTED ;

  LUT2 #(
    .INIT(4'h8)) 
    \aw_addr[5]_i_1 
       (.I0(s_axi_awvalid),
        .I1(s_axi_awready_reg_0),
        .O(aw_take));
  FDRE \aw_addr_reg[2] 
       (.C(s_axi_aclk),
        .CE(aw_take),
        .D(s_axi_awaddr[0]),
        .Q(aw_addr[2]),
        .R(rst));
  FDRE \aw_addr_reg[3] 
       (.C(s_axi_aclk),
        .CE(aw_take),
        .D(s_axi_awaddr[1]),
        .Q(aw_addr[3]),
        .R(rst));
  FDRE \aw_addr_reg[4] 
       (.C(s_axi_aclk),
        .CE(aw_take),
        .D(s_axi_awaddr[2]),
        .Q(aw_addr[4]),
        .R(rst));
  FDRE \aw_addr_reg[5] 
       (.C(s_axi_aclk),
        .CE(aw_take),
        .D(s_axi_awaddr[3]),
        .Q(aw_addr[5]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT5 #(
    .INIT(32'h0000EA00)) 
    aw_have_i_1
       (.I0(aw_have),
        .I1(s_axi_awvalid),
        .I2(s_axi_awready_reg_0),
        .I3(s_axi_aresetn),
        .I4(do_write),
        .O(aw_have_i_1_n_0));
  FDRE aw_have_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(aw_have_i_1_n_0),
        .Q(aw_have),
        .R(1'b0));
  LUT5 #(
    .INIT(32'hFFFFFE00)) 
    b_pend_i_1
       (.I0(cool[0]),
        .I1(cool[1]),
        .I2(step),
        .I3(b_pend),
        .I4(do_write),
        .O(b_pend_i_1_n_0));
  FDRE b_pend_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(b_pend_i_1_n_0),
        .Q(b_pend),
        .R(rst));
  LUT6 #(
    .INIT(64'hF444444444444444)) 
    \cool[0]_i_1 
       (.I0(cool[0]),
        .I1(cool[1]),
        .I2(p_7_in),
        .I3(\q_cmd_reg_n_0_[2] ),
        .I4(\q_cmd_reg_n_0_[1] ),
        .I5(\q_cmd_reg_n_0_[0] ),
        .O(\cool[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF888888888888888)) 
    \cool[1]_i_1 
       (.I0(cool[0]),
        .I1(cool[1]),
        .I2(p_7_in),
        .I3(\q_cmd_reg_n_0_[2] ),
        .I4(\q_cmd_reg_n_0_[1] ),
        .I5(\q_cmd_reg_n_0_[0] ),
        .O(\cool[1]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00FE)) 
    \cool[1]_i_2 
       (.I0(\q_n_reg_n_0_[2] ),
        .I1(\q_n_reg_n_0_[1] ),
        .I2(\q_n_reg_n_0_[0] ),
        .I3(q_pair),
        .O(p_7_in));
  FDRE \cool_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\cool[0]_i_1_n_0 ),
        .Q(cool[0]),
        .R(rst));
  FDRE \cool_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\cool[1]_i_1_n_0 ),
        .Q(cool[1]),
        .R(rst));
  LUT6 #(
    .INIT(64'h5335733750054004)) 
    ovf0_i_1
       (.I0(u_core_n_7),
        .I1(ovf10_out),
        .I2(u_core_n_38),
        .I3(s0),
        .I4(u_core_n_6),
        .I5(ovf0),
        .O(ovf0_i_1_n_0));
  LUT6 #(
    .INIT(64'hA808FFFFA8080000)) 
    \q_cmd[0]_i_1 
       (.I0(\q_cmd[0]_i_2_n_0 ),
        .I1(s_axi_wdata[8]),
        .I2(w_have_reg_n_0),
        .I3(w_data[8]),
        .I4(q_cmd),
        .I5(\q_cmd_reg_n_0_[0] ),
        .O(\q_cmd[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT5 #(
    .INIT(32'h00053305)) 
    \q_cmd[0]_i_2 
       (.I0(s_axi_awaddr[2]),
        .I1(aw_addr[4]),
        .I2(s_axi_awaddr[1]),
        .I3(aw_have),
        .I4(aw_addr[3]),
        .O(\q_cmd[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h470000000000FF00)) 
    \q_cmd[0]_i_3 
       (.I0(aw_addr[4]),
        .I1(aw_have),
        .I2(s_axi_awaddr[2]),
        .I3(\q_cmd[2]_i_4_n_0 ),
        .I4(p_0_in[0]),
        .I5(p_0_in[1]),
        .O(q_cmd));
  LUT6 #(
    .INIT(64'hFFFFFFEF300000E0)) 
    \q_cmd[1]_i_1 
       (.I0(data_now__95[9]),
        .I1(p_0_in[2]),
        .I2(\q_cmd[2]_i_4_n_0 ),
        .I3(p_0_in[0]),
        .I4(p_0_in[1]),
        .I5(\q_cmd_reg_n_0_[1] ),
        .O(\q_cmd[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \q_cmd[1]_i_2 
       (.I0(w_data[9]),
        .I1(w_have_reg_n_0),
        .I2(s_axi_wdata[9]),
        .O(data_now__95[9]));
  LUT6 #(
    .INIT(64'hCFFFFFEF000000E0)) 
    \q_cmd[2]_i_1 
       (.I0(data_now__95[10]),
        .I1(p_0_in[2]),
        .I2(\q_cmd[2]_i_4_n_0 ),
        .I3(p_0_in[0]),
        .I4(p_0_in[1]),
        .I5(\q_cmd_reg_n_0_[2] ),
        .O(\q_cmd[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \q_cmd[2]_i_2 
       (.I0(w_data[10]),
        .I1(w_have_reg_n_0),
        .I2(s_axi_wdata[10]),
        .O(data_now__95[10]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \q_cmd[2]_i_3 
       (.I0(aw_addr[4]),
        .I1(aw_have),
        .I2(s_axi_awaddr[2]),
        .O(p_0_in[2]));
  LUT4 #(
    .INIT(16'h02A2)) 
    \q_cmd[2]_i_4 
       (.I0(do_write),
        .I1(s_axi_awaddr[3]),
        .I2(aw_have),
        .I3(aw_addr[5]),
        .O(\q_cmd[2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \q_cmd[2]_i_5 
       (.I0(aw_addr[2]),
        .I1(aw_have),
        .I2(s_axi_awaddr[0]),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \q_cmd[2]_i_6 
       (.I0(aw_addr[3]),
        .I1(aw_have),
        .I2(s_axi_awaddr[1]),
        .O(p_0_in[1]));
  FDRE \q_cmd_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\q_cmd[0]_i_1_n_0 ),
        .Q(\q_cmd_reg_n_0_[0] ),
        .R(rst));
  FDRE \q_cmd_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\q_cmd[1]_i_1_n_0 ),
        .Q(\q_cmd_reg_n_0_[1] ),
        .R(rst));
  FDRE \q_cmd_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\q_cmd[2]_i_1_n_0 ),
        .Q(\q_cmd_reg_n_0_[2] ),
        .R(rst));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[0]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[8]),
        .I3(\q_data_reg_n_0_[16] ),
        .I4(\q_data[0]_i_2_n_0 ),
        .O(p_1_in[0]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[0]_i_2 
       (.I0(w_data[0]),
        .I1(s_axi_wdata[0]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0CCAAAA)) 
    \q_data[10]_i_1 
       (.I0(data_now__95[10]),
        .I1(\q_data_reg_n_0_[18] ),
        .I2(\q_data_reg_n_0_[26] ),
        .I3(q_pair),
        .I4(step),
        .O(p_1_in[10]));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[11]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\q_data_reg_n_0_[19] ),
        .I3(\q_data_reg_n_0_[27] ),
        .I4(\q_data[11]_i_2_n_0 ),
        .O(p_1_in[11]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[11]_i_2 
       (.I0(w_data[11]),
        .I1(s_axi_wdata[11]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[12]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\q_data_reg_n_0_[20] ),
        .I3(\q_data_reg_n_0_[28] ),
        .I4(\q_data[12]_i_2_n_0 ),
        .O(p_1_in[12]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[12]_i_2 
       (.I0(w_data[12]),
        .I1(s_axi_wdata[12]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[13]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\q_data_reg_n_0_[21] ),
        .I3(\q_data_reg_n_0_[29] ),
        .I4(\q_data[13]_i_2_n_0 ),
        .O(p_1_in[13]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[13]_i_2 
       (.I0(w_data[13]),
        .I1(s_axi_wdata[13]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[14]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\q_data_reg_n_0_[22] ),
        .I3(\q_data_reg_n_0_[30] ),
        .I4(\q_data[14]_i_2_n_0 ),
        .O(p_1_in[14]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[14]_i_2 
       (.I0(w_data[14]),
        .I1(s_axi_wdata[14]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[15]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\q_data_reg_n_0_[23] ),
        .I3(\q_data_reg_n_0_[31] ),
        .I4(\q_data[15]_i_2_n_0 ),
        .O(p_1_in[15]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[15]_i_2 
       (.I0(w_data[15]),
        .I1(s_axi_wdata[15]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[15]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[16]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[16]),
        .I2(w_data[16]),
        .I3(\q_data_reg_n_0_[24] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[16]));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[17]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[17]),
        .I2(w_data[17]),
        .I3(\q_data_reg_n_0_[25] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[17]));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[18]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[18]),
        .I2(w_data[18]),
        .I3(\q_data_reg_n_0_[26] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[18]));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[19]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[19]),
        .I2(w_data[19]),
        .I3(\q_data_reg_n_0_[27] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[19]));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[1]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[9]),
        .I3(\q_data_reg_n_0_[17] ),
        .I4(\q_data[1]_i_2_n_0 ),
        .O(p_1_in[1]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[1]_i_2 
       (.I0(w_data[1]),
        .I1(s_axi_wdata[1]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[20]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[20]),
        .I2(w_data[20]),
        .I3(\q_data_reg_n_0_[28] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[20]));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[21]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[21]),
        .I2(w_data[21]),
        .I3(\q_data_reg_n_0_[29] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[21]));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[22]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[22]),
        .I2(w_data[22]),
        .I3(\q_data_reg_n_0_[30] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[22]));
  LUT6 #(
    .INIT(64'h0000E4E4FF00E4E4)) 
    \q_data[23]_i_1 
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wdata[23]),
        .I2(w_data[23]),
        .I3(\q_data_reg_n_0_[31] ),
        .I4(step),
        .I5(q_pair),
        .O(p_1_in[23]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[24]_i_1 
       (.I0(w_data[24]),
        .I1(s_axi_wdata[24]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[24]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[25]_i_1 
       (.I0(w_data[25]),
        .I1(s_axi_wdata[25]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[25]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[26]_i_1 
       (.I0(w_data[26]),
        .I1(s_axi_wdata[26]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[26]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[27]_i_1 
       (.I0(w_data[27]),
        .I1(s_axi_wdata[27]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[27]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[28]_i_1 
       (.I0(w_data[28]),
        .I1(s_axi_wdata[28]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[28]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[29]_i_1 
       (.I0(w_data[29]),
        .I1(s_axi_wdata[29]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[29]));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[2]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[10]),
        .I3(\q_data_reg_n_0_[18] ),
        .I4(\q_data[2]_i_2_n_0 ),
        .O(p_1_in[2]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[2]_i_2 
       (.I0(w_data[2]),
        .I1(s_axi_wdata[2]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[30]_i_1 
       (.I0(w_data[30]),
        .I1(s_axi_wdata[30]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[30]));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \q_data[31]_i_1 
       (.I0(\q_n_reg_n_0_[2] ),
        .I1(\q_n_reg_n_0_[1] ),
        .I2(\q_n_reg_n_0_[0] ),
        .I3(do_write),
        .O(\q_data[31]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[31]_i_2 
       (.I0(w_data[31]),
        .I1(s_axi_wdata[31]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(p_1_in[31]));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[3]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[11]),
        .I3(\q_data_reg_n_0_[19] ),
        .I4(\q_data[3]_i_2_n_0 ),
        .O(p_1_in[3]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[3]_i_2 
       (.I0(w_data[3]),
        .I1(s_axi_wdata[3]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[4]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[12]),
        .I3(\q_data_reg_n_0_[20] ),
        .I4(\q_data[4]_i_2_n_0 ),
        .O(p_1_in[4]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[4]_i_2 
       (.I0(w_data[4]),
        .I1(s_axi_wdata[4]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[5]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[13]),
        .I3(\q_data_reg_n_0_[21] ),
        .I4(\q_data[5]_i_2_n_0 ),
        .O(p_1_in[5]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[5]_i_2 
       (.I0(w_data[5]),
        .I1(s_axi_wdata[5]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[6]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[14]),
        .I3(\q_data_reg_n_0_[22] ),
        .I4(\q_data[6]_i_2_n_0 ),
        .O(p_1_in[6]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[6]_i_2 
       (.I0(w_data[6]),
        .I1(s_axi_wdata[6]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFC840)) 
    \q_data[7]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(q_data[15]),
        .I3(\q_data_reg_n_0_[23] ),
        .I4(\q_data[7]_i_2_n_0 ),
        .O(p_1_in[7]));
  LUT6 #(
    .INIT(64'h00000000000000AC)) 
    \q_data[7]_i_2 
       (.I0(w_data[7]),
        .I1(s_axi_wdata[7]),
        .I2(w_have_reg_n_0),
        .I3(\q_n_reg_n_0_[2] ),
        .I4(\q_n_reg_n_0_[1] ),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_data[7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hF0CCAAAA)) 
    \q_data[8]_i_1 
       (.I0(data_now__95[8]),
        .I1(\q_data_reg_n_0_[16] ),
        .I2(\q_data_reg_n_0_[24] ),
        .I3(q_pair),
        .I4(step),
        .O(p_1_in[8]));
  LUT3 #(
    .INIT(8'hB8)) 
    \q_data[8]_i_2 
       (.I0(w_data[8]),
        .I1(w_have_reg_n_0),
        .I2(s_axi_wdata[8]),
        .O(data_now__95[8]));
  LUT5 #(
    .INIT(32'hF0CCAAAA)) 
    \q_data[9]_i_1 
       (.I0(data_now__95[9]),
        .I1(\q_data_reg_n_0_[17] ),
        .I2(\q_data_reg_n_0_[25] ),
        .I3(q_pair),
        .I4(step),
        .O(p_1_in[9]));
  FDRE \q_data_reg[0] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[0]),
        .Q(q_data[0]),
        .R(rst));
  FDRE \q_data_reg[10] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[10]),
        .Q(q_data[10]),
        .R(rst));
  FDRE \q_data_reg[11] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[11]),
        .Q(q_data[11]),
        .R(rst));
  FDRE \q_data_reg[12] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[12]),
        .Q(q_data[12]),
        .R(rst));
  FDRE \q_data_reg[13] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[13]),
        .Q(q_data[13]),
        .R(rst));
  FDRE \q_data_reg[14] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[14]),
        .Q(q_data[14]),
        .R(rst));
  FDRE \q_data_reg[15] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[15]),
        .Q(q_data[15]),
        .R(rst));
  FDRE \q_data_reg[16] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[16]),
        .Q(\q_data_reg_n_0_[16] ),
        .R(rst));
  FDRE \q_data_reg[17] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[17]),
        .Q(\q_data_reg_n_0_[17] ),
        .R(rst));
  FDRE \q_data_reg[18] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[18]),
        .Q(\q_data_reg_n_0_[18] ),
        .R(rst));
  FDRE \q_data_reg[19] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[19]),
        .Q(\q_data_reg_n_0_[19] ),
        .R(rst));
  FDRE \q_data_reg[1] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[1]),
        .Q(q_data[1]),
        .R(rst));
  FDRE \q_data_reg[20] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[20]),
        .Q(\q_data_reg_n_0_[20] ),
        .R(rst));
  FDRE \q_data_reg[21] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[21]),
        .Q(\q_data_reg_n_0_[21] ),
        .R(rst));
  FDRE \q_data_reg[22] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[22]),
        .Q(\q_data_reg_n_0_[22] ),
        .R(rst));
  FDRE \q_data_reg[23] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[23]),
        .Q(\q_data_reg_n_0_[23] ),
        .R(rst));
  FDRE \q_data_reg[24] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[24]),
        .Q(\q_data_reg_n_0_[24] ),
        .R(rst));
  FDRE \q_data_reg[25] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[25]),
        .Q(\q_data_reg_n_0_[25] ),
        .R(rst));
  FDRE \q_data_reg[26] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[26]),
        .Q(\q_data_reg_n_0_[26] ),
        .R(rst));
  FDRE \q_data_reg[27] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[27]),
        .Q(\q_data_reg_n_0_[27] ),
        .R(rst));
  FDRE \q_data_reg[28] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[28]),
        .Q(\q_data_reg_n_0_[28] ),
        .R(rst));
  FDRE \q_data_reg[29] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[29]),
        .Q(\q_data_reg_n_0_[29] ),
        .R(rst));
  FDRE \q_data_reg[2] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[2]),
        .Q(q_data[2]),
        .R(rst));
  FDRE \q_data_reg[30] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[30]),
        .Q(\q_data_reg_n_0_[30] ),
        .R(rst));
  FDRE \q_data_reg[31] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[31]),
        .Q(\q_data_reg_n_0_[31] ),
        .R(rst));
  FDRE \q_data_reg[3] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[3]),
        .Q(q_data[3]),
        .R(rst));
  FDRE \q_data_reg[4] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[4]),
        .Q(q_data[4]),
        .R(rst));
  FDRE \q_data_reg[5] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[5]),
        .Q(q_data[5]),
        .R(rst));
  FDRE \q_data_reg[6] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[6]),
        .Q(q_data[6]),
        .R(rst));
  FDRE \q_data_reg[7] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[7]),
        .Q(q_data[7]),
        .R(rst));
  FDRE \q_data_reg[8] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[8]),
        .Q(q_data[8]),
        .R(rst));
  FDRE \q_data_reg[9] 
       (.C(s_axi_aclk),
        .CE(\q_data[31]_i_1_n_0 ),
        .D(p_1_in[9]),
        .Q(q_data[9]),
        .R(rst));
  LUT6 #(
    .INIT(64'h51555115AAAEAAAE)) 
    \q_n[0]_i_1 
       (.I0(step),
        .I1(\q_cmd[2]_i_4_n_0 ),
        .I2(p_0_in[2]),
        .I3(p_0_in[1]),
        .I4(p_0_in[0]),
        .I5(\q_n_reg_n_0_[0] ),
        .O(\q_n[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hC2C2C3C2C2C2C2C2)) 
    \q_n[1]_i_1 
       (.I0(\q_n_reg_n_0_[2] ),
        .I1(\q_n_reg_n_0_[1] ),
        .I2(\q_n_reg_n_0_[0] ),
        .I3(q_pair4_out),
        .I4(p_0_in[0]),
        .I5(p_0_in[1]),
        .O(\q_n[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1F111FFF00000000)) 
    \q_n[1]_i_2 
       (.I0(p_0_in[0]),
        .I1(p_0_in[1]),
        .I2(aw_addr[4]),
        .I3(aw_have),
        .I4(s_axi_awaddr[2]),
        .I5(\q_cmd[2]_i_4_n_0 ),
        .O(q_pair4_out));
  LUT6 #(
    .INIT(64'h8898888888889888)) 
    \q_n[2]_i_1 
       (.I0(\q_n_reg_n_0_[2] ),
        .I1(\q_n[2]_i_2_n_0 ),
        .I2(\q_cmd[2]_i_4_n_0 ),
        .I3(p_0_in[2]),
        .I4(p_0_in[1]),
        .I5(p_0_in[0]),
        .O(\q_n[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \q_n[2]_i_2 
       (.I0(\q_n_reg_n_0_[1] ),
        .I1(\q_n_reg_n_0_[0] ),
        .O(\q_n[2]_i_2_n_0 ));
  FDRE \q_n_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\q_n[0]_i_1_n_0 ),
        .Q(\q_n_reg_n_0_[0] ),
        .R(rst));
  FDRE \q_n_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\q_n[1]_i_1_n_0 ),
        .Q(\q_n_reg_n_0_[1] ),
        .R(rst));
  FDRE \q_n_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\q_n[2]_i_1_n_0 ),
        .Q(\q_n_reg_n_0_[2] ),
        .R(rst));
  LUT5 #(
    .INIT(32'hE6FF0600)) 
    q_pair_i_1
       (.I0(p_0_in[0]),
        .I1(p_0_in[1]),
        .I2(p_0_in[2]),
        .I3(\q_cmd[2]_i_4_n_0 ),
        .I4(q_pair),
        .O(q_pair_i_1_n_0));
  FDRE q_pair_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(q_pair_i_1_n_0),
        .Q(q_pair),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000000000004)) 
    s_axi_arready_i_1
       (.I0(s_axi_rvalid),
        .I1(s_axi_arvalid),
        .I2(s_axi_arready_reg_0),
        .I3(step),
        .I4(cool[1]),
        .I5(cool[0]),
        .O(s_axi_arready0));
  FDRE s_axi_arready_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_arready0),
        .Q(s_axi_arready_reg_0),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000100010001)) 
    s_axi_awready_i_2
       (.I0(do_write),
        .I1(s_axi_bvalid_reg_0),
        .I2(b_pend),
        .I3(aw_have),
        .I4(s_axi_awvalid),
        .I5(s_axi_awready_reg_0),
        .O(s_axi_awready0));
  LUT6 #(
    .INIT(64'h000E000000000000)) 
    s_axi_awready_i_3
       (.I0(w_take),
        .I1(w_have_reg_n_0),
        .I2(b_pend),
        .I3(s_axi_bvalid_reg_0),
        .I4(aw_now__0),
        .I5(do_write0__0),
        .O(do_write));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT3 #(
    .INIT(8'hF8)) 
    s_axi_awready_i_4
       (.I0(s_axi_awready_reg_0),
        .I1(s_axi_awvalid),
        .I2(aw_have),
        .O(aw_now__0));
  FDRE s_axi_awready_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_awready0),
        .Q(s_axi_awready_reg_0),
        .R(rst));
  LUT6 #(
    .INIT(64'hF000F0000080F080)) 
    s_axi_bvalid_i_1
       (.I0(b_pend),
        .I1(do_write0__0),
        .I2(s_axi_aresetn),
        .I3(s_axi_bvalid_reg_0),
        .I4(s_axi_bready),
        .I5(do_write),
        .O(s_axi_bvalid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT5 #(
    .INIT(32'h00000001)) 
    s_axi_bvalid_i_2
       (.I0(cool[0]),
        .I1(cool[1]),
        .I2(\q_n_reg_n_0_[2] ),
        .I3(\q_n_reg_n_0_[1] ),
        .I4(\q_n_reg_n_0_[0] ),
        .O(do_write0__0));
  FDRE s_axi_bvalid_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_bvalid_i_1_n_0),
        .Q(s_axi_bvalid_reg_0),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT3 #(
    .INIT(8'hC7)) 
    \s_axi_rdata[0]_i_3 
       (.I0(steps_reg[0]),
        .I1(s_axi_araddr[3]),
        .I2(s_axi_araddr[2]),
        .O(\s_axi_rdata[0]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    \s_axi_rdata[19]_i_2 
       (.I0(s_axi_araddr[3]),
        .I1(s_axi_araddr[0]),
        .I2(s_axi_araddr[1]),
        .I3(s_axi_araddr[2]),
        .O(\s_axi_rdata[19]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT4 #(
    .INIT(16'h0400)) 
    \s_axi_rdata[19]_i_3 
       (.I0(s_axi_araddr[3]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[1]),
        .I3(s_axi_araddr[0]),
        .O(\s_axi_rdata[19]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT4 #(
    .INIT(16'h0400)) 
    \s_axi_rdata[19]_i_4 
       (.I0(s_axi_araddr[2]),
        .I1(s_axi_araddr[3]),
        .I2(s_axi_araddr[1]),
        .I3(s_axi_araddr[0]),
        .O(\s_axi_rdata[19]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT3 #(
    .INIT(8'hC7)) 
    \s_axi_rdata[1]_i_3 
       (.I0(steps_reg[1]),
        .I1(s_axi_araddr[3]),
        .I2(s_axi_araddr[2]),
        .O(\s_axi_rdata[1]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT3 #(
    .INIT(8'hC7)) 
    \s_axi_rdata[2]_i_3 
       (.I0(steps_reg[2]),
        .I1(s_axi_araddr[3]),
        .I2(s_axi_araddr[2]),
        .O(\s_axi_rdata[2]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \s_axi_rdata[31]_i_1 
       (.I0(s_axi_arvalid),
        .I1(s_axi_arready_reg_0),
        .O(s_axi_rvalid06_out));
  LUT3 #(
    .INIT(8'hC7)) 
    \s_axi_rdata[6]_i_3 
       (.I0(steps_reg[6]),
        .I1(s_axi_araddr[3]),
        .I2(s_axi_araddr[2]),
        .O(\s_axi_rdata[6]_i_3_n_0 ));
  FDRE \s_axi_rdata_reg[0] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[0]),
        .Q(s_axi_rdata[0]),
        .R(rst));
  FDRE \s_axi_rdata_reg[10] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[10]),
        .Q(s_axi_rdata[10]),
        .R(rst));
  FDRE \s_axi_rdata_reg[11] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[11]),
        .Q(s_axi_rdata[11]),
        .R(rst));
  FDRE \s_axi_rdata_reg[12] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[12]),
        .Q(s_axi_rdata[12]),
        .R(rst));
  FDRE \s_axi_rdata_reg[13] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[13]),
        .Q(s_axi_rdata[13]),
        .R(rst));
  FDRE \s_axi_rdata_reg[14] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[14]),
        .Q(s_axi_rdata[14]),
        .R(rst));
  FDRE \s_axi_rdata_reg[15] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[15]),
        .Q(s_axi_rdata[15]),
        .R(rst));
  FDRE \s_axi_rdata_reg[16] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[16]),
        .Q(s_axi_rdata[16]),
        .R(rst));
  FDRE \s_axi_rdata_reg[17] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[17]),
        .Q(s_axi_rdata[17]),
        .R(rst));
  FDRE \s_axi_rdata_reg[18] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[18]),
        .Q(s_axi_rdata[18]),
        .R(rst));
  FDRE \s_axi_rdata_reg[19] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[19]),
        .Q(s_axi_rdata[19]),
        .R(rst));
  FDRE \s_axi_rdata_reg[1] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[1]),
        .Q(s_axi_rdata[1]),
        .R(rst));
  FDRE \s_axi_rdata_reg[20] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[20]),
        .Q(s_axi_rdata[20]),
        .R(rst));
  FDRE \s_axi_rdata_reg[21] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[21]),
        .Q(s_axi_rdata[21]),
        .R(rst));
  FDRE \s_axi_rdata_reg[22] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[22]),
        .Q(s_axi_rdata[22]),
        .R(rst));
  FDRE \s_axi_rdata_reg[23] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[23]),
        .Q(s_axi_rdata[23]),
        .R(rst));
  FDRE \s_axi_rdata_reg[24] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[24]),
        .Q(s_axi_rdata[24]),
        .R(rst));
  FDRE \s_axi_rdata_reg[25] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[25]),
        .Q(s_axi_rdata[25]),
        .R(rst));
  FDRE \s_axi_rdata_reg[26] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[26]),
        .Q(s_axi_rdata[26]),
        .R(rst));
  FDRE \s_axi_rdata_reg[27] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[27]),
        .Q(s_axi_rdata[27]),
        .R(rst));
  FDRE \s_axi_rdata_reg[28] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[28]),
        .Q(s_axi_rdata[28]),
        .R(rst));
  FDRE \s_axi_rdata_reg[29] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[29]),
        .Q(s_axi_rdata[29]),
        .R(rst));
  FDRE \s_axi_rdata_reg[2] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[2]),
        .Q(s_axi_rdata[2]),
        .R(rst));
  FDRE \s_axi_rdata_reg[30] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[30]),
        .Q(s_axi_rdata[30]),
        .R(rst));
  FDRE \s_axi_rdata_reg[31] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[31]),
        .Q(s_axi_rdata[31]),
        .R(rst));
  FDRE \s_axi_rdata_reg[3] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[3]),
        .Q(s_axi_rdata[3]),
        .R(rst));
  FDRE \s_axi_rdata_reg[4] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[4]),
        .Q(s_axi_rdata[4]),
        .R(rst));
  FDRE \s_axi_rdata_reg[5] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[5]),
        .Q(s_axi_rdata[5]),
        .R(rst));
  FDRE \s_axi_rdata_reg[6] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[6]),
        .Q(s_axi_rdata[6]),
        .R(rst));
  FDRE \s_axi_rdata_reg[7] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[7]),
        .Q(s_axi_rdata[7]),
        .R(rst));
  FDRE \s_axi_rdata_reg[8] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[8]),
        .Q(s_axi_rdata[8]),
        .R(rst));
  FDRE \s_axi_rdata_reg[9] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid06_out),
        .D(s_axi_rdata_70[9]),
        .Q(s_axi_rdata[9]),
        .R(rst));
  LUT4 #(
    .INIT(16'h8F88)) 
    s_axi_rvalid_i_1
       (.I0(s_axi_arready_reg_0),
        .I1(s_axi_arvalid),
        .I2(s_axi_rready),
        .I3(s_axi_rvalid),
        .O(s_axi_rvalid_i_1_n_0));
  FDRE s_axi_rvalid_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_rvalid_i_1_n_0),
        .Q(s_axi_rvalid),
        .R(rst));
  LUT6 #(
    .INIT(64'h0000000100010001)) 
    s_axi_wready_i_1
       (.I0(do_write),
        .I1(s_axi_bvalid_reg_0),
        .I2(b_pend),
        .I3(w_have_reg_n_0),
        .I4(s_axi_wvalid),
        .I5(s_axi_wready_reg_0),
        .O(s_axi_wready0));
  FDRE s_axi_wready_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_wready0),
        .Q(s_axi_wready_reg_0),
        .R(rst));
  LUT2 #(
    .INIT(4'h6)) 
    sel_i_1
       (.I0(u_core_n_4),
        .I1(sel0),
        .O(sel_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    \steps[0]_i_3 
       (.I0(steps_reg[0]),
        .O(\steps[0]_i_3_n_0 ));
  FDRE \steps_reg[0] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[0]_i_2_n_7 ),
        .Q(steps_reg[0]),
        .R(rst));
  CARRY4 \steps_reg[0]_i_2 
       (.CI(1'b0),
        .CO({\steps_reg[0]_i_2_n_0 ,\steps_reg[0]_i_2_n_1 ,\steps_reg[0]_i_2_n_2 ,\steps_reg[0]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\steps_reg[0]_i_2_n_4 ,\steps_reg[0]_i_2_n_5 ,\steps_reg[0]_i_2_n_6 ,\steps_reg[0]_i_2_n_7 }),
        .S({steps_reg[3:1],\steps[0]_i_3_n_0 }));
  FDRE \steps_reg[10] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[8]_i_1_n_5 ),
        .Q(steps_reg[10]),
        .R(rst));
  FDRE \steps_reg[11] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[8]_i_1_n_4 ),
        .Q(steps_reg[11]),
        .R(rst));
  FDRE \steps_reg[12] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[12]_i_1_n_7 ),
        .Q(steps_reg[12]),
        .R(rst));
  CARRY4 \steps_reg[12]_i_1 
       (.CI(\steps_reg[8]_i_1_n_0 ),
        .CO({\steps_reg[12]_i_1_n_0 ,\steps_reg[12]_i_1_n_1 ,\steps_reg[12]_i_1_n_2 ,\steps_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[12]_i_1_n_4 ,\steps_reg[12]_i_1_n_5 ,\steps_reg[12]_i_1_n_6 ,\steps_reg[12]_i_1_n_7 }),
        .S(steps_reg[15:12]));
  FDRE \steps_reg[13] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[12]_i_1_n_6 ),
        .Q(steps_reg[13]),
        .R(rst));
  FDRE \steps_reg[14] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[12]_i_1_n_5 ),
        .Q(steps_reg[14]),
        .R(rst));
  FDRE \steps_reg[15] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[12]_i_1_n_4 ),
        .Q(steps_reg[15]),
        .R(rst));
  FDRE \steps_reg[16] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[16]_i_1_n_7 ),
        .Q(steps_reg[16]),
        .R(rst));
  CARRY4 \steps_reg[16]_i_1 
       (.CI(\steps_reg[12]_i_1_n_0 ),
        .CO({\steps_reg[16]_i_1_n_0 ,\steps_reg[16]_i_1_n_1 ,\steps_reg[16]_i_1_n_2 ,\steps_reg[16]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[16]_i_1_n_4 ,\steps_reg[16]_i_1_n_5 ,\steps_reg[16]_i_1_n_6 ,\steps_reg[16]_i_1_n_7 }),
        .S(steps_reg[19:16]));
  FDRE \steps_reg[17] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[16]_i_1_n_6 ),
        .Q(steps_reg[17]),
        .R(rst));
  FDRE \steps_reg[18] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[16]_i_1_n_5 ),
        .Q(steps_reg[18]),
        .R(rst));
  FDRE \steps_reg[19] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[16]_i_1_n_4 ),
        .Q(steps_reg[19]),
        .R(rst));
  FDRE \steps_reg[1] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[0]_i_2_n_6 ),
        .Q(steps_reg[1]),
        .R(rst));
  FDRE \steps_reg[20] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[20]_i_1_n_7 ),
        .Q(steps_reg[20]),
        .R(rst));
  CARRY4 \steps_reg[20]_i_1 
       (.CI(\steps_reg[16]_i_1_n_0 ),
        .CO({\steps_reg[20]_i_1_n_0 ,\steps_reg[20]_i_1_n_1 ,\steps_reg[20]_i_1_n_2 ,\steps_reg[20]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[20]_i_1_n_4 ,\steps_reg[20]_i_1_n_5 ,\steps_reg[20]_i_1_n_6 ,\steps_reg[20]_i_1_n_7 }),
        .S(steps_reg[23:20]));
  FDRE \steps_reg[21] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[20]_i_1_n_6 ),
        .Q(steps_reg[21]),
        .R(rst));
  FDRE \steps_reg[22] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[20]_i_1_n_5 ),
        .Q(steps_reg[22]),
        .R(rst));
  FDRE \steps_reg[23] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[20]_i_1_n_4 ),
        .Q(steps_reg[23]),
        .R(rst));
  FDRE \steps_reg[24] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[24]_i_1_n_7 ),
        .Q(steps_reg[24]),
        .R(rst));
  CARRY4 \steps_reg[24]_i_1 
       (.CI(\steps_reg[20]_i_1_n_0 ),
        .CO({\steps_reg[24]_i_1_n_0 ,\steps_reg[24]_i_1_n_1 ,\steps_reg[24]_i_1_n_2 ,\steps_reg[24]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[24]_i_1_n_4 ,\steps_reg[24]_i_1_n_5 ,\steps_reg[24]_i_1_n_6 ,\steps_reg[24]_i_1_n_7 }),
        .S(steps_reg[27:24]));
  FDRE \steps_reg[25] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[24]_i_1_n_6 ),
        .Q(steps_reg[25]),
        .R(rst));
  FDRE \steps_reg[26] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[24]_i_1_n_5 ),
        .Q(steps_reg[26]),
        .R(rst));
  FDRE \steps_reg[27] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[24]_i_1_n_4 ),
        .Q(steps_reg[27]),
        .R(rst));
  FDRE \steps_reg[28] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[28]_i_1_n_7 ),
        .Q(steps_reg[28]),
        .R(rst));
  CARRY4 \steps_reg[28]_i_1 
       (.CI(\steps_reg[24]_i_1_n_0 ),
        .CO({\NLW_steps_reg[28]_i_1_CO_UNCONNECTED [3],\steps_reg[28]_i_1_n_1 ,\steps_reg[28]_i_1_n_2 ,\steps_reg[28]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[28]_i_1_n_4 ,\steps_reg[28]_i_1_n_5 ,\steps_reg[28]_i_1_n_6 ,\steps_reg[28]_i_1_n_7 }),
        .S(steps_reg[31:28]));
  FDRE \steps_reg[29] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[28]_i_1_n_6 ),
        .Q(steps_reg[29]),
        .R(rst));
  FDRE \steps_reg[2] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[0]_i_2_n_5 ),
        .Q(steps_reg[2]),
        .R(rst));
  FDRE \steps_reg[30] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[28]_i_1_n_5 ),
        .Q(steps_reg[30]),
        .R(rst));
  FDRE \steps_reg[31] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[28]_i_1_n_4 ),
        .Q(steps_reg[31]),
        .R(rst));
  FDRE \steps_reg[3] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[0]_i_2_n_4 ),
        .Q(steps_reg[3]),
        .R(rst));
  FDRE \steps_reg[4] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[4]_i_1_n_7 ),
        .Q(steps_reg[4]),
        .R(rst));
  CARRY4 \steps_reg[4]_i_1 
       (.CI(\steps_reg[0]_i_2_n_0 ),
        .CO({\steps_reg[4]_i_1_n_0 ,\steps_reg[4]_i_1_n_1 ,\steps_reg[4]_i_1_n_2 ,\steps_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[4]_i_1_n_4 ,\steps_reg[4]_i_1_n_5 ,\steps_reg[4]_i_1_n_6 ,\steps_reg[4]_i_1_n_7 }),
        .S(steps_reg[7:4]));
  FDRE \steps_reg[5] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[4]_i_1_n_6 ),
        .Q(steps_reg[5]),
        .R(rst));
  FDRE \steps_reg[6] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[4]_i_1_n_5 ),
        .Q(steps_reg[6]),
        .R(rst));
  FDRE \steps_reg[7] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[4]_i_1_n_4 ),
        .Q(steps_reg[7]),
        .R(rst));
  FDRE \steps_reg[8] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[8]_i_1_n_7 ),
        .Q(steps_reg[8]),
        .R(rst));
  CARRY4 \steps_reg[8]_i_1 
       (.CI(\steps_reg[4]_i_1_n_0 ),
        .CO({\steps_reg[8]_i_1_n_0 ,\steps_reg[8]_i_1_n_1 ,\steps_reg[8]_i_1_n_2 ,\steps_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\steps_reg[8]_i_1_n_4 ,\steps_reg[8]_i_1_n_5 ,\steps_reg[8]_i_1_n_6 ,\steps_reg[8]_i_1_n_7 }),
        .S(steps_reg[11:8]));
  FDRE \steps_reg[9] 
       (.C(s_axi_aclk),
        .CE(step),
        .D(\steps_reg[8]_i_1_n_6 ),
        .Q(steps_reg[9]),
        .R(rst));
  system_tpu_0_tiny_tpu_v2_core u_core
       (.CO(CO),
        .D(s_axi_rdata_70),
        .E(u_core_n_6),
        .O(s0),
        .Q(q_data),
        .\acc0_reg[11]_i_2_0 (\acc0_reg[11]_i_2 ),
        .\acc0_reg[15]_0 (O),
        .\acc0_reg[15]_i_2_0 (\acc0_reg[15]_i_2 ),
        .\acc0_reg[20]_0 (u_core_n_38),
        .\acc0_reg[21]_0 (\q_n_reg_n_0_[0] ),
        .\acc0_reg[21]_1 (\q_n_reg_n_0_[1] ),
        .\acc0_reg[21]_2 (\q_n_reg_n_0_[2] ),
        .\acc0_reg[7]_i_2_0 (\acc0_reg[7]_i_2 ),
        .\acc1_reg[11]_i_2_0 (\acc1_reg[11]_i_2 ),
        .\acc1_reg[15]_0 (\acc1_reg[15] ),
        .\acc1_reg[15]_i_2_0 (\acc1_reg[15]_i_2 ),
        .\acc1_reg[7]_i_2_0 (\acc1_reg[7]_i_2 ),
        .ovf0(ovf0),
        .ovf0_reg_0(ovf0_i_1_n_0),
        .ovf10_out(ovf10_out),
        .\ptr_reg[0]_rep_0 (\q_cmd_reg_n_0_[1] ),
        .\ptr_reg[0]_rep_1 (\q_cmd_reg_n_0_[0] ),
        .\ptr_reg[0]_rep_2 (\q_cmd_reg_n_0_[2] ),
        .\q_data_reg[0] (\q_data_reg[0]_0 ),
        .\q_data_reg[10] (\q_data_reg[10]_0 ),
        .\q_data_reg[10]_0 (\q_data_reg[10]_1 ),
        .\q_data_reg[10]_1 (\q_data_reg[10]_2 ),
        .\q_data_reg[11] (\q_data_reg[11]_0 ),
        .\q_data_reg[13] (\q_data_reg[13]_0 ),
        .\q_data_reg[13]_0 (\q_data_reg[13]_1 ),
        .\q_data_reg[13]_1 (\q_data_reg[13]_2 ),
        .\q_data_reg[14] (\q_data_reg[14]_0 ),
        .\q_data_reg[15] (\q_data_reg[15]_0 ),
        .\q_data_reg[15]_0 (\q_data_reg[15]_1 ),
        .\q_data_reg[2] (\q_data_reg[2]_0 ),
        .\q_data_reg[2]_0 (\q_data_reg[2]_1 ),
        .\q_data_reg[3] (\q_data_reg[3]_0 ),
        .\q_data_reg[5] (\q_data_reg[5]_0 ),
        .\q_data_reg[5]_0 (\q_data_reg[5]_1 ),
        .\q_data_reg[5]_1 (\q_data_reg[5]_2 ),
        .\q_data_reg[6] (\q_data_reg[6]_0 ),
        .\q_data_reg[7] (\q_data_reg[7]_0 ),
        .\q_data_reg[7]_0 (\q_data_reg[7]_1 ),
        .\q_data_reg[8] (\q_data_reg[8]_0 ),
        .\q_n_reg[0] (u_core_n_7),
        .q_pair(q_pair),
        .q_pair_reg(u_core_n_4),
        .rst(rst),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_aresetn(s_axi_aresetn),
        .\s_axi_rdata_reg[0] (\s_axi_rdata[0]_i_3_n_0 ),
        .\s_axi_rdata_reg[1] (\s_axi_rdata[1]_i_3_n_0 ),
        .\s_axi_rdata_reg[2] (\s_axi_rdata[2]_i_3_n_0 ),
        .\s_axi_rdata_reg[6] (\s_axi_rdata[6]_i_3_n_0 ),
        .\s_axi_rdata_reg[7] (\s_axi_rdata[19]_i_2_n_0 ),
        .\s_axi_rdata_reg[7]_0 (\s_axi_rdata[19]_i_3_n_0 ),
        .\s_axi_rdata_reg[7]_1 (\s_axi_rdata[19]_i_4_n_0 ),
        .sel0(sel0),
        .sel_reg_0(sel_i_1_n_0),
        .step(step),
        .steps_reg({steps_reg[31:7],steps_reg[5:3]}));
  LUT2 #(
    .INIT(4'h8)) 
    \w_data[31]_i_1 
       (.I0(s_axi_wvalid),
        .I1(s_axi_wready_reg_0),
        .O(w_take));
  FDRE \w_data_reg[0] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[0]),
        .Q(w_data[0]),
        .R(rst));
  FDRE \w_data_reg[10] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[10]),
        .Q(w_data[10]),
        .R(rst));
  FDRE \w_data_reg[11] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[11]),
        .Q(w_data[11]),
        .R(rst));
  FDRE \w_data_reg[12] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[12]),
        .Q(w_data[12]),
        .R(rst));
  FDRE \w_data_reg[13] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[13]),
        .Q(w_data[13]),
        .R(rst));
  FDRE \w_data_reg[14] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[14]),
        .Q(w_data[14]),
        .R(rst));
  FDRE \w_data_reg[15] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[15]),
        .Q(w_data[15]),
        .R(rst));
  FDRE \w_data_reg[16] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[16]),
        .Q(w_data[16]),
        .R(rst));
  FDRE \w_data_reg[17] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[17]),
        .Q(w_data[17]),
        .R(rst));
  FDRE \w_data_reg[18] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[18]),
        .Q(w_data[18]),
        .R(rst));
  FDRE \w_data_reg[19] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[19]),
        .Q(w_data[19]),
        .R(rst));
  FDRE \w_data_reg[1] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[1]),
        .Q(w_data[1]),
        .R(rst));
  FDRE \w_data_reg[20] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[20]),
        .Q(w_data[20]),
        .R(rst));
  FDRE \w_data_reg[21] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[21]),
        .Q(w_data[21]),
        .R(rst));
  FDRE \w_data_reg[22] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[22]),
        .Q(w_data[22]),
        .R(rst));
  FDRE \w_data_reg[23] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[23]),
        .Q(w_data[23]),
        .R(rst));
  FDRE \w_data_reg[24] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[24]),
        .Q(w_data[24]),
        .R(rst));
  FDRE \w_data_reg[25] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[25]),
        .Q(w_data[25]),
        .R(rst));
  FDRE \w_data_reg[26] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[26]),
        .Q(w_data[26]),
        .R(rst));
  FDRE \w_data_reg[27] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[27]),
        .Q(w_data[27]),
        .R(rst));
  FDRE \w_data_reg[28] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[28]),
        .Q(w_data[28]),
        .R(rst));
  FDRE \w_data_reg[29] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[29]),
        .Q(w_data[29]),
        .R(rst));
  FDRE \w_data_reg[2] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[2]),
        .Q(w_data[2]),
        .R(rst));
  FDRE \w_data_reg[30] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[30]),
        .Q(w_data[30]),
        .R(rst));
  FDRE \w_data_reg[31] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[31]),
        .Q(w_data[31]),
        .R(rst));
  FDRE \w_data_reg[3] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[3]),
        .Q(w_data[3]),
        .R(rst));
  FDRE \w_data_reg[4] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[4]),
        .Q(w_data[4]),
        .R(rst));
  FDRE \w_data_reg[5] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[5]),
        .Q(w_data[5]),
        .R(rst));
  FDRE \w_data_reg[6] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[6]),
        .Q(w_data[6]),
        .R(rst));
  FDRE \w_data_reg[7] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[7]),
        .Q(w_data[7]),
        .R(rst));
  FDRE \w_data_reg[8] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[8]),
        .Q(w_data[8]),
        .R(rst));
  FDRE \w_data_reg[9] 
       (.C(s_axi_aclk),
        .CE(w_take),
        .D(s_axi_wdata[9]),
        .Q(w_data[9]),
        .R(rst));
  LUT5 #(
    .INIT(32'h0000EA00)) 
    w_have_i_1
       (.I0(w_have_reg_n_0),
        .I1(s_axi_wvalid),
        .I2(s_axi_wready_reg_0),
        .I3(s_axi_aresetn),
        .I4(do_write),
        .O(w_have_i_1_n_0));
  FDRE w_have_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(w_have_i_1_n_0),
        .Q(w_have_reg_n_0),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "tiny_tpu_v2_core" *) 
module system_tpu_0_tiny_tpu_v2_core
   (rst,
    sel0,
    ovf0,
    step,
    q_pair_reg,
    ovf10_out,
    E,
    \q_n_reg[0] ,
    O,
    \q_data_reg[0] ,
    \q_data_reg[2] ,
    CO,
    \q_data_reg[2]_0 ,
    \q_data_reg[3] ,
    \q_data_reg[5] ,
    \q_data_reg[5]_0 ,
    \q_data_reg[5]_1 ,
    \q_data_reg[7] ,
    \q_data_reg[6] ,
    \q_data_reg[7]_0 ,
    \acc0_reg[20]_0 ,
    \q_data_reg[8] ,
    \q_data_reg[10] ,
    \q_data_reg[10]_0 ,
    \q_data_reg[10]_1 ,
    \q_data_reg[11] ,
    \q_data_reg[13] ,
    \q_data_reg[13]_0 ,
    \q_data_reg[13]_1 ,
    \q_data_reg[15] ,
    \q_data_reg[14] ,
    \q_data_reg[15]_0 ,
    D,
    Q,
    s_axi_aclk,
    sel_reg_0,
    ovf0_reg_0,
    \ptr_reg[0]_rep_0 ,
    \ptr_reg[0]_rep_1 ,
    q_pair,
    \ptr_reg[0]_rep_2 ,
    \acc0_reg[21]_0 ,
    \acc0_reg[21]_1 ,
    \acc0_reg[21]_2 ,
    \acc0_reg[15]_0 ,
    \acc1_reg[15]_0 ,
    \acc0_reg[7]_i_2_0 ,
    \acc0_reg[11]_i_2_0 ,
    \acc0_reg[15]_i_2_0 ,
    \acc1_reg[7]_i_2_0 ,
    \acc1_reg[11]_i_2_0 ,
    \acc1_reg[15]_i_2_0 ,
    s_axi_aresetn,
    s_axi_araddr,
    \s_axi_rdata_reg[0] ,
    \s_axi_rdata_reg[1] ,
    \s_axi_rdata_reg[2] ,
    \s_axi_rdata_reg[6] ,
    \s_axi_rdata_reg[7] ,
    \s_axi_rdata_reg[7]_0 ,
    steps_reg,
    \s_axi_rdata_reg[7]_1 );
  output rst;
  output [0:0]sel0;
  output ovf0;
  output step;
  output q_pair_reg;
  output ovf10_out;
  output [0:0]E;
  output \q_n_reg[0] ;
  output [0:0]O;
  output [0:0]\q_data_reg[0] ;
  output [3:0]\q_data_reg[2] ;
  output [0:0]CO;
  output [1:0]\q_data_reg[2]_0 ;
  output [3:0]\q_data_reg[3] ;
  output [3:0]\q_data_reg[5] ;
  output [0:0]\q_data_reg[5]_0 ;
  output [1:0]\q_data_reg[5]_1 ;
  output [3:0]\q_data_reg[7] ;
  output [3:0]\q_data_reg[6] ;
  output [1:0]\q_data_reg[7]_0 ;
  output [0:0]\acc0_reg[20]_0 ;
  output [0:0]\q_data_reg[8] ;
  output [3:0]\q_data_reg[10] ;
  output [0:0]\q_data_reg[10]_0 ;
  output [1:0]\q_data_reg[10]_1 ;
  output [3:0]\q_data_reg[11] ;
  output [3:0]\q_data_reg[13] ;
  output [0:0]\q_data_reg[13]_0 ;
  output [1:0]\q_data_reg[13]_1 ;
  output [3:0]\q_data_reg[15] ;
  output [3:0]\q_data_reg[14] ;
  output [1:0]\q_data_reg[15]_0 ;
  output [31:0]D;
  input [15:0]Q;
  input s_axi_aclk;
  input sel_reg_0;
  input ovf0_reg_0;
  input \ptr_reg[0]_rep_0 ;
  input \ptr_reg[0]_rep_1 ;
  input q_pair;
  input \ptr_reg[0]_rep_2 ;
  input \acc0_reg[21]_0 ;
  input \acc0_reg[21]_1 ;
  input \acc0_reg[21]_2 ;
  input [0:0]\acc0_reg[15]_0 ;
  input [0:0]\acc1_reg[15]_0 ;
  input [3:0]\acc0_reg[7]_i_2_0 ;
  input [3:0]\acc0_reg[11]_i_2_0 ;
  input [3:0]\acc0_reg[15]_i_2_0 ;
  input [3:0]\acc1_reg[7]_i_2_0 ;
  input [3:0]\acc1_reg[11]_i_2_0 ;
  input [3:0]\acc1_reg[15]_i_2_0 ;
  input s_axi_aresetn;
  input [3:0]s_axi_araddr;
  input \s_axi_rdata_reg[0] ;
  input \s_axi_rdata_reg[1] ;
  input \s_axi_rdata_reg[2] ;
  input \s_axi_rdata_reg[6] ;
  input \s_axi_rdata_reg[7] ;
  input \s_axi_rdata_reg[7]_0 ;
  input [27:0]steps_reg;
  input \s_axi_rdata_reg[7]_1 ;

  wire [24:0]A;
  wire CEP;
  wire [0:0]CO;
  wire [31:0]D;
  wire [0:0]E;
  wire [0:0]O;
  wire [15:0]Q;
  wire \acc0[0]_i_1_n_0 ;
  wire \acc0[10]_i_1_n_0 ;
  wire \acc0[11]_i_18_n_0 ;
  wire \acc0[11]_i_19_n_0 ;
  wire \acc0[11]_i_1_n_0 ;
  wire \acc0[11]_i_20_n_0 ;
  wire \acc0[11]_i_21_n_0 ;
  wire \acc0[11]_i_22_n_0 ;
  wire \acc0[11]_i_23_n_0 ;
  wire \acc0[11]_i_24_n_0 ;
  wire \acc0[11]_i_25_n_0 ;
  wire \acc0[11]_i_26_n_0 ;
  wire \acc0[11]_i_27_n_0 ;
  wire \acc0[11]_i_28_n_0 ;
  wire \acc0[11]_i_29_n_0 ;
  wire \acc0[11]_i_30_n_0 ;
  wire \acc0[11]_i_31_n_0 ;
  wire \acc0[11]_i_32_n_0 ;
  wire \acc0[11]_i_33_n_0 ;
  wire \acc0[11]_i_34_n_0 ;
  wire \acc0[11]_i_35_n_0 ;
  wire \acc0[11]_i_3_n_0 ;
  wire \acc0[11]_i_4_n_0 ;
  wire \acc0[11]_i_5_n_0 ;
  wire \acc0[11]_i_6_n_0 ;
  wire \acc0[12]_i_1_n_0 ;
  wire \acc0[13]_i_1_n_0 ;
  wire \acc0[14]_i_1_n_0 ;
  wire \acc0[15]_i_18_n_0 ;
  wire \acc0[15]_i_19_n_0 ;
  wire \acc0[15]_i_1_n_0 ;
  wire \acc0[15]_i_24_n_0 ;
  wire \acc0[15]_i_25_n_0 ;
  wire \acc0[15]_i_26_n_0 ;
  wire \acc0[15]_i_27_n_0 ;
  wire \acc0[15]_i_28_n_0 ;
  wire \acc0[15]_i_29_n_0 ;
  wire \acc0[15]_i_30_n_0 ;
  wire \acc0[15]_i_31_n_0 ;
  wire \acc0[15]_i_32_n_0 ;
  wire \acc0[15]_i_33_n_0 ;
  wire \acc0[15]_i_34_n_0 ;
  wire \acc0[15]_i_35_n_0 ;
  wire \acc0[15]_i_36_n_0 ;
  wire \acc0[15]_i_37_n_0 ;
  wire \acc0[15]_i_38_n_0 ;
  wire \acc0[15]_i_39_n_0 ;
  wire \acc0[15]_i_40_n_0 ;
  wire \acc0[15]_i_41_n_0 ;
  wire \acc0[15]_i_42_n_0 ;
  wire \acc0[15]_i_43_n_0 ;
  wire \acc0[15]_i_44_n_0 ;
  wire \acc0[15]_i_45_n_0 ;
  wire \acc0[15]_i_46_n_0 ;
  wire \acc0[15]_i_47_n_0 ;
  wire \acc0[15]_i_48_n_0 ;
  wire \acc0[15]_i_49_n_0 ;
  wire \acc0[15]_i_4_n_0 ;
  wire \acc0[15]_i_50_n_0 ;
  wire \acc0[15]_i_51_n_0 ;
  wire \acc0[15]_i_52_n_0 ;
  wire \acc0[15]_i_53_n_0 ;
  wire \acc0[15]_i_54_n_0 ;
  wire \acc0[15]_i_55_n_0 ;
  wire \acc0[15]_i_56_n_0 ;
  wire \acc0[15]_i_57_n_0 ;
  wire \acc0[15]_i_58_n_0 ;
  wire \acc0[15]_i_59_n_0 ;
  wire \acc0[15]_i_5_n_0 ;
  wire \acc0[15]_i_6_n_0 ;
  wire \acc0[15]_i_7_n_0 ;
  wire \acc0[16]_i_1_n_0 ;
  wire \acc0[17]_i_1_n_0 ;
  wire \acc0[18]_i_1_n_0 ;
  wire \acc0[19]_i_1_n_0 ;
  wire \acc0[19]_i_3_n_0 ;
  wire \acc0[19]_i_4_n_0 ;
  wire \acc0[19]_i_5_n_0 ;
  wire \acc0[19]_i_6_n_0 ;
  wire \acc0[19]_i_7_n_0 ;
  wire \acc0[1]_i_1_n_0 ;
  wire \acc0[20]_i_1_n_0 ;
  wire \acc0[21]_i_2_n_0 ;
  wire \acc0[21]_i_4_n_0 ;
  wire \acc0[21]_i_5_n_0 ;
  wire \acc0[2]_i_1_n_0 ;
  wire \acc0[3]_i_10_n_0 ;
  wire \acc0[3]_i_11_n_0 ;
  wire \acc0[3]_i_12_n_0 ;
  wire \acc0[3]_i_13_n_0 ;
  wire \acc0[3]_i_14_n_0 ;
  wire \acc0[3]_i_1_n_0 ;
  wire \acc0[3]_i_3_n_0 ;
  wire \acc0[3]_i_4_n_0 ;
  wire \acc0[3]_i_5_n_0 ;
  wire \acc0[3]_i_6_n_0 ;
  wire \acc0[3]_i_8_n_0 ;
  wire \acc0[3]_i_9_n_0 ;
  wire \acc0[4]_i_1_n_0 ;
  wire \acc0[5]_i_1_n_0 ;
  wire \acc0[6]_i_1_n_0 ;
  wire \acc0[7]_i_1_n_0 ;
  wire \acc0[7]_i_3_n_0 ;
  wire \acc0[7]_i_4_n_0 ;
  wire \acc0[7]_i_5_n_0 ;
  wire \acc0[7]_i_6_n_0 ;
  wire \acc0[8]_i_1_n_0 ;
  wire \acc0[9]_i_1_n_0 ;
  wire [21:0]acc0__0;
  wire \acc0_reg[11]_i_16_n_0 ;
  wire \acc0_reg[11]_i_16_n_1 ;
  wire \acc0_reg[11]_i_16_n_2 ;
  wire \acc0_reg[11]_i_16_n_3 ;
  wire \acc0_reg[11]_i_17_n_0 ;
  wire \acc0_reg[11]_i_17_n_1 ;
  wire \acc0_reg[11]_i_17_n_2 ;
  wire \acc0_reg[11]_i_17_n_3 ;
  wire [3:0]\acc0_reg[11]_i_2_0 ;
  wire \acc0_reg[11]_i_2_n_0 ;
  wire \acc0_reg[11]_i_2_n_1 ;
  wire \acc0_reg[11]_i_2_n_2 ;
  wire \acc0_reg[11]_i_2_n_3 ;
  wire [0:0]\acc0_reg[15]_0 ;
  wire \acc0_reg[15]_i_17_n_0 ;
  wire \acc0_reg[15]_i_17_n_1 ;
  wire \acc0_reg[15]_i_17_n_2 ;
  wire \acc0_reg[15]_i_17_n_3 ;
  wire \acc0_reg[15]_i_20_n_3 ;
  wire \acc0_reg[15]_i_21_n_3 ;
  wire \acc0_reg[15]_i_22_n_0 ;
  wire \acc0_reg[15]_i_22_n_1 ;
  wire \acc0_reg[15]_i_22_n_2 ;
  wire \acc0_reg[15]_i_22_n_3 ;
  wire \acc0_reg[15]_i_23_n_0 ;
  wire \acc0_reg[15]_i_23_n_1 ;
  wire \acc0_reg[15]_i_23_n_2 ;
  wire \acc0_reg[15]_i_23_n_3 ;
  wire [3:0]\acc0_reg[15]_i_2_0 ;
  wire \acc0_reg[15]_i_2_n_0 ;
  wire \acc0_reg[15]_i_2_n_1 ;
  wire \acc0_reg[15]_i_2_n_2 ;
  wire \acc0_reg[15]_i_2_n_3 ;
  wire \acc0_reg[15]_i_9_n_3 ;
  wire \acc0_reg[19]_i_2_n_0 ;
  wire \acc0_reg[19]_i_2_n_1 ;
  wire \acc0_reg[19]_i_2_n_2 ;
  wire \acc0_reg[19]_i_2_n_3 ;
  wire [0:0]\acc0_reg[20]_0 ;
  wire \acc0_reg[21]_0 ;
  wire \acc0_reg[21]_1 ;
  wire \acc0_reg[21]_2 ;
  wire \acc0_reg[21]_i_3_n_3 ;
  wire \acc0_reg[3]_i_2_n_0 ;
  wire \acc0_reg[3]_i_2_n_1 ;
  wire \acc0_reg[3]_i_2_n_2 ;
  wire \acc0_reg[3]_i_2_n_3 ;
  wire \acc0_reg[3]_i_7_n_0 ;
  wire \acc0_reg[3]_i_7_n_1 ;
  wire \acc0_reg[3]_i_7_n_2 ;
  wire \acc0_reg[3]_i_7_n_3 ;
  wire \acc0_reg[3]_i_7_n_5 ;
  wire \acc0_reg[3]_i_7_n_6 ;
  wire \acc0_reg[3]_i_7_n_7 ;
  wire [3:0]\acc0_reg[7]_i_2_0 ;
  wire \acc0_reg[7]_i_2_n_0 ;
  wire \acc0_reg[7]_i_2_n_1 ;
  wire \acc0_reg[7]_i_2_n_2 ;
  wire \acc0_reg[7]_i_2_n_3 ;
  wire \acc1[11]_i_18_n_0 ;
  wire \acc1[11]_i_19_n_0 ;
  wire \acc1[11]_i_20_n_0 ;
  wire \acc1[11]_i_21_n_0 ;
  wire \acc1[11]_i_22_n_0 ;
  wire \acc1[11]_i_23_n_0 ;
  wire \acc1[11]_i_24_n_0 ;
  wire \acc1[11]_i_25_n_0 ;
  wire \acc1[11]_i_26_n_0 ;
  wire \acc1[11]_i_27_n_0 ;
  wire \acc1[11]_i_28_n_0 ;
  wire \acc1[11]_i_29_n_0 ;
  wire \acc1[11]_i_30_n_0 ;
  wire \acc1[11]_i_31_n_0 ;
  wire \acc1[11]_i_32_n_0 ;
  wire \acc1[11]_i_33_n_0 ;
  wire \acc1[11]_i_34_n_0 ;
  wire \acc1[11]_i_35_n_0 ;
  wire \acc1[11]_i_3_n_0 ;
  wire \acc1[11]_i_4_n_0 ;
  wire \acc1[11]_i_5_n_0 ;
  wire \acc1[11]_i_6_n_0 ;
  wire \acc1[15]_i_18_n_0 ;
  wire \acc1[15]_i_19_n_0 ;
  wire \acc1[15]_i_24_n_0 ;
  wire \acc1[15]_i_25_n_0 ;
  wire \acc1[15]_i_26_n_0 ;
  wire \acc1[15]_i_27_n_0 ;
  wire \acc1[15]_i_28_n_0 ;
  wire \acc1[15]_i_29_n_0 ;
  wire \acc1[15]_i_30_n_0 ;
  wire \acc1[15]_i_31_n_0 ;
  wire \acc1[15]_i_32_n_0 ;
  wire \acc1[15]_i_33_n_0 ;
  wire \acc1[15]_i_34_n_0 ;
  wire \acc1[15]_i_35_n_0 ;
  wire \acc1[15]_i_36_n_0 ;
  wire \acc1[15]_i_37_n_0 ;
  wire \acc1[15]_i_38_n_0 ;
  wire \acc1[15]_i_39_n_0 ;
  wire \acc1[15]_i_40_n_0 ;
  wire \acc1[15]_i_41_n_0 ;
  wire \acc1[15]_i_42_n_0 ;
  wire \acc1[15]_i_43_n_0 ;
  wire \acc1[15]_i_44_n_0 ;
  wire \acc1[15]_i_45_n_0 ;
  wire \acc1[15]_i_46_n_0 ;
  wire \acc1[15]_i_47_n_0 ;
  wire \acc1[15]_i_48_n_0 ;
  wire \acc1[15]_i_49_n_0 ;
  wire \acc1[15]_i_4_n_0 ;
  wire \acc1[15]_i_50_n_0 ;
  wire \acc1[15]_i_51_n_0 ;
  wire \acc1[15]_i_52_n_0 ;
  wire \acc1[15]_i_53_n_0 ;
  wire \acc1[15]_i_54_n_0 ;
  wire \acc1[15]_i_55_n_0 ;
  wire \acc1[15]_i_56_n_0 ;
  wire \acc1[15]_i_57_n_0 ;
  wire \acc1[15]_i_58_n_0 ;
  wire \acc1[15]_i_59_n_0 ;
  wire \acc1[15]_i_5_n_0 ;
  wire \acc1[15]_i_6_n_0 ;
  wire \acc1[15]_i_7_n_0 ;
  wire \acc1[19]_i_3_n_0 ;
  wire \acc1[19]_i_4_n_0 ;
  wire \acc1[19]_i_5_n_0 ;
  wire \acc1[19]_i_6_n_0 ;
  wire \acc1[19]_i_7_n_0 ;
  wire \acc1[21]_i_1_n_0 ;
  wire \acc1[21]_i_4_n_0 ;
  wire \acc1[21]_i_5_n_0 ;
  wire \acc1[3]_i_10_n_0 ;
  wire \acc1[3]_i_11_n_0 ;
  wire \acc1[3]_i_12_n_0 ;
  wire \acc1[3]_i_13_n_0 ;
  wire \acc1[3]_i_14_n_0 ;
  wire \acc1[3]_i_3_n_0 ;
  wire \acc1[3]_i_4_n_0 ;
  wire \acc1[3]_i_5_n_0 ;
  wire \acc1[3]_i_6_n_0 ;
  wire \acc1[3]_i_8_n_0 ;
  wire \acc1[3]_i_9_n_0 ;
  wire \acc1[7]_i_3_n_0 ;
  wire \acc1[7]_i_4_n_0 ;
  wire \acc1[7]_i_5_n_0 ;
  wire \acc1[7]_i_6_n_0 ;
  wire [21:0]acc1__0;
  wire \acc1_reg[11]_i_16_n_0 ;
  wire \acc1_reg[11]_i_16_n_1 ;
  wire \acc1_reg[11]_i_16_n_2 ;
  wire \acc1_reg[11]_i_16_n_3 ;
  wire \acc1_reg[11]_i_17_n_0 ;
  wire \acc1_reg[11]_i_17_n_1 ;
  wire \acc1_reg[11]_i_17_n_2 ;
  wire \acc1_reg[11]_i_17_n_3 ;
  wire [3:0]\acc1_reg[11]_i_2_0 ;
  wire \acc1_reg[11]_i_2_n_0 ;
  wire \acc1_reg[11]_i_2_n_1 ;
  wire \acc1_reg[11]_i_2_n_2 ;
  wire \acc1_reg[11]_i_2_n_3 ;
  wire [0:0]\acc1_reg[15]_0 ;
  wire \acc1_reg[15]_i_17_n_0 ;
  wire \acc1_reg[15]_i_17_n_1 ;
  wire \acc1_reg[15]_i_17_n_2 ;
  wire \acc1_reg[15]_i_17_n_3 ;
  wire \acc1_reg[15]_i_20_n_3 ;
  wire \acc1_reg[15]_i_21_n_3 ;
  wire \acc1_reg[15]_i_22_n_0 ;
  wire \acc1_reg[15]_i_22_n_1 ;
  wire \acc1_reg[15]_i_22_n_2 ;
  wire \acc1_reg[15]_i_22_n_3 ;
  wire \acc1_reg[15]_i_23_n_0 ;
  wire \acc1_reg[15]_i_23_n_1 ;
  wire \acc1_reg[15]_i_23_n_2 ;
  wire \acc1_reg[15]_i_23_n_3 ;
  wire [3:0]\acc1_reg[15]_i_2_0 ;
  wire \acc1_reg[15]_i_2_n_0 ;
  wire \acc1_reg[15]_i_2_n_1 ;
  wire \acc1_reg[15]_i_2_n_2 ;
  wire \acc1_reg[15]_i_2_n_3 ;
  wire \acc1_reg[15]_i_9_n_3 ;
  wire \acc1_reg[19]_i_2_n_0 ;
  wire \acc1_reg[19]_i_2_n_1 ;
  wire \acc1_reg[19]_i_2_n_2 ;
  wire \acc1_reg[19]_i_2_n_3 ;
  wire \acc1_reg[21]_i_3_n_1 ;
  wire \acc1_reg[21]_i_3_n_3 ;
  wire \acc1_reg[3]_i_2_n_0 ;
  wire \acc1_reg[3]_i_2_n_1 ;
  wire \acc1_reg[3]_i_2_n_2 ;
  wire \acc1_reg[3]_i_2_n_3 ;
  wire \acc1_reg[3]_i_7_n_0 ;
  wire \acc1_reg[3]_i_7_n_1 ;
  wire \acc1_reg[3]_i_7_n_2 ;
  wire \acc1_reg[3]_i_7_n_3 ;
  wire \acc1_reg[3]_i_7_n_5 ;
  wire \acc1_reg[3]_i_7_n_6 ;
  wire \acc1_reg[3]_i_7_n_7 ;
  wire [3:0]\acc1_reg[7]_i_2_0 ;
  wire \acc1_reg[7]_i_2_n_0 ;
  wire \acc1_reg[7]_i_2_n_1 ;
  wire \acc1_reg[7]_i_2_n_2 ;
  wire \acc1_reg[7]_i_2_n_3 ;
  wire [5:0]clip_shift0_return;
  wire [5:0]clip_shift_return;
  wire core_mac2;
  wire finish10_in;
  wire finish2;
  wire [48:0]finish3;
  wire [15:0]m0_0;
  wire [15:0]m0_1;
  wire \mem[0][0]_i_1_n_0 ;
  wire \mem[0][1]_i_1_n_0 ;
  wire \mem[0][2]_i_1_n_0 ;
  wire \mem[0][3]_i_1_n_0 ;
  wire \mem[0][4]_i_1_n_0 ;
  wire \mem[0][5]_i_1_n_0 ;
  wire \mem[0][6]_i_1_n_0 ;
  wire \mem[0][7]_i_1_n_0 ;
  wire \mem[0][7]_i_2_n_0 ;
  wire \mem[0][7]_i_3_n_0 ;
  wire \mem[10][0]_i_1_n_0 ;
  wire \mem[10][1]_i_1_n_0 ;
  wire \mem[10][2]_i_1_n_0 ;
  wire \mem[10][3]_i_1_n_0 ;
  wire \mem[10][4]_i_1_n_0 ;
  wire \mem[10][5]_i_1_n_0 ;
  wire \mem[10][6]_i_1_n_0 ;
  wire \mem[10][7]_i_1_n_0 ;
  wire \mem[10][7]_i_2_n_0 ;
  wire \mem[10][7]_i_3_n_0 ;
  wire \mem[10][7]_i_4_n_0 ;
  wire \mem[10][7]_i_5_n_0 ;
  wire \mem[11][0]_i_1_n_0 ;
  wire \mem[11][1]_i_1_n_0 ;
  wire \mem[11][2]_i_1_n_0 ;
  wire \mem[11][3]_i_1_n_0 ;
  wire \mem[11][4]_i_1_n_0 ;
  wire \mem[11][5]_i_1_n_0 ;
  wire \mem[11][6]_i_1_n_0 ;
  wire \mem[11][7]_i_1_n_0 ;
  wire \mem[11][7]_i_2_n_0 ;
  wire \mem[11][7]_i_3_n_0 ;
  wire \mem[11][7]_i_4_n_0 ;
  wire \mem[12][0]_i_1_n_0 ;
  wire \mem[12][1]_i_1_n_0 ;
  wire \mem[12][2]_i_1_n_0 ;
  wire \mem[12][3]_i_1_n_0 ;
  wire \mem[12][4]_i_1_n_0 ;
  wire \mem[12][5]_i_1_n_0 ;
  wire \mem[12][6]_i_1_n_0 ;
  wire \mem[12][7]_i_1_n_0 ;
  wire \mem[12][7]_i_2_n_0 ;
  wire \mem[12][7]_i_3_n_0 ;
  wire \mem[12][7]_i_4_n_0 ;
  wire \mem[13][0]_i_1_n_0 ;
  wire \mem[13][1]_i_1_n_0 ;
  wire \mem[13][2]_i_1_n_0 ;
  wire \mem[13][3]_i_1_n_0 ;
  wire \mem[13][4]_i_1_n_0 ;
  wire \mem[13][5]_i_1_n_0 ;
  wire \mem[13][6]_i_1_n_0 ;
  wire \mem[13][7]_i_1_n_0 ;
  wire \mem[13][7]_i_2_n_0 ;
  wire \mem[13][7]_i_3_n_0 ;
  wire \mem[13][7]_i_4_n_0 ;
  wire \mem[13][7]_i_5_n_0 ;
  wire \mem[14][0]_i_1_n_0 ;
  wire \mem[14][1]_i_1_n_0 ;
  wire \mem[14][2]_i_1_n_0 ;
  wire \mem[14][3]_i_1_n_0 ;
  wire \mem[14][4]_i_1_n_0 ;
  wire \mem[14][5]_i_1_n_0 ;
  wire \mem[14][6]_i_1_n_0 ;
  wire \mem[14][7]_i_1_n_0 ;
  wire \mem[14][7]_i_2_n_0 ;
  wire \mem[14][7]_i_3_n_0 ;
  wire \mem[14][7]_i_4_n_0 ;
  wire \mem[15][0]_i_1_n_0 ;
  wire \mem[15][1]_i_1_n_0 ;
  wire \mem[15][2]_i_1_n_0 ;
  wire \mem[15][3]_i_1_n_0 ;
  wire \mem[15][4]_i_1_n_0 ;
  wire \mem[15][5]_i_1_n_0 ;
  wire \mem[15][6]_i_1_n_0 ;
  wire \mem[15][7]_i_1_n_0 ;
  wire \mem[15][7]_i_2_n_0 ;
  wire \mem[15][7]_i_3_n_0 ;
  wire \mem[15][7]_i_4_n_0 ;
  wire \mem[15][7]_i_5_n_0 ;
  wire \mem[16][0]_i_1_n_0 ;
  wire \mem[16][1]_i_1_n_0 ;
  wire \mem[16][2]_i_1_n_0 ;
  wire \mem[16][3]_i_1_n_0 ;
  wire \mem[16][4]_i_1_n_0 ;
  wire \mem[16][5]_i_1_n_0 ;
  wire \mem[16][6]_i_1_n_0 ;
  wire \mem[16][7]_i_1_n_0 ;
  wire \mem[16][7]_i_2_n_0 ;
  wire \mem[16][7]_i_3_n_0 ;
  wire \mem[16][7]_i_4_n_0 ;
  wire \mem[16][7]_i_5_n_0 ;
  wire \mem[17][0]_i_1_n_0 ;
  wire \mem[17][1]_i_1_n_0 ;
  wire \mem[17][2]_i_1_n_0 ;
  wire \mem[17][3]_i_1_n_0 ;
  wire \mem[17][4]_i_1_n_0 ;
  wire \mem[17][5]_i_1_n_0 ;
  wire \mem[17][6]_i_1_n_0 ;
  wire \mem[17][7]_i_1_n_0 ;
  wire \mem[17][7]_i_2_n_0 ;
  wire \mem[17][7]_i_3_n_0 ;
  wire \mem[17][7]_i_4_n_0 ;
  wire \mem[18][0]_i_1_n_0 ;
  wire \mem[18][1]_i_1_n_0 ;
  wire \mem[18][2]_i_1_n_0 ;
  wire \mem[18][3]_i_1_n_0 ;
  wire \mem[18][4]_i_1_n_0 ;
  wire \mem[18][5]_i_1_n_0 ;
  wire \mem[18][6]_i_1_n_0 ;
  wire \mem[18][7]_i_1_n_0 ;
  wire \mem[18][7]_i_2_n_0 ;
  wire \mem[18][7]_i_3_n_0 ;
  wire \mem[18][7]_i_4_n_0 ;
  wire \mem[19][0]_i_1_n_0 ;
  wire \mem[19][1]_i_1_n_0 ;
  wire \mem[19][2]_i_1_n_0 ;
  wire \mem[19][3]_i_1_n_0 ;
  wire \mem[19][4]_i_1_n_0 ;
  wire \mem[19][5]_i_1_n_0 ;
  wire \mem[19][6]_i_1_n_0 ;
  wire \mem[19][7]_i_1_n_0 ;
  wire \mem[19][7]_i_2_n_0 ;
  wire \mem[19][7]_i_3_n_0 ;
  wire \mem[19][7]_i_4_n_0 ;
  wire \mem[1][0]_i_1_n_0 ;
  wire \mem[1][1]_i_1_n_0 ;
  wire \mem[1][2]_i_1_n_0 ;
  wire \mem[1][3]_i_1_n_0 ;
  wire \mem[1][4]_i_1_n_0 ;
  wire \mem[1][5]_i_1_n_0 ;
  wire \mem[1][6]_i_1_n_0 ;
  wire \mem[1][7]_i_1_n_0 ;
  wire \mem[1][7]_i_2_n_0 ;
  wire \mem[1][7]_i_3_n_0 ;
  wire \mem[20][0]_i_1_n_0 ;
  wire \mem[20][1]_i_1_n_0 ;
  wire \mem[20][2]_i_1_n_0 ;
  wire \mem[20][3]_i_1_n_0 ;
  wire \mem[20][4]_i_1_n_0 ;
  wire \mem[20][5]_i_1_n_0 ;
  wire \mem[20][6]_i_1_n_0 ;
  wire \mem[20][7]_i_1_n_0 ;
  wire \mem[20][7]_i_2_n_0 ;
  wire \mem[20][7]_i_3_n_0 ;
  wire \mem[21][0]_i_1_n_0 ;
  wire \mem[21][1]_i_1_n_0 ;
  wire \mem[21][2]_i_1_n_0 ;
  wire \mem[21][3]_i_1_n_0 ;
  wire \mem[21][4]_i_1_n_0 ;
  wire \mem[21][5]_i_1_n_0 ;
  wire \mem[21][6]_i_1_n_0 ;
  wire \mem[21][7]_i_1_n_0 ;
  wire \mem[21][7]_i_2_n_0 ;
  wire \mem[21][7]_i_3_n_0 ;
  wire \mem[22][0]_i_1_n_0 ;
  wire \mem[22][1]_i_1_n_0 ;
  wire \mem[22][2]_i_1_n_0 ;
  wire \mem[22][3]_i_1_n_0 ;
  wire \mem[22][4]_i_1_n_0 ;
  wire \mem[22][5]_i_1_n_0 ;
  wire \mem[22][6]_i_1_n_0 ;
  wire \mem[22][7]_i_1_n_0 ;
  wire \mem[22][7]_i_2_n_0 ;
  wire \mem[22][7]_i_3_n_0 ;
  wire \mem[22][7]_i_4_n_0 ;
  wire \mem[22][7]_i_5_n_0 ;
  wire \mem[22][7]_i_6_n_0 ;
  wire \mem[23][0]_i_1_n_0 ;
  wire \mem[23][1]_i_1_n_0 ;
  wire \mem[23][2]_i_1_n_0 ;
  wire \mem[23][3]_i_1_n_0 ;
  wire \mem[23][4]_i_1_n_0 ;
  wire \mem[23][5]_i_1_n_0 ;
  wire \mem[23][6]_i_1_n_0 ;
  wire \mem[23][7]_i_1_n_0 ;
  wire \mem[23][7]_i_2_n_0 ;
  wire \mem[23][7]_i_3_n_0 ;
  wire \mem[23][7]_i_4_n_0 ;
  wire \mem[23][7]_i_5_n_0 ;
  wire \mem[24][0]_i_1_n_0 ;
  wire \mem[24][1]_i_1_n_0 ;
  wire \mem[24][2]_i_1_n_0 ;
  wire \mem[24][3]_i_1_n_0 ;
  wire \mem[24][4]_i_1_n_0 ;
  wire \mem[24][5]_i_1_n_0 ;
  wire \mem[24][6]_i_1_n_0 ;
  wire \mem[24][7]_i_1_n_0 ;
  wire \mem[24][7]_i_2_n_0 ;
  wire \mem[24][7]_i_3_n_0 ;
  wire \mem[24][7]_i_4_n_0 ;
  wire \mem[24][7]_i_5_n_0 ;
  wire \mem[25][0]_i_1_n_0 ;
  wire \mem[25][1]_i_1_n_0 ;
  wire \mem[25][2]_i_1_n_0 ;
  wire \mem[25][3]_i_1_n_0 ;
  wire \mem[25][4]_i_1_n_0 ;
  wire \mem[25][5]_i_1_n_0 ;
  wire \mem[25][6]_i_1_n_0 ;
  wire \mem[25][7]_i_1_n_0 ;
  wire \mem[25][7]_i_2_n_0 ;
  wire \mem[25][7]_i_3_n_0 ;
  wire \mem[25][7]_i_4_n_0 ;
  wire \mem[26][0]_i_1_n_0 ;
  wire \mem[26][1]_i_1_n_0 ;
  wire \mem[26][2]_i_1_n_0 ;
  wire \mem[26][3]_i_1_n_0 ;
  wire \mem[26][4]_i_1_n_0 ;
  wire \mem[26][4]_i_2_n_0 ;
  wire \mem[26][4]_i_3_n_0 ;
  wire \mem[26][5]_i_1_n_0 ;
  wire \mem[26][6]_i_1_n_0 ;
  wire \mem[26][7]_i_1_n_0 ;
  wire \mem[26][7]_i_2_n_0 ;
  wire \mem[26][7]_i_3_n_0 ;
  wire \mem[26][7]_i_4_n_0 ;
  wire \mem[27][0]_i_1_n_0 ;
  wire \mem[27][1]_i_1_n_0 ;
  wire \mem[27][2]_i_1_n_0 ;
  wire \mem[27][3]_i_1_n_0 ;
  wire \mem[27][4]_i_1_n_0 ;
  wire \mem[27][5]_i_1_n_0 ;
  wire \mem[27][6]_i_1_n_0 ;
  wire \mem[27][7]_i_1_n_0 ;
  wire \mem[27][7]_i_2_n_0 ;
  wire \mem[27][7]_i_3_n_0 ;
  wire \mem[28][0]_i_1_n_0 ;
  wire \mem[28][1]_i_1_n_0 ;
  wire \mem[28][2]_i_1_n_0 ;
  wire \mem[28][3]_i_1_n_0 ;
  wire \mem[28][4]_i_1_n_0 ;
  wire \mem[28][5]_i_1_n_0 ;
  wire \mem[28][6]_i_1_n_0 ;
  wire \mem[28][7]_i_1_n_0 ;
  wire \mem[28][7]_i_2_n_0 ;
  wire \mem[28][7]_i_3_n_0 ;
  wire \mem[28][7]_i_4_n_0 ;
  wire \mem[29][0]_i_1_n_0 ;
  wire \mem[29][1]_i_1_n_0 ;
  wire \mem[29][2]_i_1_n_0 ;
  wire \mem[29][3]_i_1_n_0 ;
  wire \mem[29][4]_i_1_n_0 ;
  wire \mem[29][5]_i_1_n_0 ;
  wire \mem[29][6]_i_1_n_0 ;
  wire \mem[29][7]_i_1_n_0 ;
  wire \mem[29][7]_i_2_n_0 ;
  wire \mem[29][7]_i_3_n_0 ;
  wire \mem[29][7]_i_4_n_0 ;
  wire \mem[29][7]_i_5_n_0 ;
  wire \mem[2][0]_i_1_n_0 ;
  wire \mem[2][1]_i_1_n_0 ;
  wire \mem[2][2]_i_1_n_0 ;
  wire \mem[2][3]_i_1_n_0 ;
  wire \mem[2][4]_i_1_n_0 ;
  wire \mem[2][5]_i_1_n_0 ;
  wire \mem[2][6]_i_1_n_0 ;
  wire \mem[2][7]_i_1_n_0 ;
  wire \mem[2][7]_i_2_n_0 ;
  wire \mem[2][7]_i_3_n_0 ;
  wire \mem[30][0]_i_1_n_0 ;
  wire \mem[30][1]_i_1_n_0 ;
  wire \mem[30][2]_i_1_n_0 ;
  wire \mem[30][3]_i_1_n_0 ;
  wire \mem[30][4]_i_1_n_0 ;
  wire \mem[30][5]_i_1_n_0 ;
  wire \mem[30][6]_i_1_n_0 ;
  wire \mem[30][7]_i_1_n_0 ;
  wire \mem[30][7]_i_2_n_0 ;
  wire \mem[30][7]_i_3_n_0 ;
  wire \mem[30][7]_i_4_n_0 ;
  wire \mem[30][7]_i_5_n_0 ;
  wire \mem[31][0]_i_1_n_0 ;
  wire \mem[31][1]_i_1_n_0 ;
  wire \mem[31][2]_i_1_n_0 ;
  wire \mem[31][3]_i_1_n_0 ;
  wire \mem[31][4]_i_1_n_0 ;
  wire \mem[31][5]_i_1_n_0 ;
  wire \mem[31][6]_i_1_n_0 ;
  wire \mem[31][7]_i_1_n_0 ;
  wire \mem[31][7]_i_2_n_0 ;
  wire \mem[31][7]_i_3_n_0 ;
  wire \mem[31][7]_i_4_n_0 ;
  wire \mem[31][7]_i_5_n_0 ;
  wire \mem[31][7]_i_6_n_0 ;
  wire \mem[31][7]_i_7_n_0 ;
  wire \mem[31][7]_i_8_n_0 ;
  wire \mem[32][0]_i_1_n_0 ;
  wire \mem[32][1]_i_1_n_0 ;
  wire \mem[32][2]_i_1_n_0 ;
  wire \mem[32][3]_i_1_n_0 ;
  wire \mem[32][4]_i_1_n_0 ;
  wire \mem[32][5]_i_1_n_0 ;
  wire \mem[32][6]_i_1_n_0 ;
  wire \mem[32][7]_i_1_n_0 ;
  wire \mem[32][7]_i_2_n_0 ;
  wire \mem[32][7]_i_3_n_0 ;
  wire \mem[32][7]_i_4_n_0 ;
  wire \mem[32][7]_i_5_n_0 ;
  wire \mem[33][0]_i_1_n_0 ;
  wire \mem[33][1]_i_1_n_0 ;
  wire \mem[33][2]_i_1_n_0 ;
  wire \mem[33][3]_i_1_n_0 ;
  wire \mem[33][4]_i_1_n_0 ;
  wire \mem[33][5]_i_1_n_0 ;
  wire \mem[33][6]_i_1_n_0 ;
  wire \mem[33][7]_i_1_n_0 ;
  wire \mem[33][7]_i_2_n_0 ;
  wire \mem[33][7]_i_3_n_0 ;
  wire \mem[33][7]_i_4_n_0 ;
  wire \mem[33][7]_i_5_n_0 ;
  wire \mem[34][0]_i_1_n_0 ;
  wire \mem[34][1]_i_1_n_0 ;
  wire \mem[34][2]_i_1_n_0 ;
  wire \mem[34][3]_i_1_n_0 ;
  wire \mem[34][4]_i_1_n_0 ;
  wire \mem[34][5]_i_1_n_0 ;
  wire \mem[34][6]_i_1_n_0 ;
  wire \mem[34][7]_i_1_n_0 ;
  wire \mem[34][7]_i_2_n_0 ;
  wire \mem[34][7]_i_3_n_0 ;
  wire \mem[35][0]_i_1_n_0 ;
  wire \mem[35][1]_i_1_n_0 ;
  wire \mem[35][2]_i_1_n_0 ;
  wire \mem[35][3]_i_1_n_0 ;
  wire \mem[35][4]_i_1_n_0 ;
  wire \mem[35][5]_i_1_n_0 ;
  wire \mem[35][6]_i_1_n_0 ;
  wire \mem[35][7]_i_1_n_0 ;
  wire \mem[35][7]_i_2_n_0 ;
  wire \mem[35][7]_i_3_n_0 ;
  wire \mem[35][7]_i_4_n_0 ;
  wire \mem[35][7]_i_5_n_0 ;
  wire \mem[36][0]_i_1_n_0 ;
  wire \mem[36][1]_i_1_n_0 ;
  wire \mem[36][2]_i_1_n_0 ;
  wire \mem[36][3]_i_1_n_0 ;
  wire \mem[36][4]_i_1_n_0 ;
  wire \mem[36][5]_i_1_n_0 ;
  wire \mem[36][6]_i_1_n_0 ;
  wire \mem[36][7]_i_1_n_0 ;
  wire \mem[36][7]_i_2_n_0 ;
  wire \mem[36][7]_i_3_n_0 ;
  wire \mem[36][7]_i_4_n_0 ;
  wire \mem[37][0]_i_1_n_0 ;
  wire \mem[37][1]_i_1_n_0 ;
  wire \mem[37][2]_i_1_n_0 ;
  wire \mem[37][3]_i_1_n_0 ;
  wire \mem[37][4]_i_1_n_0 ;
  wire \mem[37][5]_i_1_n_0 ;
  wire \mem[37][6]_i_1_n_0 ;
  wire \mem[37][7]_i_1_n_0 ;
  wire \mem[37][7]_i_2_n_0 ;
  wire \mem[37][7]_i_3_n_0 ;
  wire \mem[37][7]_i_4_n_0 ;
  wire \mem[37][7]_i_5_n_0 ;
  wire \mem[37][7]_i_6_n_0 ;
  wire \mem[37][7]_i_7_n_0 ;
  wire \mem[38][0]_i_1_n_0 ;
  wire \mem[38][1]_i_1_n_0 ;
  wire \mem[38][2]_i_1_n_0 ;
  wire \mem[38][3]_i_1_n_0 ;
  wire \mem[38][4]_i_1_n_0 ;
  wire \mem[38][4]_i_2_n_0 ;
  wire \mem[38][5]_i_1_n_0 ;
  wire \mem[38][6]_i_1_n_0 ;
  wire \mem[38][7]_i_1_n_0 ;
  wire \mem[38][7]_i_2_n_0 ;
  wire \mem[38][7]_i_3_n_0 ;
  wire \mem[38][7]_i_4_n_0 ;
  wire \mem[39][0]_i_1_n_0 ;
  wire \mem[39][1]_i_1_n_0 ;
  wire \mem[39][2]_i_1_n_0 ;
  wire \mem[39][3]_i_1_n_0 ;
  wire \mem[39][4]_i_1_n_0 ;
  wire \mem[39][5]_i_1_n_0 ;
  wire \mem[39][6]_i_1_n_0 ;
  wire \mem[39][7]_i_1_n_0 ;
  wire \mem[39][7]_i_2_n_0 ;
  wire \mem[39][7]_i_3_n_0 ;
  wire \mem[39][7]_i_4_n_0 ;
  wire \mem[39][7]_i_5_n_0 ;
  wire \mem[39][7]_i_6_n_0 ;
  wire \mem[3][0]_i_1_n_0 ;
  wire \mem[3][1]_i_1_n_0 ;
  wire \mem[3][2]_i_1_n_0 ;
  wire \mem[3][3]_i_1_n_0 ;
  wire \mem[3][4]_i_1_n_0 ;
  wire \mem[3][5]_i_1_n_0 ;
  wire \mem[3][6]_i_1_n_0 ;
  wire \mem[3][7]_i_1_n_0 ;
  wire \mem[3][7]_i_2_n_0 ;
  wire \mem[3][7]_i_3_n_0 ;
  wire \mem[3][7]_i_4_n_0 ;
  wire \mem[3][7]_i_5_n_0 ;
  wire \mem[40][0]_i_1_n_0 ;
  wire \mem[40][1]_i_1_n_0 ;
  wire \mem[40][2]_i_1_n_0 ;
  wire \mem[40][3]_i_1_n_0 ;
  wire \mem[40][4]_i_1_n_0 ;
  wire \mem[40][5]_i_1_n_0 ;
  wire \mem[40][6]_i_1_n_0 ;
  wire \mem[40][7]_i_1_n_0 ;
  wire \mem[40][7]_i_2_n_0 ;
  wire \mem[40][7]_i_3_n_0 ;
  wire \mem[40][7]_i_4_n_0 ;
  wire \mem[41][0]_i_1_n_0 ;
  wire \mem[41][1]_i_1_n_0 ;
  wire \mem[41][2]_i_1_n_0 ;
  wire \mem[41][3]_i_1_n_0 ;
  wire \mem[41][4]_i_1_n_0 ;
  wire \mem[41][5]_i_1_n_0 ;
  wire \mem[41][6]_i_1_n_0 ;
  wire \mem[41][7]_i_1_n_0 ;
  wire \mem[41][7]_i_2_n_0 ;
  wire \mem[41][7]_i_3_n_0 ;
  wire \mem[41][7]_i_4_n_0 ;
  wire \mem[41][7]_i_5_n_0 ;
  wire \mem[41][7]_i_6_n_0 ;
  wire \mem[42][0]_i_1_n_0 ;
  wire \mem[42][1]_i_1_n_0 ;
  wire \mem[42][2]_i_1_n_0 ;
  wire \mem[42][3]_i_1_n_0 ;
  wire \mem[42][4]_i_1_n_0 ;
  wire \mem[42][5]_i_1_n_0 ;
  wire \mem[42][6]_i_1_n_0 ;
  wire \mem[42][7]_i_1_n_0 ;
  wire \mem[42][7]_i_2_n_0 ;
  wire \mem[42][7]_i_3_n_0 ;
  wire \mem[42][7]_i_4_n_0 ;
  wire \mem[42][7]_i_5_n_0 ;
  wire \mem[43][0]_i_1_n_0 ;
  wire \mem[43][1]_i_1_n_0 ;
  wire \mem[43][2]_i_1_n_0 ;
  wire \mem[43][3]_i_1_n_0 ;
  wire \mem[43][4]_i_1_n_0 ;
  wire \mem[43][5]_i_1_n_0 ;
  wire \mem[43][6]_i_1_n_0 ;
  wire \mem[43][7]_i_1_n_0 ;
  wire \mem[43][7]_i_2_n_0 ;
  wire \mem[43][7]_i_3_n_0 ;
  wire \mem[43][7]_i_4_n_0 ;
  wire \mem[44][0]_i_1_n_0 ;
  wire \mem[44][1]_i_1_n_0 ;
  wire \mem[44][2]_i_1_n_0 ;
  wire \mem[44][3]_i_1_n_0 ;
  wire \mem[44][4]_i_1_n_0 ;
  wire \mem[44][5]_i_1_n_0 ;
  wire \mem[44][6]_i_1_n_0 ;
  wire \mem[44][7]_i_1_n_0 ;
  wire \mem[44][7]_i_2_n_0 ;
  wire \mem[44][7]_i_3_n_0 ;
  wire \mem[44][7]_i_4_n_0 ;
  wire \mem[44][7]_i_5_n_0 ;
  wire \mem[44][7]_i_6_n_0 ;
  wire \mem[45][0]_i_1_n_0 ;
  wire \mem[45][1]_i_1_n_0 ;
  wire \mem[45][2]_i_1_n_0 ;
  wire \mem[45][3]_i_1_n_0 ;
  wire \mem[45][3]_i_2_n_0 ;
  wire \mem[45][4]_i_1_n_0 ;
  wire \mem[45][5]_i_1_n_0 ;
  wire \mem[45][6]_i_1_n_0 ;
  wire \mem[45][7]_i_1_n_0 ;
  wire \mem[45][7]_i_2_n_0 ;
  wire \mem[45][7]_i_3_n_0 ;
  wire \mem[45][7]_i_4_n_0 ;
  wire \mem[45][7]_i_5_n_0 ;
  wire \mem[45][7]_i_6_n_0 ;
  wire \mem[46][0]_i_1_n_0 ;
  wire \mem[46][1]_i_1_n_0 ;
  wire \mem[46][2]_i_1_n_0 ;
  wire \mem[46][2]_i_2_n_0 ;
  wire \mem[46][3]_i_1_n_0 ;
  wire \mem[46][4]_i_1_n_0 ;
  wire \mem[46][5]_i_1_n_0 ;
  wire \mem[46][6]_i_1_n_0 ;
  wire \mem[46][7]_i_1_n_0 ;
  wire \mem[46][7]_i_2_n_0 ;
  wire \mem[46][7]_i_3_n_0 ;
  wire \mem[46][7]_i_4_n_0 ;
  wire \mem[47][0]_i_1_n_0 ;
  wire \mem[47][1]_i_1_n_0 ;
  wire \mem[47][2]_i_1_n_0 ;
  wire \mem[47][3]_i_1_n_0 ;
  wire \mem[47][4]_i_1_n_0 ;
  wire \mem[47][5]_i_1_n_0 ;
  wire \mem[47][6]_i_1_n_0 ;
  wire \mem[47][7]_i_1_n_0 ;
  wire \mem[47][7]_i_2_n_0 ;
  wire \mem[47][7]_i_3_n_0 ;
  wire \mem[47][7]_i_4_n_0 ;
  wire \mem[47][7]_i_5_n_0 ;
  wire \mem[48][0]_i_1_n_0 ;
  wire \mem[48][1]_i_1_n_0 ;
  wire \mem[48][2]_i_1_n_0 ;
  wire \mem[48][3]_i_1_n_0 ;
  wire \mem[48][4]_i_1_n_0 ;
  wire \mem[48][5]_i_1_n_0 ;
  wire \mem[48][6]_i_1_n_0 ;
  wire \mem[48][7]_i_1_n_0 ;
  wire \mem[48][7]_i_2_n_0 ;
  wire \mem[48][7]_i_3_n_0 ;
  wire \mem[48][7]_i_4_n_0 ;
  wire \mem[49][0]_i_1_n_0 ;
  wire \mem[49][1]_i_1_n_0 ;
  wire \mem[49][2]_i_1_n_0 ;
  wire \mem[49][3]_i_1_n_0 ;
  wire \mem[49][4]_i_1_n_0 ;
  wire \mem[49][5]_i_1_n_0 ;
  wire \mem[49][6]_i_1_n_0 ;
  wire \mem[49][7]_i_1_n_0 ;
  wire \mem[49][7]_i_2_n_0 ;
  wire \mem[49][7]_i_3_n_0 ;
  wire \mem[49][7]_i_4_n_0 ;
  wire \mem[4][0]_i_1_n_0 ;
  wire \mem[4][1]_i_1_n_0 ;
  wire \mem[4][2]_i_1_n_0 ;
  wire \mem[4][3]_i_1_n_0 ;
  wire \mem[4][4]_i_1_n_0 ;
  wire \mem[4][5]_i_1_n_0 ;
  wire \mem[4][6]_i_1_n_0 ;
  wire \mem[4][7]_i_1_n_0 ;
  wire \mem[4][7]_i_2_n_0 ;
  wire \mem[4][7]_i_3_n_0 ;
  wire \mem[4][7]_i_4_n_0 ;
  wire \mem[4][7]_i_5_n_0 ;
  wire \mem[50][0]_i_1_n_0 ;
  wire \mem[50][1]_i_1_n_0 ;
  wire \mem[50][2]_i_1_n_0 ;
  wire \mem[50][3]_i_1_n_0 ;
  wire \mem[50][4]_i_1_n_0 ;
  wire \mem[50][5]_i_1_n_0 ;
  wire \mem[50][6]_i_1_n_0 ;
  wire \mem[50][7]_i_1_n_0 ;
  wire \mem[50][7]_i_2_n_0 ;
  wire \mem[50][7]_i_3_n_0 ;
  wire \mem[50][7]_i_4_n_0 ;
  wire \mem[50][7]_i_5_n_0 ;
  wire \mem[50][7]_i_6_n_0 ;
  wire \mem[51][0]_i_1_n_0 ;
  wire \mem[51][1]_i_1_n_0 ;
  wire \mem[51][2]_i_1_n_0 ;
  wire \mem[51][3]_i_1_n_0 ;
  wire \mem[51][4]_i_1_n_0 ;
  wire \mem[51][5]_i_1_n_0 ;
  wire \mem[51][6]_i_1_n_0 ;
  wire \mem[51][7]_i_1_n_0 ;
  wire \mem[51][7]_i_2_n_0 ;
  wire \mem[51][7]_i_3_n_0 ;
  wire \mem[51][7]_i_4_n_0 ;
  wire \mem[51][7]_i_5_n_0 ;
  wire \mem[51][7]_i_6_n_0 ;
  wire \mem[51][7]_i_7_n_0 ;
  wire \mem[51][7]_i_8_n_0 ;
  wire \mem[52][0]_i_1_n_0 ;
  wire \mem[52][1]_i_1_n_0 ;
  wire \mem[52][2]_i_1_n_0 ;
  wire \mem[52][3]_i_1_n_0 ;
  wire \mem[52][4]_i_1_n_0 ;
  wire \mem[52][5]_i_1_n_0 ;
  wire \mem[52][6]_i_1_n_0 ;
  wire \mem[52][7]_i_1_n_0 ;
  wire \mem[52][7]_i_2_n_0 ;
  wire \mem[52][7]_i_3_n_0 ;
  wire \mem[52][7]_i_4_n_0 ;
  wire \mem[52][7]_i_5_n_0 ;
  wire \mem[53][0]_i_1_n_0 ;
  wire \mem[53][1]_i_1_n_0 ;
  wire \mem[53][2]_i_1_n_0 ;
  wire \mem[53][3]_i_1_n_0 ;
  wire \mem[53][4]_i_1_n_0 ;
  wire \mem[53][5]_i_1_n_0 ;
  wire \mem[53][6]_i_1_n_0 ;
  wire \mem[53][7]_i_1_n_0 ;
  wire \mem[53][7]_i_2_n_0 ;
  wire \mem[53][7]_i_3_n_0 ;
  wire \mem[53][7]_i_4_n_0 ;
  wire \mem[53][7]_i_5_n_0 ;
  wire \mem[53][7]_i_6_n_0 ;
  wire \mem[54][0]_i_1_n_0 ;
  wire \mem[54][1]_i_1_n_0 ;
  wire \mem[54][2]_i_1_n_0 ;
  wire \mem[54][3]_i_1_n_0 ;
  wire \mem[54][4]_i_1_n_0 ;
  wire \mem[54][5]_i_1_n_0 ;
  wire \mem[54][6]_i_1_n_0 ;
  wire \mem[54][7]_i_1_n_0 ;
  wire \mem[54][7]_i_2_n_0 ;
  wire \mem[54][7]_i_3_n_0 ;
  wire \mem[54][7]_i_4_n_0 ;
  wire \mem[54][7]_i_5_n_0 ;
  wire \mem[55][0]_i_1_n_0 ;
  wire \mem[55][1]_i_1_n_0 ;
  wire \mem[55][2]_i_1_n_0 ;
  wire \mem[55][3]_i_1_n_0 ;
  wire \mem[55][4]_i_1_n_0 ;
  wire \mem[55][5]_i_1_n_0 ;
  wire \mem[55][6]_i_1_n_0 ;
  wire \mem[55][7]_i_1_n_0 ;
  wire \mem[55][7]_i_2_n_0 ;
  wire \mem[55][7]_i_3_n_0 ;
  wire \mem[55][7]_i_4_n_0 ;
  wire \mem[55][7]_i_5_n_0 ;
  wire \mem[55][7]_i_6_n_0 ;
  wire \mem[56][0]_i_1_n_0 ;
  wire \mem[56][1]_i_1_n_0 ;
  wire \mem[56][2]_i_1_n_0 ;
  wire \mem[56][3]_i_1_n_0 ;
  wire \mem[56][4]_i_1_n_0 ;
  wire \mem[56][5]_i_1_n_0 ;
  wire \mem[56][6]_i_1_n_0 ;
  wire \mem[56][7]_i_1_n_0 ;
  wire \mem[56][7]_i_2_n_0 ;
  wire \mem[56][7]_i_3_n_0 ;
  wire \mem[56][7]_i_4_n_0 ;
  wire \mem[56][7]_i_5_n_0 ;
  wire \mem[56][7]_i_6_n_0 ;
  wire \mem[57][0]_i_1_n_0 ;
  wire \mem[57][1]_i_1_n_0 ;
  wire \mem[57][2]_i_1_n_0 ;
  wire \mem[57][3]_i_1_n_0 ;
  wire \mem[57][4]_i_1_n_0 ;
  wire \mem[57][5]_i_1_n_0 ;
  wire \mem[57][6]_i_1_n_0 ;
  wire \mem[57][7]_i_1_n_0 ;
  wire \mem[57][7]_i_2_n_0 ;
  wire \mem[57][7]_i_3_n_0 ;
  wire \mem[57][7]_i_4_n_0 ;
  wire \mem[57][7]_i_5_n_0 ;
  wire \mem[58][0]_i_1_n_0 ;
  wire \mem[58][1]_i_1_n_0 ;
  wire \mem[58][2]_i_1_n_0 ;
  wire \mem[58][3]_i_1_n_0 ;
  wire \mem[58][4]_i_1_n_0 ;
  wire \mem[58][4]_i_2_n_0 ;
  wire \mem[58][5]_i_1_n_0 ;
  wire \mem[58][6]_i_1_n_0 ;
  wire \mem[58][7]_i_1_n_0 ;
  wire \mem[58][7]_i_2_n_0 ;
  wire \mem[58][7]_i_3_n_0 ;
  wire \mem[58][7]_i_4_n_0 ;
  wire \mem[58][7]_i_5_n_0 ;
  wire \mem[59][0]_i_1_n_0 ;
  wire \mem[59][1]_i_1_n_0 ;
  wire \mem[59][2]_i_1_n_0 ;
  wire \mem[59][3]_i_1_n_0 ;
  wire \mem[59][4]_i_1_n_0 ;
  wire \mem[59][5]_i_1_n_0 ;
  wire \mem[59][6]_i_1_n_0 ;
  wire \mem[59][7]_i_1_n_0 ;
  wire \mem[59][7]_i_2_n_0 ;
  wire \mem[59][7]_i_3_n_0 ;
  wire \mem[59][7]_i_4_n_0 ;
  wire \mem[59][7]_i_5_n_0 ;
  wire \mem[5][0]_i_1_n_0 ;
  wire \mem[5][1]_i_1_n_0 ;
  wire \mem[5][2]_i_1_n_0 ;
  wire \mem[5][3]_i_1_n_0 ;
  wire \mem[5][4]_i_1_n_0 ;
  wire \mem[5][5]_i_1_n_0 ;
  wire \mem[5][6]_i_1_n_0 ;
  wire \mem[5][7]_i_1_n_0 ;
  wire \mem[5][7]_i_2_n_0 ;
  wire \mem[5][7]_i_3_n_0 ;
  wire \mem[5][7]_i_4_n_0 ;
  wire \mem[5][7]_i_5_n_0 ;
  wire \mem[60][0]_i_1_n_0 ;
  wire \mem[60][1]_i_1_n_0 ;
  wire \mem[60][2]_i_1_n_0 ;
  wire \mem[60][3]_i_1_n_0 ;
  wire \mem[60][4]_i_1_n_0 ;
  wire \mem[60][5]_i_1_n_0 ;
  wire \mem[60][6]_i_1_n_0 ;
  wire \mem[60][7]_i_1_n_0 ;
  wire \mem[60][7]_i_2_n_0 ;
  wire \mem[60][7]_i_3_n_0 ;
  wire \mem[60][7]_i_4_n_0 ;
  wire \mem[60][7]_i_5_n_0 ;
  wire \mem[60][7]_i_6_n_0 ;
  wire \mem[60][7]_i_7_n_0 ;
  wire \mem[61][0]_i_1_n_0 ;
  wire \mem[61][1]_i_1_n_0 ;
  wire \mem[61][2]_i_1_n_0 ;
  wire \mem[61][3]_i_1_n_0 ;
  wire \mem[61][4]_i_1_n_0 ;
  wire \mem[61][5]_i_1_n_0 ;
  wire \mem[61][6]_i_1_n_0 ;
  wire \mem[61][7]_i_1_n_0 ;
  wire \mem[61][7]_i_2_n_0 ;
  wire \mem[61][7]_i_3_n_0 ;
  wire \mem[62][0]_i_10_n_0 ;
  wire \mem[62][0]_i_11_n_0 ;
  wire \mem[62][0]_i_12_n_0 ;
  wire \mem[62][0]_i_13_n_0 ;
  wire \mem[62][0]_i_14_n_0 ;
  wire \mem[62][0]_i_15_n_0 ;
  wire \mem[62][0]_i_16_n_0 ;
  wire \mem[62][0]_i_17_n_0 ;
  wire \mem[62][0]_i_18_n_0 ;
  wire \mem[62][0]_i_19_n_0 ;
  wire \mem[62][0]_i_22_n_0 ;
  wire \mem[62][0]_i_23_n_0 ;
  wire \mem[62][0]_i_24_n_0 ;
  wire \mem[62][0]_i_25_n_0 ;
  wire \mem[62][0]_i_26_n_0 ;
  wire \mem[62][0]_i_27_n_0 ;
  wire \mem[62][0]_i_28_n_0 ;
  wire \mem[62][0]_i_29_n_0 ;
  wire \mem[62][0]_i_2_n_0 ;
  wire \mem[62][0]_i_30_n_0 ;
  wire \mem[62][0]_i_31_n_0 ;
  wire \mem[62][0]_i_3_n_0 ;
  wire \mem[62][0]_i_4_n_0 ;
  wire \mem[62][0]_i_5_n_0 ;
  wire \mem[62][0]_i_6_n_0 ;
  wire \mem[62][0]_i_7_n_0 ;
  wire \mem[62][0]_i_9_n_0 ;
  wire \mem[62][1]_i_10_n_0 ;
  wire \mem[62][1]_i_11_n_0 ;
  wire \mem[62][1]_i_12_n_0 ;
  wire \mem[62][1]_i_13_n_0 ;
  wire \mem[62][1]_i_14_n_0 ;
  wire \mem[62][1]_i_15_n_0 ;
  wire \mem[62][1]_i_16_n_0 ;
  wire \mem[62][1]_i_17_n_0 ;
  wire \mem[62][1]_i_18_n_0 ;
  wire \mem[62][1]_i_19_n_0 ;
  wire \mem[62][1]_i_24_n_0 ;
  wire \mem[62][1]_i_25_n_0 ;
  wire \mem[62][1]_i_26_n_0 ;
  wire \mem[62][1]_i_27_n_0 ;
  wire \mem[62][1]_i_28_n_0 ;
  wire \mem[62][1]_i_29_n_0 ;
  wire \mem[62][1]_i_2_n_0 ;
  wire \mem[62][1]_i_30_n_0 ;
  wire \mem[62][1]_i_31_n_0 ;
  wire \mem[62][1]_i_32_n_0 ;
  wire \mem[62][1]_i_33_n_0 ;
  wire \mem[62][1]_i_3_n_0 ;
  wire \mem[62][1]_i_4_n_0 ;
  wire \mem[62][1]_i_5_n_0 ;
  wire \mem[62][1]_i_6_n_0 ;
  wire \mem[62][1]_i_7_n_0 ;
  wire \mem[62][2]_i_10_n_0 ;
  wire \mem[62][2]_i_19_n_0 ;
  wire \mem[62][2]_i_20_n_0 ;
  wire \mem[62][2]_i_21_n_0 ;
  wire \mem[62][2]_i_22_n_0 ;
  wire \mem[62][2]_i_23_n_0 ;
  wire \mem[62][2]_i_24_n_0 ;
  wire \mem[62][2]_i_25_n_0 ;
  wire \mem[62][2]_i_26_n_0 ;
  wire \mem[62][2]_i_27_n_0 ;
  wire \mem[62][2]_i_28_n_0 ;
  wire \mem[62][2]_i_29_n_0 ;
  wire \mem[62][2]_i_2_n_0 ;
  wire \mem[62][2]_i_30_n_0 ;
  wire \mem[62][2]_i_31_n_0 ;
  wire \mem[62][2]_i_32_n_0 ;
  wire \mem[62][2]_i_33_n_0 ;
  wire \mem[62][2]_i_34_n_0 ;
  wire \mem[62][2]_i_35_n_0 ;
  wire \mem[62][2]_i_36_n_0 ;
  wire \mem[62][2]_i_3_n_0 ;
  wire \mem[62][2]_i_4_n_0 ;
  wire \mem[62][2]_i_5_n_0 ;
  wire \mem[62][3]_i_10_n_0 ;
  wire \mem[62][3]_i_19_n_0 ;
  wire \mem[62][3]_i_20_n_0 ;
  wire \mem[62][3]_i_21_n_0 ;
  wire \mem[62][3]_i_22_n_0 ;
  wire \mem[62][3]_i_23_n_0 ;
  wire \mem[62][3]_i_24_n_0 ;
  wire \mem[62][3]_i_25_n_0 ;
  wire \mem[62][3]_i_26_n_0 ;
  wire \mem[62][3]_i_27_n_0 ;
  wire \mem[62][3]_i_28_n_0 ;
  wire \mem[62][3]_i_29_n_0 ;
  wire \mem[62][3]_i_2_n_0 ;
  wire \mem[62][3]_i_30_n_0 ;
  wire \mem[62][3]_i_31_n_0 ;
  wire \mem[62][3]_i_32_n_0 ;
  wire \mem[62][3]_i_33_n_0 ;
  wire \mem[62][3]_i_34_n_0 ;
  wire \mem[62][3]_i_35_n_0 ;
  wire \mem[62][3]_i_36_n_0 ;
  wire \mem[62][3]_i_38_n_0 ;
  wire \mem[62][3]_i_39_n_0 ;
  wire \mem[62][3]_i_3_n_0 ;
  wire \mem[62][3]_i_40_n_0 ;
  wire \mem[62][3]_i_41_n_0 ;
  wire \mem[62][3]_i_4_n_0 ;
  wire \mem[62][3]_i_5_n_0 ;
  wire \mem[62][4]_i_10_n_0 ;
  wire \mem[62][4]_i_11_n_0 ;
  wire \mem[62][4]_i_12_n_0 ;
  wire \mem[62][4]_i_13_n_0 ;
  wire \mem[62][4]_i_14_n_0 ;
  wire \mem[62][4]_i_15_n_0 ;
  wire \mem[62][4]_i_16_n_0 ;
  wire \mem[62][4]_i_17_n_0 ;
  wire \mem[62][4]_i_18_n_0 ;
  wire \mem[62][4]_i_23_n_0 ;
  wire \mem[62][4]_i_24_n_0 ;
  wire \mem[62][4]_i_25_n_0 ;
  wire \mem[62][4]_i_26_n_0 ;
  wire \mem[62][4]_i_27_n_0 ;
  wire \mem[62][4]_i_28_n_0 ;
  wire \mem[62][4]_i_29_n_0 ;
  wire \mem[62][4]_i_2_n_0 ;
  wire \mem[62][4]_i_30_n_0 ;
  wire \mem[62][4]_i_31_n_0 ;
  wire \mem[62][4]_i_32_n_0 ;
  wire \mem[62][4]_i_3_n_0 ;
  wire \mem[62][4]_i_4_n_0 ;
  wire \mem[62][4]_i_5_n_0 ;
  wire \mem[62][4]_i_6_n_0 ;
  wire \mem[62][4]_i_7_n_0 ;
  wire \mem[62][5]_i_10_n_0 ;
  wire \mem[62][5]_i_19_n_0 ;
  wire \mem[62][5]_i_20_n_0 ;
  wire \mem[62][5]_i_21_n_0 ;
  wire \mem[62][5]_i_22_n_0 ;
  wire \mem[62][5]_i_23_n_0 ;
  wire \mem[62][5]_i_24_n_0 ;
  wire \mem[62][5]_i_25_n_0 ;
  wire \mem[62][5]_i_26_n_0 ;
  wire \mem[62][5]_i_27_n_0 ;
  wire \mem[62][5]_i_28_n_0 ;
  wire \mem[62][5]_i_29_n_0 ;
  wire \mem[62][5]_i_2_n_0 ;
  wire \mem[62][5]_i_30_n_0 ;
  wire \mem[62][5]_i_31_n_0 ;
  wire \mem[62][5]_i_32_n_0 ;
  wire \mem[62][5]_i_33_n_0 ;
  wire \mem[62][5]_i_34_n_0 ;
  wire \mem[62][5]_i_35_n_0 ;
  wire \mem[62][5]_i_36_n_0 ;
  wire \mem[62][5]_i_3_n_0 ;
  wire \mem[62][5]_i_4_n_0 ;
  wire \mem[62][5]_i_5_n_0 ;
  wire \mem[62][6]_i_13_n_0 ;
  wire \mem[62][6]_i_14_n_0 ;
  wire \mem[62][6]_i_15_n_0 ;
  wire \mem[62][6]_i_16_n_0 ;
  wire \mem[62][6]_i_26_n_0 ;
  wire \mem[62][6]_i_27_n_0 ;
  wire \mem[62][6]_i_28_n_0 ;
  wire \mem[62][6]_i_29_n_0 ;
  wire \mem[62][6]_i_2_n_0 ;
  wire \mem[62][6]_i_30_n_0 ;
  wire \mem[62][6]_i_31_n_0 ;
  wire \mem[62][6]_i_32_n_0 ;
  wire \mem[62][6]_i_33_n_0 ;
  wire \mem[62][6]_i_34_n_0 ;
  wire \mem[62][6]_i_35_n_0 ;
  wire \mem[62][6]_i_36_n_0 ;
  wire \mem[62][6]_i_37_n_0 ;
  wire \mem[62][6]_i_38_n_0 ;
  wire \mem[62][6]_i_39_n_0 ;
  wire \mem[62][6]_i_3_n_0 ;
  wire \mem[62][6]_i_40_n_0 ;
  wire \mem[62][6]_i_41_n_0 ;
  wire \mem[62][6]_i_42_n_0 ;
  wire \mem[62][6]_i_43_n_0 ;
  wire \mem[62][6]_i_44_n_0 ;
  wire \mem[62][6]_i_45_n_0 ;
  wire \mem[62][6]_i_46_n_0 ;
  wire \mem[62][6]_i_47_n_0 ;
  wire \mem[62][6]_i_48_n_0 ;
  wire \mem[62][6]_i_49_n_0 ;
  wire \mem[62][6]_i_4_n_0 ;
  wire \mem[62][6]_i_50_n_0 ;
  wire \mem[62][6]_i_51_n_0 ;
  wire \mem[62][6]_i_53_n_0 ;
  wire \mem[62][6]_i_54_n_0 ;
  wire \mem[62][6]_i_55_n_0 ;
  wire \mem[62][6]_i_56_n_0 ;
  wire \mem[62][6]_i_57_n_0 ;
  wire \mem[62][6]_i_58_n_0 ;
  wire \mem[62][6]_i_59_n_0 ;
  wire \mem[62][6]_i_60_n_0 ;
  wire \mem[62][6]_i_62_n_0 ;
  wire \mem[62][6]_i_63_n_0 ;
  wire \mem[62][6]_i_64_n_0 ;
  wire \mem[62][6]_i_65_n_0 ;
  wire \mem[62][6]_i_66_n_0 ;
  wire \mem[62][6]_i_67_n_0 ;
  wire \mem[62][6]_i_68_n_0 ;
  wire \mem[62][6]_i_69_n_0 ;
  wire \mem[62][6]_i_6_n_0 ;
  wire \mem[62][6]_i_71_n_0 ;
  wire \mem[62][6]_i_72_n_0 ;
  wire \mem[62][6]_i_73_n_0 ;
  wire \mem[62][6]_i_74_n_0 ;
  wire \mem[62][6]_i_75_n_0 ;
  wire \mem[62][6]_i_76_n_0 ;
  wire \mem[62][6]_i_77_n_0 ;
  wire \mem[62][6]_i_78_n_0 ;
  wire \mem[62][6]_i_79_n_0 ;
  wire \mem[62][6]_i_7_n_0 ;
  wire \mem[62][6]_i_80_n_0 ;
  wire \mem[62][6]_i_81_n_0 ;
  wire \mem[62][6]_i_82_n_0 ;
  wire \mem[62][6]_i_83_n_0 ;
  wire \mem[62][6]_i_84_n_0 ;
  wire \mem[62][6]_i_85_n_0 ;
  wire \mem[62][6]_i_86_n_0 ;
  wire \mem[62][7]_i_100_n_0 ;
  wire \mem[62][7]_i_101_n_0 ;
  wire \mem[62][7]_i_102_n_0 ;
  wire \mem[62][7]_i_103_n_0 ;
  wire \mem[62][7]_i_104_n_0 ;
  wire \mem[62][7]_i_105_n_0 ;
  wire \mem[62][7]_i_106_n_0 ;
  wire \mem[62][7]_i_107_n_0 ;
  wire \mem[62][7]_i_108_n_0 ;
  wire \mem[62][7]_i_109_n_0 ;
  wire \mem[62][7]_i_110_n_0 ;
  wire \mem[62][7]_i_111_n_0 ;
  wire \mem[62][7]_i_112_n_0 ;
  wire \mem[62][7]_i_113_n_0 ;
  wire \mem[62][7]_i_114_n_0 ;
  wire \mem[62][7]_i_115_n_0 ;
  wire \mem[62][7]_i_116_n_0 ;
  wire \mem[62][7]_i_117_n_0 ;
  wire \mem[62][7]_i_119_n_0 ;
  wire \mem[62][7]_i_11_n_0 ;
  wire \mem[62][7]_i_120_n_0 ;
  wire \mem[62][7]_i_121_n_0 ;
  wire \mem[62][7]_i_122_n_0 ;
  wire \mem[62][7]_i_123_n_0 ;
  wire \mem[62][7]_i_124_n_0 ;
  wire \mem[62][7]_i_125_n_0 ;
  wire \mem[62][7]_i_126_n_0 ;
  wire \mem[62][7]_i_127_n_0 ;
  wire \mem[62][7]_i_128_n_0 ;
  wire \mem[62][7]_i_129_n_0 ;
  wire \mem[62][7]_i_12_n_0 ;
  wire \mem[62][7]_i_13_n_0 ;
  wire \mem[62][7]_i_140_n_0 ;
  wire \mem[62][7]_i_141_n_0 ;
  wire \mem[62][7]_i_142_n_0 ;
  wire \mem[62][7]_i_143_n_0 ;
  wire \mem[62][7]_i_144_n_0 ;
  wire \mem[62][7]_i_145_n_0 ;
  wire \mem[62][7]_i_146_n_0 ;
  wire \mem[62][7]_i_147_n_0 ;
  wire \mem[62][7]_i_148_n_0 ;
  wire \mem[62][7]_i_149_n_0 ;
  wire \mem[62][7]_i_14_n_0 ;
  wire \mem[62][7]_i_150_n_0 ;
  wire \mem[62][7]_i_151_n_0 ;
  wire \mem[62][7]_i_152_n_0 ;
  wire \mem[62][7]_i_153_n_0 ;
  wire \mem[62][7]_i_154_n_0 ;
  wire \mem[62][7]_i_155_n_0 ;
  wire \mem[62][7]_i_156_n_0 ;
  wire \mem[62][7]_i_157_n_0 ;
  wire \mem[62][7]_i_158_n_0 ;
  wire \mem[62][7]_i_159_n_0 ;
  wire \mem[62][7]_i_160_n_0 ;
  wire \mem[62][7]_i_161_n_0 ;
  wire \mem[62][7]_i_162_n_0 ;
  wire \mem[62][7]_i_163_n_0 ;
  wire \mem[62][7]_i_164_n_0 ;
  wire \mem[62][7]_i_165_n_0 ;
  wire \mem[62][7]_i_166_n_0 ;
  wire \mem[62][7]_i_167_n_0 ;
  wire \mem[62][7]_i_168_n_0 ;
  wire \mem[62][7]_i_169_n_0 ;
  wire \mem[62][7]_i_170_n_0 ;
  wire \mem[62][7]_i_171_n_0 ;
  wire \mem[62][7]_i_172_n_0 ;
  wire \mem[62][7]_i_173_n_0 ;
  wire \mem[62][7]_i_174_n_0 ;
  wire \mem[62][7]_i_175_n_0 ;
  wire \mem[62][7]_i_176_n_0 ;
  wire \mem[62][7]_i_177_n_0 ;
  wire \mem[62][7]_i_178_n_0 ;
  wire \mem[62][7]_i_179_n_0 ;
  wire \mem[62][7]_i_180_n_0 ;
  wire \mem[62][7]_i_181_n_0 ;
  wire \mem[62][7]_i_182_n_0 ;
  wire \mem[62][7]_i_183_n_0 ;
  wire \mem[62][7]_i_184_n_0 ;
  wire \mem[62][7]_i_185_n_0 ;
  wire \mem[62][7]_i_186_n_0 ;
  wire \mem[62][7]_i_187_n_0 ;
  wire \mem[62][7]_i_188_n_0 ;
  wire \mem[62][7]_i_189_n_0 ;
  wire \mem[62][7]_i_190_n_0 ;
  wire \mem[62][7]_i_191_n_0 ;
  wire \mem[62][7]_i_192_n_0 ;
  wire \mem[62][7]_i_193_n_0 ;
  wire \mem[62][7]_i_194_n_0 ;
  wire \mem[62][7]_i_195_n_0 ;
  wire \mem[62][7]_i_196_n_0 ;
  wire \mem[62][7]_i_197_n_0 ;
  wire \mem[62][7]_i_198_n_0 ;
  wire \mem[62][7]_i_199_n_0 ;
  wire \mem[62][7]_i_200_n_0 ;
  wire \mem[62][7]_i_201_n_0 ;
  wire \mem[62][7]_i_202_n_0 ;
  wire \mem[62][7]_i_203_n_0 ;
  wire \mem[62][7]_i_204_n_0 ;
  wire \mem[62][7]_i_205_n_0 ;
  wire \mem[62][7]_i_206_n_0 ;
  wire \mem[62][7]_i_207_n_0 ;
  wire \mem[62][7]_i_208_n_0 ;
  wire \mem[62][7]_i_209_n_0 ;
  wire \mem[62][7]_i_20_n_0 ;
  wire \mem[62][7]_i_210_n_0 ;
  wire \mem[62][7]_i_212_n_0 ;
  wire \mem[62][7]_i_213_n_0 ;
  wire \mem[62][7]_i_214_n_0 ;
  wire \mem[62][7]_i_215_n_0 ;
  wire \mem[62][7]_i_216_n_0 ;
  wire \mem[62][7]_i_217_n_0 ;
  wire \mem[62][7]_i_218_n_0 ;
  wire \mem[62][7]_i_219_n_0 ;
  wire \mem[62][7]_i_220_n_0 ;
  wire \mem[62][7]_i_221_n_0 ;
  wire \mem[62][7]_i_222_n_0 ;
  wire \mem[62][7]_i_223_n_0 ;
  wire \mem[62][7]_i_224_n_0 ;
  wire \mem[62][7]_i_225_n_0 ;
  wire \mem[62][7]_i_226_n_0 ;
  wire \mem[62][7]_i_227_n_0 ;
  wire \mem[62][7]_i_228_n_0 ;
  wire \mem[62][7]_i_229_n_0 ;
  wire \mem[62][7]_i_22_n_0 ;
  wire \mem[62][7]_i_230_n_0 ;
  wire \mem[62][7]_i_231_n_0 ;
  wire \mem[62][7]_i_232_n_0 ;
  wire \mem[62][7]_i_233_n_0 ;
  wire \mem[62][7]_i_234_n_0 ;
  wire \mem[62][7]_i_235_n_0 ;
  wire \mem[62][7]_i_236_n_0 ;
  wire \mem[62][7]_i_237_n_0 ;
  wire \mem[62][7]_i_238_n_0 ;
  wire \mem[62][7]_i_239_n_0 ;
  wire \mem[62][7]_i_23_n_0 ;
  wire \mem[62][7]_i_240_n_0 ;
  wire \mem[62][7]_i_241_n_0 ;
  wire \mem[62][7]_i_242_n_0 ;
  wire \mem[62][7]_i_243_n_0 ;
  wire \mem[62][7]_i_244_n_0 ;
  wire \mem[62][7]_i_245_n_0 ;
  wire \mem[62][7]_i_246_n_0 ;
  wire \mem[62][7]_i_247_n_0 ;
  wire \mem[62][7]_i_248_n_0 ;
  wire \mem[62][7]_i_249_n_0 ;
  wire \mem[62][7]_i_24_n_0 ;
  wire \mem[62][7]_i_250_n_0 ;
  wire \mem[62][7]_i_251_n_0 ;
  wire \mem[62][7]_i_252_n_0 ;
  wire \mem[62][7]_i_253_n_0 ;
  wire \mem[62][7]_i_254_n_0 ;
  wire \mem[62][7]_i_255_n_0 ;
  wire \mem[62][7]_i_256_n_0 ;
  wire \mem[62][7]_i_257_n_0 ;
  wire \mem[62][7]_i_258_n_0 ;
  wire \mem[62][7]_i_259_n_0 ;
  wire \mem[62][7]_i_25_n_0 ;
  wire \mem[62][7]_i_260_n_0 ;
  wire \mem[62][7]_i_261_n_0 ;
  wire \mem[62][7]_i_262_n_0 ;
  wire \mem[62][7]_i_263_n_0 ;
  wire \mem[62][7]_i_264_n_0 ;
  wire \mem[62][7]_i_265_n_0 ;
  wire \mem[62][7]_i_266_n_0 ;
  wire \mem[62][7]_i_267_n_0 ;
  wire \mem[62][7]_i_268_n_0 ;
  wire \mem[62][7]_i_269_n_0 ;
  wire \mem[62][7]_i_26_n_0 ;
  wire \mem[62][7]_i_270_n_0 ;
  wire \mem[62][7]_i_271_n_0 ;
  wire \mem[62][7]_i_272_n_0 ;
  wire \mem[62][7]_i_273_n_0 ;
  wire \mem[62][7]_i_274_n_0 ;
  wire \mem[62][7]_i_275_n_0 ;
  wire \mem[62][7]_i_276_n_0 ;
  wire \mem[62][7]_i_277_n_0 ;
  wire \mem[62][7]_i_278_n_0 ;
  wire \mem[62][7]_i_279_n_0 ;
  wire \mem[62][7]_i_27_n_0 ;
  wire \mem[62][7]_i_280_n_0 ;
  wire \mem[62][7]_i_281_n_0 ;
  wire \mem[62][7]_i_282_n_0 ;
  wire \mem[62][7]_i_283_n_0 ;
  wire \mem[62][7]_i_284_n_0 ;
  wire \mem[62][7]_i_285_n_0 ;
  wire \mem[62][7]_i_286_n_0 ;
  wire \mem[62][7]_i_287_n_0 ;
  wire \mem[62][7]_i_288_n_0 ;
  wire \mem[62][7]_i_289_n_0 ;
  wire \mem[62][7]_i_28_n_0 ;
  wire \mem[62][7]_i_290_n_0 ;
  wire \mem[62][7]_i_291_n_0 ;
  wire \mem[62][7]_i_292_n_0 ;
  wire \mem[62][7]_i_293_n_0 ;
  wire \mem[62][7]_i_294_n_0 ;
  wire \mem[62][7]_i_295_n_0 ;
  wire \mem[62][7]_i_296_n_0 ;
  wire \mem[62][7]_i_297_n_0 ;
  wire \mem[62][7]_i_298_n_0 ;
  wire \mem[62][7]_i_299_n_0 ;
  wire \mem[62][7]_i_29_n_0 ;
  wire \mem[62][7]_i_2_n_0 ;
  wire \mem[62][7]_i_300_n_0 ;
  wire \mem[62][7]_i_301_n_0 ;
  wire \mem[62][7]_i_302_n_0 ;
  wire \mem[62][7]_i_303_n_0 ;
  wire \mem[62][7]_i_304_n_0 ;
  wire \mem[62][7]_i_305_n_0 ;
  wire \mem[62][7]_i_306_n_0 ;
  wire \mem[62][7]_i_307_n_0 ;
  wire \mem[62][7]_i_308_n_0 ;
  wire \mem[62][7]_i_309_n_0 ;
  wire \mem[62][7]_i_30_n_0 ;
  wire \mem[62][7]_i_310_n_0 ;
  wire \mem[62][7]_i_311_n_0 ;
  wire \mem[62][7]_i_312_n_0 ;
  wire \mem[62][7]_i_313_n_0 ;
  wire \mem[62][7]_i_314_n_0 ;
  wire \mem[62][7]_i_315_n_0 ;
  wire \mem[62][7]_i_316_n_0 ;
  wire \mem[62][7]_i_317_n_0 ;
  wire \mem[62][7]_i_318_n_0 ;
  wire \mem[62][7]_i_319_n_0 ;
  wire \mem[62][7]_i_31_n_0 ;
  wire \mem[62][7]_i_320_n_0 ;
  wire \mem[62][7]_i_321_n_0 ;
  wire \mem[62][7]_i_322_n_0 ;
  wire \mem[62][7]_i_323_n_0 ;
  wire \mem[62][7]_i_324_n_0 ;
  wire \mem[62][7]_i_325_n_0 ;
  wire \mem[62][7]_i_326_n_0 ;
  wire \mem[62][7]_i_327_n_0 ;
  wire \mem[62][7]_i_328_n_0 ;
  wire \mem[62][7]_i_329_n_0 ;
  wire \mem[62][7]_i_32_n_0 ;
  wire \mem[62][7]_i_330_n_0 ;
  wire \mem[62][7]_i_331_n_0 ;
  wire \mem[62][7]_i_332_n_0 ;
  wire \mem[62][7]_i_333_n_0 ;
  wire \mem[62][7]_i_334_n_0 ;
  wire \mem[62][7]_i_335_n_0 ;
  wire \mem[62][7]_i_336_n_0 ;
  wire \mem[62][7]_i_337_n_0 ;
  wire \mem[62][7]_i_338_n_0 ;
  wire \mem[62][7]_i_339_n_0 ;
  wire \mem[62][7]_i_340_n_0 ;
  wire \mem[62][7]_i_3_n_0 ;
  wire \mem[62][7]_i_42_n_0 ;
  wire \mem[62][7]_i_43_n_0 ;
  wire \mem[62][7]_i_44_n_0 ;
  wire \mem[62][7]_i_45_n_0 ;
  wire \mem[62][7]_i_46_n_0 ;
  wire \mem[62][7]_i_47_n_0 ;
  wire \mem[62][7]_i_48_n_0 ;
  wire \mem[62][7]_i_49_n_0 ;
  wire \mem[62][7]_i_4_n_0 ;
  wire \mem[62][7]_i_50_n_0 ;
  wire \mem[62][7]_i_52_n_0 ;
  wire \mem[62][7]_i_53_n_0 ;
  wire \mem[62][7]_i_54_n_0 ;
  wire \mem[62][7]_i_55_n_0 ;
  wire \mem[62][7]_i_56_n_0 ;
  wire \mem[62][7]_i_57_n_0 ;
  wire \mem[62][7]_i_58_n_0 ;
  wire \mem[62][7]_i_59_n_0 ;
  wire \mem[62][7]_i_5_n_0 ;
  wire \mem[62][7]_i_60_n_0 ;
  wire \mem[62][7]_i_61_n_0 ;
  wire \mem[62][7]_i_62_n_0 ;
  wire \mem[62][7]_i_63_n_0 ;
  wire \mem[62][7]_i_64_n_0 ;
  wire \mem[62][7]_i_65_n_0 ;
  wire \mem[62][7]_i_66_n_0 ;
  wire \mem[62][7]_i_67_n_0 ;
  wire \mem[62][7]_i_68_n_0 ;
  wire \mem[62][7]_i_69_n_0 ;
  wire \mem[62][7]_i_6_n_0 ;
  wire \mem[62][7]_i_70_n_0 ;
  wire \mem[62][7]_i_71_n_0 ;
  wire \mem[62][7]_i_72_n_0 ;
  wire \mem[62][7]_i_73_n_0 ;
  wire \mem[62][7]_i_74_n_0 ;
  wire \mem[62][7]_i_75_n_0 ;
  wire \mem[62][7]_i_76_n_0 ;
  wire \mem[62][7]_i_77_n_0 ;
  wire \mem[62][7]_i_78_n_0 ;
  wire \mem[62][7]_i_79_n_0 ;
  wire \mem[62][7]_i_7_n_0 ;
  wire \mem[62][7]_i_80_n_0 ;
  wire \mem[62][7]_i_81_n_0 ;
  wire \mem[62][7]_i_82_n_0 ;
  wire \mem[62][7]_i_83_n_0 ;
  wire \mem[62][7]_i_84_n_0 ;
  wire \mem[62][7]_i_85_n_0 ;
  wire \mem[62][7]_i_86_n_0 ;
  wire \mem[62][7]_i_87_n_0 ;
  wire \mem[62][7]_i_88_n_0 ;
  wire \mem[62][7]_i_89_n_0 ;
  wire \mem[62][7]_i_8_n_0 ;
  wire \mem[62][7]_i_90_n_0 ;
  wire \mem[62][7]_i_91_n_0 ;
  wire \mem[62][7]_i_92_n_0 ;
  wire \mem[62][7]_i_93_n_0 ;
  wire \mem[62][7]_i_94_n_0 ;
  wire \mem[62][7]_i_95_n_0 ;
  wire \mem[62][7]_i_96_n_0 ;
  wire \mem[62][7]_i_97_n_0 ;
  wire \mem[62][7]_i_99_n_0 ;
  wire \mem[62][7]_i_9_n_0 ;
  wire \mem[63][0]_i_1_n_0 ;
  wire \mem[63][1]_i_1_n_0 ;
  wire \mem[63][2]_i_1_n_0 ;
  wire \mem[63][3]_i_1_n_0 ;
  wire \mem[63][4]_i_1_n_0 ;
  wire \mem[63][5]_i_1_n_0 ;
  wire \mem[63][6]_i_1_n_0 ;
  wire \mem[63][7]_i_1_n_0 ;
  wire \mem[63][7]_i_2_n_0 ;
  wire \mem[63][7]_i_3_n_0 ;
  wire \mem[6][0]_i_1_n_0 ;
  wire \mem[6][1]_i_1_n_0 ;
  wire \mem[6][2]_i_1_n_0 ;
  wire \mem[6][3]_i_1_n_0 ;
  wire \mem[6][4]_i_1_n_0 ;
  wire \mem[6][5]_i_1_n_0 ;
  wire \mem[6][6]_i_1_n_0 ;
  wire \mem[6][7]_i_1_n_0 ;
  wire \mem[6][7]_i_2_n_0 ;
  wire \mem[6][7]_i_3_n_0 ;
  wire \mem[7][0]_i_1_n_0 ;
  wire \mem[7][1]_i_1_n_0 ;
  wire \mem[7][2]_i_1_n_0 ;
  wire \mem[7][3]_i_1_n_0 ;
  wire \mem[7][4]_i_1_n_0 ;
  wire \mem[7][5]_i_1_n_0 ;
  wire \mem[7][6]_i_1_n_0 ;
  wire \mem[7][7]_i_1_n_0 ;
  wire \mem[7][7]_i_2_n_0 ;
  wire \mem[7][7]_i_3_n_0 ;
  wire \mem[7][7]_i_4_n_0 ;
  wire \mem[8][0]_i_1_n_0 ;
  wire \mem[8][1]_i_1_n_0 ;
  wire \mem[8][2]_i_1_n_0 ;
  wire \mem[8][3]_i_1_n_0 ;
  wire \mem[8][4]_i_1_n_0 ;
  wire \mem[8][4]_i_2_n_0 ;
  wire \mem[8][4]_i_3_n_0 ;
  wire \mem[8][4]_i_4_n_0 ;
  wire \mem[8][4]_i_5_n_0 ;
  wire \mem[8][5]_i_1_n_0 ;
  wire \mem[8][6]_i_1_n_0 ;
  wire \mem[8][7]_i_1_n_0 ;
  wire \mem[8][7]_i_2_n_0 ;
  wire \mem[8][7]_i_3_n_0 ;
  wire \mem[9][0]_i_1_n_0 ;
  wire \mem[9][1]_i_1_n_0 ;
  wire \mem[9][2]_i_1_n_0 ;
  wire \mem[9][3]_i_1_n_0 ;
  wire \mem[9][4]_i_1_n_0 ;
  wire \mem[9][5]_i_1_n_0 ;
  wire \mem[9][6]_i_1_n_0 ;
  wire \mem[9][7]_i_1_n_0 ;
  wire \mem[9][7]_i_2_n_0 ;
  wire \mem[9][7]_i_3_n_0 ;
  wire \mem[9][7]_i_4_n_0 ;
  wire \mem[9][7]_i_5_n_0 ;
  wire [7:0]\mem_reg[0]_62 ;
  wire [7:0]\mem_reg[10]_52 ;
  wire [7:0]\mem_reg[11]_51 ;
  wire [7:0]\mem_reg[12]_50 ;
  wire [7:0]\mem_reg[13]_49 ;
  wire [7:0]\mem_reg[14]_48 ;
  wire [7:0]\mem_reg[15]_47 ;
  wire [7:0]\mem_reg[16]_46 ;
  wire [7:0]\mem_reg[17]_45 ;
  wire [7:0]\mem_reg[18]_44 ;
  wire [7:0]\mem_reg[19]_43 ;
  wire [7:0]\mem_reg[1]_61 ;
  wire [7:0]\mem_reg[20]_42 ;
  wire [7:0]\mem_reg[21]_41 ;
  wire [7:0]\mem_reg[22]_40 ;
  wire [7:0]\mem_reg[23]_39 ;
  wire [7:0]\mem_reg[24]_38 ;
  wire [7:0]\mem_reg[25]_37 ;
  wire [7:0]\mem_reg[26]_36 ;
  wire [7:0]\mem_reg[27]_35 ;
  wire [7:0]\mem_reg[28]_34 ;
  wire [7:0]\mem_reg[29]_33 ;
  wire [7:0]\mem_reg[2]_60 ;
  wire [7:0]\mem_reg[30]_32 ;
  wire [7:0]\mem_reg[31]_31 ;
  wire [7:0]\mem_reg[32]_30 ;
  wire [7:0]\mem_reg[33]_29 ;
  wire [7:0]\mem_reg[34]_28 ;
  wire [7:0]\mem_reg[35]_27 ;
  wire [7:0]\mem_reg[36]_26 ;
  wire [7:0]\mem_reg[37]_25 ;
  wire [7:0]\mem_reg[38]_24 ;
  wire [7:0]\mem_reg[39]_23 ;
  wire [7:0]\mem_reg[3]_59 ;
  wire [7:0]\mem_reg[40]_22 ;
  wire [7:0]\mem_reg[41]_21 ;
  wire [7:0]\mem_reg[42]_20 ;
  wire [7:0]\mem_reg[43]_19 ;
  wire [7:0]\mem_reg[44]_18 ;
  wire [7:0]\mem_reg[45]_17 ;
  wire [7:0]\mem_reg[46]_16 ;
  wire [7:0]\mem_reg[47]_15 ;
  wire [7:0]\mem_reg[48]_14 ;
  wire [7:0]\mem_reg[49]_13 ;
  wire [7:0]\mem_reg[4]_58 ;
  wire [7:0]\mem_reg[50]_12 ;
  wire [7:0]\mem_reg[51]_11 ;
  wire [7:0]\mem_reg[52]_10 ;
  wire [7:0]\mem_reg[53]_9 ;
  wire [7:0]\mem_reg[54]_8 ;
  wire [7:0]\mem_reg[55]_7 ;
  wire [7:0]\mem_reg[56]_6 ;
  wire [7:0]\mem_reg[57]_5 ;
  wire [7:0]\mem_reg[58]_4 ;
  wire [7:0]\mem_reg[59]_3 ;
  wire [7:0]\mem_reg[5]_57 ;
  wire [7:0]\mem_reg[60]_2 ;
  wire [7:0]\mem_reg[61]_1 ;
  wire \mem_reg[62][0]_i_20_n_0 ;
  wire \mem_reg[62][0]_i_21_n_0 ;
  wire \mem_reg[62][0]_i_8_n_0 ;
  wire \mem_reg[62][1]_i_20_n_0 ;
  wire \mem_reg[62][1]_i_21_n_0 ;
  wire \mem_reg[62][1]_i_22_n_0 ;
  wire \mem_reg[62][1]_i_23_n_0 ;
  wire \mem_reg[62][1]_i_8_n_0 ;
  wire \mem_reg[62][1]_i_9_n_0 ;
  wire \mem_reg[62][2]_i_11_n_0 ;
  wire \mem_reg[62][2]_i_12_n_0 ;
  wire \mem_reg[62][2]_i_13_n_0 ;
  wire \mem_reg[62][2]_i_14_n_0 ;
  wire \mem_reg[62][2]_i_15_n_0 ;
  wire \mem_reg[62][2]_i_16_n_0 ;
  wire \mem_reg[62][2]_i_17_n_0 ;
  wire \mem_reg[62][2]_i_18_n_0 ;
  wire \mem_reg[62][2]_i_6_n_0 ;
  wire \mem_reg[62][2]_i_7_n_0 ;
  wire \mem_reg[62][2]_i_8_n_0 ;
  wire \mem_reg[62][2]_i_9_n_0 ;
  wire \mem_reg[62][3]_i_11_n_0 ;
  wire \mem_reg[62][3]_i_12_n_0 ;
  wire \mem_reg[62][3]_i_13_n_0 ;
  wire \mem_reg[62][3]_i_14_n_0 ;
  wire \mem_reg[62][3]_i_15_n_0 ;
  wire \mem_reg[62][3]_i_16_n_0 ;
  wire \mem_reg[62][3]_i_17_n_0 ;
  wire \mem_reg[62][3]_i_18_n_0 ;
  wire \mem_reg[62][3]_i_37_n_0 ;
  wire \mem_reg[62][3]_i_37_n_1 ;
  wire \mem_reg[62][3]_i_37_n_2 ;
  wire \mem_reg[62][3]_i_37_n_3 ;
  wire \mem_reg[62][3]_i_6_n_0 ;
  wire \mem_reg[62][3]_i_7_n_0 ;
  wire \mem_reg[62][3]_i_8_n_0 ;
  wire \mem_reg[62][3]_i_9_n_0 ;
  wire \mem_reg[62][4]_i_19_n_0 ;
  wire \mem_reg[62][4]_i_20_n_0 ;
  wire \mem_reg[62][4]_i_21_n_0 ;
  wire \mem_reg[62][4]_i_22_n_0 ;
  wire \mem_reg[62][4]_i_8_n_0 ;
  wire \mem_reg[62][4]_i_9_n_0 ;
  wire \mem_reg[62][5]_i_11_n_0 ;
  wire \mem_reg[62][5]_i_12_n_0 ;
  wire \mem_reg[62][5]_i_13_n_0 ;
  wire \mem_reg[62][5]_i_14_n_0 ;
  wire \mem_reg[62][5]_i_15_n_0 ;
  wire \mem_reg[62][5]_i_16_n_0 ;
  wire \mem_reg[62][5]_i_17_n_0 ;
  wire \mem_reg[62][5]_i_18_n_0 ;
  wire \mem_reg[62][5]_i_6_n_0 ;
  wire \mem_reg[62][5]_i_7_n_0 ;
  wire \mem_reg[62][5]_i_8_n_0 ;
  wire \mem_reg[62][5]_i_9_n_0 ;
  wire \mem_reg[62][6]_i_10_n_0 ;
  wire \mem_reg[62][6]_i_11_n_0 ;
  wire \mem_reg[62][6]_i_12_n_0 ;
  wire \mem_reg[62][6]_i_12_n_1 ;
  wire \mem_reg[62][6]_i_12_n_2 ;
  wire \mem_reg[62][6]_i_12_n_3 ;
  wire \mem_reg[62][6]_i_17_n_0 ;
  wire \mem_reg[62][6]_i_18_n_0 ;
  wire \mem_reg[62][6]_i_19_n_0 ;
  wire \mem_reg[62][6]_i_20_n_0 ;
  wire \mem_reg[62][6]_i_21_n_0 ;
  wire \mem_reg[62][6]_i_22_n_0 ;
  wire \mem_reg[62][6]_i_23_n_0 ;
  wire \mem_reg[62][6]_i_24_n_0 ;
  wire \mem_reg[62][6]_i_25_n_0 ;
  wire \mem_reg[62][6]_i_25_n_1 ;
  wire \mem_reg[62][6]_i_25_n_2 ;
  wire \mem_reg[62][6]_i_25_n_3 ;
  wire \mem_reg[62][6]_i_52_n_0 ;
  wire \mem_reg[62][6]_i_52_n_1 ;
  wire \mem_reg[62][6]_i_52_n_2 ;
  wire \mem_reg[62][6]_i_52_n_3 ;
  wire \mem_reg[62][6]_i_5_n_3 ;
  wire \mem_reg[62][6]_i_61_n_0 ;
  wire \mem_reg[62][6]_i_61_n_1 ;
  wire \mem_reg[62][6]_i_61_n_2 ;
  wire \mem_reg[62][6]_i_61_n_3 ;
  wire \mem_reg[62][6]_i_70_n_0 ;
  wire \mem_reg[62][6]_i_70_n_1 ;
  wire \mem_reg[62][6]_i_70_n_2 ;
  wire \mem_reg[62][6]_i_70_n_3 ;
  wire \mem_reg[62][6]_i_8_n_0 ;
  wire \mem_reg[62][6]_i_9_n_0 ;
  wire \mem_reg[62][7]_i_10_n_3 ;
  wire \mem_reg[62][7]_i_118_n_0 ;
  wire \mem_reg[62][7]_i_118_n_1 ;
  wire \mem_reg[62][7]_i_118_n_2 ;
  wire \mem_reg[62][7]_i_118_n_3 ;
  wire \mem_reg[62][7]_i_130_n_0 ;
  wire \mem_reg[62][7]_i_130_n_1 ;
  wire \mem_reg[62][7]_i_130_n_2 ;
  wire \mem_reg[62][7]_i_130_n_3 ;
  wire \mem_reg[62][7]_i_131_n_0 ;
  wire \mem_reg[62][7]_i_131_n_1 ;
  wire \mem_reg[62][7]_i_131_n_2 ;
  wire \mem_reg[62][7]_i_131_n_3 ;
  wire \mem_reg[62][7]_i_132_n_0 ;
  wire \mem_reg[62][7]_i_132_n_1 ;
  wire \mem_reg[62][7]_i_132_n_2 ;
  wire \mem_reg[62][7]_i_132_n_3 ;
  wire \mem_reg[62][7]_i_133_n_0 ;
  wire \mem_reg[62][7]_i_133_n_1 ;
  wire \mem_reg[62][7]_i_133_n_2 ;
  wire \mem_reg[62][7]_i_133_n_3 ;
  wire \mem_reg[62][7]_i_134_n_0 ;
  wire \mem_reg[62][7]_i_134_n_1 ;
  wire \mem_reg[62][7]_i_134_n_2 ;
  wire \mem_reg[62][7]_i_134_n_3 ;
  wire \mem_reg[62][7]_i_135_n_0 ;
  wire \mem_reg[62][7]_i_135_n_1 ;
  wire \mem_reg[62][7]_i_135_n_2 ;
  wire \mem_reg[62][7]_i_135_n_3 ;
  wire \mem_reg[62][7]_i_136_n_0 ;
  wire \mem_reg[62][7]_i_136_n_1 ;
  wire \mem_reg[62][7]_i_136_n_2 ;
  wire \mem_reg[62][7]_i_136_n_3 ;
  wire \mem_reg[62][7]_i_137_n_0 ;
  wire \mem_reg[62][7]_i_137_n_1 ;
  wire \mem_reg[62][7]_i_137_n_2 ;
  wire \mem_reg[62][7]_i_137_n_3 ;
  wire \mem_reg[62][7]_i_138_n_0 ;
  wire \mem_reg[62][7]_i_138_n_1 ;
  wire \mem_reg[62][7]_i_138_n_2 ;
  wire \mem_reg[62][7]_i_138_n_3 ;
  wire \mem_reg[62][7]_i_139_n_0 ;
  wire \mem_reg[62][7]_i_139_n_1 ;
  wire \mem_reg[62][7]_i_139_n_2 ;
  wire \mem_reg[62][7]_i_139_n_3 ;
  wire \mem_reg[62][7]_i_15_n_0 ;
  wire \mem_reg[62][7]_i_16_n_0 ;
  wire \mem_reg[62][7]_i_17_n_0 ;
  wire \mem_reg[62][7]_i_18_n_0 ;
  wire \mem_reg[62][7]_i_19_n_0 ;
  wire \mem_reg[62][7]_i_19_n_1 ;
  wire \mem_reg[62][7]_i_19_n_2 ;
  wire \mem_reg[62][7]_i_19_n_3 ;
  wire \mem_reg[62][7]_i_211_n_0 ;
  wire \mem_reg[62][7]_i_211_n_1 ;
  wire \mem_reg[62][7]_i_211_n_2 ;
  wire \mem_reg[62][7]_i_211_n_3 ;
  wire \mem_reg[62][7]_i_33_n_0 ;
  wire \mem_reg[62][7]_i_34_n_0 ;
  wire \mem_reg[62][7]_i_35_n_0 ;
  wire \mem_reg[62][7]_i_36_n_0 ;
  wire \mem_reg[62][7]_i_37_n_0 ;
  wire \mem_reg[62][7]_i_38_n_0 ;
  wire \mem_reg[62][7]_i_39_n_0 ;
  wire \mem_reg[62][7]_i_40_n_0 ;
  wire \mem_reg[62][7]_i_41_n_0 ;
  wire \mem_reg[62][7]_i_41_n_1 ;
  wire \mem_reg[62][7]_i_41_n_2 ;
  wire \mem_reg[62][7]_i_41_n_3 ;
  wire \mem_reg[62][7]_i_51_n_0 ;
  wire \mem_reg[62][7]_i_51_n_1 ;
  wire \mem_reg[62][7]_i_51_n_2 ;
  wire \mem_reg[62][7]_i_51_n_3 ;
  wire \mem_reg[62][7]_i_98_n_0 ;
  wire \mem_reg[62][7]_i_98_n_1 ;
  wire \mem_reg[62][7]_i_98_n_2 ;
  wire \mem_reg[62][7]_i_98_n_3 ;
  wire [7:0]\mem_reg[62]_0 ;
  wire [7:0]\mem_reg[63]_69 ;
  wire [7:0]\mem_reg[6]_56 ;
  wire [7:0]\mem_reg[7]_55 ;
  wire [7:0]\mem_reg[8]_54 ;
  wire [7:0]\mem_reg[9]_53 ;
  wire [15:0]mq0;
  wire [15:0]mq1;
  wire \optr[4]_i_1_n_0 ;
  wire \optr[4]_i_4_n_0 ;
  wire [4:0]optr_reg;
  wire ovf0;
  wire ovf0_reg_0;
  wire ovf1;
  wire ovf10_out;
  wire ovf1_i_1_n_0;
  wire [4:0]p_0_in;
  wire [7:0]p_0_in__0;
  wire [4:0]p_0_in__1;
  wire [21:0]p_1_in;
  wire \phase[0]_i_1_n_0 ;
  wire \phase[0]_rep_i_1__0_n_0 ;
  wire \phase[0]_rep_i_1_n_0 ;
  wire \phase[1]_i_1_n_0 ;
  wire \phase[1]_rep_i_1__0_n_0 ;
  wire \phase[1]_rep_i_1_n_0 ;
  wire \phase_reg[0]_rep__0_n_0 ;
  wire \phase_reg[0]_rep_n_0 ;
  wire \phase_reg[1]_rep__0_n_0 ;
  wire \phase_reg[1]_rep_n_0 ;
  wire \phase_reg_n_0_[0] ;
  wire \phase_reg_n_0_[1] ;
  wire pptr;
  wire \pptr[0]_i_1_n_0 ;
  wire \pptr[1]_i_1_n_0 ;
  wire \pptr[2]_i_1_n_0 ;
  wire \pptr[3]_i_2_n_0 ;
  wire \pptr[3]_i_3_n_0 ;
  wire \pptr_reg_n_0_[0] ;
  wire \pptr_reg_n_0_[1] ;
  wire \pptr_reg_n_0_[2] ;
  wire \pptr_reg_n_0_[3] ;
  wire prm;
  wire \prm[10][7]_i_1_n_0 ;
  wire \prm[11][7]_i_1_n_0 ;
  wire \prm[1][7]_i_1_n_0 ;
  wire \prm[2][7]_i_1_n_0 ;
  wire \prm[3][7]_i_1_n_0 ;
  wire \prm[4][7]_i_1_n_0 ;
  wire \prm[5][7]_i_1_n_0 ;
  wire \prm[6][7]_i_1_n_0 ;
  wire \prm[7][7]_i_1_n_0 ;
  wire \prm[8][7]_i_1_n_0 ;
  wire \prm[9][7]_i_1_n_0 ;
  wire [7:0]\prm_reg[0]_66 ;
  wire [7:0]\prm_reg[1]_67 ;
  wire [7:0]\prm_reg[2]_68 ;
  wire [7:0]\prm_reg[6]_63 ;
  wire [7:0]\prm_reg[7]_64 ;
  wire [7:0]\prm_reg[8]_65 ;
  wire \prm_reg_n_0_[11][0] ;
  wire \prm_reg_n_0_[11][1] ;
  wire \prm_reg_n_0_[11][2] ;
  wire \prm_reg_n_0_[11][3] ;
  wire \prm_reg_n_0_[11][4] ;
  wire \prm_reg_n_0_[11][5] ;
  wire \prm_reg_n_0_[11][6] ;
  wire \prm_reg_n_0_[11][7] ;
  wire \prm_reg_n_0_[5][0] ;
  wire \prm_reg_n_0_[5][1] ;
  wire \prm_reg_n_0_[5][2] ;
  wire \prm_reg_n_0_[5][3] ;
  wire \prm_reg_n_0_[5][4] ;
  wire \prm_reg_n_0_[5][5] ;
  wire \prm_reg_n_0_[5][6] ;
  wire \prm_reg_n_0_[5][7] ;
  wire [4:0]ptr;
  wire \ptr[0]_rep_i_1_n_0 ;
  wire \ptr[1]_rep_i_1__0_n_0 ;
  wire \ptr[1]_rep_i_1_n_0 ;
  wire \ptr[4]_i_1_n_0 ;
  wire \ptr_reg[0]_rep_0 ;
  wire \ptr_reg[0]_rep_1 ;
  wire \ptr_reg[0]_rep_2 ;
  wire \ptr_reg[0]_rep_n_0 ;
  wire \ptr_reg[1]_rep__0_n_0 ;
  wire \ptr_reg[1]_rep_n_0 ;
  wire [0:0]\q_data_reg[0] ;
  wire [3:0]\q_data_reg[10] ;
  wire [0:0]\q_data_reg[10]_0 ;
  wire [1:0]\q_data_reg[10]_1 ;
  wire [3:0]\q_data_reg[11] ;
  wire [3:0]\q_data_reg[13] ;
  wire [0:0]\q_data_reg[13]_0 ;
  wire [1:0]\q_data_reg[13]_1 ;
  wire [3:0]\q_data_reg[14] ;
  wire [3:0]\q_data_reg[15] ;
  wire [1:0]\q_data_reg[15]_0 ;
  wire [3:0]\q_data_reg[2] ;
  wire [1:0]\q_data_reg[2]_0 ;
  wire [3:0]\q_data_reg[3] ;
  wire [3:0]\q_data_reg[5] ;
  wire [0:0]\q_data_reg[5]_0 ;
  wire [1:0]\q_data_reg[5]_1 ;
  wire [3:0]\q_data_reg[6] ;
  wire [3:0]\q_data_reg[7] ;
  wire [1:0]\q_data_reg[7]_0 ;
  wire [0:0]\q_data_reg[8] ;
  wire \q_dst[5]_i_1_n_0 ;
  wire \q_dst_reg_n_0_[0] ;
  wire \q_dst_reg_n_0_[1] ;
  wire \q_dst_reg_n_0_[2] ;
  wire \q_dst_reg_n_0_[3] ;
  wire \q_dst_reg_n_0_[4] ;
  wire \q_n_reg[0] ;
  wire q_pair;
  wire q_pair_reg;
  wire q_single_i_2_n_0;
  wire q_single_reg_n_0;
  wire relu;
  wire [21:0]result0;
  wire \result0[0]_i_1_n_0 ;
  wire \result0[10]_i_1_n_0 ;
  wire \result0[11]_i_1_n_0 ;
  wire \result0[12]_i_1_n_0 ;
  wire \result0[13]_i_1_n_0 ;
  wire \result0[14]_i_1_n_0 ;
  wire \result0[15]_i_1_n_0 ;
  wire \result0[16]_i_1_n_0 ;
  wire \result0[17]_i_1_n_0 ;
  wire \result0[18]_i_1_n_0 ;
  wire \result0[19]_i_1_n_0 ;
  wire \result0[1]_i_1_n_0 ;
  wire \result0[20]_i_1_n_0 ;
  wire \result0[21]_i_1_n_0 ;
  wire \result0[21]_i_2_n_0 ;
  wire \result0[21]_i_3_n_0 ;
  wire \result0[2]_i_1_n_0 ;
  wire \result0[3]_i_1_n_0 ;
  wire \result0[4]_i_1_n_0 ;
  wire \result0[5]_i_1_n_0 ;
  wire \result0[6]_i_1_n_0 ;
  wire \result0[7]_i_1_n_0 ;
  wire \result0[8]_i_1_n_0 ;
  wire \result0[9]_i_1_n_0 ;
  wire [21:0]result1;
  wire \result1[0]_i_1_n_0 ;
  wire \result1[10]_i_1_n_0 ;
  wire \result1[11]_i_1_n_0 ;
  wire \result1[12]_i_1_n_0 ;
  wire \result1[13]_i_1_n_0 ;
  wire \result1[14]_i_1_n_0 ;
  wire \result1[15]_i_1_n_0 ;
  wire \result1[16]_i_1_n_0 ;
  wire \result1[17]_i_1_n_0 ;
  wire \result1[18]_i_1_n_0 ;
  wire \result1[19]_i_1_n_0 ;
  wire \result1[1]_i_1_n_0 ;
  wire \result1[20]_i_1_n_0 ;
  wire \result1[21]_i_1_n_0 ;
  wire \result1[21]_i_2_n_0 ;
  wire \result1[21]_i_3_n_0 ;
  wire \result1[2]_i_1_n_0 ;
  wire \result1[3]_i_1_n_0 ;
  wire \result1[4]_i_1_n_0 ;
  wire \result1[5]_i_1_n_0 ;
  wire \result1[6]_i_1_n_0 ;
  wire \result1[7]_i_1_n_0 ;
  wire \result1[8]_i_1_n_0 ;
  wire \result1[9]_i_1_n_0 ;
  wire rst;
  wire [20:0]s0;
  wire [21:0]s1__0;
  wire s_axi_aclk;
  wire [3:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire \s_axi_rdata[0]_i_2_n_0 ;
  wire \s_axi_rdata[10]_i_2_n_0 ;
  wire \s_axi_rdata[12]_i_2_n_0 ;
  wire \s_axi_rdata[14]_i_2_n_0 ;
  wire \s_axi_rdata[1]_i_2_n_0 ;
  wire \s_axi_rdata[20]_i_2_n_0 ;
  wire \s_axi_rdata[2]_i_2_n_0 ;
  wire \s_axi_rdata[30]_i_2_n_0 ;
  wire \s_axi_rdata[30]_i_3_n_0 ;
  wire \s_axi_rdata[31]_i_3_n_0 ;
  wire \s_axi_rdata[3]_i_2_n_0 ;
  wire \s_axi_rdata[4]_i_2_n_0 ;
  wire \s_axi_rdata[5]_i_2_n_0 ;
  wire \s_axi_rdata[6]_i_2_n_0 ;
  wire \s_axi_rdata[8]_i_2_n_0 ;
  wire \s_axi_rdata_reg[0] ;
  wire \s_axi_rdata_reg[1] ;
  wire \s_axi_rdata_reg[2] ;
  wire \s_axi_rdata_reg[6] ;
  wire \s_axi_rdata_reg[7] ;
  wire \s_axi_rdata_reg[7]_0 ;
  wire \s_axi_rdata_reg[7]_1 ;
  wire [0:0]sel0;
  wire [5:5]sel0__0;
  wire sel_reg_0;
  wire [5:0]shq0;
  wire \shq0[4]_i_1_n_0 ;
  wire shq1;
  wire \shq1[4]_i_1_n_0 ;
  wire \shq1_reg_n_0_[0] ;
  wire \shq1_reg_n_0_[1] ;
  wire \shq1_reg_n_0_[2] ;
  wire \shq1_reg_n_0_[3] ;
  wire \shq1_reg_n_0_[4] ;
  wire \shq1_reg_n_0_[5] ;
  wire step;
  wire [27:0]steps_reg;
  wire t_reg_i_10_n_0;
  wire t_reg_i_11_n_0;
  wire t_reg_i_12_n_0;
  wire t_reg_i_13_n_0;
  wire t_reg_i_14_n_0;
  wire t_reg_i_15_n_0;
  wire t_reg_i_16_n_0;
  wire t_reg_i_17_n_0;
  wire t_reg_i_2_n_0;
  wire t_reg_i_3_n_0;
  wire t_reg_i_4_n_0;
  wire t_reg_i_5_n_0;
  wire t_reg_i_6_n_0;
  wire t_reg_i_7_n_0;
  wire t_reg_i_8_n_0;
  wire t_reg_i_9_n_0;
  wire t_reg_n_100;
  wire t_reg_n_101;
  wire t_reg_n_102;
  wire t_reg_n_103;
  wire t_reg_n_104;
  wire t_reg_n_105;
  wire t_reg_n_64;
  wire t_reg_n_65;
  wire t_reg_n_66;
  wire t_reg_n_67;
  wire t_reg_n_68;
  wire t_reg_n_69;
  wire t_reg_n_70;
  wire t_reg_n_71;
  wire t_reg_n_72;
  wire t_reg_n_73;
  wire t_reg_n_74;
  wire t_reg_n_75;
  wire t_reg_n_76;
  wire t_reg_n_77;
  wire t_reg_n_78;
  wire t_reg_n_79;
  wire t_reg_n_80;
  wire t_reg_n_81;
  wire t_reg_n_82;
  wire t_reg_n_83;
  wire t_reg_n_84;
  wire t_reg_n_85;
  wire t_reg_n_86;
  wire t_reg_n_87;
  wire t_reg_n_88;
  wire t_reg_n_89;
  wire t_reg_n_90;
  wire t_reg_n_91;
  wire t_reg_n_92;
  wire t_reg_n_93;
  wire t_reg_n_94;
  wire t_reg_n_95;
  wire t_reg_n_96;
  wire t_reg_n_97;
  wire t_reg_n_98;
  wire t_reg_n_99;
  wire [24:0]v0;
  wire [24:0]v1;
  wire [24:0]vq0;
  wire \vq0[11]_i_2_n_0 ;
  wire \vq0[11]_i_3_n_0 ;
  wire \vq0[11]_i_4_n_0 ;
  wire \vq0[11]_i_5_n_0 ;
  wire \vq0[15]_i_2_n_0 ;
  wire \vq0[15]_i_3_n_0 ;
  wire \vq0[15]_i_4_n_0 ;
  wire \vq0[15]_i_5_n_0 ;
  wire \vq0[19]_i_2_n_0 ;
  wire \vq0[19]_i_3_n_0 ;
  wire \vq0[19]_i_4_n_0 ;
  wire \vq0[19]_i_5_n_0 ;
  wire \vq0[23]_i_2_n_0 ;
  wire \vq0[23]_i_3_n_0 ;
  wire \vq0[23]_i_4_n_0 ;
  wire \vq0[23]_i_5_n_0 ;
  wire \vq0[23]_i_6_n_0 ;
  wire \vq0[3]_i_2_n_0 ;
  wire \vq0[3]_i_3_n_0 ;
  wire \vq0[3]_i_4_n_0 ;
  wire \vq0[3]_i_5_n_0 ;
  wire \vq0[7]_i_2_n_0 ;
  wire \vq0[7]_i_3_n_0 ;
  wire \vq0[7]_i_4_n_0 ;
  wire \vq0[7]_i_5_n_0 ;
  wire \vq0_reg[11]_i_1_n_0 ;
  wire \vq0_reg[11]_i_1_n_1 ;
  wire \vq0_reg[11]_i_1_n_2 ;
  wire \vq0_reg[11]_i_1_n_3 ;
  wire \vq0_reg[15]_i_1_n_0 ;
  wire \vq0_reg[15]_i_1_n_1 ;
  wire \vq0_reg[15]_i_1_n_2 ;
  wire \vq0_reg[15]_i_1_n_3 ;
  wire \vq0_reg[19]_i_1_n_0 ;
  wire \vq0_reg[19]_i_1_n_1 ;
  wire \vq0_reg[19]_i_1_n_2 ;
  wire \vq0_reg[19]_i_1_n_3 ;
  wire \vq0_reg[23]_i_1_n_0 ;
  wire \vq0_reg[23]_i_1_n_1 ;
  wire \vq0_reg[23]_i_1_n_2 ;
  wire \vq0_reg[23]_i_1_n_3 ;
  wire \vq0_reg[3]_i_1_n_0 ;
  wire \vq0_reg[3]_i_1_n_1 ;
  wire \vq0_reg[3]_i_1_n_2 ;
  wire \vq0_reg[3]_i_1_n_3 ;
  wire \vq0_reg[7]_i_1_n_0 ;
  wire \vq0_reg[7]_i_1_n_1 ;
  wire \vq0_reg[7]_i_1_n_2 ;
  wire \vq0_reg[7]_i_1_n_3 ;
  wire \vq1[11]_i_2_n_0 ;
  wire \vq1[11]_i_3_n_0 ;
  wire \vq1[11]_i_4_n_0 ;
  wire \vq1[11]_i_5_n_0 ;
  wire \vq1[15]_i_2_n_0 ;
  wire \vq1[15]_i_3_n_0 ;
  wire \vq1[15]_i_4_n_0 ;
  wire \vq1[15]_i_5_n_0 ;
  wire \vq1[19]_i_2_n_0 ;
  wire \vq1[19]_i_3_n_0 ;
  wire \vq1[19]_i_4_n_0 ;
  wire \vq1[19]_i_5_n_0 ;
  wire \vq1[23]_i_2_n_0 ;
  wire \vq1[23]_i_3_n_0 ;
  wire \vq1[23]_i_4_n_0 ;
  wire \vq1[23]_i_5_n_0 ;
  wire \vq1[23]_i_6_n_0 ;
  wire \vq1[3]_i_2_n_0 ;
  wire \vq1[3]_i_3_n_0 ;
  wire \vq1[3]_i_4_n_0 ;
  wire \vq1[3]_i_5_n_0 ;
  wire \vq1[7]_i_2_n_0 ;
  wire \vq1[7]_i_3_n_0 ;
  wire \vq1[7]_i_4_n_0 ;
  wire \vq1[7]_i_5_n_0 ;
  wire \vq1_reg[11]_i_1_n_0 ;
  wire \vq1_reg[11]_i_1_n_1 ;
  wire \vq1_reg[11]_i_1_n_2 ;
  wire \vq1_reg[11]_i_1_n_3 ;
  wire \vq1_reg[15]_i_1_n_0 ;
  wire \vq1_reg[15]_i_1_n_1 ;
  wire \vq1_reg[15]_i_1_n_2 ;
  wire \vq1_reg[15]_i_1_n_3 ;
  wire \vq1_reg[19]_i_1_n_0 ;
  wire \vq1_reg[19]_i_1_n_1 ;
  wire \vq1_reg[19]_i_1_n_2 ;
  wire \vq1_reg[19]_i_1_n_3 ;
  wire \vq1_reg[23]_i_1_n_0 ;
  wire \vq1_reg[23]_i_1_n_1 ;
  wire \vq1_reg[23]_i_1_n_2 ;
  wire \vq1_reg[23]_i_1_n_3 ;
  wire \vq1_reg[3]_i_1_n_0 ;
  wire \vq1_reg[3]_i_1_n_1 ;
  wire \vq1_reg[3]_i_1_n_2 ;
  wire \vq1_reg[3]_i_1_n_3 ;
  wire \vq1_reg[7]_i_1_n_0 ;
  wire \vq1_reg[7]_i_1_n_1 ;
  wire \vq1_reg[7]_i_1_n_2 ;
  wire \vq1_reg[7]_i_1_n_3 ;
  wire \vq1_reg_n_0_[0] ;
  wire \vq1_reg_n_0_[10] ;
  wire \vq1_reg_n_0_[11] ;
  wire \vq1_reg_n_0_[12] ;
  wire \vq1_reg_n_0_[13] ;
  wire \vq1_reg_n_0_[14] ;
  wire \vq1_reg_n_0_[15] ;
  wire \vq1_reg_n_0_[16] ;
  wire \vq1_reg_n_0_[17] ;
  wire \vq1_reg_n_0_[18] ;
  wire \vq1_reg_n_0_[19] ;
  wire \vq1_reg_n_0_[1] ;
  wire \vq1_reg_n_0_[20] ;
  wire \vq1_reg_n_0_[21] ;
  wire \vq1_reg_n_0_[22] ;
  wire \vq1_reg_n_0_[23] ;
  wire \vq1_reg_n_0_[24] ;
  wire \vq1_reg_n_0_[2] ;
  wire \vq1_reg_n_0_[3] ;
  wire \vq1_reg_n_0_[4] ;
  wire \vq1_reg_n_0_[5] ;
  wire \vq1_reg_n_0_[6] ;
  wire \vq1_reg_n_0_[7] ;
  wire \vq1_reg_n_0_[8] ;
  wire \vq1_reg_n_0_[9] ;
  wire [3:1]\NLW_acc0_reg[15]_i_20_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc0_reg[15]_i_20_O_UNCONNECTED ;
  wire [3:1]\NLW_acc0_reg[15]_i_21_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc0_reg[15]_i_21_O_UNCONNECTED ;
  wire [3:1]\NLW_acc0_reg[15]_i_9_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc0_reg[15]_i_9_O_UNCONNECTED ;
  wire [3:1]\NLW_acc0_reg[21]_i_3_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc0_reg[21]_i_3_O_UNCONNECTED ;
  wire [3:1]\NLW_acc1_reg[15]_i_20_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc1_reg[15]_i_20_O_UNCONNECTED ;
  wire [3:1]\NLW_acc1_reg[15]_i_21_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc1_reg[15]_i_21_O_UNCONNECTED ;
  wire [3:1]\NLW_acc1_reg[15]_i_9_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc1_reg[15]_i_9_O_UNCONNECTED ;
  wire [3:1]\NLW_acc1_reg[21]_i_3_CO_UNCONNECTED ;
  wire [3:2]\NLW_acc1_reg[21]_i_3_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][6]_i_12_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][6]_i_25_O_UNCONNECTED ;
  wire [3:2]\NLW_mem_reg[62][6]_i_5_CO_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][6]_i_5_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][6]_i_52_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][6]_i_61_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][6]_i_70_O_UNCONNECTED ;
  wire [3:2]\NLW_mem_reg[62][7]_i_10_CO_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_10_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_139_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_19_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_21_CO_UNCONNECTED ;
  wire [3:1]\NLW_mem_reg[62][7]_i_21_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_211_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_41_O_UNCONNECTED ;
  wire [3:0]\NLW_mem_reg[62][7]_i_98_O_UNCONNECTED ;
  wire NLW_t_reg_CARRYCASCOUT_UNCONNECTED;
  wire NLW_t_reg_MULTSIGNOUT_UNCONNECTED;
  wire NLW_t_reg_OVERFLOW_UNCONNECTED;
  wire NLW_t_reg_PATTERNBDETECT_UNCONNECTED;
  wire NLW_t_reg_PATTERNDETECT_UNCONNECTED;
  wire NLW_t_reg_UNDERFLOW_UNCONNECTED;
  wire [29:0]NLW_t_reg_ACOUT_UNCONNECTED;
  wire [17:0]NLW_t_reg_BCOUT_UNCONNECTED;
  wire [3:0]NLW_t_reg_CARRYOUT_UNCONNECTED;
  wire [47:42]NLW_t_reg_P_UNCONNECTED;
  wire [47:0]NLW_t_reg_PCOUT_UNCONNECTED;
  wire [3:0]\NLW_vq0_reg[24]_i_1_CO_UNCONNECTED ;
  wire [3:1]\NLW_vq0_reg[24]_i_1_O_UNCONNECTED ;
  wire [3:0]\NLW_vq1_reg[24]_i_1_CO_UNCONNECTED ;
  wire [3:1]\NLW_vq1_reg[24]_i_1_O_UNCONNECTED ;

  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[0]_i_1 
       (.I0(s0[0]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[10]_i_1 
       (.I0(s0[10]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[11]_i_1 
       (.I0(s0[11]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[11]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hF8888000)) 
    \acc0[11]_i_18 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[2]),
        .I2(Q[1]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(\acc0[11]_i_33_n_0 ),
        .O(\acc0[11]_i_18_n_0 ));
  LUT5 #(
    .INIT(32'hF2222000)) 
    \acc0[11]_i_19 
       (.I0(Q[2]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(Q[1]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .I4(\acc0[11]_i_34_n_0 ),
        .O(\acc0[11]_i_19_n_0 ));
  LUT6 #(
    .INIT(64'h8000F88880008000)) 
    \acc0[11]_i_20 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[0]),
        .I2(Q[2]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .I4(\mem[62][3]_i_4_n_0 ),
        .I5(Q[1]),
        .O(\acc0[11]_i_20_n_0 ));
  LUT6 #(
    .INIT(64'hF222200020002000)) 
    \acc0[11]_i_21 
       (.I0(Q[0]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[2]),
        .I4(Q[1]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[11]_i_21_n_0 ));
  LUT6 #(
    .INIT(64'h956A6A6A6A959595)) 
    \acc0[11]_i_22 
       (.I0(\acc0[11]_i_18_n_0 ),
        .I1(\mem[62][6]_i_4_n_0 ),
        .I2(Q[1]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(Q[2]),
        .I5(\acc0[15]_i_56_n_0 ),
        .O(\acc0[11]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    \acc0[11]_i_23 
       (.I0(\acc0[11]_i_19_n_0 ),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[1]),
        .I3(Q[2]),
        .I4(\mem[62][4]_i_4_n_0 ),
        .I5(\acc0[11]_i_33_n_0 ),
        .O(\acc0[11]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'h956A95956A956A6A)) 
    \acc0[11]_i_24 
       (.I0(\acc0[11]_i_20_n_0 ),
        .I1(\mem[62][4]_i_4_n_0 ),
        .I2(Q[1]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(Q[2]),
        .I5(\acc0[11]_i_34_n_0 ),
        .O(\acc0[11]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'h8878778777878878)) 
    \acc0[11]_i_25 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[0]),
        .I2(Q[1]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(\acc0[11]_i_21_n_0 ),
        .I5(\acc0[11]_i_35_n_0 ),
        .O(\acc0[11]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'h2DDDD222D222D222)) 
    \acc0[11]_i_26 
       (.I0(Q[3]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[5]),
        .I4(Q[4]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[11]_i_26_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc0[11]_i_27 
       (.I0(Q[4]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[5]),
        .O(\acc0[11]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[11]_i_28 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[4]),
        .O(\acc0[11]_i_28_n_0 ));
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \acc0[11]_i_29 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[4]),
        .I2(Q[5]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .I4(\acc0[11]_i_26_n_0 ),
        .O(\acc0[11]_i_29_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[11]_i_3 
       (.I0(acc0__0[11]),
        .I1(\acc0_reg[15]_i_2_0 [0]),
        .O(\acc0[11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    \acc0[11]_i_30 
       (.I0(Q[4]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[5]),
        .I4(Q[3]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[11]_i_30_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc0[11]_i_31 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[4]),
        .I2(Q[3]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .O(\acc0[11]_i_31_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[11]_i_32 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[3]),
        .O(\acc0[11]_i_32_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[11]_i_33 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[0]),
        .O(\acc0[11]_i_33_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[11]_i_34 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[0]),
        .O(\acc0[11]_i_34_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[11]_i_35 
       (.I0(\mem[62][2]_i_4_n_0 ),
        .I1(Q[2]),
        .O(\acc0[11]_i_35_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[11]_i_4 
       (.I0(acc0__0[10]),
        .I1(\acc0_reg[11]_i_2_0 [3]),
        .O(\acc0[11]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[11]_i_5 
       (.I0(acc0__0[9]),
        .I1(\acc0_reg[11]_i_2_0 [2]),
        .O(\acc0[11]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[11]_i_6 
       (.I0(acc0__0[8]),
        .I1(\acc0_reg[11]_i_2_0 [1]),
        .O(\acc0[11]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[12]_i_1 
       (.I0(s0[12]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[13]_i_1 
       (.I0(s0[13]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[14]_i_1 
       (.I0(s0[14]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[15]_i_1 
       (.I0(s0[15]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[15]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0777)) 
    \acc0[15]_i_18 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[7]),
        .I2(\mem[62][7]_i_7_n_0 ),
        .I3(Q[6]),
        .O(\acc0[15]_i_18_n_0 ));
  LUT4 #(
    .INIT(16'hCB77)) 
    \acc0[15]_i_19 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[7]),
        .I2(Q[6]),
        .I3(\mem[62][7]_i_7_n_0 ),
        .O(\acc0[15]_i_19_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc0[15]_i_24 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[6]),
        .I2(Q[7]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .O(\acc0[15]_i_24_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc0[15]_i_25 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[6]),
        .I2(Q[7]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .O(\acc0[15]_i_25_n_0 ));
  LUT4 #(
    .INIT(16'h8088)) 
    \acc0[15]_i_26 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[6]),
        .I2(\mem[62][3]_i_4_n_0 ),
        .I3(Q[7]),
        .O(\acc0[15]_i_26_n_0 ));
  LUT4 #(
    .INIT(16'h0070)) 
    \acc0[15]_i_27 
       (.I0(Q[7]),
        .I1(\mem[62][2]_i_4_n_0 ),
        .I2(Q[6]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .O(\acc0[15]_i_27_n_0 ));
  LUT5 #(
    .INIT(32'h74B48888)) 
    \acc0[15]_i_28 
       (.I0(\mem[62][7]_i_7_n_0 ),
        .I1(Q[6]),
        .I2(Q[7]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(\mem[62][6]_i_4_n_0 ),
        .O(\acc0[15]_i_28_n_0 ));
  LUT5 #(
    .INIT(32'h8B4B7777)) 
    \acc0[15]_i_29 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[6]),
        .I2(Q[7]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .I4(\mem[62][5]_i_4_n_0 ),
        .O(\acc0[15]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'h48BB7777)) 
    \acc0[15]_i_30 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[6]),
        .I2(\mem[62][3]_i_4_n_0 ),
        .I3(Q[7]),
        .I4(\mem[62][4]_i_4_n_0 ),
        .O(\acc0[15]_i_30_n_0 ));
  LUT5 #(
    .INIT(32'h77778B4B)) 
    \acc0[15]_i_31 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[6]),
        .I2(Q[7]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .I4(\mem[62][3]_i_4_n_0 ),
        .O(\acc0[15]_i_31_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc0[15]_i_32 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[5]),
        .I2(\mem[62][7]_i_7_n_0 ),
        .I3(Q[4]),
        .O(\acc0[15]_i_32_n_0 ));
  LUT5 #(
    .INIT(32'h8000EAC0)) 
    \acc0[15]_i_33 
       (.I0(Q[4]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[5]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(\acc0[15]_i_55_n_0 ),
        .O(\acc0[15]_i_33_n_0 ));
  LUT4 #(
    .INIT(16'h3B77)) 
    \acc0[15]_i_34 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[5]),
        .I2(Q[4]),
        .I3(\mem[62][7]_i_7_n_0 ),
        .O(\acc0[15]_i_34_n_0 ));
  LUT6 #(
    .INIT(64'h25404FBFF03FCF3F)) 
    \acc0[15]_i_35 
       (.I0(Q[3]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[5]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(Q[4]),
        .I5(\mem[62][7]_i_7_n_0 ),
        .O(\acc0[15]_i_35_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc0[15]_i_36 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[2]),
        .I2(\mem[62][7]_i_7_n_0 ),
        .I3(Q[1]),
        .O(\acc0[15]_i_36_n_0 ));
  LUT5 #(
    .INIT(32'h8000EAC0)) 
    \acc0[15]_i_37 
       (.I0(Q[1]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[2]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(\acc0[15]_i_56_n_0 ),
        .O(\acc0[15]_i_37_n_0 ));
  LUT4 #(
    .INIT(16'h3B77)) 
    \acc0[15]_i_38 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[2]),
        .I2(Q[1]),
        .I3(\mem[62][7]_i_7_n_0 ),
        .O(\acc0[15]_i_38_n_0 ));
  LUT6 #(
    .INIT(64'h25404FBFF03FCF3F)) 
    \acc0[15]_i_39 
       (.I0(Q[0]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[2]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(Q[1]),
        .I5(\mem[62][7]_i_7_n_0 ),
        .O(\acc0[15]_i_39_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[15]_i_4 
       (.I0(\acc0_reg[15]_0 ),
        .I1(acc0__0[15]),
        .O(\acc0[15]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hF8888000)) 
    \acc0[15]_i_40 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[5]),
        .I2(Q[4]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(\acc0[15]_i_57_n_0 ),
        .O(\acc0[15]_i_40_n_0 ));
  LUT5 #(
    .INIT(32'hF2222000)) 
    \acc0[15]_i_41 
       (.I0(Q[5]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(Q[4]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .I4(\acc0[15]_i_58_n_0 ),
        .O(\acc0[15]_i_41_n_0 ));
  LUT6 #(
    .INIT(64'h8000F88880008000)) 
    \acc0[15]_i_42 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[3]),
        .I2(Q[5]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .I4(\mem[62][3]_i_4_n_0 ),
        .I5(Q[4]),
        .O(\acc0[15]_i_42_n_0 ));
  LUT6 #(
    .INIT(64'hF222200020002000)) 
    \acc0[15]_i_43 
       (.I0(Q[3]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[5]),
        .I4(Q[4]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[15]_i_43_n_0 ));
  LUT6 #(
    .INIT(64'h956A6A6A6A959595)) 
    \acc0[15]_i_44 
       (.I0(\acc0[15]_i_40_n_0 ),
        .I1(\mem[62][6]_i_4_n_0 ),
        .I2(Q[4]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(Q[5]),
        .I5(\acc0[15]_i_55_n_0 ),
        .O(\acc0[15]_i_44_n_0 ));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    \acc0[15]_i_45 
       (.I0(\acc0[15]_i_41_n_0 ),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[4]),
        .I3(Q[5]),
        .I4(\mem[62][4]_i_4_n_0 ),
        .I5(\acc0[15]_i_57_n_0 ),
        .O(\acc0[15]_i_45_n_0 ));
  LUT6 #(
    .INIT(64'h956A95956A956A6A)) 
    \acc0[15]_i_46 
       (.I0(\acc0[15]_i_42_n_0 ),
        .I1(\mem[62][4]_i_4_n_0 ),
        .I2(Q[4]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(Q[5]),
        .I5(\acc0[15]_i_58_n_0 ),
        .O(\acc0[15]_i_46_n_0 ));
  LUT6 #(
    .INIT(64'h8878778777878878)) 
    \acc0[15]_i_47 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[3]),
        .I2(Q[4]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(\acc0[15]_i_43_n_0 ),
        .I5(\acc0[15]_i_59_n_0 ),
        .O(\acc0[15]_i_47_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \acc0[15]_i_48 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[7]),
        .O(\acc0[15]_i_48_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_49 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[7]),
        .O(\acc0[15]_i_49_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[15]_i_5 
       (.I0(acc0__0[14]),
        .I1(\acc0_reg[15]_i_2_0 [3]),
        .O(\acc0[15]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \acc0[15]_i_50 
       (.I0(Q[7]),
        .I1(\mem[62][0]_i_4_n_0 ),
        .O(\acc0[15]_i_50_n_0 ));
  LUT5 #(
    .INIT(32'h4848B748)) 
    \acc0[15]_i_51 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[7]),
        .I2(\mem[62][2]_i_4_n_0 ),
        .I3(Q[6]),
        .I4(\mem[62][3]_i_4_n_0 ),
        .O(\acc0[15]_i_51_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc0[15]_i_52 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[7]),
        .I2(Q[6]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[15]_i_52_n_0 ));
  LUT4 #(
    .INIT(16'h8777)) 
    \acc0[15]_i_53 
       (.I0(Q[7]),
        .I1(\mem[62][0]_i_4_n_0 ),
        .I2(Q[6]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .O(\acc0[15]_i_53_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_54 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[6]),
        .O(\acc0[15]_i_54_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_55 
       (.I0(\mem[62][7]_i_7_n_0 ),
        .I1(Q[3]),
        .O(\acc0[15]_i_55_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_56 
       (.I0(\mem[62][7]_i_7_n_0 ),
        .I1(Q[0]),
        .O(\acc0[15]_i_56_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_57 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[3]),
        .O(\acc0[15]_i_57_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_58 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[3]),
        .O(\acc0[15]_i_58_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[15]_i_59 
       (.I0(\mem[62][2]_i_4_n_0 ),
        .I1(Q[5]),
        .O(\acc0[15]_i_59_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[15]_i_6 
       (.I0(acc0__0[13]),
        .I1(\acc0_reg[15]_i_2_0 [2]),
        .O(\acc0[15]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[15]_i_7 
       (.I0(acc0__0[12]),
        .I1(\acc0_reg[15]_i_2_0 [1]),
        .O(\acc0[15]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[16]_i_1 
       (.I0(s0[16]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[16]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[17]_i_1 
       (.I0(s0[17]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[17]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[18]_i_1 
       (.I0(s0[18]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[18]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[19]_i_1 
       (.I0(s0[19]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[19]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \acc0[19]_i_3 
       (.I0(\acc0_reg[15]_0 ),
        .O(\acc0[19]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc0[19]_i_4 
       (.I0(acc0__0[18]),
        .I1(acc0__0[19]),
        .O(\acc0[19]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc0[19]_i_5 
       (.I0(acc0__0[17]),
        .I1(acc0__0[18]),
        .O(\acc0[19]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc0[19]_i_6 
       (.I0(acc0__0[16]),
        .I1(acc0__0[17]),
        .O(\acc0[19]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[19]_i_7 
       (.I0(\acc0_reg[15]_0 ),
        .I1(acc0__0[16]),
        .O(\acc0[19]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[1]_i_1 
       (.I0(s0[1]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[20]_i_1 
       (.I0(s0[20]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[20]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAA8FFFCAAA8AAA8)) 
    \acc0[21]_i_1 
       (.I0(q_pair),
        .I1(\acc0_reg[21]_0 ),
        .I2(\acc0_reg[21]_1 ),
        .I3(\acc0_reg[21]_2 ),
        .I4(\ptr_reg[0]_rep_2 ),
        .I5(\ptr_reg[0]_rep_1 ),
        .O(E));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[21]_i_2 
       (.I0(O),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[21]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc0[21]_i_4 
       (.I0(acc0__0[20]),
        .I1(acc0__0[21]),
        .O(\acc0[21]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc0[21]_i_5 
       (.I0(acc0__0[19]),
        .I1(acc0__0[20]),
        .O(\acc0[21]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[2]_i_1 
       (.I0(s0[2]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[3]_i_1 
       (.I0(s0[3]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[3]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[3]_i_10 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[1]),
        .O(\acc0[3]_i_10_n_0 ));
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \acc0[3]_i_11 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[1]),
        .I2(Q[2]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .I4(\acc0[3]_i_8_n_0 ),
        .O(\acc0[3]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    \acc0[3]_i_12 
       (.I0(Q[1]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[2]),
        .I4(Q[0]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[3]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc0[3]_i_13 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .O(\acc0[3]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc0[3]_i_14 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[0]),
        .O(\acc0[3]_i_14_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[3]_i_3 
       (.I0(acc0__0[3]),
        .I1(\acc0_reg[7]_i_2_0 [0]),
        .O(\acc0[3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[3]_i_4 
       (.I0(acc0__0[2]),
        .I1(\acc0_reg[3]_i_7_n_5 ),
        .O(\acc0[3]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[3]_i_5 
       (.I0(acc0__0[1]),
        .I1(\acc0_reg[3]_i_7_n_6 ),
        .O(\acc0[3]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[3]_i_6 
       (.I0(acc0__0[0]),
        .I1(\acc0_reg[3]_i_7_n_7 ),
        .O(\acc0[3]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h2DDDD222D222D222)) 
    \acc0[3]_i_8 
       (.I0(Q[0]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[2]),
        .I4(Q[1]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc0[3]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc0[3]_i_9 
       (.I0(Q[1]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[2]),
        .O(\acc0[3]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[4]_i_1 
       (.I0(s0[4]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[5]_i_1 
       (.I0(s0[5]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[6]_i_1 
       (.I0(s0[6]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[7]_i_1 
       (.I0(s0[7]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[7]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[7]_i_3 
       (.I0(acc0__0[7]),
        .I1(\acc0_reg[11]_i_2_0 [0]),
        .O(\acc0[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[7]_i_4 
       (.I0(acc0__0[6]),
        .I1(\acc0_reg[7]_i_2_0 [3]),
        .O(\acc0[7]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[7]_i_5 
       (.I0(acc0__0[5]),
        .I1(\acc0_reg[7]_i_2_0 [2]),
        .O(\acc0[7]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc0[7]_i_6 
       (.I0(acc0__0[4]),
        .I1(\acc0_reg[7]_i_2_0 [1]),
        .O(\acc0[7]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[8]_i_1 
       (.I0(s0[8]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A8A8A8A8A888)) 
    \acc0[9]_i_1 
       (.I0(s0[9]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\acc0[9]_i_1_n_0 ));
  FDRE \acc0_reg[0] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[0]_i_1_n_0 ),
        .Q(acc0__0[0]),
        .R(rst));
  FDRE \acc0_reg[10] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[10]_i_1_n_0 ),
        .Q(acc0__0[10]),
        .R(rst));
  FDRE \acc0_reg[11] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[11]_i_1_n_0 ),
        .Q(acc0__0[11]),
        .R(rst));
  CARRY4 \acc0_reg[11]_i_16 
       (.CI(\acc0_reg[3]_i_7_n_0 ),
        .CO({\acc0_reg[11]_i_16_n_0 ,\acc0_reg[11]_i_16_n_1 ,\acc0_reg[11]_i_16_n_2 ,\acc0_reg[11]_i_16_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[11]_i_18_n_0 ,\acc0[11]_i_19_n_0 ,\acc0[11]_i_20_n_0 ,\acc0[11]_i_21_n_0 }),
        .O(\q_data_reg[2] ),
        .S({\acc0[11]_i_22_n_0 ,\acc0[11]_i_23_n_0 ,\acc0[11]_i_24_n_0 ,\acc0[11]_i_25_n_0 }));
  CARRY4 \acc0_reg[11]_i_17 
       (.CI(1'b0),
        .CO({\acc0_reg[11]_i_17_n_0 ,\acc0_reg[11]_i_17_n_1 ,\acc0_reg[11]_i_17_n_2 ,\acc0_reg[11]_i_17_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[11]_i_26_n_0 ,\acc0[11]_i_27_n_0 ,\acc0[11]_i_28_n_0 ,1'b0}),
        .O(\q_data_reg[3] ),
        .S({\acc0[11]_i_29_n_0 ,\acc0[11]_i_30_n_0 ,\acc0[11]_i_31_n_0 ,\acc0[11]_i_32_n_0 }));
  CARRY4 \acc0_reg[11]_i_2 
       (.CI(\acc0_reg[7]_i_2_n_0 ),
        .CO({\acc0_reg[11]_i_2_n_0 ,\acc0_reg[11]_i_2_n_1 ,\acc0_reg[11]_i_2_n_2 ,\acc0_reg[11]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[11:8]),
        .O(s0[11:8]),
        .S({\acc0[11]_i_3_n_0 ,\acc0[11]_i_4_n_0 ,\acc0[11]_i_5_n_0 ,\acc0[11]_i_6_n_0 }));
  FDRE \acc0_reg[12] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[12]_i_1_n_0 ),
        .Q(acc0__0[12]),
        .R(rst));
  FDRE \acc0_reg[13] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[13]_i_1_n_0 ),
        .Q(acc0__0[13]),
        .R(rst));
  FDRE \acc0_reg[14] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[14]_i_1_n_0 ),
        .Q(acc0__0[14]),
        .R(rst));
  FDRE \acc0_reg[15] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[15]_i_1_n_0 ),
        .Q(acc0__0[15]),
        .R(rst));
  CARRY4 \acc0_reg[15]_i_17 
       (.CI(\acc0_reg[15]_i_23_n_0 ),
        .CO({\acc0_reg[15]_i_17_n_0 ,\acc0_reg[15]_i_17_n_1 ,\acc0_reg[15]_i_17_n_2 ,\acc0_reg[15]_i_17_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[15]_i_24_n_0 ,\acc0[15]_i_25_n_0 ,\acc0[15]_i_26_n_0 ,\acc0[15]_i_27_n_0 }),
        .O(\q_data_reg[6] ),
        .S({\acc0[15]_i_28_n_0 ,\acc0[15]_i_29_n_0 ,\acc0[15]_i_30_n_0 ,\acc0[15]_i_31_n_0 }));
  CARRY4 \acc0_reg[15]_i_2 
       (.CI(\acc0_reg[11]_i_2_n_0 ),
        .CO({\acc0_reg[15]_i_2_n_0 ,\acc0_reg[15]_i_2_n_1 ,\acc0_reg[15]_i_2_n_2 ,\acc0_reg[15]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0_reg[15]_0 ,acc0__0[14:12]}),
        .O(s0[15:12]),
        .S({\acc0[15]_i_4_n_0 ,\acc0[15]_i_5_n_0 ,\acc0[15]_i_6_n_0 ,\acc0[15]_i_7_n_0 }));
  CARRY4 \acc0_reg[15]_i_20 
       (.CI(\acc0_reg[15]_i_22_n_0 ),
        .CO({\NLW_acc0_reg[15]_i_20_CO_UNCONNECTED [3],\q_data_reg[5]_0 ,\NLW_acc0_reg[15]_i_20_CO_UNCONNECTED [1],\acc0_reg[15]_i_20_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,\acc0[15]_i_32_n_0 ,\acc0[15]_i_33_n_0 }),
        .O({\NLW_acc0_reg[15]_i_20_O_UNCONNECTED [3:2],\q_data_reg[5]_1 }),
        .S({1'b0,1'b1,\acc0[15]_i_34_n_0 ,\acc0[15]_i_35_n_0 }));
  CARRY4 \acc0_reg[15]_i_21 
       (.CI(\acc0_reg[11]_i_16_n_0 ),
        .CO({\NLW_acc0_reg[15]_i_21_CO_UNCONNECTED [3],CO,\NLW_acc0_reg[15]_i_21_CO_UNCONNECTED [1],\acc0_reg[15]_i_21_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,\acc0[15]_i_36_n_0 ,\acc0[15]_i_37_n_0 }),
        .O({\NLW_acc0_reg[15]_i_21_O_UNCONNECTED [3:2],\q_data_reg[2]_0 }),
        .S({1'b0,1'b1,\acc0[15]_i_38_n_0 ,\acc0[15]_i_39_n_0 }));
  CARRY4 \acc0_reg[15]_i_22 
       (.CI(\acc0_reg[11]_i_17_n_0 ),
        .CO({\acc0_reg[15]_i_22_n_0 ,\acc0_reg[15]_i_22_n_1 ,\acc0_reg[15]_i_22_n_2 ,\acc0_reg[15]_i_22_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[15]_i_40_n_0 ,\acc0[15]_i_41_n_0 ,\acc0[15]_i_42_n_0 ,\acc0[15]_i_43_n_0 }),
        .O(\q_data_reg[5] ),
        .S({\acc0[15]_i_44_n_0 ,\acc0[15]_i_45_n_0 ,\acc0[15]_i_46_n_0 ,\acc0[15]_i_47_n_0 }));
  CARRY4 \acc0_reg[15]_i_23 
       (.CI(1'b0),
        .CO({\acc0_reg[15]_i_23_n_0 ,\acc0_reg[15]_i_23_n_1 ,\acc0_reg[15]_i_23_n_2 ,\acc0_reg[15]_i_23_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[15]_i_48_n_0 ,\acc0[15]_i_49_n_0 ,\acc0[15]_i_50_n_0 ,1'b0}),
        .O(\q_data_reg[7] ),
        .S({\acc0[15]_i_51_n_0 ,\acc0[15]_i_52_n_0 ,\acc0[15]_i_53_n_0 ,\acc0[15]_i_54_n_0 }));
  CARRY4 \acc0_reg[15]_i_9 
       (.CI(\acc0_reg[15]_i_17_n_0 ),
        .CO({\NLW_acc0_reg[15]_i_9_CO_UNCONNECTED [3:1],\acc0_reg[15]_i_9_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\acc0[15]_i_18_n_0 }),
        .O({\NLW_acc0_reg[15]_i_9_O_UNCONNECTED [3:2],\q_data_reg[7]_0 }),
        .S({1'b0,1'b0,1'b1,\acc0[15]_i_19_n_0 }));
  FDRE \acc0_reg[16] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[16]_i_1_n_0 ),
        .Q(acc0__0[16]),
        .R(rst));
  FDRE \acc0_reg[17] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[17]_i_1_n_0 ),
        .Q(acc0__0[17]),
        .R(rst));
  FDRE \acc0_reg[18] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[18]_i_1_n_0 ),
        .Q(acc0__0[18]),
        .R(rst));
  FDRE \acc0_reg[19] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[19]_i_1_n_0 ),
        .Q(acc0__0[19]),
        .R(rst));
  CARRY4 \acc0_reg[19]_i_2 
       (.CI(\acc0_reg[15]_i_2_n_0 ),
        .CO({\acc0_reg[19]_i_2_n_0 ,\acc0_reg[19]_i_2_n_1 ,\acc0_reg[19]_i_2_n_2 ,\acc0_reg[19]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({acc0__0[18:16],\acc0[19]_i_3_n_0 }),
        .O(s0[19:16]),
        .S({\acc0[19]_i_4_n_0 ,\acc0[19]_i_5_n_0 ,\acc0[19]_i_6_n_0 ,\acc0[19]_i_7_n_0 }));
  FDRE \acc0_reg[1] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[1]_i_1_n_0 ),
        .Q(acc0__0[1]),
        .R(rst));
  FDRE \acc0_reg[20] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[20]_i_1_n_0 ),
        .Q(acc0__0[20]),
        .R(rst));
  FDRE \acc0_reg[21] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[21]_i_2_n_0 ),
        .Q(acc0__0[21]),
        .R(rst));
  CARRY4 \acc0_reg[21]_i_3 
       (.CI(\acc0_reg[19]_i_2_n_0 ),
        .CO({\NLW_acc0_reg[21]_i_3_CO_UNCONNECTED [3],\acc0_reg[20]_0 ,\NLW_acc0_reg[21]_i_3_CO_UNCONNECTED [1],\acc0_reg[21]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,acc0__0[20:19]}),
        .O({\NLW_acc0_reg[21]_i_3_O_UNCONNECTED [3:2],O,s0[20]}),
        .S({1'b0,1'b1,\acc0[21]_i_4_n_0 ,\acc0[21]_i_5_n_0 }));
  FDRE \acc0_reg[2] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[2]_i_1_n_0 ),
        .Q(acc0__0[2]),
        .R(rst));
  FDRE \acc0_reg[3] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[3]_i_1_n_0 ),
        .Q(acc0__0[3]),
        .R(rst));
  CARRY4 \acc0_reg[3]_i_2 
       (.CI(1'b0),
        .CO({\acc0_reg[3]_i_2_n_0 ,\acc0_reg[3]_i_2_n_1 ,\acc0_reg[3]_i_2_n_2 ,\acc0_reg[3]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[3:0]),
        .O(s0[3:0]),
        .S({\acc0[3]_i_3_n_0 ,\acc0[3]_i_4_n_0 ,\acc0[3]_i_5_n_0 ,\acc0[3]_i_6_n_0 }));
  CARRY4 \acc0_reg[3]_i_7 
       (.CI(1'b0),
        .CO({\acc0_reg[3]_i_7_n_0 ,\acc0_reg[3]_i_7_n_1 ,\acc0_reg[3]_i_7_n_2 ,\acc0_reg[3]_i_7_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc0[3]_i_8_n_0 ,\acc0[3]_i_9_n_0 ,\acc0[3]_i_10_n_0 ,1'b0}),
        .O({\q_data_reg[0] ,\acc0_reg[3]_i_7_n_5 ,\acc0_reg[3]_i_7_n_6 ,\acc0_reg[3]_i_7_n_7 }),
        .S({\acc0[3]_i_11_n_0 ,\acc0[3]_i_12_n_0 ,\acc0[3]_i_13_n_0 ,\acc0[3]_i_14_n_0 }));
  FDRE \acc0_reg[4] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[4]_i_1_n_0 ),
        .Q(acc0__0[4]),
        .R(rst));
  FDRE \acc0_reg[5] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[5]_i_1_n_0 ),
        .Q(acc0__0[5]),
        .R(rst));
  FDRE \acc0_reg[6] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[6]_i_1_n_0 ),
        .Q(acc0__0[6]),
        .R(rst));
  FDRE \acc0_reg[7] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[7]_i_1_n_0 ),
        .Q(acc0__0[7]),
        .R(rst));
  CARRY4 \acc0_reg[7]_i_2 
       (.CI(\acc0_reg[3]_i_2_n_0 ),
        .CO({\acc0_reg[7]_i_2_n_0 ,\acc0_reg[7]_i_2_n_1 ,\acc0_reg[7]_i_2_n_2 ,\acc0_reg[7]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[7:4]),
        .O(s0[7:4]),
        .S({\acc0[7]_i_3_n_0 ,\acc0[7]_i_4_n_0 ,\acc0[7]_i_5_n_0 ,\acc0[7]_i_6_n_0 }));
  FDRE \acc0_reg[8] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[8]_i_1_n_0 ),
        .Q(acc0__0[8]),
        .R(rst));
  FDRE \acc0_reg[9] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(\acc0[9]_i_1_n_0 ),
        .Q(acc0__0[9]),
        .R(rst));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[0]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[0]),
        .O(p_1_in[0]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[10]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[10]),
        .O(p_1_in[10]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[11]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[11]),
        .O(p_1_in[11]));
  LUT5 #(
    .INIT(32'hF8888000)) 
    \acc1[11]_i_18 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[10]),
        .I2(Q[9]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(\acc1[11]_i_33_n_0 ),
        .O(\acc1[11]_i_18_n_0 ));
  LUT5 #(
    .INIT(32'hF2222000)) 
    \acc1[11]_i_19 
       (.I0(Q[10]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(Q[9]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .I4(\acc1[11]_i_34_n_0 ),
        .O(\acc1[11]_i_19_n_0 ));
  LUT6 #(
    .INIT(64'h8000F88880008000)) 
    \acc1[11]_i_20 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[8]),
        .I2(Q[10]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .I4(\mem[62][3]_i_4_n_0 ),
        .I5(Q[9]),
        .O(\acc1[11]_i_20_n_0 ));
  LUT6 #(
    .INIT(64'hF222200020002000)) 
    \acc1[11]_i_21 
       (.I0(Q[8]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[10]),
        .I4(Q[9]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[11]_i_21_n_0 ));
  LUT6 #(
    .INIT(64'h956A6A6A6A959595)) 
    \acc1[11]_i_22 
       (.I0(\acc1[11]_i_18_n_0 ),
        .I1(\mem[62][6]_i_4_n_0 ),
        .I2(Q[9]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(Q[10]),
        .I5(\acc1[15]_i_56_n_0 ),
        .O(\acc1[11]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    \acc1[11]_i_23 
       (.I0(\acc1[11]_i_19_n_0 ),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[9]),
        .I3(Q[10]),
        .I4(\mem[62][4]_i_4_n_0 ),
        .I5(\acc1[11]_i_33_n_0 ),
        .O(\acc1[11]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'h956A95956A956A6A)) 
    \acc1[11]_i_24 
       (.I0(\acc1[11]_i_20_n_0 ),
        .I1(\mem[62][4]_i_4_n_0 ),
        .I2(Q[9]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(Q[10]),
        .I5(\acc1[11]_i_34_n_0 ),
        .O(\acc1[11]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'h8878778777878878)) 
    \acc1[11]_i_25 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[8]),
        .I2(Q[9]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(\acc1[11]_i_21_n_0 ),
        .I5(\acc1[11]_i_35_n_0 ),
        .O(\acc1[11]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'h2DDDD222D222D222)) 
    \acc1[11]_i_26 
       (.I0(Q[11]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[13]),
        .I4(Q[12]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[11]_i_26_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc1[11]_i_27 
       (.I0(Q[12]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[13]),
        .O(\acc1[11]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[11]_i_28 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[12]),
        .O(\acc1[11]_i_28_n_0 ));
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \acc1[11]_i_29 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[12]),
        .I2(Q[13]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .I4(\acc1[11]_i_26_n_0 ),
        .O(\acc1[11]_i_29_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[11]_i_3 
       (.I0(acc1__0[11]),
        .I1(\acc1_reg[15]_i_2_0 [0]),
        .O(\acc1[11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    \acc1[11]_i_30 
       (.I0(Q[12]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[13]),
        .I4(Q[11]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[11]_i_30_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc1[11]_i_31 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[12]),
        .I2(Q[11]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .O(\acc1[11]_i_31_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[11]_i_32 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[11]),
        .O(\acc1[11]_i_32_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[11]_i_33 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[8]),
        .O(\acc1[11]_i_33_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[11]_i_34 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[8]),
        .O(\acc1[11]_i_34_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[11]_i_35 
       (.I0(\mem[62][2]_i_4_n_0 ),
        .I1(Q[10]),
        .O(\acc1[11]_i_35_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[11]_i_4 
       (.I0(acc1__0[10]),
        .I1(\acc1_reg[11]_i_2_0 [3]),
        .O(\acc1[11]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[11]_i_5 
       (.I0(acc1__0[9]),
        .I1(\acc1_reg[11]_i_2_0 [2]),
        .O(\acc1[11]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[11]_i_6 
       (.I0(acc1__0[8]),
        .I1(\acc1_reg[11]_i_2_0 [1]),
        .O(\acc1[11]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[12]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[12]),
        .O(p_1_in[12]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[13]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[13]),
        .O(p_1_in[13]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[14]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[14]),
        .O(p_1_in[14]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[15]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[15]),
        .O(p_1_in[15]));
  LUT4 #(
    .INIT(16'h0777)) 
    \acc1[15]_i_18 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[15]),
        .I2(\mem[62][7]_i_7_n_0 ),
        .I3(Q[14]),
        .O(\acc1[15]_i_18_n_0 ));
  LUT4 #(
    .INIT(16'hCB77)) 
    \acc1[15]_i_19 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[15]),
        .I2(Q[14]),
        .I3(\mem[62][7]_i_7_n_0 ),
        .O(\acc1[15]_i_19_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc1[15]_i_24 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[14]),
        .I2(Q[15]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .O(\acc1[15]_i_24_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc1[15]_i_25 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[14]),
        .I2(Q[15]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .O(\acc1[15]_i_25_n_0 ));
  LUT4 #(
    .INIT(16'h8088)) 
    \acc1[15]_i_26 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[14]),
        .I2(\mem[62][3]_i_4_n_0 ),
        .I3(Q[15]),
        .O(\acc1[15]_i_26_n_0 ));
  LUT4 #(
    .INIT(16'h0070)) 
    \acc1[15]_i_27 
       (.I0(Q[15]),
        .I1(\mem[62][2]_i_4_n_0 ),
        .I2(Q[14]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .O(\acc1[15]_i_27_n_0 ));
  LUT5 #(
    .INIT(32'h74B48888)) 
    \acc1[15]_i_28 
       (.I0(\mem[62][7]_i_7_n_0 ),
        .I1(Q[14]),
        .I2(Q[15]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(\mem[62][6]_i_4_n_0 ),
        .O(\acc1[15]_i_28_n_0 ));
  LUT5 #(
    .INIT(32'h8B4B7777)) 
    \acc1[15]_i_29 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[14]),
        .I2(Q[15]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .I4(\mem[62][5]_i_4_n_0 ),
        .O(\acc1[15]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'h48BB7777)) 
    \acc1[15]_i_30 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[14]),
        .I2(\mem[62][3]_i_4_n_0 ),
        .I3(Q[15]),
        .I4(\mem[62][4]_i_4_n_0 ),
        .O(\acc1[15]_i_30_n_0 ));
  LUT5 #(
    .INIT(32'h77778B4B)) 
    \acc1[15]_i_31 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[14]),
        .I2(Q[15]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .I4(\mem[62][3]_i_4_n_0 ),
        .O(\acc1[15]_i_31_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc1[15]_i_32 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[13]),
        .I2(\mem[62][7]_i_7_n_0 ),
        .I3(Q[12]),
        .O(\acc1[15]_i_32_n_0 ));
  LUT5 #(
    .INIT(32'h8000EAC0)) 
    \acc1[15]_i_33 
       (.I0(Q[12]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[13]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(\acc1[15]_i_55_n_0 ),
        .O(\acc1[15]_i_33_n_0 ));
  LUT4 #(
    .INIT(16'h3B77)) 
    \acc1[15]_i_34 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[13]),
        .I2(Q[12]),
        .I3(\mem[62][7]_i_7_n_0 ),
        .O(\acc1[15]_i_34_n_0 ));
  LUT6 #(
    .INIT(64'h25404FBFF03FCF3F)) 
    \acc1[15]_i_35 
       (.I0(Q[11]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[13]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(Q[12]),
        .I5(\mem[62][7]_i_7_n_0 ),
        .O(\acc1[15]_i_35_n_0 ));
  LUT4 #(
    .INIT(16'h0888)) 
    \acc1[15]_i_36 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[10]),
        .I2(\mem[62][7]_i_7_n_0 ),
        .I3(Q[9]),
        .O(\acc1[15]_i_36_n_0 ));
  LUT5 #(
    .INIT(32'h8000EAC0)) 
    \acc1[15]_i_37 
       (.I0(Q[9]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[10]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(\acc1[15]_i_56_n_0 ),
        .O(\acc1[15]_i_37_n_0 ));
  LUT4 #(
    .INIT(16'h3B77)) 
    \acc1[15]_i_38 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[10]),
        .I2(Q[9]),
        .I3(\mem[62][7]_i_7_n_0 ),
        .O(\acc1[15]_i_38_n_0 ));
  LUT6 #(
    .INIT(64'h25404FBFF03FCF3F)) 
    \acc1[15]_i_39 
       (.I0(Q[8]),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[10]),
        .I3(\mem[62][6]_i_4_n_0 ),
        .I4(Q[9]),
        .I5(\mem[62][7]_i_7_n_0 ),
        .O(\acc1[15]_i_39_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[15]_i_4 
       (.I0(\acc1_reg[15]_0 ),
        .I1(acc1__0[15]),
        .O(\acc1[15]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hF8888000)) 
    \acc1[15]_i_40 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[13]),
        .I2(Q[12]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(\acc1[15]_i_57_n_0 ),
        .O(\acc1[15]_i_40_n_0 ));
  LUT5 #(
    .INIT(32'hF2222000)) 
    \acc1[15]_i_41 
       (.I0(Q[13]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(Q[12]),
        .I3(\mem[62][4]_i_4_n_0 ),
        .I4(\acc1[15]_i_58_n_0 ),
        .O(\acc1[15]_i_41_n_0 ));
  LUT6 #(
    .INIT(64'h8000F88880008000)) 
    \acc1[15]_i_42 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[11]),
        .I2(Q[13]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .I4(\mem[62][3]_i_4_n_0 ),
        .I5(Q[12]),
        .O(\acc1[15]_i_42_n_0 ));
  LUT6 #(
    .INIT(64'hF222200020002000)) 
    \acc1[15]_i_43 
       (.I0(Q[11]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[13]),
        .I4(Q[12]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[15]_i_43_n_0 ));
  LUT6 #(
    .INIT(64'h956A6A6A6A959595)) 
    \acc1[15]_i_44 
       (.I0(\acc1[15]_i_40_n_0 ),
        .I1(\mem[62][6]_i_4_n_0 ),
        .I2(Q[12]),
        .I3(\mem[62][5]_i_4_n_0 ),
        .I4(Q[13]),
        .I5(\acc1[15]_i_55_n_0 ),
        .O(\acc1[15]_i_44_n_0 ));
  LUT6 #(
    .INIT(64'h6A959595956A6A6A)) 
    \acc1[15]_i_45 
       (.I0(\acc1[15]_i_41_n_0 ),
        .I1(\mem[62][5]_i_4_n_0 ),
        .I2(Q[12]),
        .I3(Q[13]),
        .I4(\mem[62][4]_i_4_n_0 ),
        .I5(\acc1[15]_i_57_n_0 ),
        .O(\acc1[15]_i_45_n_0 ));
  LUT6 #(
    .INIT(64'h956A95956A956A6A)) 
    \acc1[15]_i_46 
       (.I0(\acc1[15]_i_42_n_0 ),
        .I1(\mem[62][4]_i_4_n_0 ),
        .I2(Q[12]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(Q[13]),
        .I5(\acc1[15]_i_58_n_0 ),
        .O(\acc1[15]_i_46_n_0 ));
  LUT6 #(
    .INIT(64'h8878778777878878)) 
    \acc1[15]_i_47 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[11]),
        .I2(Q[12]),
        .I3(\mem[62][3]_i_4_n_0 ),
        .I4(\acc1[15]_i_43_n_0 ),
        .I5(\acc1[15]_i_59_n_0 ),
        .O(\acc1[15]_i_47_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \acc1[15]_i_48 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[15]),
        .O(\acc1[15]_i_48_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_49 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[15]),
        .O(\acc1[15]_i_49_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[15]_i_5 
       (.I0(acc1__0[14]),
        .I1(\acc1_reg[15]_i_2_0 [3]),
        .O(\acc1[15]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \acc1[15]_i_50 
       (.I0(Q[15]),
        .I1(\mem[62][0]_i_4_n_0 ),
        .O(\acc1[15]_i_50_n_0 ));
  LUT5 #(
    .INIT(32'h4848B748)) 
    \acc1[15]_i_51 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[15]),
        .I2(\mem[62][2]_i_4_n_0 ),
        .I3(Q[14]),
        .I4(\mem[62][3]_i_4_n_0 ),
        .O(\acc1[15]_i_51_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc1[15]_i_52 
       (.I0(\mem[62][1]_i_4_n_0 ),
        .I1(Q[15]),
        .I2(Q[14]),
        .I3(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[15]_i_52_n_0 ));
  LUT4 #(
    .INIT(16'h8777)) 
    \acc1[15]_i_53 
       (.I0(Q[15]),
        .I1(\mem[62][0]_i_4_n_0 ),
        .I2(Q[14]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .O(\acc1[15]_i_53_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_54 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[14]),
        .O(\acc1[15]_i_54_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_55 
       (.I0(\mem[62][7]_i_7_n_0 ),
        .I1(Q[11]),
        .O(\acc1[15]_i_55_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_56 
       (.I0(\mem[62][7]_i_7_n_0 ),
        .I1(Q[8]),
        .O(\acc1[15]_i_56_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_57 
       (.I0(\mem[62][6]_i_4_n_0 ),
        .I1(Q[11]),
        .O(\acc1[15]_i_57_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_58 
       (.I0(\mem[62][5]_i_4_n_0 ),
        .I1(Q[11]),
        .O(\acc1[15]_i_58_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[15]_i_59 
       (.I0(\mem[62][2]_i_4_n_0 ),
        .I1(Q[13]),
        .O(\acc1[15]_i_59_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[15]_i_6 
       (.I0(acc1__0[13]),
        .I1(\acc1_reg[15]_i_2_0 [2]),
        .O(\acc1[15]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[15]_i_7 
       (.I0(acc1__0[12]),
        .I1(\acc1_reg[15]_i_2_0 [1]),
        .O(\acc1[15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[16]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[16]),
        .O(p_1_in[16]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[17]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[17]),
        .O(p_1_in[17]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[18]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[18]),
        .O(p_1_in[18]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[19]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[19]),
        .O(p_1_in[19]));
  LUT1 #(
    .INIT(2'h1)) 
    \acc1[19]_i_3 
       (.I0(\acc1_reg[15]_0 ),
        .O(\acc1[19]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc1[19]_i_4 
       (.I0(acc1__0[18]),
        .I1(acc1__0[19]),
        .O(\acc1[19]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc1[19]_i_5 
       (.I0(acc1__0[17]),
        .I1(acc1__0[18]),
        .O(\acc1[19]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc1[19]_i_6 
       (.I0(acc1__0[16]),
        .I1(acc1__0[17]),
        .O(\acc1[19]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[19]_i_7 
       (.I0(\acc1_reg[15]_0 ),
        .I1(acc1__0[16]),
        .O(\acc1[19]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[1]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[1]),
        .O(p_1_in[1]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[20]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[20]),
        .O(p_1_in[20]));
  LUT5 #(
    .INIT(32'hFF000400)) 
    \acc1[21]_i_1 
       (.I0(\ptr_reg[0]_rep_0 ),
        .I1(\ptr_reg[0]_rep_1 ),
        .I2(\ptr_reg[0]_rep_2 ),
        .I3(step),
        .I4(q_pair),
        .O(\acc1[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[21]_i_2 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[21]),
        .O(p_1_in[21]));
  LUT2 #(
    .INIT(4'h9)) 
    \acc1[21]_i_4 
       (.I0(acc1__0[20]),
        .I1(acc1__0[21]),
        .O(\acc1[21]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \acc1[21]_i_5 
       (.I0(acc1__0[19]),
        .I1(acc1__0[20]),
        .O(\acc1[21]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[2]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[2]),
        .O(p_1_in[2]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[3]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[3]),
        .O(p_1_in[3]));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[3]_i_10 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[9]),
        .O(\acc1[3]_i_10_n_0 ));
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \acc1[3]_i_11 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[9]),
        .I2(Q[10]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .I4(\acc1[3]_i_8_n_0 ),
        .O(\acc1[3]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    \acc1[3]_i_12 
       (.I0(Q[9]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[10]),
        .I4(Q[8]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[3]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc1[3]_i_13 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[9]),
        .I2(Q[8]),
        .I3(\mem[62][1]_i_4_n_0 ),
        .O(\acc1[3]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \acc1[3]_i_14 
       (.I0(\mem[62][0]_i_4_n_0 ),
        .I1(Q[8]),
        .O(\acc1[3]_i_14_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[3]_i_3 
       (.I0(acc1__0[3]),
        .I1(\acc1_reg[7]_i_2_0 [0]),
        .O(\acc1[3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[3]_i_4 
       (.I0(acc1__0[2]),
        .I1(\acc1_reg[3]_i_7_n_5 ),
        .O(\acc1[3]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[3]_i_5 
       (.I0(acc1__0[1]),
        .I1(\acc1_reg[3]_i_7_n_6 ),
        .O(\acc1[3]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[3]_i_6 
       (.I0(acc1__0[0]),
        .I1(\acc1_reg[3]_i_7_n_7 ),
        .O(\acc1[3]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h2DDDD222D222D222)) 
    \acc1[3]_i_8 
       (.I0(Q[8]),
        .I1(\mem[62][3]_i_4_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .I3(Q[10]),
        .I4(Q[9]),
        .I5(\mem[62][2]_i_4_n_0 ),
        .O(\acc1[3]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \acc1[3]_i_9 
       (.I0(Q[9]),
        .I1(\mem[62][1]_i_4_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .I3(Q[10]),
        .O(\acc1[3]_i_9_n_0 ));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[4]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[4]),
        .O(p_1_in[4]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[5]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[5]),
        .O(p_1_in[5]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[6]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[6]),
        .O(p_1_in[6]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[7]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[7]),
        .O(p_1_in[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[7]_i_3 
       (.I0(acc1__0[7]),
        .I1(\acc1_reg[11]_i_2_0 [0]),
        .O(\acc1[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[7]_i_4 
       (.I0(acc1__0[6]),
        .I1(\acc1_reg[7]_i_2_0 [3]),
        .O(\acc1[7]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[7]_i_5 
       (.I0(acc1__0[5]),
        .I1(\acc1_reg[7]_i_2_0 [2]),
        .O(\acc1[7]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \acc1[7]_i_6 
       (.I0(acc1__0[4]),
        .I1(\acc1_reg[7]_i_2_0 [1]),
        .O(\acc1[7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[8]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[8]),
        .O(p_1_in[8]));
  LUT5 #(
    .INIT(32'hFE000000)) 
    \acc1[9]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(s1__0[9]),
        .O(p_1_in[9]));
  FDRE \acc1_reg[0] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[0]),
        .Q(acc1__0[0]),
        .R(rst));
  FDRE \acc1_reg[10] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[10]),
        .Q(acc1__0[10]),
        .R(rst));
  FDRE \acc1_reg[11] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[11]),
        .Q(acc1__0[11]),
        .R(rst));
  CARRY4 \acc1_reg[11]_i_16 
       (.CI(\acc1_reg[3]_i_7_n_0 ),
        .CO({\acc1_reg[11]_i_16_n_0 ,\acc1_reg[11]_i_16_n_1 ,\acc1_reg[11]_i_16_n_2 ,\acc1_reg[11]_i_16_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[11]_i_18_n_0 ,\acc1[11]_i_19_n_0 ,\acc1[11]_i_20_n_0 ,\acc1[11]_i_21_n_0 }),
        .O(\q_data_reg[10] ),
        .S({\acc1[11]_i_22_n_0 ,\acc1[11]_i_23_n_0 ,\acc1[11]_i_24_n_0 ,\acc1[11]_i_25_n_0 }));
  CARRY4 \acc1_reg[11]_i_17 
       (.CI(1'b0),
        .CO({\acc1_reg[11]_i_17_n_0 ,\acc1_reg[11]_i_17_n_1 ,\acc1_reg[11]_i_17_n_2 ,\acc1_reg[11]_i_17_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[11]_i_26_n_0 ,\acc1[11]_i_27_n_0 ,\acc1[11]_i_28_n_0 ,1'b0}),
        .O(\q_data_reg[11] ),
        .S({\acc1[11]_i_29_n_0 ,\acc1[11]_i_30_n_0 ,\acc1[11]_i_31_n_0 ,\acc1[11]_i_32_n_0 }));
  CARRY4 \acc1_reg[11]_i_2 
       (.CI(\acc1_reg[7]_i_2_n_0 ),
        .CO({\acc1_reg[11]_i_2_n_0 ,\acc1_reg[11]_i_2_n_1 ,\acc1_reg[11]_i_2_n_2 ,\acc1_reg[11]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[11:8]),
        .O(s1__0[11:8]),
        .S({\acc1[11]_i_3_n_0 ,\acc1[11]_i_4_n_0 ,\acc1[11]_i_5_n_0 ,\acc1[11]_i_6_n_0 }));
  FDRE \acc1_reg[12] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[12]),
        .Q(acc1__0[12]),
        .R(rst));
  FDRE \acc1_reg[13] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[13]),
        .Q(acc1__0[13]),
        .R(rst));
  FDRE \acc1_reg[14] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[14]),
        .Q(acc1__0[14]),
        .R(rst));
  FDRE \acc1_reg[15] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[15]),
        .Q(acc1__0[15]),
        .R(rst));
  CARRY4 \acc1_reg[15]_i_17 
       (.CI(\acc1_reg[15]_i_23_n_0 ),
        .CO({\acc1_reg[15]_i_17_n_0 ,\acc1_reg[15]_i_17_n_1 ,\acc1_reg[15]_i_17_n_2 ,\acc1_reg[15]_i_17_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[15]_i_24_n_0 ,\acc1[15]_i_25_n_0 ,\acc1[15]_i_26_n_0 ,\acc1[15]_i_27_n_0 }),
        .O(\q_data_reg[14] ),
        .S({\acc1[15]_i_28_n_0 ,\acc1[15]_i_29_n_0 ,\acc1[15]_i_30_n_0 ,\acc1[15]_i_31_n_0 }));
  CARRY4 \acc1_reg[15]_i_2 
       (.CI(\acc1_reg[11]_i_2_n_0 ),
        .CO({\acc1_reg[15]_i_2_n_0 ,\acc1_reg[15]_i_2_n_1 ,\acc1_reg[15]_i_2_n_2 ,\acc1_reg[15]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1_reg[15]_0 ,acc1__0[14:12]}),
        .O(s1__0[15:12]),
        .S({\acc1[15]_i_4_n_0 ,\acc1[15]_i_5_n_0 ,\acc1[15]_i_6_n_0 ,\acc1[15]_i_7_n_0 }));
  CARRY4 \acc1_reg[15]_i_20 
       (.CI(\acc1_reg[15]_i_22_n_0 ),
        .CO({\NLW_acc1_reg[15]_i_20_CO_UNCONNECTED [3],\q_data_reg[13]_0 ,\NLW_acc1_reg[15]_i_20_CO_UNCONNECTED [1],\acc1_reg[15]_i_20_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,\acc1[15]_i_32_n_0 ,\acc1[15]_i_33_n_0 }),
        .O({\NLW_acc1_reg[15]_i_20_O_UNCONNECTED [3:2],\q_data_reg[13]_1 }),
        .S({1'b0,1'b1,\acc1[15]_i_34_n_0 ,\acc1[15]_i_35_n_0 }));
  CARRY4 \acc1_reg[15]_i_21 
       (.CI(\acc1_reg[11]_i_16_n_0 ),
        .CO({\NLW_acc1_reg[15]_i_21_CO_UNCONNECTED [3],\q_data_reg[10]_0 ,\NLW_acc1_reg[15]_i_21_CO_UNCONNECTED [1],\acc1_reg[15]_i_21_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,\acc1[15]_i_36_n_0 ,\acc1[15]_i_37_n_0 }),
        .O({\NLW_acc1_reg[15]_i_21_O_UNCONNECTED [3:2],\q_data_reg[10]_1 }),
        .S({1'b0,1'b1,\acc1[15]_i_38_n_0 ,\acc1[15]_i_39_n_0 }));
  CARRY4 \acc1_reg[15]_i_22 
       (.CI(\acc1_reg[11]_i_17_n_0 ),
        .CO({\acc1_reg[15]_i_22_n_0 ,\acc1_reg[15]_i_22_n_1 ,\acc1_reg[15]_i_22_n_2 ,\acc1_reg[15]_i_22_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[15]_i_40_n_0 ,\acc1[15]_i_41_n_0 ,\acc1[15]_i_42_n_0 ,\acc1[15]_i_43_n_0 }),
        .O(\q_data_reg[13] ),
        .S({\acc1[15]_i_44_n_0 ,\acc1[15]_i_45_n_0 ,\acc1[15]_i_46_n_0 ,\acc1[15]_i_47_n_0 }));
  CARRY4 \acc1_reg[15]_i_23 
       (.CI(1'b0),
        .CO({\acc1_reg[15]_i_23_n_0 ,\acc1_reg[15]_i_23_n_1 ,\acc1_reg[15]_i_23_n_2 ,\acc1_reg[15]_i_23_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[15]_i_48_n_0 ,\acc1[15]_i_49_n_0 ,\acc1[15]_i_50_n_0 ,1'b0}),
        .O(\q_data_reg[15] ),
        .S({\acc1[15]_i_51_n_0 ,\acc1[15]_i_52_n_0 ,\acc1[15]_i_53_n_0 ,\acc1[15]_i_54_n_0 }));
  CARRY4 \acc1_reg[15]_i_9 
       (.CI(\acc1_reg[15]_i_17_n_0 ),
        .CO({\NLW_acc1_reg[15]_i_9_CO_UNCONNECTED [3:1],\acc1_reg[15]_i_9_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\acc1[15]_i_18_n_0 }),
        .O({\NLW_acc1_reg[15]_i_9_O_UNCONNECTED [3:2],\q_data_reg[15]_0 }),
        .S({1'b0,1'b0,1'b1,\acc1[15]_i_19_n_0 }));
  FDRE \acc1_reg[16] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[16]),
        .Q(acc1__0[16]),
        .R(rst));
  FDRE \acc1_reg[17] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[17]),
        .Q(acc1__0[17]),
        .R(rst));
  FDRE \acc1_reg[18] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[18]),
        .Q(acc1__0[18]),
        .R(rst));
  FDRE \acc1_reg[19] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[19]),
        .Q(acc1__0[19]),
        .R(rst));
  CARRY4 \acc1_reg[19]_i_2 
       (.CI(\acc1_reg[15]_i_2_n_0 ),
        .CO({\acc1_reg[19]_i_2_n_0 ,\acc1_reg[19]_i_2_n_1 ,\acc1_reg[19]_i_2_n_2 ,\acc1_reg[19]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({acc1__0[18:16],\acc1[19]_i_3_n_0 }),
        .O(s1__0[19:16]),
        .S({\acc1[19]_i_4_n_0 ,\acc1[19]_i_5_n_0 ,\acc1[19]_i_6_n_0 ,\acc1[19]_i_7_n_0 }));
  FDRE \acc1_reg[1] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[1]),
        .Q(acc1__0[1]),
        .R(rst));
  FDRE \acc1_reg[20] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[20]),
        .Q(acc1__0[20]),
        .R(rst));
  FDRE \acc1_reg[21] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[21]),
        .Q(acc1__0[21]),
        .R(rst));
  CARRY4 \acc1_reg[21]_i_3 
       (.CI(\acc1_reg[19]_i_2_n_0 ),
        .CO({\NLW_acc1_reg[21]_i_3_CO_UNCONNECTED [3],\acc1_reg[21]_i_3_n_1 ,\NLW_acc1_reg[21]_i_3_CO_UNCONNECTED [1],\acc1_reg[21]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,acc1__0[20:19]}),
        .O({\NLW_acc1_reg[21]_i_3_O_UNCONNECTED [3:2],s1__0[21:20]}),
        .S({1'b0,1'b1,\acc1[21]_i_4_n_0 ,\acc1[21]_i_5_n_0 }));
  FDRE \acc1_reg[2] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[2]),
        .Q(acc1__0[2]),
        .R(rst));
  FDRE \acc1_reg[3] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[3]),
        .Q(acc1__0[3]),
        .R(rst));
  CARRY4 \acc1_reg[3]_i_2 
       (.CI(1'b0),
        .CO({\acc1_reg[3]_i_2_n_0 ,\acc1_reg[3]_i_2_n_1 ,\acc1_reg[3]_i_2_n_2 ,\acc1_reg[3]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[3:0]),
        .O(s1__0[3:0]),
        .S({\acc1[3]_i_3_n_0 ,\acc1[3]_i_4_n_0 ,\acc1[3]_i_5_n_0 ,\acc1[3]_i_6_n_0 }));
  CARRY4 \acc1_reg[3]_i_7 
       (.CI(1'b0),
        .CO({\acc1_reg[3]_i_7_n_0 ,\acc1_reg[3]_i_7_n_1 ,\acc1_reg[3]_i_7_n_2 ,\acc1_reg[3]_i_7_n_3 }),
        .CYINIT(1'b0),
        .DI({\acc1[3]_i_8_n_0 ,\acc1[3]_i_9_n_0 ,\acc1[3]_i_10_n_0 ,1'b0}),
        .O({\q_data_reg[8] ,\acc1_reg[3]_i_7_n_5 ,\acc1_reg[3]_i_7_n_6 ,\acc1_reg[3]_i_7_n_7 }),
        .S({\acc1[3]_i_11_n_0 ,\acc1[3]_i_12_n_0 ,\acc1[3]_i_13_n_0 ,\acc1[3]_i_14_n_0 }));
  FDRE \acc1_reg[4] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[4]),
        .Q(acc1__0[4]),
        .R(rst));
  FDRE \acc1_reg[5] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[5]),
        .Q(acc1__0[5]),
        .R(rst));
  FDRE \acc1_reg[6] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[6]),
        .Q(acc1__0[6]),
        .R(rst));
  FDRE \acc1_reg[7] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[7]),
        .Q(acc1__0[7]),
        .R(rst));
  CARRY4 \acc1_reg[7]_i_2 
       (.CI(\acc1_reg[3]_i_2_n_0 ),
        .CO({\acc1_reg[7]_i_2_n_0 ,\acc1_reg[7]_i_2_n_1 ,\acc1_reg[7]_i_2_n_2 ,\acc1_reg[7]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[7:4]),
        .O(s1__0[7:4]),
        .S({\acc1[7]_i_3_n_0 ,\acc1[7]_i_4_n_0 ,\acc1[7]_i_5_n_0 ,\acc1[7]_i_6_n_0 }));
  FDRE \acc1_reg[8] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[8]),
        .Q(acc1__0[8]),
        .R(rst));
  FDRE \acc1_reg[9] 
       (.C(s_axi_aclk),
        .CE(\acc1[21]_i_1_n_0 ),
        .D(p_1_in[9]),
        .Q(acc1__0[9]),
        .R(rst));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[0][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem_reg[0]_62 [0]),
        .I3(\mem[0][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[0][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[0][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem_reg[0]_62 [1]),
        .I3(\mem[0][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[0][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[0][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem_reg[0]_62 [2]),
        .I3(\mem[0][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[0][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2E2EFF00)) 
    \mem[0][3]_i_1 
       (.I0(\mem_reg[0]_62 [3]),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[62][3]_i_3_n_0 ),
        .I4(\mem[0][7]_i_3_n_0 ),
        .O(\mem[0][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2E2FF00)) 
    \mem[0][4]_i_1 
       (.I0(\mem_reg[0]_62 [4]),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[62][4]_i_3_n_0 ),
        .I4(\mem[0][7]_i_3_n_0 ),
        .O(\mem[0][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[0][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem_reg[0]_62 [5]),
        .I3(\mem[0][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[0][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[0][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[0][7]_i_2_n_0 ),
        .I2(\mem_reg[0]_62 [6]),
        .I3(\mem[0][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[0][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[0][7]_i_1 
       (.I0(\mem[0][7]_i_2_n_0 ),
        .I1(\mem_reg[0]_62 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[0][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[0][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000001)) 
    \mem[0][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[0][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFCF7FFFFFFF)) 
    \mem[0][7]_i_3 
       (.I0(\mem[3][7]_i_5_n_0 ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\mem[3][7]_i_4_n_0 ),
        .O(\mem[0][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[10][0]_i_1 
       (.I0(\mem_reg[10]_52 [0]),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[10][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[10][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem_reg[10]_52 [1]),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[10][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[10][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem_reg[10]_52 [2]),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[10][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[10][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem_reg[10]_52 [3]),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[10][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[10][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem_reg[10]_52 [4]),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[10][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[10][5]_i_1 
       (.I0(\mem_reg[10]_52 [5]),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[10][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[10][6]_i_1 
       (.I0(\mem_reg[10]_52 [6]),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[10][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[10][7]_i_1 
       (.I0(\mem_reg[10]_52 [7]),
        .I1(\mem[10][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[10][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[10][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000040000)) 
    \mem[10][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[3]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[0]),
        .O(\mem[10][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FEFFFFFF)) 
    \mem[10][7]_i_3 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(sel0__0),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .I4(\mem[14][7]_i_4_n_0 ),
        .I5(\mem[10][7]_i_4_n_0 ),
        .O(\mem[10][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0200000000000000)) 
    \mem[10][7]_i_4 
       (.I0(\mem[10][7]_i_5_n_0 ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\result1[21]_i_3_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[10][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000000080007FFF)) 
    \mem[10][7]_i_5 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(sel0__0),
        .O(\mem[10][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[11][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [0]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[11][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[11][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [1]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[11][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[11][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [2]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[11][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[11][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [3]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[11][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[11][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [4]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[11][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[11][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [5]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[11][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[11][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[11][7]_i_3_n_0 ),
        .I2(\mem_reg[11]_51 [6]),
        .I3(\mem[11][7]_i_2_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[11][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hEEE22E22)) 
    \mem[11][7]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\mem[11][7]_i_2_n_0 ),
        .I2(\mem[11][7]_i_3_n_0 ),
        .I3(\mem_reg[11]_51 [7]),
        .I4(\mem[62][7]_i_3_n_0 ),
        .O(\mem[11][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FFFFFBFF)) 
    \mem[11][7]_i_2 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\mem[31][7]_i_4_n_0 ),
        .I5(\mem[11][7]_i_4_n_0 ),
        .O(\mem[11][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0004000000000000)) 
    \mem[11][7]_i_3 
       (.I0(ptr[2]),
        .I1(ptr[3]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[11][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000001000000)) 
    \mem[11][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[3] ),
        .I5(\mem[29][7]_i_4_n_0 ),
        .O(\mem[11][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[12][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem_reg[12]_50 [0]),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[12][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[12][1]_i_1 
       (.I0(\mem_reg[12]_50 [1]),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[12][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[12][2]_i_1 
       (.I0(\mem_reg[12]_50 [2]),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[12][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[12][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem_reg[12]_50 [3]),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[12][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[12][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem_reg[12]_50 [4]),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[12][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[12][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem_reg[12]_50 [5]),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[12][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[12][6]_i_1 
       (.I0(\mem_reg[12]_50 [6]),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[12][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[12][7]_i_1 
       (.I0(\mem_reg[12]_50 [7]),
        .I1(\mem[12][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[12][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[12][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0001000000000000)) 
    \mem[12][7]_i_2 
       (.I0(ptr[4]),
        .I1(sel0),
        .I2(ptr[0]),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[12][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFBBFFBBFF0BFFBB)) 
    \mem[12][7]_i_3 
       (.I0(\mem[60][7]_i_7_n_0 ),
        .I1(\mem[60][7]_i_6_n_0 ),
        .I2(\mem[12][7]_i_4_n_0 ),
        .I3(sel0__0),
        .I4(\result0[21]_i_3_n_0 ),
        .I5(\q_dst_reg_n_0_[0] ),
        .O(\mem[12][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    \mem[12][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[4] ),
        .O(\mem[12][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[13][0]_i_1 
       (.I0(\mem[13][7]_i_2_n_0 ),
        .I1(\mem_reg[13]_49 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[62][0]_i_3_n_0 ),
        .I4(\mem[13][7]_i_3_n_0 ),
        .O(\mem[13][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[13][1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\mem[13][7]_i_3_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[13][7]_i_2_n_0 ),
        .I4(\mem_reg[13]_49 [1]),
        .O(\mem[13][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[13][2]_i_1 
       (.I0(\mem[62][2]_i_3_n_0 ),
        .I1(\mem[13][7]_i_3_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[13][7]_i_2_n_0 ),
        .I4(\mem_reg[13]_49 [2]),
        .O(\mem[13][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF004E4E)) 
    \mem[13][3]_i_1 
       (.I0(\mem[13][7]_i_2_n_0 ),
        .I1(\mem_reg[13]_49 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[62][3]_i_3_n_0 ),
        .I4(\mem[13][7]_i_3_n_0 ),
        .O(\mem[13][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[13][4]_i_1 
       (.I0(\mem[62][4]_i_3_n_0 ),
        .I1(\mem[13][7]_i_3_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[13][7]_i_2_n_0 ),
        .I4(\mem_reg[13]_49 [4]),
        .O(\mem[13][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[13][5]_i_1 
       (.I0(\mem[62][5]_i_3_n_0 ),
        .I1(\mem[13][7]_i_3_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[13][7]_i_2_n_0 ),
        .I4(\mem_reg[13]_49 [5]),
        .O(\mem[13][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[13][6]_i_1 
       (.I0(\mem[13][7]_i_2_n_0 ),
        .I1(\mem_reg[13]_49 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[62][6]_i_3_n_0 ),
        .I4(\mem[13][7]_i_3_n_0 ),
        .O(\mem[13][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[13][7]_i_1 
       (.I0(\mem[13][7]_i_2_n_0 ),
        .I1(\mem_reg[13]_49 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_5_n_0 ),
        .I4(\mem[13][7]_i_3_n_0 ),
        .O(\mem[13][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000010000000)) 
    \mem[13][7]_i_2 
       (.I0(sel0),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[0]),
        .I3(ptr[2]),
        .I4(ptr[3]),
        .I5(ptr[4]),
        .O(\mem[13][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h44444F4444444444)) 
    \mem[13][7]_i_3 
       (.I0(\mem[15][7]_i_4_n_0 ),
        .I1(\mem[13][7]_i_4_n_0 ),
        .I2(\mem[13][7]_i_5_n_0 ),
        .I3(\mem[31][7]_i_7_n_0 ),
        .I4(\mem[29][7]_i_4_n_0 ),
        .I5(\mem[15][7]_i_5_n_0 ),
        .O(\mem[13][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    \mem[13][7]_i_4 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep_n_0 ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[13][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \mem[13][7]_i_5 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .O(\mem[13][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[14][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[14][7]_i_2_n_0 ),
        .I2(\mem_reg[14]_48 [0]),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[14][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[14][1]_i_1 
       (.I0(\mem[14][7]_i_2_n_0 ),
        .I1(\mem_reg[14]_48 [1]),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[14][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[14][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[14][7]_i_2_n_0 ),
        .I2(\mem_reg[14]_48 [2]),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[14][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[14][3]_i_1 
       (.I0(\mem_reg[14]_48 [3]),
        .I1(\mem[14][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[14][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[14][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[14][7]_i_2_n_0 ),
        .I2(\mem_reg[14]_48 [4]),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[14][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[14][5]_i_1 
       (.I0(\mem[14][7]_i_2_n_0 ),
        .I1(\mem_reg[14]_48 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[14][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[14][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[14][7]_i_2_n_0 ),
        .I2(\mem_reg[14]_48 [6]),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[14][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[14][7]_i_1 
       (.I0(\mem[62][7]_i_3_n_0 ),
        .I1(\mem[14][7]_i_2_n_0 ),
        .I2(\mem_reg[14]_48 [7]),
        .I3(\mem[14][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[14][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000080000)) 
    \mem[14][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[2]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[0]),
        .O(\mem[14][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBBBBB0BBBBBBB)) 
    \mem[14][7]_i_3 
       (.I0(\mem[15][7]_i_4_n_0 ),
        .I1(\mem[14][7]_i_4_n_0 ),
        .I2(\mem[22][7]_i_5_n_0 ),
        .I3(\mem[15][7]_i_5_n_0 ),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(sel0__0),
        .O(\mem[14][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    \mem[14][7]_i_4 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[14][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[15][0]_i_1 
       (.I0(\mem_reg[15]_47 [0]),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[15][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[15][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem_reg[15]_47 [1]),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[15][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[15][2]_i_1 
       (.I0(\mem_reg[15]_47 [2]),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[15][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[15][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem_reg[15]_47 [3]),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[15][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[15][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem_reg[15]_47 [4]),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[15][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[15][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem_reg[15]_47 [5]),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[15][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[15][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem_reg[15]_47 [6]),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[15][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[15][7]_i_1 
       (.I0(\mem_reg[15]_47 [7]),
        .I1(\mem[15][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[15][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[15][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000008000)) 
    \mem[15][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[2]),
        .I2(ptr[0]),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[15][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBBBBB0BBBBBBB)) 
    \mem[15][7]_i_3 
       (.I0(\mem[15][7]_i_4_n_0 ),
        .I1(\mem[51][7]_i_8_n_0 ),
        .I2(\mem[15][7]_i_5_n_0 ),
        .I3(\mem[51][7]_i_5_n_0 ),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(sel0__0),
        .O(\mem[15][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'hEFFF)) 
    \mem[15][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(sel0__0),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .O(\mem[15][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT4 #(
    .INIT(16'h2A80)) 
    \mem[15][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .O(\mem[15][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[16][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem_reg[16]_46 [0]),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[16][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[16][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem_reg[16]_46 [1]),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[16][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[16][2]_i_1 
       (.I0(\mem_reg[16]_46 [2]),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[16][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[16][3]_i_1 
       (.I0(\mem_reg[16]_46 [3]),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[16][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[16][4]_i_1 
       (.I0(\mem_reg[16]_46 [4]),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[16][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[16][5]_i_1 
       (.I0(\mem_reg[16]_46 [5]),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[16][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[16][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem_reg[16]_46 [6]),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[16][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[16][7]_i_1 
       (.I0(\mem_reg[16]_46 [7]),
        .I1(\mem[16][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[16][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[16][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000010)) 
    \mem[16][7]_i_2 
       (.I0(ptr[2]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[0]),
        .I5(ptr[3]),
        .O(\mem[16][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBBBBBB0BBBBBB)) 
    \mem[16][7]_i_3 
       (.I0(\mem[56][7]_i_5_n_0 ),
        .I1(\mem[23][7]_i_5_n_0 ),
        .I2(\mem[16][7]_i_4_n_0 ),
        .I3(\result0[21]_i_3_n_0 ),
        .I4(\mem[51][7]_i_7_n_0 ),
        .I5(\mem[16][7]_i_5_n_0 ),
        .O(\mem[16][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \mem[16][7]_i_4 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[1] ),
        .O(\mem[16][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \mem[16][7]_i_5 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .O(\mem[16][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[17][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem_reg[17]_45 [0]),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[17][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[17][1]_i_1 
       (.I0(\mem_reg[17]_45 [1]),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[17][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[17][2]_i_1 
       (.I0(\mem_reg[17]_45 [2]),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[17][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[17][3]_i_1 
       (.I0(\mem_reg[17]_45 [3]),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[17][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[17][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem_reg[17]_45 [4]),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[17][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[17][5]_i_1 
       (.I0(\mem_reg[17]_45 [5]),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[17][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[17][6]_i_1 
       (.I0(\mem_reg[17]_45 [6]),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[17][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[17][7]_i_1 
       (.I0(\mem_reg[17]_45 [7]),
        .I1(\mem[17][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[17][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[17][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000040)) 
    \mem[17][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[17][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FFFFDFFF)) 
    \mem[17][7]_i_3 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\mem[23][7]_i_5_n_0 ),
        .I3(\result1[21]_i_3_n_0 ),
        .I4(\mem[32][7]_i_5_n_0 ),
        .I5(\mem[17][7]_i_4_n_0 ),
        .O(\mem[17][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h1000000000000000)) 
    \mem[17][7]_i_4 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\mem[51][7]_i_7_n_0 ),
        .I3(\q_dst_reg_n_0_[4] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\result0[21]_i_3_n_0 ),
        .O(\mem[17][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[18][0]_i_1 
       (.I0(\mem_reg[18]_44 [0]),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[18][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[18][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem_reg[18]_44 [1]),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[18][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[18][2]_i_1 
       (.I0(\mem_reg[18]_44 [2]),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[18][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[18][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem_reg[18]_44 [3]),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[18][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[18][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem_reg[18]_44 [4]),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[18][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[18][5]_i_1 
       (.I0(\mem[18][7]_i_2_n_0 ),
        .I1(\mem_reg[18]_44 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[18][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[18][6]_i_1 
       (.I0(\mem_reg[18]_44 [6]),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[18][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[18][7]_i_1 
       (.I0(\mem_reg[18]_44 [7]),
        .I1(\mem[18][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[18][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[18][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000040000)) 
    \mem[18][7]_i_2 
       (.I0(sel0),
        .I1(ptr[4]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[0]),
        .O(\mem[18][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000FF7FFF7FFF7F)) 
    \mem[18][7]_i_3 
       (.I0(\mem[23][7]_i_5_n_0 ),
        .I1(\mem[42][7]_i_4_n_0 ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(\mem[31][7]_i_7_n_0 ),
        .I4(\mem[18][7]_i_4_n_0 ),
        .I5(\mem[30][7]_i_4_n_0 ),
        .O(\mem[18][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT4 #(
    .INIT(16'h1000)) 
    \mem[18][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[4] ),
        .O(\mem[18][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[19][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [0]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[19][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[19][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [1]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[19][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[19][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [2]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[19][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[19][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [3]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[19][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[19][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [4]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[19][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[19][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [5]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[19][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[19][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem_reg[19]_43 [6]),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[19][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[19][7]_i_1 
       (.I0(\mem_reg[19]_43 [7]),
        .I1(\mem[19][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[19][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[19][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0004000000000000)) 
    \mem[19][7]_i_2 
       (.I0(sel0),
        .I1(ptr[4]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[19][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FFFFFFEF)) 
    \mem[19][7]_i_3 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(sel0__0),
        .I2(\mem[51][7]_i_5_n_0 ),
        .I3(\mem[56][7]_i_4_n_0 ),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(\mem[19][7]_i_4_n_0 ),
        .O(\mem[19][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000080000000)) 
    \mem[19][7]_i_4 
       (.I0(\mem[51][7]_i_7_n_0 ),
        .I1(\result0[21]_i_3_n_0 ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(sel0__0),
        .O(\mem[19][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[1][0]_i_1 
       (.I0(\mem[1][7]_i_2_n_0 ),
        .I1(\mem_reg[1]_61 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[1][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[1][1]_i_1 
       (.I0(\mem[1][7]_i_2_n_0 ),
        .I1(\mem_reg[1]_61 [1]),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[1][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[1][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[1][7]_i_2_n_0 ),
        .I2(\mem_reg[1]_61 [2]),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[1][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[1][3]_i_1 
       (.I0(\mem_reg[1]_61 [3]),
        .I1(\mem[1][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[1][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[1][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[1][7]_i_2_n_0 ),
        .I2(\mem_reg[1]_61 [4]),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[1][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[1][5]_i_1 
       (.I0(\mem_reg[1]_61 [5]),
        .I1(\mem[1][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[1][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[1][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[1][7]_i_2_n_0 ),
        .I2(\mem_reg[1]_61 [6]),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[1][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[1][7]_i_1 
       (.I0(\mem_reg[1]_61 [7]),
        .I1(\mem[1][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[1][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[1][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000004)) 
    \mem[1][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[1][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFDF3FFFFFDFFF)) 
    \mem[1][7]_i_3 
       (.I0(\mem[3][7]_i_5_n_0 ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\mem[3][7]_i_4_n_0 ),
        .O(\mem[1][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[20][0]_i_1 
       (.I0(\mem[20][7]_i_2_n_0 ),
        .I1(\mem_reg[20]_42 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[62][0]_i_3_n_0 ),
        .I4(\mem[20][7]_i_3_n_0 ),
        .O(\mem[20][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    \mem[20][1]_i_1 
       (.I0(\mem[20][7]_i_2_n_0 ),
        .I1(\mem_reg[20]_42 [1]),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[20][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[20][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[20][2]_i_1 
       (.I0(\mem[62][2]_i_3_n_0 ),
        .I1(\mem[20][7]_i_3_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[20][7]_i_2_n_0 ),
        .I4(\mem_reg[20]_42 [2]),
        .O(\mem[20][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF004E4E)) 
    \mem[20][3]_i_1 
       (.I0(\mem[20][7]_i_2_n_0 ),
        .I1(\mem_reg[20]_42 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[62][3]_i_3_n_0 ),
        .I4(\mem[20][7]_i_3_n_0 ),
        .O(\mem[20][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[20][4]_i_1 
       (.I0(\mem[20][7]_i_2_n_0 ),
        .I1(\mem_reg[20]_42 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[62][4]_i_3_n_0 ),
        .I4(\mem[20][7]_i_3_n_0 ),
        .O(\mem[20][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[20][5]_i_1 
       (.I0(\mem[62][5]_i_3_n_0 ),
        .I1(\mem[20][7]_i_3_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[20][7]_i_2_n_0 ),
        .I4(\mem_reg[20]_42 [5]),
        .O(\mem[20][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[20][6]_i_1 
       (.I0(\mem[20][7]_i_2_n_0 ),
        .I1(\mem_reg[20]_42 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[62][6]_i_3_n_0 ),
        .I4(\mem[20][7]_i_3_n_0 ),
        .O(\mem[20][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[20][7]_i_1 
       (.I0(\mem[20][7]_i_2_n_0 ),
        .I1(\mem_reg[20]_42 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_5_n_0 ),
        .I4(\mem[20][7]_i_3_n_0 ),
        .O(\mem[20][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000100000)) 
    \mem[20][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[20][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h008000FF00800080)) 
    \mem[20][7]_i_3 
       (.I0(\mem[24][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\mem[60][7]_i_5_n_0 ),
        .I3(sel0__0),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(\mem[52][7]_i_4_n_0 ),
        .O(\mem[20][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[21][0]_i_1 
       (.I0(\mem_reg[21]_41 [0]),
        .I1(\mem[21][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[21][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[21][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[21][7]_i_2_n_0 ),
        .I2(\mem_reg[21]_41 [1]),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[21][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[21][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[21][7]_i_2_n_0 ),
        .I2(\mem_reg[21]_41 [2]),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[21][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[21][3]_i_1 
       (.I0(\mem_reg[21]_41 [3]),
        .I1(\mem[21][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[21][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[21][4]_i_1 
       (.I0(\mem_reg[21]_41 [4]),
        .I1(\mem[21][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[21][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[21][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[21][7]_i_2_n_0 ),
        .I2(\mem_reg[21]_41 [5]),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[21][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[21][6]_i_1 
       (.I0(\mem[21][7]_i_2_n_0 ),
        .I1(\mem_reg[21]_41 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[21][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[21][7]_i_1 
       (.I0(\mem[21][7]_i_2_n_0 ),
        .I1(\mem_reg[21]_41 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[21][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[21][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000400000)) 
    \mem[21][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[21][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hEFEFEFEF00EFEFEF)) 
    \mem[21][7]_i_3 
       (.I0(\mem[31][7]_i_6_n_0 ),
        .I1(\mem[22][7]_i_4_n_0 ),
        .I2(\mem[53][7]_i_6_n_0 ),
        .I3(\mem[53][7]_i_4_n_0 ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(sel0__0),
        .O(\mem[21][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[22][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem_reg[22]_40 [0]),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[22][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[22][1]_i_1 
       (.I0(\mem_reg[22]_40 [1]),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[22][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[22][2]_i_1 
       (.I0(\mem_reg[22]_40 [2]),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[22][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[22][3]_i_1 
       (.I0(\mem_reg[22]_40 [3]),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[22][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[22][4]_i_1 
       (.I0(\mem_reg[22]_40 [4]),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[22][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[22][5]_i_1 
       (.I0(\mem_reg[22]_40 [5]),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[22][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[22][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem_reg[22]_40 [6]),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[22][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[22][7]_i_1 
       (.I0(\mem_reg[22]_40 [7]),
        .I1(\mem[22][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[22][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[22][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    \mem[22][7]_i_2 
       (.I0(ptr[2]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[0]),
        .I5(ptr[3]),
        .O(\mem[22][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00BFBFBFBFBFBFBF)) 
    \mem[22][7]_i_3 
       (.I0(\mem[22][7]_i_4_n_0 ),
        .I1(\mem[22][7]_i_5_n_0 ),
        .I2(\mem[23][7]_i_5_n_0 ),
        .I3(\mem[50][7]_i_6_n_0 ),
        .I4(\mem[22][7]_i_6_n_0 ),
        .I5(\mem[54][7]_i_5_n_0 ),
        .O(\mem[22][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT4 #(
    .INIT(16'hD57F)) 
    \mem[22][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .O(\mem[22][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    \mem[22][7]_i_5 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[22][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \mem[22][7]_i_6 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(sel0__0),
        .O(\mem[22][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[23][0]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[23][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[23][1]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [1]),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[23][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[23][2]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[23][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[23][3]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[23][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[23][4]_i_1 
       (.I0(\mem_reg[23]_39 [4]),
        .I1(\mem[23][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[23][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[23][5]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[23][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[23][6]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[23][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[23][7]_i_1 
       (.I0(\mem[23][7]_i_2_n_0 ),
        .I1(\mem_reg[23]_39 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[23][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[23][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000800000)) 
    \mem[23][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[23][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hB0BBBBBBBBBBBBBB)) 
    \mem[23][7]_i_3 
       (.I0(\mem[23][7]_i_4_n_0 ),
        .I1(\mem[51][7]_i_8_n_0 ),
        .I2(\mem[60][7]_i_6_n_0 ),
        .I3(\mem[39][7]_i_5_n_0 ),
        .I4(\mem[23][7]_i_5_n_0 ),
        .I5(\mem[51][7]_i_5_n_0 ),
        .O(\mem[23][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'hFBFF)) 
    \mem[23][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(sel0__0),
        .I3(\q_dst_reg_n_0_[4] ),
        .O(\mem[23][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'h40001555)) 
    \mem[23][7]_i_5 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[3] ),
        .O(\mem[23][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[24][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[24][7]_i_2_n_0 ),
        .I2(\mem_reg[24]_38 [0]),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[24][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[24][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[24][7]_i_2_n_0 ),
        .I2(\mem_reg[24]_38 [1]),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[24][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[24][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[24][7]_i_2_n_0 ),
        .I2(\mem_reg[24]_38 [2]),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[24][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[24][3]_i_1 
       (.I0(\mem_reg[24]_38 [3]),
        .I1(\mem[24][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[24][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[24][4]_i_1 
       (.I0(\mem_reg[24]_38 [4]),
        .I1(\mem[24][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[24][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[24][5]_i_1 
       (.I0(\mem[24][7]_i_2_n_0 ),
        .I1(\mem_reg[24]_38 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[24][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[24][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[24][7]_i_2_n_0 ),
        .I2(\mem_reg[24]_38 [6]),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[24][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[24][7]_i_1 
       (.I0(\mem[24][7]_i_2_n_0 ),
        .I1(\mem_reg[24]_38 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[24][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[24][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000100000)) 
    \mem[24][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[3]),
        .I5(ptr[2]),
        .O(\mem[24][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBBBBBB0BBBBBB)) 
    \mem[24][7]_i_3 
       (.I0(\mem[25][7]_i_4_n_0 ),
        .I1(\mem[60][7]_i_5_n_0 ),
        .I2(\mem[60][7]_i_6_n_0 ),
        .I3(\mem[24][7]_i_4_n_0 ),
        .I4(\mem[24][7]_i_5_n_0 ),
        .I5(\mem[29][7]_i_4_n_0 ),
        .O(\mem[24][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \mem[24][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .O(\mem[24][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \mem[24][7]_i_5 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .O(\mem[24][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[25][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem_reg[25]_37 [0]),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[25][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[25][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem_reg[25]_37 [1]),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[25][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[25][2]_i_1 
       (.I0(\mem_reg[25]_37 [2]),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[25][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[25][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem_reg[25]_37 [3]),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[25][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[25][4]_i_1 
       (.I0(\mem_reg[25]_37 [4]),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[25][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[25][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem_reg[25]_37 [5]),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[25][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[25][6]_i_1 
       (.I0(\mem_reg[25]_37 [6]),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[25][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[25][7]_i_1 
       (.I0(\mem_reg[25]_37 [7]),
        .I1(\mem[25][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[25][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[25][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000080)) 
    \mem[25][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[25][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBFFFFBBBBF0FF)) 
    \mem[25][7]_i_3 
       (.I0(sel0__0),
        .I1(\mem[57][7]_i_5_n_0 ),
        .I2(\mem[25][7]_i_4_n_0 ),
        .I3(\result1[21]_i_3_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[25][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'hFBFF)) 
    \mem[25][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(sel0__0),
        .I3(\q_dst_reg_n_0_[4] ),
        .O(\mem[25][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[26][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem_reg[26]_36 [0]),
        .I3(\mem[26][4]_i_2_n_0 ),
        .I4(\mem[26][7]_i_3_n_0 ),
        .I5(\mem[62][0]_i_3_n_0 ),
        .O(\mem[26][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2E2FF00)) 
    \mem[26][1]_i_1 
       (.I0(\mem_reg[26]_36 [1]),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[62][1]_i_3_n_0 ),
        .I4(\mem[26][7]_i_3_n_0 ),
        .O(\mem[26][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[26][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem_reg[26]_36 [2]),
        .I3(\mem[26][4]_i_2_n_0 ),
        .I4(\mem[26][7]_i_3_n_0 ),
        .I5(\mem[62][2]_i_3_n_0 ),
        .O(\mem[26][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7400FFFF74007400)) 
    \mem[26][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem_reg[26]_36 [3]),
        .I3(\mem[26][4]_i_2_n_0 ),
        .I4(\mem[26][7]_i_3_n_0 ),
        .I5(\mem[62][3]_i_3_n_0 ),
        .O(\mem[26][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[26][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem_reg[26]_36 [4]),
        .I3(\mem[26][4]_i_2_n_0 ),
        .I4(\mem[26][7]_i_3_n_0 ),
        .I5(\mem[62][4]_i_3_n_0 ),
        .O(\mem[26][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hA2AAAAAAAAAAAAAA)) 
    \mem[26][4]_i_2 
       (.I0(\mem[26][4]_i_3_n_0 ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(sel0__0),
        .I3(\mem[58][7]_i_5_n_0 ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[26][4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFBFFFFF)) 
    \mem[26][4]_i_3 
       (.I0(sel0__0),
        .I1(\result1[21]_i_3_n_0 ),
        .I2(\mem[31][7]_i_8_n_0 ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[2] ),
        .O(\mem[26][4]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hE2E2FF00)) 
    \mem[26][5]_i_1 
       (.I0(\mem_reg[26]_36 [5]),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[62][5]_i_3_n_0 ),
        .I4(\mem[26][7]_i_3_n_0 ),
        .O(\mem[26][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[26][6]_i_1 
       (.I0(\mem_reg[26]_36 [6]),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[26][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[26][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[26][7]_i_1 
       (.I0(\mem_reg[26]_36 [7]),
        .I1(\mem[26][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[26][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[26][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000400000)) 
    \mem[26][7]_i_2 
       (.I0(ptr[0]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[3]),
        .I5(ptr[2]),
        .O(\mem[26][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h5155555555555555)) 
    \mem[26][7]_i_3 
       (.I0(\mem[26][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(sel0__0),
        .I3(\q_dst_reg_n_0_[3] ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\mem[58][7]_i_5_n_0 ),
        .O(\mem[26][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000080000)) 
    \mem[26][7]_i_4 
       (.I0(\mem[31][7]_i_8_n_0 ),
        .I1(\result1[21]_i_3_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[2] ),
        .O(\mem[26][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[27][0]_i_1 
       (.I0(\mem_reg[27]_35 [0]),
        .I1(\mem[27][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[27][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[27][1]_i_1 
       (.I0(\mem_reg[27]_35 [1]),
        .I1(\mem[27][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[27][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[27][2]_i_1 
       (.I0(\mem[27][7]_i_2_n_0 ),
        .I1(\mem_reg[27]_35 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[27][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[27][3]_i_1 
       (.I0(\mem[27][7]_i_2_n_0 ),
        .I1(\mem_reg[27]_35 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[27][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[27][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[27][7]_i_2_n_0 ),
        .I2(\mem_reg[27]_35 [4]),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[27][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[27][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[27][7]_i_2_n_0 ),
        .I2(\mem_reg[27]_35 [5]),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[27][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[27][6]_i_1 
       (.I0(\mem[27][7]_i_2_n_0 ),
        .I1(\mem_reg[27]_35 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[27][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[27][7]_i_1 
       (.I0(\mem[27][7]_i_2_n_0 ),
        .I1(\mem_reg[27]_35 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[27][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[27][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000800000)) 
    \mem[27][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(ptr[3]),
        .I5(ptr[2]),
        .O(\mem[27][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFCFFFFFFFDFFFFF)) 
    \mem[27][7]_i_3 
       (.I0(\mem[51][7]_i_8_n_0 ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\mem[51][7]_i_5_n_0 ),
        .O(\mem[27][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[28][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem_reg[28]_34 [0]),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[28][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[28][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem_reg[28]_34 [1]),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[28][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[28][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem_reg[28]_34 [2]),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[28][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[28][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem_reg[28]_34 [3]),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[28][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[28][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem_reg[28]_34 [4]),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[28][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[28][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem_reg[28]_34 [5]),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[28][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[28][6]_i_1 
       (.I0(\mem_reg[28]_34 [6]),
        .I1(\mem[28][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[28][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[28][7]_i_1 
       (.I0(\mem[28][7]_i_2_n_0 ),
        .I1(\mem_reg[28]_34 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[28][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[28][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0004000000000000)) 
    \mem[28][7]_i_2 
       (.I0(sel0),
        .I1(ptr[4]),
        .I2(ptr[0]),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[28][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h5515555555555555)) 
    \mem[28][7]_i_3 
       (.I0(\mem[28][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\mem[60][7]_i_5_n_0 ),
        .O(\mem[28][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0020000000000000)) 
    \mem[28][7]_i_4 
       (.I0(\mem[31][7]_i_8_n_0 ),
        .I1(sel0__0),
        .I2(\result1[21]_i_3_n_0 ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[28][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[29][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem_reg[29]_33 [0]),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[29][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[29][1]_i_1 
       (.I0(\mem_reg[29]_33 [1]),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[29][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[29][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem_reg[29]_33 [2]),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[29][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[29][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem_reg[29]_33 [3]),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[29][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[29][4]_i_1 
       (.I0(\mem_reg[29]_33 [4]),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[29][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[29][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem_reg[29]_33 [5]),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[29][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[29][6]_i_1 
       (.I0(\mem_reg[29]_33 [6]),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[29][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[29][7]_i_1 
       (.I0(\mem_reg[29]_33 [7]),
        .I1(\mem[29][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[29][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[29][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1000000000000000)) 
    \mem[29][7]_i_2 
       (.I0(sel0),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[0]),
        .I3(ptr[2]),
        .I4(ptr[4]),
        .I5(ptr[3]),
        .O(\mem[29][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FEFFFFFF)) 
    \mem[29][7]_i_3 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\mem[29][7]_i_4_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\mem[31][7]_i_8_n_0 ),
        .I5(\mem[29][7]_i_5_n_0 ),
        .O(\mem[29][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hBF)) 
    \mem[29][7]_i_4 
       (.I0(sel0__0),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .O(\mem[29][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000008000)) 
    \mem[29][7]_i_5 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\result0[21]_i_3_n_0 ),
        .I3(\mem[60][7]_i_4_n_0 ),
        .I4(sel0__0),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[29][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[2][0]_i_1 
       (.I0(\mem_reg[2]_60 [0]),
        .I1(\mem[2][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[2][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[2][1]_i_1 
       (.I0(\mem_reg[2]_60 [1]),
        .I1(\mem[2][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[2][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[2][2]_i_1 
       (.I0(\mem[2][7]_i_2_n_0 ),
        .I1(\mem_reg[2]_60 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[2][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[2][3]_i_1 
       (.I0(\mem_reg[2]_60 [3]),
        .I1(\mem[2][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[2][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[2][4]_i_1 
       (.I0(\mem[2][7]_i_2_n_0 ),
        .I1(\mem_reg[2]_60 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[2][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[2][5]_i_1 
       (.I0(\mem_reg[2]_60 [5]),
        .I1(\mem[2][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[2][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[2][6]_i_1 
       (.I0(\mem[2][7]_i_2_n_0 ),
        .I1(\mem_reg[2]_60 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[2][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[2][7]_i_1 
       (.I0(\mem_reg[2]_60 [7]),
        .I1(\mem[2][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[2][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[2][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000004)) 
    \mem[2][7]_i_2 
       (.I0(ptr[0]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[2][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFF7FCFFFFF7FFFFF)) 
    \mem[2][7]_i_3 
       (.I0(\mem[3][7]_i_5_n_0 ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\mem[3][7]_i_4_n_0 ),
        .O(\mem[2][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[30][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem_reg[30]_32 [0]),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[30][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[30][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem_reg[30]_32 [1]),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[30][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[30][2]_i_1 
       (.I0(\mem_reg[30]_32 [2]),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[30][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[30][3]_i_1 
       (.I0(\mem_reg[30]_32 [3]),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[30][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[30][4]_i_1 
       (.I0(\mem_reg[30]_32 [4]),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[30][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[30][5]_i_1 
       (.I0(\mem_reg[30]_32 [5]),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[30][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[30][6]_i_1 
       (.I0(\mem_reg[30]_32 [6]),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[30][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[30][7]_i_1 
       (.I0(\mem_reg[30]_32 [7]),
        .I1(\mem[30][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[30][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[30][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1000000000000000)) 
    \mem[30][7]_i_2 
       (.I0(ptr[0]),
        .I1(sel0),
        .I2(ptr[3]),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[30][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00007FFF7FFF7FFF)) 
    \mem[30][7]_i_3 
       (.I0(\mem[30][7]_i_4_n_0 ),
        .I1(\mem[45][7]_i_6_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[4] ),
        .I4(\mem[31][7]_i_8_n_0 ),
        .I5(\mem[30][7]_i_5_n_0 ),
        .O(\mem[30][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \mem[30][7]_i_4 
       (.I0(sel0__0),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[30][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0040000000000000)) 
    \mem[30][7]_i_5 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\phase_reg[1]_rep_n_0 ),
        .I5(\phase_reg[0]_rep__0_n_0 ),
        .O(\mem[30][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[31][0]_i_1 
       (.I0(\mem[62][0]_i_3_n_0 ),
        .I1(\mem[31][7]_i_3_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[31][7]_i_2_n_0 ),
        .I4(\mem_reg[31]_31 [0]),
        .O(\mem[31][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[31][1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\mem[31][7]_i_3_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[31][7]_i_2_n_0 ),
        .I4(\mem_reg[31]_31 [1]),
        .O(\mem[31][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[31][2]_i_1 
       (.I0(\mem[31][7]_i_2_n_0 ),
        .I1(\mem_reg[31]_31 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[62][2]_i_3_n_0 ),
        .I4(\mem[31][7]_i_3_n_0 ),
        .O(\mem[31][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hC5CFC5C0)) 
    \mem[31][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[62][3]_i_3_n_0 ),
        .I2(\mem[31][7]_i_3_n_0 ),
        .I3(\mem[31][7]_i_2_n_0 ),
        .I4(\mem_reg[31]_31 [3]),
        .O(\mem[31][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[31][4]_i_1 
       (.I0(\mem[31][7]_i_2_n_0 ),
        .I1(\mem_reg[31]_31 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[62][4]_i_3_n_0 ),
        .I4(\mem[31][7]_i_3_n_0 ),
        .O(\mem[31][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[31][5]_i_1 
       (.I0(\mem[31][7]_i_2_n_0 ),
        .I1(\mem_reg[31]_31 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[62][5]_i_3_n_0 ),
        .I4(\mem[31][7]_i_3_n_0 ),
        .O(\mem[31][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[31][6]_i_1 
       (.I0(\mem[31][7]_i_2_n_0 ),
        .I1(\mem_reg[31]_31 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[62][6]_i_3_n_0 ),
        .I4(\mem[31][7]_i_3_n_0 ),
        .O(\mem[31][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[31][7]_i_1 
       (.I0(\mem[31][7]_i_2_n_0 ),
        .I1(\mem_reg[31]_31 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_5_n_0 ),
        .I4(\mem[31][7]_i_3_n_0 ),
        .O(\mem[31][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000080000000)) 
    \mem[31][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[0]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[31][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h444F444444444444)) 
    \mem[31][7]_i_3 
       (.I0(\mem[31][7]_i_4_n_0 ),
        .I1(\mem[31][7]_i_5_n_0 ),
        .I2(\mem[31][7]_i_6_n_0 ),
        .I3(\mem[31][7]_i_7_n_0 ),
        .I4(\mem[39][7]_i_5_n_0 ),
        .I5(\mem[31][7]_i_8_n_0 ),
        .O(\mem[31][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT4 #(
    .INIT(16'hFBFF)) 
    \mem[31][7]_i_4 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(sel0__0),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[31][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \mem[31][7]_i_5 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[4] ),
        .O(\mem[31][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT4 #(
    .INIT(16'hFFBF)) 
    \mem[31][7]_i_6 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(sel0__0),
        .O(\mem[31][7]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT2 #(
    .INIT(4'h9)) 
    \mem[31][7]_i_7 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .O(\mem[31][7]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'h7F800000)) 
    \mem[31][7]_i_8 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .I4(\q_dst_reg_n_0_[4] ),
        .O(\mem[31][7]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[32][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem_reg[32]_30 [0]),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[32][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[32][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem_reg[32]_30 [1]),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[32][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[32][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem_reg[32]_30 [2]),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[32][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[32][3]_i_1 
       (.I0(\mem_reg[32]_30 [3]),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[32][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[32][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem_reg[32]_30 [4]),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[32][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[32][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem_reg[32]_30 [5]),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[32][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[32][6]_i_1 
       (.I0(\mem_reg[32]_30 [6]),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[32][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[32][7]_i_1 
       (.I0(\mem_reg[32]_30 [7]),
        .I1(\mem[32][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[32][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[32][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000100)) 
    \mem[32][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[32][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h5555555515555555)) 
    \mem[32][7]_i_3 
       (.I0(\mem[32][7]_i_4_n_0 ),
        .I1(\result1[21]_i_3_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(sel0__0),
        .I4(\mem[39][7]_i_6_n_0 ),
        .I5(\mem[32][7]_i_5_n_0 ),
        .O(\mem[32][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000100000000000)) 
    \mem[32][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\mem[51][7]_i_7_n_0 ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\result0[21]_i_3_n_0 ),
        .O(\mem[32][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'h7E)) 
    \mem[32][7]_i_5 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .O(\mem[32][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[33][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem_reg[33]_29 [0]),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[33][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[33][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem_reg[33]_29 [1]),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[33][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[33][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem_reg[33]_29 [2]),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[33][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[33][3]_i_1 
       (.I0(\mem_reg[33]_29 [3]),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[33][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[33][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem_reg[33]_29 [4]),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[33][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[33][5]_i_1 
       (.I0(\mem_reg[33]_29 [5]),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[33][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[33][6]_i_1 
       (.I0(\mem_reg[33]_29 [6]),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[33][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[33][7]_i_1 
       (.I0(\mem_reg[33]_29 [7]),
        .I1(\mem[33][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[33][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[33][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000400)) 
    \mem[33][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(ptr[4]),
        .I3(sel0),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[33][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFBFBFB3BFBFBFBFB)) 
    \mem[33][7]_i_3 
       (.I0(\mem[33][7]_i_4_n_0 ),
        .I1(sel0__0),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\mem[33][7]_i_5_n_0 ),
        .O(\mem[33][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFB)) 
    \mem[33][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\result1[21]_i_3_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[33][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \mem[33][7]_i_5 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .O(\mem[33][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[34][0]_i_1 
       (.I0(\mem_reg[34]_28 [0]),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[34][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[34][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem_reg[34]_28 [1]),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[34][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[34][2]_i_1 
       (.I0(\mem_reg[34]_28 [2]),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[34][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[34][3]_i_1 
       (.I0(\mem_reg[34]_28 [3]),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[34][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[34][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem_reg[34]_28 [4]),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[34][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[34][5]_i_1 
       (.I0(\mem[34][7]_i_2_n_0 ),
        .I1(\mem_reg[34]_28 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[34][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[34][6]_i_1 
       (.I0(\mem_reg[34]_28 [6]),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[34][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[34][7]_i_1 
       (.I0(\mem_reg[34]_28 [7]),
        .I1(\mem[34][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[34][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[34][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000020000)) 
    \mem[34][7]_i_2 
       (.I0(sel0),
        .I1(ptr[4]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[0]),
        .O(\mem[34][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBBBBBB0BBBBBBBBB)) 
    \mem[34][7]_i_3 
       (.I0(\mem[50][7]_i_4_n_0 ),
        .I1(\mem[39][7]_i_6_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\mem[44][7]_i_6_n_0 ),
        .I5(\mem[54][7]_i_5_n_0 ),
        .O(\mem[34][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[35][0]_i_1 
       (.I0(\mem[35][7]_i_2_n_0 ),
        .I1(\mem_reg[35]_27 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[62][0]_i_3_n_0 ),
        .I4(\mem[35][7]_i_3_n_0 ),
        .O(\mem[35][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[35][1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\mem[35][7]_i_3_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[35][7]_i_2_n_0 ),
        .I4(\mem_reg[35]_27 [1]),
        .O(\mem[35][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[35][2]_i_1 
       (.I0(\mem[35][7]_i_2_n_0 ),
        .I1(\mem_reg[35]_27 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[62][2]_i_3_n_0 ),
        .I4(\mem[35][7]_i_3_n_0 ),
        .O(\mem[35][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hC5CFC5C0)) 
    \mem[35][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[62][3]_i_3_n_0 ),
        .I2(\mem[35][7]_i_3_n_0 ),
        .I3(\mem[35][7]_i_2_n_0 ),
        .I4(\mem_reg[35]_27 [3]),
        .O(\mem[35][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[35][4]_i_1 
       (.I0(\mem[35][7]_i_2_n_0 ),
        .I1(\mem_reg[35]_27 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[62][4]_i_3_n_0 ),
        .I4(\mem[35][7]_i_3_n_0 ),
        .O(\mem[35][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[35][5]_i_1 
       (.I0(\mem[62][5]_i_3_n_0 ),
        .I1(\mem[35][7]_i_3_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[35][7]_i_2_n_0 ),
        .I4(\mem_reg[35]_27 [5]),
        .O(\mem[35][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[35][6]_i_1 
       (.I0(\mem[35][7]_i_2_n_0 ),
        .I1(\mem_reg[35]_27 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[62][6]_i_3_n_0 ),
        .I4(\mem[35][7]_i_3_n_0 ),
        .O(\mem[35][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[35][7]_i_1 
       (.I0(\mem[35][7]_i_2_n_0 ),
        .I1(\mem_reg[35]_27 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_5_n_0 ),
        .I4(\mem[35][7]_i_3_n_0 ),
        .O(\mem[35][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0002000000000000)) 
    \mem[35][7]_i_2 
       (.I0(sel0),
        .I1(ptr[4]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[35][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBAAAAAAAAAAAAAAA)) 
    \mem[35][7]_i_3 
       (.I0(\mem[35][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\mem[51][7]_i_7_n_0 ),
        .I4(\result0[21]_i_3_n_0 ),
        .I5(\mem[45][7]_i_5_n_0 ),
        .O(\mem[35][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000010)) 
    \mem[35][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\mem[35][7]_i_5_n_0 ),
        .O(\mem[35][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'h7F)) 
    \mem[35][7]_i_5 
       (.I0(sel0__0),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .O(\mem[35][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[36][0]_i_1 
       (.I0(\mem_reg[36]_26 [0]),
        .I1(\mem[36][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[36][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[36][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[36][7]_i_2_n_0 ),
        .I2(\mem_reg[36]_26 [1]),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[36][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[36][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[36][7]_i_2_n_0 ),
        .I2(\mem_reg[36]_26 [2]),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[36][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[36][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[36][7]_i_2_n_0 ),
        .I2(\mem_reg[36]_26 [3]),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[36][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[36][4]_i_1 
       (.I0(\mem[36][7]_i_2_n_0 ),
        .I1(\mem_reg[36]_26 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[36][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[36][5]_i_1 
       (.I0(\mem_reg[36]_26 [5]),
        .I1(\mem[36][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[36][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[36][6]_i_1 
       (.I0(\mem_reg[36]_26 [6]),
        .I1(\mem[36][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[36][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[36][7]_i_1 
       (.I0(\mem[36][7]_i_2_n_0 ),
        .I1(\mem_reg[36]_26 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[36][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[36][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000001000000000)) 
    \mem[36][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[36][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hB0BBBBBBBBBBBBBB)) 
    \mem[36][7]_i_3 
       (.I0(\mem[39][7]_i_4_n_0 ),
        .I1(\mem[60][7]_i_5_n_0 ),
        .I2(\mem[36][7]_i_4_n_0 ),
        .I3(\mem[39][7]_i_5_n_0 ),
        .I4(sel0__0),
        .I5(\mem[39][7]_i_6_n_0 ),
        .O(\mem[36][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \mem[36][7]_i_4 
       (.I0(\phase_reg[0]_rep_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[36][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[37][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[37][7]_i_2_n_0 ),
        .I2(\mem_reg[37]_25 [0]),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[37][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[37][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[37][7]_i_2_n_0 ),
        .I2(\mem_reg[37]_25 [1]),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[37][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[37][2]_i_1 
       (.I0(\mem_reg[37]_25 [2]),
        .I1(\mem[37][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[37][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[37][3]_i_1 
       (.I0(\mem_reg[37]_25 [3]),
        .I1(\mem[37][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[37][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[37][4]_i_1 
       (.I0(\mem_reg[37]_25 [4]),
        .I1(\mem[37][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[37][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[37][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[37][7]_i_2_n_0 ),
        .I2(\mem_reg[37]_25 [5]),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[37][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[37][6]_i_1 
       (.I0(\mem[37][7]_i_2_n_0 ),
        .I1(\mem_reg[37]_25 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[37][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[37][7]_i_1 
       (.I0(\mem[37][7]_i_2_n_0 ),
        .I1(\mem_reg[37]_25 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[37][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[37][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000004000000000)) 
    \mem[37][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[37][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFF0FFBBFFFFFFBB)) 
    \mem[37][7]_i_3 
       (.I0(\mem[37][7]_i_4_n_0 ),
        .I1(\mem[37][7]_i_5_n_0 ),
        .I2(\mem[37][7]_i_6_n_0 ),
        .I3(\q_dst_reg_n_0_[4] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\mem[37][7]_i_7_n_0 ),
        .O(\mem[37][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'hD57F)) 
    \mem[37][7]_i_4 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .O(\mem[37][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h9005000000000000)) 
    \mem[37][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\phase_reg[0]_rep__0_n_0 ),
        .I5(\phase_reg[1]_rep_n_0 ),
        .O(\mem[37][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \mem[37][7]_i_6 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[2] ),
        .O(\mem[37][7]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \mem[37][7]_i_7 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[37][7]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[38][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [0]),
        .I3(\mem[38][4]_i_2_n_0 ),
        .I4(\mem[38][7]_i_3_n_0 ),
        .I5(\mem[62][0]_i_3_n_0 ),
        .O(\mem[38][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[38][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [1]),
        .I3(\mem[38][4]_i_2_n_0 ),
        .I4(\mem[38][7]_i_3_n_0 ),
        .I5(\mem[62][1]_i_3_n_0 ),
        .O(\mem[38][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[38][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [2]),
        .I3(\mem[38][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[38][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[38][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [3]),
        .I3(\mem[38][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[38][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[38][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [4]),
        .I3(\mem[38][4]_i_2_n_0 ),
        .I4(\mem[38][7]_i_3_n_0 ),
        .I5(\mem[62][4]_i_3_n_0 ),
        .O(\mem[38][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000DFFFFFFF)) 
    \mem[38][4]_i_2 
       (.I0(\mem[54][7]_i_5_n_0 ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\mem[38][7]_i_4_n_0 ),
        .O(\mem[38][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[38][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [5]),
        .I3(\mem[38][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[38][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[38][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem_reg[38]_24 [6]),
        .I3(\mem[38][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[38][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[38][7]_i_1 
       (.I0(\mem_reg[38]_24 [7]),
        .I1(\mem[38][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[38][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[38][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000004000000000)) 
    \mem[38][7]_i_2 
       (.I0(ptr[0]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[38][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h5555155555555555)) 
    \mem[38][7]_i_3 
       (.I0(\mem[38][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\mem[54][7]_i_5_n_0 ),
        .O(\mem[38][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0110000000000000)) 
    \mem[38][7]_i_4 
       (.I0(\mem[54][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(sel0__0),
        .I5(\q_dst_reg_n_0_[2] ),
        .O(\mem[38][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[39][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[39][7]_i_2_n_0 ),
        .I2(\mem_reg[39]_23 [0]),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[39][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[39][1]_i_1 
       (.I0(\mem_reg[39]_23 [1]),
        .I1(\mem[39][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[39][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[39][2]_i_1 
       (.I0(\mem[39][7]_i_2_n_0 ),
        .I1(\mem_reg[39]_23 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[39][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[39][3]_i_1 
       (.I0(\mem[39][7]_i_2_n_0 ),
        .I1(\mem_reg[39]_23 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[39][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[39][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[39][7]_i_2_n_0 ),
        .I2(\mem_reg[39]_23 [4]),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[39][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[39][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[39][7]_i_2_n_0 ),
        .I2(\mem_reg[39]_23 [5]),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[39][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[39][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[39][7]_i_2_n_0 ),
        .I2(\mem_reg[39]_23 [6]),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[39][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[39][7]_i_1 
       (.I0(\mem[39][7]_i_2_n_0 ),
        .I1(\mem_reg[39]_23 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[39][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[39][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000008000000000)) 
    \mem[39][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[39][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0BBBBBBBBBBBBBBB)) 
    \mem[39][7]_i_3 
       (.I0(\mem[39][7]_i_4_n_0 ),
        .I1(\mem[51][7]_i_8_n_0 ),
        .I2(\mem[39][7]_i_5_n_0 ),
        .I3(sel0__0),
        .I4(\mem[51][7]_i_5_n_0 ),
        .I5(\mem[39][7]_i_6_n_0 ),
        .O(\mem[39][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT4 #(
    .INIT(16'hFDFF)) 
    \mem[39][7]_i_4 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .O(\mem[39][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'h6A)) 
    \mem[39][7]_i_5 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .O(\mem[39][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h80001555)) 
    \mem[39][7]_i_6 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[3] ),
        .O(\mem[39][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[3][0]_i_1 
       (.I0(\mem[3][7]_i_2_n_0 ),
        .I1(\mem_reg[3]_59 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[3][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[3][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[3][7]_i_2_n_0 ),
        .I2(\mem_reg[3]_59 [1]),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[3][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[3][2]_i_1 
       (.I0(\mem[3][7]_i_2_n_0 ),
        .I1(\mem_reg[3]_59 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[3][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[3][3]_i_1 
       (.I0(\mem_reg[3]_59 [3]),
        .I1(\mem[3][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[3][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[3][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[3][7]_i_2_n_0 ),
        .I2(\mem_reg[3]_59 [4]),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[3][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[3][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[3][7]_i_2_n_0 ),
        .I2(\mem_reg[3]_59 [5]),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[3][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[3][6]_i_1 
       (.I0(\mem[3][7]_i_2_n_0 ),
        .I1(\mem_reg[3]_59 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[3][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[3][7]_i_1 
       (.I0(\mem[3][7]_i_2_n_0 ),
        .I1(\mem_reg[3]_59 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[3][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[3][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    \mem[3][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[3][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hDFFF3FFFDFFFFFFF)) 
    \mem[3][7]_i_3 
       (.I0(\mem[3][7]_i_4_n_0 ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\mem[3][7]_i_5_n_0 ),
        .O(\mem[3][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \mem[3][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(sel0__0),
        .O(\mem[3][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000000080010101)) 
    \mem[3][7]_i_5 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(sel0__0),
        .O(\mem[3][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[40][0]_i_1 
       (.I0(\mem[40][7]_i_2_n_0 ),
        .I1(\mem_reg[40]_22 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[62][0]_i_3_n_0 ),
        .I4(\mem[40][7]_i_3_n_0 ),
        .O(\mem[40][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[40][1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\mem[40][7]_i_3_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[40][7]_i_2_n_0 ),
        .I4(\mem_reg[40]_22 [1]),
        .O(\mem[40][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[40][2]_i_1 
       (.I0(\mem[62][2]_i_3_n_0 ),
        .I1(\mem[40][7]_i_3_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[40][7]_i_2_n_0 ),
        .I4(\mem_reg[40]_22 [2]),
        .O(\mem[40][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF004E4E)) 
    \mem[40][3]_i_1 
       (.I0(\mem[40][7]_i_2_n_0 ),
        .I1(\mem_reg[40]_22 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[62][3]_i_3_n_0 ),
        .I4(\mem[40][7]_i_3_n_0 ),
        .O(\mem[40][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[40][4]_i_1 
       (.I0(\mem[40][7]_i_2_n_0 ),
        .I1(\mem_reg[40]_22 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[62][4]_i_3_n_0 ),
        .I4(\mem[40][7]_i_3_n_0 ),
        .O(\mem[40][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[40][5]_i_1 
       (.I0(\mem[62][5]_i_3_n_0 ),
        .I1(\mem[40][7]_i_3_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[40][7]_i_2_n_0 ),
        .I4(\mem_reg[40]_22 [5]),
        .O(\mem[40][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[40][6]_i_1 
       (.I0(\mem[62][6]_i_3_n_0 ),
        .I1(\mem[40][7]_i_3_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[40][7]_i_2_n_0 ),
        .I4(\mem_reg[40]_22 [6]),
        .O(\mem[40][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[40][7]_i_1 
       (.I0(\mem[40][7]_i_2_n_0 ),
        .I1(\mem_reg[40]_22 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_5_n_0 ),
        .I4(\mem[40][7]_i_3_n_0 ),
        .O(\mem[40][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000001000000000)) 
    \mem[40][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[3]),
        .I3(ptr[2]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[40][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h4040404040FF4040)) 
    \mem[40][7]_i_3 
       (.I0(\mem[44][7]_i_6_n_0 ),
        .I1(\mem[56][7]_i_6_n_0 ),
        .I2(\mem[60][7]_i_5_n_0 ),
        .I3(\mem[44][7]_i_4_n_0 ),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(\mem[40][7]_i_4_n_0 ),
        .O(\mem[40][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \mem[40][7]_i_4 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .O(\mem[40][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[41][0]_i_1 
       (.I0(\mem_reg[41]_21 [0]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[41][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[41][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem_reg[41]_21 [1]),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[41][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[41][2]_i_1 
       (.I0(\mem_reg[41]_21 [2]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[41][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[41][3]_i_1 
       (.I0(\mem_reg[41]_21 [3]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[41][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[41][4]_i_1 
       (.I0(\mem_reg[41]_21 [4]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[41][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[41][5]_i_1 
       (.I0(\mem_reg[41]_21 [5]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[41][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[41][6]_i_1 
       (.I0(\mem_reg[41]_21 [6]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[41][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[41][7]_i_1 
       (.I0(\mem_reg[41]_21 [7]),
        .I1(\mem[41][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[41][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[41][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000040000000000)) 
    \mem[41][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[0]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[41][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFF0FFBBFFFFFFBB)) 
    \mem[41][7]_i_3 
       (.I0(\mem[44][7]_i_4_n_0 ),
        .I1(\mem[41][7]_i_4_n_0 ),
        .I2(\mem[41][7]_i_5_n_0 ),
        .I3(\q_dst_reg_n_0_[4] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\mem[41][7]_i_6_n_0 ),
        .O(\mem[41][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h80000008)) 
    \mem[41][7]_i_4 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .O(\mem[41][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT4 #(
    .INIT(16'hFFFB)) 
    \mem[41][7]_i_5 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[41][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \mem[41][7]_i_6 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[3] ),
        .O(\mem[41][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[42][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem_reg[42]_20 [0]),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[42][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[42][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem_reg[42]_20 [1]),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[42][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[42][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem_reg[42]_20 [2]),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[42][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[42][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem_reg[42]_20 [3]),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[42][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[42][4]_i_1 
       (.I0(\mem_reg[42]_20 [4]),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[42][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[42][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem_reg[42]_20 [5]),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[42][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[42][6]_i_1 
       (.I0(\mem_reg[42]_20 [6]),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[42][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[42][7]_i_1 
       (.I0(\mem_reg[42]_20 [7]),
        .I1(\mem[42][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[42][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[42][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000004000000000)) 
    \mem[42][7]_i_2 
       (.I0(ptr[0]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[3]),
        .I3(ptr[2]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[42][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFB00F7F7)) 
    \mem[42][7]_i_3 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\mem[42][7]_i_4_n_0 ),
        .I2(\mem[44][7]_i_4_n_0 ),
        .I3(\mem[42][7]_i_5_n_0 ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\q_dst_reg_n_0_[4] ),
        .O(\mem[42][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h90000000)) 
    \mem[42][7]_i_4 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .O(\mem[42][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFFFFFFFFFFFFF)) 
    \mem[42][7]_i_5 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[3] ),
        .I5(sel0__0),
        .O(\mem[42][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[43][0]_i_1 
       (.I0(\mem_reg[43]_19 [0]),
        .I1(\mem[43][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[43][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[43][1]_i_1 
       (.I0(\mem[43][7]_i_2_n_0 ),
        .I1(\mem_reg[43]_19 [1]),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[43][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[43][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[43][7]_i_2_n_0 ),
        .I2(\mem_reg[43]_19 [2]),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[43][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[43][3]_i_1 
       (.I0(\mem[43][7]_i_2_n_0 ),
        .I1(\mem_reg[43]_19 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[43][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[43][4]_i_1 
       (.I0(\mem_reg[43]_19 [4]),
        .I1(\mem[43][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[43][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[43][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[43][7]_i_2_n_0 ),
        .I2(\mem_reg[43]_19 [5]),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[43][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[43][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[43][7]_i_2_n_0 ),
        .I2(\mem_reg[43]_19 [6]),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[43][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[43][7]_i_1 
       (.I0(\mem_reg[43]_19 [7]),
        .I1(\mem[43][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[43][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[43][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000008000000000)) 
    \mem[43][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[3]),
        .I3(ptr[2]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[43][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBF00BFBFBFBFBFBF)) 
    \mem[43][7]_i_3 
       (.I0(\mem[44][7]_i_6_n_0 ),
        .I1(\mem[56][7]_i_6_n_0 ),
        .I2(\mem[51][7]_i_8_n_0 ),
        .I3(\mem[44][7]_i_4_n_0 ),
        .I4(\mem[51][7]_i_5_n_0 ),
        .I5(\mem[43][7]_i_4_n_0 ),
        .O(\mem[43][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT5 #(
    .INIT(32'h90000333)) 
    \mem[43][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .O(\mem[43][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[44][0]_i_1 
       (.I0(\mem_reg[44]_18 [0]),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[44][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[44][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem_reg[44]_18 [1]),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[44][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[44][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem_reg[44]_18 [2]),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[44][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[44][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem_reg[44]_18 [3]),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[44][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[44][4]_i_1 
       (.I0(\mem_reg[44]_18 [4]),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[44][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[44][5]_i_1 
       (.I0(\mem_reg[44]_18 [5]),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[44][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[44][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[44][7]_i_2_n_0 ),
        .I2(\mem_reg[44]_18 [6]),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[44][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[44][7]_i_1 
       (.I0(\mem[44][7]_i_2_n_0 ),
        .I1(\mem_reg[44]_18 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[44][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[44][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0002000000000000)) 
    \mem[44][7]_i_2 
       (.I0(sel0),
        .I1(ptr[4]),
        .I2(ptr[0]),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(ptr[2]),
        .I5(ptr[3]),
        .O(\mem[44][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBF00BFBFBFBFBFBF)) 
    \mem[44][7]_i_3 
       (.I0(\mem[44][7]_i_4_n_0 ),
        .I1(\mem[60][7]_i_6_n_0 ),
        .I2(\mem[44][7]_i_5_n_0 ),
        .I3(\mem[44][7]_i_6_n_0 ),
        .I4(\mem[45][7]_i_6_n_0 ),
        .I5(\mem[60][7]_i_5_n_0 ),
        .O(\mem[44][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'hD5557FFF)) 
    \mem[44][7]_i_4 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[3] ),
        .O(\mem[44][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h00008000)) 
    \mem[44][7]_i_5 
       (.I0(\phase_reg[0]_rep_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .O(\mem[44][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \mem[44][7]_i_6 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(sel0__0),
        .O(\mem[44][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[45][0]_i_1 
       (.I0(\mem_reg[45]_17 [0]),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[45][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[45][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[45][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem_reg[45]_17 [1]),
        .I3(\mem[45][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[45][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[45][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem_reg[45]_17 [2]),
        .I3(\mem[45][3]_i_2_n_0 ),
        .I4(\mem[45][7]_i_3_n_0 ),
        .I5(\mem[62][2]_i_3_n_0 ),
        .O(\mem[45][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7400FFFF74007400)) 
    \mem[45][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem_reg[45]_17 [3]),
        .I3(\mem[45][3]_i_2_n_0 ),
        .I4(\mem[45][7]_i_3_n_0 ),
        .I5(\mem[62][3]_i_3_n_0 ),
        .O(\mem[45][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FFFFF7FF)) 
    \mem[45][3]_i_2 
       (.I0(\mem[45][7]_i_5_n_0 ),
        .I1(\mem[45][7]_i_6_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\result0[21]_i_3_n_0 ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\mem[45][7]_i_4_n_0 ),
        .O(\mem[45][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[45][4]_i_1 
       (.I0(\mem_reg[45]_17 [4]),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[45][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[45][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[45][5]_i_1 
       (.I0(\mem_reg[45]_17 [5]),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[45][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[45][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[45][6]_i_1 
       (.I0(\mem_reg[45]_17 [6]),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[45][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[45][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[45][7]_i_1 
       (.I0(\mem_reg[45]_17 [7]),
        .I1(\mem[45][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[45][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[45][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000080000000000)) 
    \mem[45][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[0]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[45][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h5555555555551555)) 
    \mem[45][7]_i_3 
       (.I0(\mem[45][7]_i_4_n_0 ),
        .I1(\result0[21]_i_3_n_0 ),
        .I2(\mem[45][7]_i_5_n_0 ),
        .I3(\mem[45][7]_i_6_n_0 ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\q_dst_reg_n_0_[4] ),
        .O(\mem[45][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000200000)) 
    \mem[45][7]_i_4 
       (.I0(\result1[21]_i_3_n_0 ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(\mem[44][7]_i_4_n_0 ),
        .O(\mem[45][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \mem[45][7]_i_5 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[0] ),
        .O(\mem[45][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \mem[45][7]_i_6 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .O(\mem[45][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[46][0]_i_1 
       (.I0(\mem_reg[46]_16 [0]),
        .I1(\mem[46][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[46][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[46][1]_i_1 
       (.I0(\mem_reg[46]_16 [1]),
        .I1(\mem[46][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[46][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[46][2]_i_1 
       (.I0(\mem_reg[46]_16 [2]),
        .I1(\mem[46][2]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[46][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hEFFFFFFFFFFFFFFF)) 
    \mem[46][2]_i_2 
       (.I0(ptr[4]),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(sel0),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[46][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[46][3]_i_1 
       (.I0(\mem[46][7]_i_2_n_0 ),
        .I1(\mem_reg[46]_16 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[46][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[46][4]_i_1 
       (.I0(\mem_reg[46]_16 [4]),
        .I1(\mem[46][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[46][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[46][5]_i_1 
       (.I0(\mem_reg[46]_16 [5]),
        .I1(\mem[46][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[46][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[46][6]_i_1 
       (.I0(\mem[46][7]_i_2_n_0 ),
        .I1(\mem_reg[46]_16 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[46][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[46][7]_i_1 
       (.I0(\mem_reg[46]_16 [7]),
        .I1(\mem[46][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[46][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[46][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000400000000000)) 
    \mem[46][7]_i_2 
       (.I0(ptr[0]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[4]),
        .I5(sel0),
        .O(\mem[46][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0FEEFFEEFFEEFFEE)) 
    \mem[46][7]_i_3 
       (.I0(\mem[47][7]_i_5_n_0 ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\mem[60][7]_i_6_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\result1[21]_i_3_n_0 ),
        .I5(\mem[46][7]_i_4_n_0 ),
        .O(\mem[46][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'h08800000)) 
    \mem[46][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(sel0__0),
        .O(\mem[46][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[47][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem_reg[47]_15 [0]),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[47][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[47][1]_i_1 
       (.I0(\mem_reg[47]_15 [1]),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[47][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[47][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem_reg[47]_15 [2]),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[47][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[47][3]_i_1 
       (.I0(\mem_reg[47]_15 [3]),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[47][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[47][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem_reg[47]_15 [4]),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[47][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[47][5]_i_1 
       (.I0(\mem_reg[47]_15 [5]),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[47][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[47][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[47][7]_i_3_n_0 ),
        .I2(\mem_reg[47]_15 [6]),
        .I3(\mem[47][7]_i_2_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[47][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hEEE22E22)) 
    \mem[47][7]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\mem[47][7]_i_2_n_0 ),
        .I2(\mem[47][7]_i_3_n_0 ),
        .I3(\mem_reg[47]_15 [7]),
        .I4(\mem[62][7]_i_3_n_0 ),
        .O(\mem[47][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFF00F7F7)) 
    \mem[47][7]_i_2 
       (.I0(\mem[56][7]_i_4_n_0 ),
        .I1(sel0__0),
        .I2(\mem[47][7]_i_4_n_0 ),
        .I3(\mem[47][7]_i_5_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[4] ),
        .O(\mem[47][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    \mem[47][7]_i_3 
       (.I0(ptr[4]),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(sel0),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[47][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hF77FFFFF)) 
    \mem[47][7]_i_4 
       (.I0(\phase_reg[0]_rep_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .O(\mem[47][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF7FFFFFFFFFFF)) 
    \mem[47][7]_i_5 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\phase_reg[0]_rep_n_0 ),
        .I5(\phase_reg[1]_rep_n_0 ),
        .O(\mem[47][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[48][0]_i_1 
       (.I0(\mem_reg[48]_14 [0]),
        .I1(\mem[48][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[48][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[48][1]_i_1 
       (.I0(\mem_reg[48]_14 [1]),
        .I1(\mem[48][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[48][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[48][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[48][7]_i_2_n_0 ),
        .I2(\mem_reg[48]_14 [2]),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[48][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[48][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[48][7]_i_2_n_0 ),
        .I2(\mem_reg[48]_14 [3]),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[48][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[48][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[48][7]_i_2_n_0 ),
        .I2(\mem_reg[48]_14 [4]),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[48][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[48][5]_i_1 
       (.I0(\mem[48][7]_i_2_n_0 ),
        .I1(\mem_reg[48]_14 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[48][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[48][6]_i_1 
       (.I0(\mem[48][7]_i_2_n_0 ),
        .I1(\mem_reg[48]_14 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[48][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[48][7]_i_1 
       (.I0(\mem[62][7]_i_3_n_0 ),
        .I1(\mem[48][7]_i_2_n_0 ),
        .I2(\mem_reg[48]_14 [7]),
        .I3(\mem[48][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[48][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0001000000000000)) 
    \mem[48][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[2]),
        .I2(ptr[0]),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[48][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h07FFF7FFF7FFF7FF)) 
    \mem[48][7]_i_3 
       (.I0(\result1[21]_i_3_n_0 ),
        .I1(\mem[48][7]_i_4_n_0 ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(sel0__0),
        .I4(\mem[60][7]_i_5_n_0 ),
        .I5(\mem[51][7]_i_7_n_0 ),
        .O(\mem[48][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \mem[48][7]_i_4 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .O(\mem[48][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[49][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem_reg[49]_13 [0]),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[49][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[49][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem_reg[49]_13 [1]),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[49][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[49][2]_i_1 
       (.I0(\mem_reg[49]_13 [2]),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[49][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[49][3]_i_1 
       (.I0(\mem_reg[49]_13 [3]),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[49][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[49][4]_i_1 
       (.I0(\mem_reg[49]_13 [4]),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[49][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[49][5]_i_1 
       (.I0(\mem_reg[49]_13 [5]),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[49][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[49][6]_i_1 
       (.I0(\mem_reg[49]_13 [6]),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[49][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[49][7]_i_1 
       (.I0(\mem_reg[49]_13 [7]),
        .I1(\mem[49][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[49][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[49][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000004000)) 
    \mem[49][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[49][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFEEF0FFFF)) 
    \mem[49][7]_i_3 
       (.I0(\mem[57][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\mem[49][7]_i_4_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\phase_reg[1]_rep_n_0 ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[49][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'hFFF7FFFF)) 
    \mem[49][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(sel0__0),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .O(\mem[49][7]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[4][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[4][7]_i_2_n_0 ),
        .I2(\mem_reg[4]_58 [0]),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[4][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[4][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[4][7]_i_2_n_0 ),
        .I2(\mem_reg[4]_58 [1]),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[4][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[4][2]_i_1 
       (.I0(\mem_reg[4]_58 [2]),
        .I1(\mem[4][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[4][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[4][3]_i_1 
       (.I0(\mem_reg[4]_58 [3]),
        .I1(\mem[4][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[4][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[4][4]_i_1 
       (.I0(\mem[4][7]_i_2_n_0 ),
        .I1(\mem_reg[4]_58 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[4][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[4][5]_i_1 
       (.I0(\mem_reg[4]_58 [5]),
        .I1(\mem[4][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[4][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[4][6]_i_1 
       (.I0(\mem_reg[4]_58 [6]),
        .I1(\mem[4][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[4][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[4][7]_i_1 
       (.I0(\mem[4][7]_i_2_n_0 ),
        .I1(\mem_reg[4]_58 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[4][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[4][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000004)) 
    \mem[4][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[2]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[4][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00000000FFFFFF7F)) 
    \mem[4][7]_i_3 
       (.I0(\mem[60][7]_i_6_n_0 ),
        .I1(\mem[31][7]_i_7_n_0 ),
        .I2(\mem[39][7]_i_5_n_0 ),
        .I3(sel0__0),
        .I4(\mem[54][7]_i_4_n_0 ),
        .I5(\mem[4][7]_i_4_n_0 ),
        .O(\mem[4][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000002)) 
    \mem[4][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(sel0__0),
        .I5(\mem[4][7]_i_5_n_0 ),
        .O(\mem[4][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hEF)) 
    \mem[4][7]_i_5 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg[1]_rep_n_0 ),
        .O(\mem[4][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[50][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[50][7]_i_2_n_0 ),
        .I2(\mem_reg[50]_12 [0]),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[50][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[50][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[50][7]_i_2_n_0 ),
        .I2(\mem_reg[50]_12 [1]),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[50][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[50][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[50][7]_i_2_n_0 ),
        .I2(\mem_reg[50]_12 [2]),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[50][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[50][3]_i_1 
       (.I0(\mem[50][7]_i_2_n_0 ),
        .I1(\mem_reg[50]_12 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[50][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[50][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[50][7]_i_2_n_0 ),
        .I2(\mem_reg[50]_12 [4]),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[50][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[50][5]_i_1 
       (.I0(\mem[50][7]_i_2_n_0 ),
        .I1(\mem_reg[50]_12 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[50][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[50][6]_i_1 
       (.I0(\mem[50][7]_i_2_n_0 ),
        .I1(\mem_reg[50]_12 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[50][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[50][7]_i_1 
       (.I0(\mem[50][7]_i_2_n_0 ),
        .I1(\mem_reg[50]_12 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[50][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[50][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000080000)) 
    \mem[50][7]_i_2 
       (.I0(ptr[4]),
        .I1(sel0),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[0]),
        .O(\mem[50][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFE00FEFEFEFEFEFE)) 
    \mem[50][7]_i_3 
       (.I0(\mem[50][7]_i_4_n_0 ),
        .I1(\mem[56][7]_i_4_n_0 ),
        .I2(\mem[60][7]_i_6_n_0 ),
        .I3(\mem[50][7]_i_5_n_0 ),
        .I4(\mem[51][7]_i_7_n_0 ),
        .I5(\mem[50][7]_i_6_n_0 ),
        .O(\mem[50][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFF7FFFFFFFFF)) 
    \mem[50][7]_i_4 
       (.I0(\phase_reg[1]_rep_n_0 ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(sel0__0),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\q_dst_reg_n_0_[0] ),
        .O(\mem[50][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT4 #(
    .INIT(16'hFBFF)) 
    \mem[50][7]_i_5 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(sel0__0),
        .O(\mem[50][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \mem[50][7]_i_6 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .O(\mem[50][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[51][0]_i_1 
       (.I0(\mem[51][7]_i_2_n_0 ),
        .I1(\mem_reg[51]_11 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[51][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[51][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[51][7]_i_2_n_0 ),
        .I2(\mem_reg[51]_11 [1]),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[51][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[51][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[51][7]_i_2_n_0 ),
        .I2(\mem_reg[51]_11 [2]),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[51][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[51][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[51][7]_i_2_n_0 ),
        .I2(\mem_reg[51]_11 [3]),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[51][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[51][4]_i_1 
       (.I0(\mem[51][7]_i_2_n_0 ),
        .I1(\mem_reg[51]_11 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[51][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[51][5]_i_1 
       (.I0(\mem[51][7]_i_2_n_0 ),
        .I1(\mem_reg[51]_11 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[51][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[51][6]_i_1 
       (.I0(\mem[51][7]_i_2_n_0 ),
        .I1(\mem_reg[51]_11 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[51][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[51][7]_i_1 
       (.I0(\mem[51][7]_i_2_n_0 ),
        .I1(\mem_reg[51]_11 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[51][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[51][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0008000000000000)) 
    \mem[51][7]_i_2 
       (.I0(ptr[4]),
        .I1(sel0),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[51][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFB00FBFBFBFBFBFB)) 
    \mem[51][7]_i_3 
       (.I0(\mem[51][7]_i_4_n_0 ),
        .I1(\mem[51][7]_i_5_n_0 ),
        .I2(\mem[51][7]_i_6_n_0 ),
        .I3(\mem[55][7]_i_5_n_0 ),
        .I4(\mem[51][7]_i_7_n_0 ),
        .I5(\mem[51][7]_i_8_n_0 ),
        .O(\mem[51][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT4 #(
    .INIT(16'h7FF8)) 
    \mem[51][7]_i_4 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .O(\mem[51][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    \mem[51][7]_i_5 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[51][7]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h80007FFFFFFFFFFF)) 
    \mem[51][7]_i_6 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(sel0__0),
        .O(\mem[51][7]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \mem[51][7]_i_7 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .O(\mem[51][7]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT4 #(
    .INIT(16'h4000)) 
    \mem[51][7]_i_8 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[51][7]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[52][0]_i_1 
       (.I0(\mem[52][7]_i_2_n_0 ),
        .I1(\mem_reg[52]_10 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[52][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[52][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[52][7]_i_2_n_0 ),
        .I2(\mem_reg[52]_10 [1]),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[52][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[52][2]_i_1 
       (.I0(\mem_reg[52]_10 [2]),
        .I1(\mem[52][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[52][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[52][3]_i_1 
       (.I0(\mem[52][7]_i_2_n_0 ),
        .I1(\mem_reg[52]_10 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[52][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[52][4]_i_1 
       (.I0(\mem[52][7]_i_2_n_0 ),
        .I1(\mem_reg[52]_10 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[52][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[52][5]_i_1 
       (.I0(\mem[52][7]_i_2_n_0 ),
        .I1(\mem_reg[52]_10 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[52][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[52][6]_i_1 
       (.I0(\mem[52][7]_i_2_n_0 ),
        .I1(\mem_reg[52]_10 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[52][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[52][7]_i_1 
       (.I0(\mem[52][7]_i_2_n_0 ),
        .I1(\mem_reg[52]_10 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[52][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[52][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0004000000000000)) 
    \mem[52][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[2]),
        .I2(ptr[0]),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[52][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBFBFBFBFBF00BFBF)) 
    \mem[52][7]_i_3 
       (.I0(\mem[60][7]_i_6_n_0 ),
        .I1(sel0__0),
        .I2(\mem[52][7]_i_4_n_0 ),
        .I3(\mem[52][7]_i_5_n_0 ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[52][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000008000)) 
    \mem[52][7]_i_4 
       (.I0(\phase_reg[1]_rep_n_0 ),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[52][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFF7FFFF)) 
    \mem[52][7]_i_5 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(sel0__0),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\phase_reg[1]_rep_n_0 ),
        .I5(\phase_reg[0]_rep_n_0 ),
        .O(\mem[52][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[53][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem_reg[53]_9 [0]),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[53][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[53][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem_reg[53]_9 [1]),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[53][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[53][2]_i_1 
       (.I0(\mem_reg[53]_9 [2]),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[53][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[53][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem_reg[53]_9 [3]),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[53][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[53][4]_i_1 
       (.I0(\mem_reg[53]_9 [4]),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[53][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[53][5]_i_1 
       (.I0(\mem[53][7]_i_2_n_0 ),
        .I1(\mem_reg[53]_9 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[53][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[53][6]_i_1 
       (.I0(\mem_reg[53]_9 [6]),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[53][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[53][7]_i_1 
       (.I0(\mem[62][7]_i_3_n_0 ),
        .I1(\mem[53][7]_i_2_n_0 ),
        .I2(\mem_reg[53]_9 [7]),
        .I3(\mem[53][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[53][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000800000)) 
    \mem[53][7]_i_2 
       (.I0(ptr[4]),
        .I1(sel0),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[53][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h77FF70FF77FF77FF)) 
    \mem[53][7]_i_3 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\mem[53][7]_i_4_n_0 ),
        .I2(\mem[53][7]_i_5_n_0 ),
        .I3(sel0__0),
        .I4(\mem[60][7]_i_6_n_0 ),
        .I5(\mem[53][7]_i_6_n_0 ),
        .O(\mem[53][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000080000)) 
    \mem[53][7]_i_4 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\phase_reg[1]_rep_n_0 ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[53][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT4 #(
    .INIT(16'hF7FF)) 
    \mem[53][7]_i_5 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .O(\mem[53][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT4 #(
    .INIT(16'h8019)) 
    \mem[53][7]_i_6 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[0] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[3] ),
        .O(\mem[53][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[54][0]_i_1 
       (.I0(\mem_reg[54]_8 [0]),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[54][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[54][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem_reg[54]_8 [1]),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[54][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[54][2]_i_1 
       (.I0(\mem_reg[54]_8 [2]),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[54][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[54][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem_reg[54]_8 [3]),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[54][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[54][4]_i_1 
       (.I0(\mem_reg[54]_8 [4]),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[54][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[54][5]_i_1 
       (.I0(\mem_reg[54]_8 [5]),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[54][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[54][6]_i_1 
       (.I0(\mem_reg[54]_8 [6]),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[54][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[54][7]_i_1 
       (.I0(\mem_reg[54]_8 [7]),
        .I1(\mem[54][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[54][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[54][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1000000000000000)) 
    \mem[54][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[54][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF0DFFFFFFEDFF)) 
    \mem[54][7]_i_3 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\mem[54][7]_i_4_n_0 ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\mem[55][7]_i_5_n_0 ),
        .I5(\mem[54][7]_i_5_n_0 ),
        .O(\mem[54][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h78FFFFFFFFFFFFFF)) 
    \mem[54][7]_i_4 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(\phase_reg[1]_rep_n_0 ),
        .I4(\phase_reg[0]_rep__0_n_0 ),
        .I5(\q_dst_reg_n_0_[0] ),
        .O(\mem[54][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \mem[54][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[54][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[55][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem_reg[55]_7 [0]),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[55][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[55][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem_reg[55]_7 [1]),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[55][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[55][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem_reg[55]_7 [2]),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[55][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[55][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem_reg[55]_7 [3]),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[55][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[55][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem_reg[55]_7 [4]),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[55][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[55][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem_reg[55]_7 [5]),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[55][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[55][6]_i_1 
       (.I0(\mem_reg[55]_7 [6]),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[55][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[55][7]_i_1 
       (.I0(\mem_reg[55]_7 [7]),
        .I1(\mem[55][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[55][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[55][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    \mem[55][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[55][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hCFDFDFFFFFDFDFFF)) 
    \mem[55][7]_i_3 
       (.I0(\mem[55][7]_i_4_n_0 ),
        .I1(\mem[55][7]_i_5_n_0 ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\mem[55][7]_i_6_n_0 ),
        .O(\mem[55][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    \mem[55][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[55][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \mem[55][7]_i_5 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[4] ),
        .O(\mem[55][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \mem[55][7]_i_6 
       (.I0(\phase_reg[0]_rep__0_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[3] ),
        .O(\mem[55][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[56][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[56][7]_i_2_n_0 ),
        .I2(\mem_reg[56]_6 [0]),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[56][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[56][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[56][7]_i_2_n_0 ),
        .I2(\mem_reg[56]_6 [1]),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[56][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[56][2]_i_1 
       (.I0(\mem[56][7]_i_2_n_0 ),
        .I1(\mem_reg[56]_6 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[56][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[56][3]_i_1 
       (.I0(\mem_reg[56]_6 [3]),
        .I1(\mem[56][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[56][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[56][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[56][7]_i_2_n_0 ),
        .I2(\mem_reg[56]_6 [4]),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[56][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[56][5]_i_1 
       (.I0(\mem[56][7]_i_2_n_0 ),
        .I1(\mem_reg[56]_6 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[56][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[56][6]_i_1 
       (.I0(\mem[56][7]_i_2_n_0 ),
        .I1(\mem_reg[56]_6 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[56][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[56][7]_i_1 
       (.I0(\mem[56][7]_i_2_n_0 ),
        .I1(\mem_reg[56]_6 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[56][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[56][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0004000000000000)) 
    \mem[56][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[3]),
        .I2(ptr[0]),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[56][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0DFFDDFFDDFFDDFF)) 
    \mem[56][7]_i_3 
       (.I0(\mem[56][7]_i_4_n_0 ),
        .I1(\mem[56][7]_i_5_n_0 ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(sel0__0),
        .I4(\mem[60][7]_i_5_n_0 ),
        .I5(\mem[56][7]_i_6_n_0 ),
        .O(\mem[56][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT4 #(
    .INIT(16'h6AAA)) 
    \mem[56][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[56][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h9FFFFFFFFFFFFFFF)) 
    \mem[56][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\result1[21]_i_3_n_0 ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[56][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \mem[56][7]_i_6 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .O(\mem[56][7]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[57][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem_reg[57]_5 [0]),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[57][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[57][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem_reg[57]_5 [1]),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[57][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[57][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem_reg[57]_5 [2]),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[57][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[57][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem_reg[57]_5 [3]),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[57][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[57][4]_i_1 
       (.I0(\mem_reg[57]_5 [4]),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[57][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[57][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem_reg[57]_5 [5]),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[57][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[57][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem_reg[57]_5 [6]),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[57][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[57][7]_i_1 
       (.I0(\mem_reg[57]_5 [7]),
        .I1(\mem[57][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[57][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[57][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000008000)) 
    \mem[57][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[57][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00FFBFBFFFFFBFBF)) 
    \mem[57][7]_i_3 
       (.I0(\mem[57][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\result1[21]_i_3_n_0 ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\mem[57][7]_i_5_n_0 ),
        .O(\mem[57][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hD7FFFFFFFFFFFF77)) 
    \mem[57][7]_i_4 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[57][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000080000)) 
    \mem[57][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\phase_reg[1]_rep_n_0 ),
        .I5(\q_dst_reg_n_0_[2] ),
        .O(\mem[57][7]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[58][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem_reg[58]_4 [0]),
        .I3(\mem[58][4]_i_2_n_0 ),
        .I4(\mem[58][7]_i_3_n_0 ),
        .I5(\mem[62][0]_i_3_n_0 ),
        .O(\mem[58][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[58][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem_reg[58]_4 [1]),
        .I3(\mem[58][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[58][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[58][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem_reg[58]_4 [2]),
        .I3(\mem[58][4]_i_2_n_0 ),
        .I4(\mem[58][7]_i_3_n_0 ),
        .I5(\mem[62][2]_i_3_n_0 ),
        .O(\mem[58][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[58][3]_i_1 
       (.I0(\mem_reg[58]_4 [3]),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[58][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[58][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[58][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem_reg[58]_4 [4]),
        .I3(\mem[58][4]_i_2_n_0 ),
        .I4(\mem[58][7]_i_3_n_0 ),
        .I5(\mem[62][4]_i_3_n_0 ),
        .O(\mem[58][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h000000007FFFFFFF)) 
    \mem[58][4]_i_2 
       (.I0(\mem[58][7]_i_5_n_0 ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(sel0__0),
        .I5(\mem[58][7]_i_4_n_0 ),
        .O(\mem[58][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[58][5]_i_1 
       (.I0(\mem_reg[58]_4 [5]),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[58][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[58][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[58][6]_i_1 
       (.I0(\mem_reg[58]_4 [6]),
        .I1(\mem[58][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[58][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[58][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[58][7]_i_1 
       (.I0(\mem[58][7]_i_2_n_0 ),
        .I1(\mem_reg[58]_4 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[58][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[58][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0040000000000000)) 
    \mem[58][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[3]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(ptr[0]),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[58][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h1555555555555555)) 
    \mem[58][7]_i_3 
       (.I0(\mem[58][7]_i_4_n_0 ),
        .I1(\mem[58][7]_i_5_n_0 ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(sel0__0),
        .I4(\q_dst_reg_n_0_[4] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[58][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h0000020000000000)) 
    \mem[58][7]_i_4 
       (.I0(\result1[21]_i_3_n_0 ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\mem[55][7]_i_5_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[58][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \mem[58][7]_i_5 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .O(\mem[58][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[59][0]_i_1 
       (.I0(\mem_reg[59]_3 [0]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[59][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[59][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem_reg[59]_3 [1]),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[59][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[59][2]_i_1 
       (.I0(\mem_reg[59]_3 [2]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[59][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[59][3]_i_1 
       (.I0(\mem_reg[59]_3 [3]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[59][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[59][4]_i_1 
       (.I0(\mem_reg[59]_3 [4]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[59][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[59][5]_i_1 
       (.I0(\mem_reg[59]_3 [5]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[59][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[59][6]_i_1 
       (.I0(\mem_reg[59]_3 [6]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[59][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[59][7]_i_1 
       (.I0(\mem_reg[59]_3 [7]),
        .I1(\mem[59][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[59][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[59][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    \mem[59][7]_i_2 
       (.I0(ptr[2]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(\ptr_reg[1]_rep_n_0 ),
        .I4(ptr[3]),
        .I5(ptr[4]),
        .O(\mem[59][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFCFFAFFF)) 
    \mem[59][7]_i_3 
       (.I0(\mem[59][7]_i_4_n_0 ),
        .I1(\mem[59][7]_i_5_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\phase_reg[1]_rep_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[2] ),
        .O(\mem[59][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'hD7FFFFFF)) 
    \mem[59][7]_i_4 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[4] ),
        .I4(sel0__0),
        .O(\mem[59][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \mem[59][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(sel0__0),
        .O(\mem[59][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[5][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem_reg[5]_57 [0]),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[5][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[5][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem_reg[5]_57 [1]),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[5][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[5][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem_reg[5]_57 [2]),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[5][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[5][3]_i_1 
       (.I0(\mem_reg[5]_57 [3]),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[5][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[5][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem_reg[5]_57 [4]),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[5][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[5][5]_i_1 
       (.I0(\mem_reg[5]_57 [5]),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[5][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[5][6]_i_1 
       (.I0(\mem_reg[5]_57 [6]),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[5][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[5][7]_i_1 
       (.I0(\mem_reg[5]_57 [7]),
        .I1(\mem[5][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[5][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[5][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000100000)) 
    \mem[5][7]_i_2 
       (.I0(ptr[4]),
        .I1(sel0),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(ptr[0]),
        .I5(\ptr_reg[1]_rep_n_0 ),
        .O(\mem[5][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0BBBBBBBBBBBBBBB)) 
    \mem[5][7]_i_3 
       (.I0(\mem[5][7]_i_4_n_0 ),
        .I1(\mem[23][7]_i_5_n_0 ),
        .I2(\result0[21]_i_3_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\mem[5][7]_i_5_n_0 ),
        .O(\mem[5][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'hFFEFFFFF)) 
    \mem[5][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\result1[21]_i_3_n_0 ),
        .O(\mem[5][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \mem[5][7]_i_5 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[1] ),
        .I3(sel0__0),
        .O(\mem[5][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[60][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem_reg[60]_2 [0]),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[60][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[60][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem_reg[60]_2 [1]),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[60][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[60][2]_i_1 
       (.I0(\mem[60][7]_i_2_n_0 ),
        .I1(\mem_reg[60]_2 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[60][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[60][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem_reg[60]_2 [3]),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[60][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[60][4]_i_1 
       (.I0(\mem_reg[60]_2 [4]),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[60][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[60][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem_reg[60]_2 [5]),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[60][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[60][6]_i_1 
       (.I0(\mem_reg[60]_2 [6]),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[60][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[60][7]_i_1 
       (.I0(\mem_reg[60]_2 [7]),
        .I1(\mem[60][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[60][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[60][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1000000000000000)) 
    \mem[60][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[60][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h7F7FFFFF7F00FFFF)) 
    \mem[60][7]_i_3 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\mem[60][7]_i_4_n_0 ),
        .I2(\mem[60][7]_i_5_n_0 ),
        .I3(\mem[60][7]_i_6_n_0 ),
        .I4(sel0__0),
        .I5(\mem[60][7]_i_7_n_0 ),
        .O(\mem[60][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \mem[60][7]_i_4 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .O(\mem[60][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \mem[60][7]_i_5 
       (.I0(\phase_reg[0]_rep_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .O(\mem[60][7]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h95555555)) 
    \mem[60][7]_i_6 
       (.I0(\q_dst_reg_n_0_[4] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\q_dst_reg_n_0_[2] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .O(\mem[60][7]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hF7FFFFFFFFFFFFFF)) 
    \mem[60][7]_i_7 
       (.I0(\phase_reg[1]_rep__0_n_0 ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[60][7]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[61][0]_i_1 
       (.I0(\mem[61][7]_i_2_n_0 ),
        .I1(\mem_reg[61]_1 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[61][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[61][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[61][7]_i_2_n_0 ),
        .I2(\mem_reg[61]_1 [1]),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[61][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[61][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[61][7]_i_2_n_0 ),
        .I2(\mem_reg[61]_1 [2]),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[61][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[61][3]_i_1 
       (.I0(\mem[61][7]_i_2_n_0 ),
        .I1(\mem_reg[61]_1 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[61][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[61][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[61][7]_i_2_n_0 ),
        .I2(\mem_reg[61]_1 [4]),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[61][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[61][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[61][7]_i_2_n_0 ),
        .I2(\mem_reg[61]_1 [5]),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[61][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[61][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[61][7]_i_2_n_0 ),
        .I2(\mem_reg[61]_1 [6]),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[61][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[61][7]_i_1 
       (.I0(\mem_reg[61]_1 [7]),
        .I1(\mem[61][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[61][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[61][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    \mem[61][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[61][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFAFFCFFF)) 
    \mem[61][7]_i_3 
       (.I0(\mem[62][7]_i_9_n_0 ),
        .I1(\mem[62][7]_i_8_n_0 ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\phase_reg[1]_rep_n_0 ),
        .I4(\phase_reg[0]_rep__0_n_0 ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[61][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[62][0]_i_1 
       (.I0(\mem_reg[62]_0 [0]),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(p_0_in__0[0]));
  LUT6 #(
    .INIT(64'h553355330F000FFF)) 
    \mem[62][0]_i_10 
       (.I0(\mem[62][4]_i_23_n_0 ),
        .I1(\mem[62][4]_i_24_n_0 ),
        .I2(\mem[62][7]_i_63_n_0 ),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_64_n_0 ),
        .I5(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][0]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hA0AFC0C0A0AFCFCF)) 
    \mem[62][0]_i_11 
       (.I0(\mem[62][0]_i_26_n_0 ),
        .I1(\mem[62][0]_i_27_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_66_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_67_n_0 ),
        .O(\mem[62][0]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_12 
       (.I0(\mem_reg[59]_3 [0]),
        .I1(\mem_reg[58]_4 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[57]_5 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[56]_6 [0]),
        .O(\mem[62][0]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_13 
       (.I0(\mem_reg[55]_7 [0]),
        .I1(\mem_reg[54]_8 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[52]_10 [0]),
        .O(\mem[62][0]_i_13_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_14 
       (.I0(\mem_reg[63]_69 [0]),
        .I1(\mem_reg[62]_0 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[61]_1 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[60]_2 [0]),
        .O(\mem[62][0]_i_14_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_15 
       (.I0(\mem_reg[51]_11 [0]),
        .I1(\mem_reg[50]_12 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[49]_13 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[48]_14 [0]),
        .O(\mem[62][0]_i_15_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_16 
       (.I0(\mem_reg[43]_19 [0]),
        .I1(\mem_reg[42]_20 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[41]_21 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[40]_22 [0]),
        .O(\mem[62][0]_i_16_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_17 
       (.I0(\mem_reg[47]_15 [0]),
        .I1(\mem_reg[46]_16 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[45]_17 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[44]_18 [0]),
        .O(\mem[62][0]_i_17_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_18 
       (.I0(\mem_reg[39]_23 [0]),
        .I1(\mem_reg[38]_24 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[37]_25 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[36]_26 [0]),
        .O(\mem[62][0]_i_18_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_19 
       (.I0(\mem_reg[35]_27 [0]),
        .I1(\mem_reg[34]_28 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[33]_29 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[32]_30 [0]),
        .O(\mem[62][0]_i_19_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \mem[62][0]_i_2 
       (.I0(Q[0]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][0]_i_4_n_0 ),
        .O(\mem[62][0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_22 
       (.I0(\mem_reg[15]_47 [0]),
        .I1(\mem_reg[14]_48 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[13]_49 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[12]_50 [0]),
        .O(\mem[62][0]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_23 
       (.I0(\mem_reg[11]_51 [0]),
        .I1(\mem_reg[10]_52 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[9]_53 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[8]_54 [0]),
        .O(\mem[62][0]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_24 
       (.I0(\mem_reg[7]_55 [0]),
        .I1(\mem_reg[6]_56 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[5]_57 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[4]_58 [0]),
        .O(\mem[62][0]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_25 
       (.I0(\mem_reg[3]_59 [0]),
        .I1(\mem_reg[2]_60 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[1]_61 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[0]_62 [0]),
        .O(\mem[62][0]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'h554500405575FF7F)) 
    \mem[62][0]_i_26 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[16]),
        .O(\mem[62][0]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'h554500405575FF7F)) 
    \mem[62][0]_i_27 
       (.I0(finish3[32]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[0]),
        .O(\mem[62][0]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_28 
       (.I0(\mem_reg[19]_43 [0]),
        .I1(\mem_reg[18]_44 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[17]_45 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[16]_46 [0]),
        .O(\mem[62][0]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_29 
       (.I0(\mem_reg[23]_39 [0]),
        .I1(\mem_reg[22]_40 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[21]_41 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[20]_42 [0]),
        .O(\mem[62][0]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hBABFAAAA)) 
    \mem[62][0]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][1]_i_5_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][0]_i_5_n_0 ),
        .I4(\mem[62][6]_i_6_n_0 ),
        .O(\mem[62][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_30 
       (.I0(\mem_reg[27]_35 [0]),
        .I1(\mem_reg[26]_36 [0]),
        .I2(ptr[1]),
        .I3(\mem_reg[25]_37 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[24]_38 [0]),
        .O(\mem[62][0]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_31 
       (.I0(\mem_reg[31]_31 [0]),
        .I1(\mem_reg[30]_32 [0]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[29]_33 [0]),
        .I4(ptr[0]),
        .I5(\mem_reg[28]_34 [0]),
        .O(\mem[62][0]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_4 
       (.I0(\mem[62][0]_i_6_n_0 ),
        .I1(\mem[62][0]_i_7_n_0 ),
        .I2(sel0),
        .I3(\mem_reg[62][0]_i_8_n_0 ),
        .I4(ptr[4]),
        .I5(\mem[62][0]_i_9_n_0 ),
        .O(\mem[62][0]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h5F503F3F5F503030)) 
    \mem[62][0]_i_5 
       (.I0(\mem[62][6]_i_16_n_0 ),
        .I1(\mem[62][2]_i_10_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][0]_i_10_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][0]_i_11_n_0 ),
        .O(\mem[62][0]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hF0CCAAFFF0CCAA00)) 
    \mem[62][0]_i_6 
       (.I0(\mem[62][0]_i_12_n_0 ),
        .I1(\mem[62][0]_i_13_n_0 ),
        .I2(\mem[62][0]_i_14_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[2]),
        .I5(\mem[62][0]_i_15_n_0 ),
        .O(\mem[62][0]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hCCF0AAFFCCF0AA00)) 
    \mem[62][0]_i_7 
       (.I0(\mem[62][0]_i_16_n_0 ),
        .I1(\mem[62][0]_i_17_n_0 ),
        .I2(\mem[62][0]_i_18_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[2]),
        .I5(\mem[62][0]_i_19_n_0 ),
        .O(\mem[62][0]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][0]_i_9 
       (.I0(\mem[62][0]_i_22_n_0 ),
        .I1(\mem[62][0]_i_23_n_0 ),
        .I2(ptr[3]),
        .I3(\mem[62][0]_i_24_n_0 ),
        .I4(ptr[2]),
        .I5(\mem[62][0]_i_25_n_0 ),
        .O(\mem[62][0]_i_9_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[62][1]_i_1 
       (.I0(\mem_reg[62]_0 [1]),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(p_0_in__0[1]));
  LUT6 #(
    .INIT(64'h553355330F000FFF)) 
    \mem[62][1]_i_10 
       (.I0(\mem[62][5]_i_19_n_0 ),
        .I1(\mem[62][5]_i_20_n_0 ),
        .I2(\mem[62][7]_i_76_n_0 ),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_77_n_0 ),
        .I5(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][1]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hA0AFC0C0A0AFCFCF)) 
    \mem[62][1]_i_11 
       (.I0(\mem[62][1]_i_24_n_0 ),
        .I1(\mem[62][1]_i_25_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_79_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_80_n_0 ),
        .O(\mem[62][1]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_12 
       (.I0(\mem_reg[31]_31 [1]),
        .I1(\mem_reg[30]_32 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[29]_33 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[28]_34 [1]),
        .O(\mem[62][1]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_13 
       (.I0(\mem_reg[23]_39 [1]),
        .I1(\mem_reg[22]_40 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[21]_41 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[20]_42 [1]),
        .O(\mem[62][1]_i_13_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_14 
       (.I0(\mem_reg[27]_35 [1]),
        .I1(\mem_reg[26]_36 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[25]_37 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[24]_38 [1]),
        .O(\mem[62][1]_i_14_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_15 
       (.I0(\mem_reg[19]_43 [1]),
        .I1(\mem_reg[18]_44 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[17]_45 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[16]_46 [1]),
        .O(\mem[62][1]_i_15_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_16 
       (.I0(\mem_reg[3]_59 [1]),
        .I1(\mem_reg[2]_60 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[1]_61 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[0]_62 [1]),
        .O(\mem[62][1]_i_16_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_17 
       (.I0(\mem_reg[11]_51 [1]),
        .I1(\mem_reg[10]_52 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[9]_53 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[8]_54 [1]),
        .O(\mem[62][1]_i_17_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_18 
       (.I0(\mem_reg[7]_55 [1]),
        .I1(\mem_reg[6]_56 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[5]_57 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[4]_58 [1]),
        .O(\mem[62][1]_i_18_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_19 
       (.I0(\mem_reg[15]_47 [1]),
        .I1(\mem_reg[14]_48 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[13]_49 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[12]_50 [1]),
        .O(\mem[62][1]_i_19_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \mem[62][1]_i_2 
       (.I0(Q[1]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][1]_i_4_n_0 ),
        .O(\mem[62][1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h554500405575FF7F)) 
    \mem[62][1]_i_24 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[17]),
        .O(\mem[62][1]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'h554500405575FF7F)) 
    \mem[62][1]_i_25 
       (.I0(finish3[33]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[1]),
        .O(\mem[62][1]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_26 
       (.I0(\mem_reg[51]_11 [1]),
        .I1(\mem_reg[50]_12 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[49]_13 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[48]_14 [1]),
        .O(\mem[62][1]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_27 
       (.I0(\mem_reg[55]_7 [1]),
        .I1(\mem_reg[54]_8 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[52]_10 [1]),
        .O(\mem[62][1]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_28 
       (.I0(\mem_reg[59]_3 [1]),
        .I1(\mem_reg[58]_4 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[57]_5 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[56]_6 [1]),
        .O(\mem[62][1]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_29 
       (.I0(\mem_reg[63]_69 [1]),
        .I1(\mem_reg[62]_0 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[61]_1 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[60]_2 [1]),
        .O(\mem[62][1]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hEAAAEEAE)) 
    \mem[62][1]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][6]_i_6_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][2]_i_5_n_0 ),
        .I4(\mem[62][1]_i_5_n_0 ),
        .O(\mem[62][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_30 
       (.I0(\mem_reg[35]_27 [1]),
        .I1(\mem_reg[34]_28 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[33]_29 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[32]_30 [1]),
        .O(\mem[62][1]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_31 
       (.I0(\mem_reg[39]_23 [1]),
        .I1(\mem_reg[38]_24 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[37]_25 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[36]_26 [1]),
        .O(\mem[62][1]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_32 
       (.I0(\mem_reg[43]_19 [1]),
        .I1(\mem_reg[42]_20 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[41]_21 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[40]_22 [1]),
        .O(\mem[62][1]_i_32_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][1]_i_33 
       (.I0(\mem_reg[47]_15 [1]),
        .I1(\mem_reg[46]_16 [1]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[45]_17 [1]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[44]_18 [1]),
        .O(\mem[62][1]_i_33_n_0 ));
  LUT6 #(
    .INIT(64'hF0FF5533F0005533)) 
    \mem[62][1]_i_4 
       (.I0(\mem[62][1]_i_6_n_0 ),
        .I1(\mem[62][1]_i_7_n_0 ),
        .I2(\mem_reg[62][1]_i_8_n_0 ),
        .I3(ptr[4]),
        .I4(sel0),
        .I5(\mem_reg[62][1]_i_9_n_0 ),
        .O(\mem[62][1]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h5F503F3F5F503030)) 
    \mem[62][1]_i_5 
       (.I0(\mem[62][7]_i_30_n_0 ),
        .I1(\mem[62][3]_i_10_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][1]_i_10_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][1]_i_11_n_0 ),
        .O(\mem[62][1]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h550F3300550F33FF)) 
    \mem[62][1]_i_6 
       (.I0(\mem[62][1]_i_12_n_0 ),
        .I1(\mem[62][1]_i_13_n_0 ),
        .I2(\mem[62][1]_i_14_n_0 ),
        .I3(ptr[2]),
        .I4(ptr[3]),
        .I5(\mem[62][1]_i_15_n_0 ),
        .O(\mem[62][1]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h000F3355FF0F3355)) 
    \mem[62][1]_i_7 
       (.I0(\mem[62][1]_i_16_n_0 ),
        .I1(\mem[62][1]_i_17_n_0 ),
        .I2(\mem[62][1]_i_18_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[2]),
        .I5(\mem[62][1]_i_19_n_0 ),
        .O(\mem[62][1]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][2]_i_1 
       (.I0(\mem[62][2]_i_2_n_0 ),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem_reg[62]_0 [2]),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(p_0_in__0[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_10 
       (.I0(\mem[62][2]_i_19_n_0 ),
        .I1(\mem[62][2]_i_20_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_60_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_61_n_0 ),
        .O(\mem[62][2]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][2]_i_19 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[18]),
        .O(\mem[62][2]_i_19_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \mem[62][2]_i_2 
       (.I0(Q[2]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][2]_i_4_n_0 ),
        .O(\mem[62][2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][2]_i_20 
       (.I0(finish3[2]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[34]),
        .O(\mem[62][2]_i_20_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_21 
       (.I0(\mem_reg[51]_11 [2]),
        .I1(\mem_reg[50]_12 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[49]_13 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[48]_14 [2]),
        .O(\mem[62][2]_i_21_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_22 
       (.I0(\mem_reg[55]_7 [2]),
        .I1(\mem_reg[54]_8 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[52]_10 [2]),
        .O(\mem[62][2]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_23 
       (.I0(\mem_reg[59]_3 [2]),
        .I1(\mem_reg[58]_4 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[57]_5 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[56]_6 [2]),
        .O(\mem[62][2]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_24 
       (.I0(\mem_reg[63]_69 [2]),
        .I1(\mem_reg[62]_0 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[61]_1 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[60]_2 [2]),
        .O(\mem[62][2]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_25 
       (.I0(\mem_reg[35]_27 [2]),
        .I1(\mem_reg[34]_28 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[33]_29 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[32]_30 [2]),
        .O(\mem[62][2]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_26 
       (.I0(\mem_reg[39]_23 [2]),
        .I1(\mem_reg[38]_24 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[37]_25 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[36]_26 [2]),
        .O(\mem[62][2]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_27 
       (.I0(\mem_reg[43]_19 [2]),
        .I1(\mem_reg[42]_20 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[41]_21 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[40]_22 [2]),
        .O(\mem[62][2]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_28 
       (.I0(\mem_reg[47]_15 [2]),
        .I1(\mem_reg[46]_16 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[45]_17 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[44]_18 [2]),
        .O(\mem[62][2]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_29 
       (.I0(\mem_reg[19]_43 [2]),
        .I1(\mem_reg[18]_44 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[17]_45 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[16]_46 [2]),
        .O(\mem[62][2]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hEEAEEAAA)) 
    \mem[62][2]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][6]_i_6_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][3]_i_5_n_0 ),
        .I4(\mem[62][2]_i_5_n_0 ),
        .O(\mem[62][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_30 
       (.I0(\mem_reg[23]_39 [2]),
        .I1(\mem_reg[22]_40 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[21]_41 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[20]_42 [2]),
        .O(\mem[62][2]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_31 
       (.I0(\mem_reg[27]_35 [2]),
        .I1(\mem_reg[26]_36 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[25]_37 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[24]_38 [2]),
        .O(\mem[62][2]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_32 
       (.I0(\mem_reg[31]_31 [2]),
        .I1(\mem_reg[30]_32 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[29]_33 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[28]_34 [2]),
        .O(\mem[62][2]_i_32_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_33 
       (.I0(\mem_reg[3]_59 [2]),
        .I1(\mem_reg[2]_60 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[1]_61 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[0]_62 [2]),
        .O(\mem[62][2]_i_33_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_34 
       (.I0(\mem_reg[7]_55 [2]),
        .I1(\mem_reg[6]_56 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[5]_57 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[4]_58 [2]),
        .O(\mem[62][2]_i_34_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_35 
       (.I0(\mem_reg[11]_51 [2]),
        .I1(\mem_reg[10]_52 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[9]_53 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[8]_54 [2]),
        .O(\mem[62][2]_i_35_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_36 
       (.I0(\mem_reg[15]_47 [2]),
        .I1(\mem_reg[14]_48 [2]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[13]_49 [2]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[12]_50 [2]),
        .O(\mem[62][2]_i_36_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_4 
       (.I0(\mem_reg[62][2]_i_6_n_0 ),
        .I1(\mem_reg[62][2]_i_7_n_0 ),
        .I2(sel0),
        .I3(\mem_reg[62][2]_i_8_n_0 ),
        .I4(ptr[4]),
        .I5(\mem_reg[62][2]_i_9_n_0 ),
        .O(\mem[62][2]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][2]_i_5 
       (.I0(\mem[62][7]_i_28_n_0 ),
        .I1(\mem[62][4]_i_10_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][6]_i_16_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][2]_i_10_n_0 ),
        .O(\mem[62][2]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h74FF7400)) 
    \mem[62][3]_i_1 
       (.I0(\mem[62][3]_i_2_n_0 ),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem_reg[62]_0 [3]),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(p_0_in__0[3]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_10 
       (.I0(\mem[62][3]_i_19_n_0 ),
        .I1(\mem[62][3]_i_20_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_69_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_70_n_0 ),
        .O(\mem[62][3]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][3]_i_19 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[19]),
        .O(\mem[62][3]_i_19_n_0 ));
  LUT3 #(
    .INIT(8'h74)) 
    \mem[62][3]_i_2 
       (.I0(Q[3]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][3]_i_4_n_0 ),
        .O(\mem[62][3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][3]_i_20 
       (.I0(finish3[3]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[35]),
        .O(\mem[62][3]_i_20_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_21 
       (.I0(\mem_reg[35]_27 [3]),
        .I1(\mem_reg[34]_28 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[33]_29 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[32]_30 [3]),
        .O(\mem[62][3]_i_21_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_22 
       (.I0(\mem_reg[39]_23 [3]),
        .I1(\mem_reg[38]_24 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[37]_25 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[36]_26 [3]),
        .O(\mem[62][3]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_23 
       (.I0(\mem_reg[43]_19 [3]),
        .I1(\mem_reg[42]_20 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[41]_21 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[40]_22 [3]),
        .O(\mem[62][3]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_24 
       (.I0(\mem_reg[47]_15 [3]),
        .I1(\mem_reg[46]_16 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[45]_17 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[44]_18 [3]),
        .O(\mem[62][3]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_25 
       (.I0(\mem_reg[19]_43 [3]),
        .I1(\mem_reg[18]_44 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[17]_45 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[16]_46 [3]),
        .O(\mem[62][3]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_26 
       (.I0(\mem_reg[23]_39 [3]),
        .I1(\mem_reg[22]_40 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[21]_41 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[20]_42 [3]),
        .O(\mem[62][3]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_27 
       (.I0(\mem_reg[27]_35 [3]),
        .I1(\mem_reg[26]_36 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[25]_37 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[24]_38 [3]),
        .O(\mem[62][3]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_28 
       (.I0(\mem_reg[31]_31 [3]),
        .I1(\mem_reg[30]_32 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[29]_33 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[28]_34 [3]),
        .O(\mem[62][3]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_29 
       (.I0(\mem_reg[3]_59 [3]),
        .I1(\mem_reg[2]_60 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[1]_61 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[0]_62 [3]),
        .O(\mem[62][3]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hEEAEEAAA)) 
    \mem[62][3]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][6]_i_6_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][4]_i_5_n_0 ),
        .I4(\mem[62][3]_i_5_n_0 ),
        .O(\mem[62][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_30 
       (.I0(\mem_reg[7]_55 [3]),
        .I1(\mem_reg[6]_56 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[5]_57 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[4]_58 [3]),
        .O(\mem[62][3]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_31 
       (.I0(\mem_reg[11]_51 [3]),
        .I1(\mem_reg[10]_52 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[9]_53 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[8]_54 [3]),
        .O(\mem[62][3]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_32 
       (.I0(\mem_reg[15]_47 [3]),
        .I1(\mem_reg[14]_48 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[13]_49 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[12]_50 [3]),
        .O(\mem[62][3]_i_32_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_33 
       (.I0(\mem_reg[51]_11 [3]),
        .I1(\mem_reg[50]_12 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[49]_13 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[48]_14 [3]),
        .O(\mem[62][3]_i_33_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_34 
       (.I0(\mem_reg[55]_7 [3]),
        .I1(\mem_reg[54]_8 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[52]_10 [3]),
        .O(\mem[62][3]_i_34_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_35 
       (.I0(\mem_reg[59]_3 [3]),
        .I1(\mem_reg[58]_4 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[57]_5 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[56]_6 [3]),
        .O(\mem[62][3]_i_35_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_36 
       (.I0(\mem_reg[63]_69 [3]),
        .I1(\mem_reg[62]_0 [3]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[61]_1 [3]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[60]_2 [3]),
        .O(\mem[62][3]_i_36_n_0 ));
  LUT5 #(
    .INIT(32'hAAA9AAAA)) 
    \mem[62][3]_i_38 
       (.I0(t_reg_n_102),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][3]_i_38_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][3]_i_39 
       (.I0(t_reg_n_103),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][3]_i_39_n_0 ));
  LUT6 #(
    .INIT(64'h0055330FFF55330F)) 
    \mem[62][3]_i_4 
       (.I0(\mem_reg[62][3]_i_6_n_0 ),
        .I1(\mem_reg[62][3]_i_7_n_0 ),
        .I2(\mem_reg[62][3]_i_8_n_0 ),
        .I3(ptr[4]),
        .I4(sel0),
        .I5(\mem_reg[62][3]_i_9_n_0 ),
        .O(\mem[62][3]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][3]_i_40 
       (.I0(t_reg_n_104),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][3]_i_40_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][3]_i_41 
       (.I0(t_reg_n_105),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][3]_i_41_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][3]_i_5 
       (.I0(\mem[62][7]_i_32_n_0 ),
        .I1(\mem[62][5]_i_10_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_30_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][3]_i_10_n_0 ),
        .O(\mem[62][3]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem_reg[62]_0 [4]),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(p_0_in__0[4]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_10 
       (.I0(\mem[62][4]_i_23_n_0 ),
        .I1(\mem[62][4]_i_24_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_63_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_64_n_0 ),
        .O(\mem[62][4]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_11 
       (.I0(\mem_reg[59]_3 [4]),
        .I1(\mem_reg[58]_4 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[57]_5 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[56]_6 [4]),
        .O(\mem[62][4]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_12 
       (.I0(\mem_reg[55]_7 [4]),
        .I1(\mem_reg[54]_8 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[52]_10 [4]),
        .O(\mem[62][4]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_13 
       (.I0(\mem_reg[63]_69 [4]),
        .I1(\mem_reg[62]_0 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[61]_1 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[60]_2 [4]),
        .O(\mem[62][4]_i_13_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_14 
       (.I0(\mem_reg[51]_11 [4]),
        .I1(\mem_reg[50]_12 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[49]_13 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[48]_14 [4]),
        .O(\mem[62][4]_i_14_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_15 
       (.I0(\mem_reg[43]_19 [4]),
        .I1(\mem_reg[42]_20 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[41]_21 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[40]_22 [4]),
        .O(\mem[62][4]_i_15_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_16 
       (.I0(\mem_reg[35]_27 [4]),
        .I1(\mem_reg[34]_28 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[33]_29 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[32]_30 [4]),
        .O(\mem[62][4]_i_16_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_17 
       (.I0(\mem_reg[47]_15 [4]),
        .I1(\mem_reg[46]_16 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[45]_17 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[44]_18 [4]),
        .O(\mem[62][4]_i_17_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_18 
       (.I0(\mem_reg[39]_23 [4]),
        .I1(\mem_reg[38]_24 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[37]_25 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[36]_26 [4]),
        .O(\mem[62][4]_i_18_n_0 ));
  LUT3 #(
    .INIT(8'hCA)) 
    \mem[62][4]_i_2 
       (.I0(\mem[62][4]_i_4_n_0 ),
        .I1(Q[4]),
        .I2(\mem[62][7]_i_6_n_0 ),
        .O(\mem[62][4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][4]_i_23 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[20]),
        .O(\mem[62][4]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][4]_i_24 
       (.I0(finish3[4]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[36]),
        .O(\mem[62][4]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_25 
       (.I0(\mem_reg[19]_43 [4]),
        .I1(\mem_reg[18]_44 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[17]_45 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[16]_46 [4]),
        .O(\mem[62][4]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_26 
       (.I0(\mem_reg[23]_39 [4]),
        .I1(\mem_reg[22]_40 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[21]_41 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[20]_42 [4]),
        .O(\mem[62][4]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_27 
       (.I0(\mem_reg[27]_35 [4]),
        .I1(\mem_reg[26]_36 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[25]_37 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[24]_38 [4]),
        .O(\mem[62][4]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_28 
       (.I0(\mem_reg[31]_31 [4]),
        .I1(\mem_reg[30]_32 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[29]_33 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[28]_34 [4]),
        .O(\mem[62][4]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_29 
       (.I0(\mem_reg[3]_59 [4]),
        .I1(\mem_reg[2]_60 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[1]_61 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[0]_62 [4]),
        .O(\mem[62][4]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hEEEAAAEA)) 
    \mem[62][4]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][6]_i_6_n_0 ),
        .I2(\mem[62][4]_i_5_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][5]_i_5_n_0 ),
        .O(\mem[62][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_30 
       (.I0(\mem_reg[7]_55 [4]),
        .I1(\mem_reg[6]_56 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[5]_57 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[4]_58 [4]),
        .O(\mem[62][4]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_31 
       (.I0(\mem_reg[11]_51 [4]),
        .I1(\mem_reg[10]_52 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[9]_53 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[8]_54 [4]),
        .O(\mem[62][4]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_32 
       (.I0(\mem_reg[15]_47 [4]),
        .I1(\mem_reg[14]_48 [4]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[13]_49 [4]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[12]_50 [4]),
        .O(\mem[62][4]_i_32_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_4 
       (.I0(\mem[62][4]_i_6_n_0 ),
        .I1(\mem[62][4]_i_7_n_0 ),
        .I2(sel0),
        .I3(\mem_reg[62][4]_i_8_n_0 ),
        .I4(ptr[4]),
        .I5(\mem_reg[62][4]_i_9_n_0 ),
        .O(\mem[62][4]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][4]_i_5 
       (.I0(\mem[62][7]_i_24_n_0 ),
        .I1(\mem[62][6]_i_16_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_28_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][4]_i_10_n_0 ),
        .O(\mem[62][4]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hF0CCAAFFF0CCAA00)) 
    \mem[62][4]_i_6 
       (.I0(\mem[62][4]_i_11_n_0 ),
        .I1(\mem[62][4]_i_12_n_0 ),
        .I2(\mem[62][4]_i_13_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[2]),
        .I5(\mem[62][4]_i_14_n_0 ),
        .O(\mem[62][4]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hF0FFAACCF000AACC)) 
    \mem[62][4]_i_7 
       (.I0(\mem[62][4]_i_15_n_0 ),
        .I1(\mem[62][4]_i_16_n_0 ),
        .I2(\mem[62][4]_i_17_n_0 ),
        .I3(ptr[3]),
        .I4(ptr[2]),
        .I5(\mem[62][4]_i_18_n_0 ),
        .O(\mem[62][4]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem_reg[62]_0 [5]),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(p_0_in__0[5]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_10 
       (.I0(\mem[62][5]_i_19_n_0 ),
        .I1(\mem[62][5]_i_20_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_76_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_77_n_0 ),
        .O(\mem[62][5]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][5]_i_19 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[21]),
        .O(\mem[62][5]_i_19_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \mem[62][5]_i_2 
       (.I0(Q[5]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][5]_i_4_n_0 ),
        .O(\mem[62][5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][5]_i_20 
       (.I0(finish3[5]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[37]),
        .O(\mem[62][5]_i_20_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_21 
       (.I0(\mem_reg[51]_11 [5]),
        .I1(\mem_reg[50]_12 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[49]_13 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[48]_14 [5]),
        .O(\mem[62][5]_i_21_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_22 
       (.I0(\mem_reg[55]_7 [5]),
        .I1(\mem_reg[54]_8 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[52]_10 [5]),
        .O(\mem[62][5]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_23 
       (.I0(\mem_reg[59]_3 [5]),
        .I1(\mem_reg[58]_4 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[57]_5 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[56]_6 [5]),
        .O(\mem[62][5]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_24 
       (.I0(\mem_reg[63]_69 [5]),
        .I1(\mem_reg[62]_0 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[61]_1 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[60]_2 [5]),
        .O(\mem[62][5]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_25 
       (.I0(\mem_reg[35]_27 [5]),
        .I1(\mem_reg[34]_28 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[33]_29 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[32]_30 [5]),
        .O(\mem[62][5]_i_25_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_26 
       (.I0(\mem_reg[39]_23 [5]),
        .I1(\mem_reg[38]_24 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[37]_25 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[36]_26 [5]),
        .O(\mem[62][5]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_27 
       (.I0(\mem_reg[43]_19 [5]),
        .I1(\mem_reg[42]_20 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[41]_21 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[40]_22 [5]),
        .O(\mem[62][5]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_28 
       (.I0(\mem_reg[47]_15 [5]),
        .I1(\mem_reg[46]_16 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[45]_17 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[44]_18 [5]),
        .O(\mem[62][5]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_29 
       (.I0(\mem_reg[19]_43 [5]),
        .I1(\mem_reg[18]_44 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[17]_45 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[16]_46 [5]),
        .O(\mem[62][5]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hEEAEEAAA)) 
    \mem[62][5]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][6]_i_6_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][6]_i_7_n_0 ),
        .I4(\mem[62][5]_i_5_n_0 ),
        .O(\mem[62][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_30 
       (.I0(\mem_reg[23]_39 [5]),
        .I1(\mem_reg[22]_40 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[21]_41 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[20]_42 [5]),
        .O(\mem[62][5]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_31 
       (.I0(\mem_reg[27]_35 [5]),
        .I1(\mem_reg[26]_36 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[25]_37 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[24]_38 [5]),
        .O(\mem[62][5]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_32 
       (.I0(\mem_reg[31]_31 [5]),
        .I1(\mem_reg[30]_32 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[29]_33 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[28]_34 [5]),
        .O(\mem[62][5]_i_32_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_33 
       (.I0(\mem_reg[3]_59 [5]),
        .I1(\mem_reg[2]_60 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[1]_61 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[0]_62 [5]),
        .O(\mem[62][5]_i_33_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_34 
       (.I0(\mem_reg[7]_55 [5]),
        .I1(\mem_reg[6]_56 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[5]_57 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[4]_58 [5]),
        .O(\mem[62][5]_i_34_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_35 
       (.I0(\mem_reg[11]_51 [5]),
        .I1(\mem_reg[10]_52 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[9]_53 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[8]_54 [5]),
        .O(\mem[62][5]_i_35_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_36 
       (.I0(\mem_reg[15]_47 [5]),
        .I1(\mem_reg[14]_48 [5]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[13]_49 [5]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[12]_50 [5]),
        .O(\mem[62][5]_i_36_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_4 
       (.I0(\mem_reg[62][5]_i_6_n_0 ),
        .I1(\mem_reg[62][5]_i_7_n_0 ),
        .I2(sel0),
        .I3(\mem_reg[62][5]_i_8_n_0 ),
        .I4(ptr[4]),
        .I5(\mem_reg[62][5]_i_9_n_0 ),
        .O(\mem[62][5]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][5]_i_5 
       (.I0(\mem[62][7]_i_29_n_0 ),
        .I1(\mem[62][7]_i_30_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_32_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][5]_i_10_n_0 ),
        .O(\mem[62][5]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][6]_i_1 
       (.I0(\mem[62][6]_i_2_n_0 ),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem_reg[62]_0 [6]),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(p_0_in__0[6]));
  LUT6 #(
    .INIT(64'hFFFFFFFFF0F0F0E2)) 
    \mem[62][6]_i_13 
       (.I0(finish3[47]),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_54_n_0 ),
        .I5(\mem[62][7]_i_50_n_0 ),
        .O(\mem[62][6]_i_13_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \mem[62][6]_i_14 
       (.I0(finish3[48]),
        .O(\mem[62][6]_i_14_n_0 ));
  LUT6 #(
    .INIT(64'h000000000F0F0F1D)) 
    \mem[62][6]_i_15 
       (.I0(finish3[47]),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_54_n_0 ),
        .I5(\mem[62][7]_i_50_n_0 ),
        .O(\mem[62][6]_i_15_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_16 
       (.I0(\mem[62][6]_i_34_n_0 ),
        .I1(\mem[62][6]_i_35_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_56_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_57_n_0 ),
        .O(\mem[62][6]_i_16_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \mem[62][6]_i_2 
       (.I0(Q[6]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][6]_i_4_n_0 ),
        .O(\mem[62][6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFAFA0FC0C)) 
    \mem[62][6]_i_26 
       (.I0(finish3[48]),
        .I1(\mem[62][7]_i_107_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_108_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_109_n_0 ),
        .O(\mem[62][6]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFAFA0FC0C)) 
    \mem[62][6]_i_27 
       (.I0(\mem[62][7]_i_108_n_0 ),
        .I1(\mem[62][7]_i_110_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_107_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_111_n_0 ),
        .O(\mem[62][6]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \mem[62][6]_i_28 
       (.I0(\mem[62][7]_i_112_n_0 ),
        .I1(\mem[62][7]_i_113_n_0 ),
        .O(\mem[62][6]_i_28_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \mem[62][6]_i_29 
       (.I0(\mem[62][7]_i_114_n_0 ),
        .I1(\mem[62][7]_i_115_n_0 ),
        .O(\mem[62][6]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'hEAEEEAAA)) 
    \mem[62][6]_i_3 
       (.I0(finish10_in),
        .I1(\mem[62][6]_i_6_n_0 ),
        .I2(\mem[62][7]_i_13_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][6]_i_7_n_0 ),
        .O(\mem[62][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h00000000505F03F3)) 
    \mem[62][6]_i_30 
       (.I0(finish3[48]),
        .I1(\mem[62][7]_i_107_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_108_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_109_n_0 ),
        .O(\mem[62][6]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'h00000000505F03F3)) 
    \mem[62][6]_i_31 
       (.I0(\mem[62][7]_i_108_n_0 ),
        .I1(\mem[62][7]_i_110_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_107_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_111_n_0 ),
        .O(\mem[62][6]_i_31_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \mem[62][6]_i_32 
       (.I0(\mem[62][7]_i_113_n_0 ),
        .I1(\mem[62][7]_i_112_n_0 ),
        .O(\mem[62][6]_i_32_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \mem[62][6]_i_33 
       (.I0(\mem[62][7]_i_115_n_0 ),
        .I1(\mem[62][7]_i_114_n_0 ),
        .O(\mem[62][6]_i_33_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][6]_i_34 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[22]),
        .O(\mem[62][6]_i_34_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][6]_i_35 
       (.I0(finish3[6]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[38]),
        .O(\mem[62][6]_i_35_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_36 
       (.I0(\mem_reg[51]_11 [6]),
        .I1(\mem_reg[50]_12 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[49]_13 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[48]_14 [6]),
        .O(\mem[62][6]_i_36_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_37 
       (.I0(\mem_reg[55]_7 [6]),
        .I1(\mem_reg[54]_8 [6]),
        .I2(\ptr_reg[1]_rep__0_n_0 ),
        .I3(\mem_reg[53]_9 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[52]_10 [6]),
        .O(\mem[62][6]_i_37_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_38 
       (.I0(\mem_reg[59]_3 [6]),
        .I1(\mem_reg[58]_4 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[57]_5 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[56]_6 [6]),
        .O(\mem[62][6]_i_38_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_39 
       (.I0(\mem_reg[63]_69 [6]),
        .I1(\mem_reg[62]_0 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[61]_1 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[60]_2 [6]),
        .O(\mem[62][6]_i_39_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_4 
       (.I0(\mem_reg[62][6]_i_8_n_0 ),
        .I1(\mem_reg[62][6]_i_9_n_0 ),
        .I2(sel0),
        .I3(\mem_reg[62][6]_i_10_n_0 ),
        .I4(ptr[4]),
        .I5(\mem_reg[62][6]_i_11_n_0 ),
        .O(\mem[62][6]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_40 
       (.I0(\mem_reg[35]_27 [6]),
        .I1(\mem_reg[34]_28 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[33]_29 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[32]_30 [6]),
        .O(\mem[62][6]_i_40_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_41 
       (.I0(\mem_reg[39]_23 [6]),
        .I1(\mem_reg[38]_24 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[37]_25 [6]),
        .I4(ptr[0]),
        .I5(\mem_reg[36]_26 [6]),
        .O(\mem[62][6]_i_41_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_42 
       (.I0(\mem_reg[43]_19 [6]),
        .I1(\mem_reg[42]_20 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[41]_21 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[40]_22 [6]),
        .O(\mem[62][6]_i_42_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_43 
       (.I0(\mem_reg[47]_15 [6]),
        .I1(\mem_reg[46]_16 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[45]_17 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[44]_18 [6]),
        .O(\mem[62][6]_i_43_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_44 
       (.I0(\mem_reg[19]_43 [6]),
        .I1(\mem_reg[18]_44 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[17]_45 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[16]_46 [6]),
        .O(\mem[62][6]_i_44_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_45 
       (.I0(\mem_reg[23]_39 [6]),
        .I1(\mem_reg[22]_40 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[21]_41 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[20]_42 [6]),
        .O(\mem[62][6]_i_45_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_46 
       (.I0(\mem_reg[27]_35 [6]),
        .I1(\mem_reg[26]_36 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[25]_37 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[24]_38 [6]),
        .O(\mem[62][6]_i_46_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_47 
       (.I0(\mem_reg[31]_31 [6]),
        .I1(\mem_reg[30]_32 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[29]_33 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[28]_34 [6]),
        .O(\mem[62][6]_i_47_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_48 
       (.I0(\mem_reg[3]_59 [6]),
        .I1(\mem_reg[2]_60 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[1]_61 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[0]_62 [6]),
        .O(\mem[62][6]_i_48_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_49 
       (.I0(\mem_reg[7]_55 [6]),
        .I1(\mem_reg[6]_56 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[5]_57 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[4]_58 [6]),
        .O(\mem[62][6]_i_49_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_50 
       (.I0(\mem_reg[11]_51 [6]),
        .I1(\mem_reg[10]_52 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[9]_53 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[8]_54 [6]),
        .O(\mem[62][6]_i_50_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_51 
       (.I0(\mem_reg[15]_47 [6]),
        .I1(\mem_reg[14]_48 [6]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[13]_49 [6]),
        .I4(\ptr_reg[0]_rep_n_0 ),
        .I5(\mem_reg[12]_50 [6]),
        .O(\mem[62][6]_i_51_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \mem[62][6]_i_53 
       (.I0(\mem[62][7]_i_148_n_0 ),
        .I1(\mem[62][7]_i_149_n_0 ),
        .O(\mem[62][6]_i_53_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \mem[62][6]_i_54 
       (.I0(\mem[62][7]_i_150_n_0 ),
        .I1(\mem[62][7]_i_151_n_0 ),
        .O(\mem[62][6]_i_54_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \mem[62][6]_i_55 
       (.I0(\mem[62][7]_i_152_n_0 ),
        .I1(\mem[62][7]_i_153_n_0 ),
        .O(\mem[62][6]_i_55_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_56 
       (.I0(\mem[62][7]_i_154_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_155_n_0 ),
        .I3(\mem[62][7]_i_156_n_0 ),
        .O(\mem[62][6]_i_56_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \mem[62][6]_i_57 
       (.I0(\mem[62][7]_i_149_n_0 ),
        .I1(\mem[62][7]_i_148_n_0 ),
        .O(\mem[62][6]_i_57_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \mem[62][6]_i_58 
       (.I0(\mem[62][7]_i_151_n_0 ),
        .I1(\mem[62][7]_i_150_n_0 ),
        .O(\mem[62][6]_i_58_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \mem[62][6]_i_59 
       (.I0(\mem[62][7]_i_153_n_0 ),
        .I1(\mem[62][7]_i_152_n_0 ),
        .O(\mem[62][6]_i_59_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'h35)) 
    \mem[62][6]_i_6 
       (.I0(finish2),
        .I1(finish3[48]),
        .I2(relu),
        .O(\mem[62][6]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_60 
       (.I0(\mem[62][7]_i_156_n_0 ),
        .I1(\mem[62][7]_i_155_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_154_n_0 ),
        .O(\mem[62][6]_i_60_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_62 
       (.I0(\mem[62][7]_i_220_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_221_n_0 ),
        .I3(\mem[62][7]_i_155_n_0 ),
        .O(\mem[62][6]_i_62_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_63 
       (.I0(\mem[62][7]_i_222_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_223_n_0 ),
        .I3(\mem[62][7]_i_221_n_0 ),
        .O(\mem[62][6]_i_63_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_64 
       (.I0(\mem[62][7]_i_224_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_225_n_0 ),
        .I3(\mem[62][7]_i_223_n_0 ),
        .O(\mem[62][6]_i_64_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_65 
       (.I0(\mem[62][7]_i_226_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_227_n_0 ),
        .I3(\mem[62][7]_i_225_n_0 ),
        .O(\mem[62][6]_i_65_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_66 
       (.I0(\mem[62][7]_i_155_n_0 ),
        .I1(\mem[62][7]_i_221_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_220_n_0 ),
        .O(\mem[62][6]_i_66_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_67 
       (.I0(\mem[62][7]_i_221_n_0 ),
        .I1(\mem[62][7]_i_223_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_222_n_0 ),
        .O(\mem[62][6]_i_67_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_68 
       (.I0(\mem[62][7]_i_223_n_0 ),
        .I1(\mem[62][7]_i_225_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_224_n_0 ),
        .O(\mem[62][6]_i_68_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_69 
       (.I0(\mem[62][7]_i_225_n_0 ),
        .I1(\mem[62][7]_i_227_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_226_n_0 ),
        .O(\mem[62][6]_i_69_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][6]_i_7 
       (.I0(\mem[62][7]_i_26_n_0 ),
        .I1(\mem[62][7]_i_28_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_24_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][6]_i_16_n_0 ),
        .O(\mem[62][6]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_71 
       (.I0(\mem[62][7]_i_257_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_258_n_0 ),
        .I3(\mem[62][7]_i_227_n_0 ),
        .O(\mem[62][6]_i_71_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_72 
       (.I0(\mem[62][7]_i_259_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_260_n_0 ),
        .I3(\mem[62][7]_i_258_n_0 ),
        .O(\mem[62][6]_i_72_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_73 
       (.I0(\mem[62][7]_i_261_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_262_n_0 ),
        .I3(\mem[62][7]_i_260_n_0 ),
        .O(\mem[62][6]_i_73_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_74 
       (.I0(\mem[62][7]_i_263_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_264_n_0 ),
        .I3(\mem[62][7]_i_262_n_0 ),
        .O(\mem[62][6]_i_74_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_75 
       (.I0(\mem[62][7]_i_227_n_0 ),
        .I1(\mem[62][7]_i_258_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_257_n_0 ),
        .O(\mem[62][6]_i_75_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_76 
       (.I0(\mem[62][7]_i_258_n_0 ),
        .I1(\mem[62][7]_i_260_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_259_n_0 ),
        .O(\mem[62][6]_i_76_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_77 
       (.I0(\mem[62][7]_i_260_n_0 ),
        .I1(\mem[62][7]_i_262_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_261_n_0 ),
        .O(\mem[62][6]_i_77_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_78 
       (.I0(\mem[62][7]_i_262_n_0 ),
        .I1(\mem[62][7]_i_264_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_263_n_0 ),
        .O(\mem[62][6]_i_78_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_79 
       (.I0(\mem[62][7]_i_292_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_293_n_0 ),
        .I3(\mem[62][7]_i_264_n_0 ),
        .O(\mem[62][6]_i_79_n_0 ));
  LUT4 #(
    .INIT(16'hFEBA)) 
    \mem[62][6]_i_80 
       (.I0(\mem[62][7]_i_294_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_295_n_0 ),
        .I3(\mem[62][7]_i_293_n_0 ),
        .O(\mem[62][6]_i_80_n_0 ));
  LUT6 #(
    .INIT(64'hFEFBFEEABAFBBAEA)) 
    \mem[62][6]_i_81 
       (.I0(\mem[62][7]_i_296_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_297_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_298_n_0 ),
        .I5(\mem[62][7]_i_299_n_0 ),
        .O(\mem[62][6]_i_81_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][6]_i_82 
       (.I0(\mem[62][7]_i_11_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_13_n_0 ),
        .O(\mem[62][6]_i_82_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_83 
       (.I0(\mem[62][7]_i_264_n_0 ),
        .I1(\mem[62][7]_i_293_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_292_n_0 ),
        .O(\mem[62][6]_i_83_n_0 ));
  LUT4 #(
    .INIT(16'h0053)) 
    \mem[62][6]_i_84 
       (.I0(\mem[62][7]_i_293_n_0 ),
        .I1(\mem[62][7]_i_295_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_294_n_0 ),
        .O(\mem[62][6]_i_84_n_0 ));
  LUT6 #(
    .INIT(64'h00000000505F03F3)) 
    \mem[62][6]_i_85 
       (.I0(\mem[62][7]_i_299_n_0 ),
        .I1(\mem[62][7]_i_298_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_297_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_296_n_0 ),
        .O(\mem[62][6]_i_85_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \mem[62][6]_i_86 
       (.I0(\mem[62][7]_i_300_n_0 ),
        .I1(\mem[62][6]_i_82_n_0 ),
        .O(\mem[62][6]_i_86_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[62][7]_i_1 
       (.I0(\mem_reg[62]_0 [7]),
        .I1(\mem[62][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_4_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(p_0_in__0[7]));
  LUT2 #(
    .INIT(4'h7)) 
    \mem[62][7]_i_100 
       (.I0(\mem[62][7]_i_150_n_0 ),
        .I1(\mem[62][7]_i_151_n_0 ),
        .O(\mem[62][7]_i_100_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \mem[62][7]_i_101 
       (.I0(\mem[62][7]_i_152_n_0 ),
        .I1(\mem[62][7]_i_153_n_0 ),
        .O(\mem[62][7]_i_101_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_102 
       (.I0(\mem[62][7]_i_154_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_155_n_0 ),
        .I3(\mem[62][7]_i_156_n_0 ),
        .O(\mem[62][7]_i_102_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \mem[62][7]_i_103 
       (.I0(\mem[62][7]_i_149_n_0 ),
        .I1(\mem[62][7]_i_148_n_0 ),
        .O(\mem[62][7]_i_103_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \mem[62][7]_i_104 
       (.I0(\mem[62][7]_i_151_n_0 ),
        .I1(\mem[62][7]_i_150_n_0 ),
        .O(\mem[62][7]_i_104_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \mem[62][7]_i_105 
       (.I0(\mem[62][7]_i_153_n_0 ),
        .I1(\mem[62][7]_i_152_n_0 ),
        .O(\mem[62][7]_i_105_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_106 
       (.I0(\mem[62][7]_i_156_n_0 ),
        .I1(\mem[62][7]_i_155_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_154_n_0 ),
        .O(\mem[62][7]_i_106_n_0 ));
  LUT6 #(
    .INIT(64'hFFFEFFFF01000000)) 
    \mem[62][7]_i_107 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_52_n_0 ),
        .I3(finish3[44]),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_107_n_0 ));
  LUT6 #(
    .INIT(64'hFFFEFFFF01000000)) 
    \mem[62][7]_i_108 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_52_n_0 ),
        .I3(finish3[46]),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_108_n_0 ));
  LUT6 #(
    .INIT(64'hFBF8FFFF0B080000)) 
    \mem[62][7]_i_109 
       (.I0(\mem[62][7]_i_157_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_158_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_109_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_11 
       (.I0(\mem[62][7]_i_23_n_0 ),
        .I1(\mem[62][7]_i_24_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_26_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][7]_i_28_n_0 ),
        .O(\mem[62][7]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'hFBF8FFFF0B080000)) 
    \mem[62][7]_i_110 
       (.I0(\mem[62][7]_i_159_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(\mem[62][7]_i_160_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_110_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_111 
       (.I0(\mem[62][7]_i_161_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_162_n_0 ),
        .O(\mem[62][7]_i_111_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_112 
       (.I0(\mem[62][7]_i_163_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_164_n_0 ),
        .O(\mem[62][7]_i_112_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_113 
       (.I0(\mem[62][7]_i_165_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_163_n_0 ),
        .O(\mem[62][7]_i_113_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_114 
       (.I0(\mem[62][7]_i_166_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_167_n_0 ),
        .O(\mem[62][7]_i_114_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_115 
       (.I0(\mem[62][7]_i_164_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_166_n_0 ),
        .O(\mem[62][7]_i_115_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF1000)) 
    \mem[62][7]_i_116 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[47]),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(finish3[48]),
        .O(\mem[62][7]_i_116_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF1000)) 
    \mem[62][7]_i_117 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[46]),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(finish3[48]),
        .O(\mem[62][7]_i_117_n_0 ));
  LUT6 #(
    .INIT(64'h0100000000000000)) 
    \mem[62][7]_i_119 
       (.I0(\mem[62][7]_i_58_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_25_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_119_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \mem[62][7]_i_12 
       (.I0(shq0[0]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[0] ),
        .O(\mem[62][7]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'h0000000001000000)) 
    \mem[62][7]_i_120 
       (.I0(\mem[62][7]_i_58_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_25_n_0 ),
        .I5(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_120_n_0 ));
  LUT6 #(
    .INIT(64'h0000000001000000)) 
    \mem[62][7]_i_121 
       (.I0(\mem[62][7]_i_58_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_25_n_0 ),
        .O(\mem[62][7]_i_121_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000002)) 
    \mem[62][7]_i_122 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_127_n_0 ),
        .O(\mem[62][7]_i_122_n_0 ));
  LUT6 #(
    .INIT(64'hFEFFFFFFFFFFFFBF)) 
    \mem[62][7]_i_123 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_123_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFF7)) 
    \mem[62][7]_i_124 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_124_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFF9F)) 
    \mem[62][7]_i_125 
       (.I0(\mem[62][7]_i_12_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_125_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFB)) 
    \mem[62][7]_i_126 
       (.I0(\mem[62][7]_i_25_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_126_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT4 #(
    .INIT(16'h04F7)) 
    \mem[62][7]_i_127 
       (.I0(shq0[5]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[5] ),
        .O(\mem[62][7]_i_127_n_0 ));
  LUT6 #(
    .INIT(64'h0000000004F70000)) 
    \mem[62][7]_i_128 
       (.I0(shq0[1]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[1] ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_128_n_0 ));
  LUT6 #(
    .INIT(64'h00000000000004F7)) 
    \mem[62][7]_i_129 
       (.I0(shq0[1]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[1] ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_129_n_0 ));
  LUT6 #(
    .INIT(64'hF0FFF000AACCAACC)) 
    \mem[62][7]_i_13 
       (.I0(\mem[62][7]_i_29_n_0 ),
        .I1(\mem[62][7]_i_30_n_0 ),
        .I2(\mem[62][7]_i_31_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_32_n_0 ),
        .I5(\mem[62][7]_i_25_n_0 ),
        .O(\mem[62][7]_i_13_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hEA)) 
    \mem[62][7]_i_14 
       (.I0(finish10_in),
        .I1(finish3[48]),
        .I2(relu),
        .O(\mem[62][7]_i_14_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_140 
       (.I0(\mem[62][7]_i_220_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_221_n_0 ),
        .I3(\mem[62][7]_i_155_n_0 ),
        .O(\mem[62][7]_i_140_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_141 
       (.I0(\mem[62][7]_i_222_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_223_n_0 ),
        .I3(\mem[62][7]_i_221_n_0 ),
        .O(\mem[62][7]_i_141_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_142 
       (.I0(\mem[62][7]_i_224_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_225_n_0 ),
        .I3(\mem[62][7]_i_223_n_0 ),
        .O(\mem[62][7]_i_142_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_143 
       (.I0(\mem[62][7]_i_226_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_227_n_0 ),
        .I3(\mem[62][7]_i_225_n_0 ),
        .O(\mem[62][7]_i_143_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_144 
       (.I0(\mem[62][7]_i_155_n_0 ),
        .I1(\mem[62][7]_i_221_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_220_n_0 ),
        .O(\mem[62][7]_i_144_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_145 
       (.I0(\mem[62][7]_i_221_n_0 ),
        .I1(\mem[62][7]_i_223_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_222_n_0 ),
        .O(\mem[62][7]_i_145_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_146 
       (.I0(\mem[62][7]_i_223_n_0 ),
        .I1(\mem[62][7]_i_225_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_224_n_0 ),
        .O(\mem[62][7]_i_146_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_147 
       (.I0(\mem[62][7]_i_225_n_0 ),
        .I1(\mem[62][7]_i_227_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_226_n_0 ),
        .O(\mem[62][7]_i_147_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_148 
       (.I0(\mem[62][7]_i_228_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_229_n_0 ),
        .O(\mem[62][7]_i_148_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_149 
       (.I0(\mem[62][7]_i_167_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_228_n_0 ),
        .O(\mem[62][7]_i_149_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_150 
       (.I0(\mem[62][7]_i_230_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_231_n_0 ),
        .O(\mem[62][7]_i_150_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_151 
       (.I0(\mem[62][7]_i_229_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_230_n_0 ),
        .O(\mem[62][7]_i_151_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_152 
       (.I0(\mem[62][7]_i_232_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_156_n_0 ),
        .O(\mem[62][7]_i_152_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_153 
       (.I0(\mem[62][7]_i_231_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][7]_i_232_n_0 ),
        .O(\mem[62][7]_i_153_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_154 
       (.I0(\mem[62][7]_i_233_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_234_n_0 ),
        .O(\mem[62][7]_i_154_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_155 
       (.I0(\mem[62][7]_i_235_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_236_n_0 ),
        .O(\mem[62][7]_i_155_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_156 
       (.I0(\mem[62][7]_i_237_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_235_n_0 ),
        .O(\mem[62][7]_i_156_n_0 ));
  LUT6 #(
    .INIT(64'hCDCCCDDDC8CCC888)) 
    \mem[62][7]_i_157 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(finish3[48]),
        .I2(shq0[5]),
        .I3(\result0[21]_i_3_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[47]),
        .O(\mem[62][7]_i_157_n_0 ));
  LUT6 #(
    .INIT(64'hCDCCCDDDC8CCC888)) 
    \mem[62][7]_i_158 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(finish3[48]),
        .I2(shq0[5]),
        .I3(\result0[21]_i_3_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[45]),
        .O(\mem[62][7]_i_158_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_159 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[46]),
        .O(\mem[62][7]_i_159_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_160 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[42]),
        .O(\mem[62][7]_i_160_n_0 ));
  LUT6 #(
    .INIT(64'hFFFEFFFF01000000)) 
    \mem[62][7]_i_161 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_52_n_0 ),
        .I3(finish3[45]),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_161_n_0 ));
  LUT6 #(
    .INIT(64'hBBB8FFFF8B880000)) 
    \mem[62][7]_i_162 
       (.I0(\mem[62][7]_i_157_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(\mem[62][7]_i_238_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_162_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_163 
       (.I0(\mem[62][7]_i_162_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_239_n_0 ),
        .O(\mem[62][7]_i_163_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_164 
       (.I0(\mem[62][7]_i_110_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_240_n_0 ),
        .O(\mem[62][7]_i_164_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_165 
       (.I0(\mem[62][7]_i_107_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_110_n_0 ),
        .O(\mem[62][7]_i_165_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_166 
       (.I0(\mem[62][7]_i_239_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_241_n_0 ),
        .O(\mem[62][7]_i_166_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_167 
       (.I0(\mem[62][7]_i_240_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_242_n_0 ),
        .O(\mem[62][7]_i_167_n_0 ));
  LUT6 #(
    .INIT(64'h0000000001000000)) 
    \mem[62][7]_i_168 
       (.I0(\mem[62][7]_i_58_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_25_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_168_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000010000)) 
    \mem[62][7]_i_169 
       (.I0(\mem[62][7]_i_58_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_25_n_0 ),
        .I5(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_169_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFB)) 
    \mem[62][7]_i_170 
       (.I0(\mem[62][7]_i_12_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_170_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFEFEFFFFFF)) 
    \mem[62][7]_i_171 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_171_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFB)) 
    \mem[62][7]_i_172 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_127_n_0 ),
        .I3(\mem[62][7]_i_53_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_172_n_0 ));
  LUT5 #(
    .INIT(32'hFBFF0400)) 
    \mem[62][7]_i_173 
       (.I0(\mem[62][7]_i_12_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_243_n_0 ),
        .I4(t_reg_n_64),
        .O(\mem[62][7]_i_173_n_0 ));
  LUT5 #(
    .INIT(32'hAA9AAAAA)) 
    \mem[62][7]_i_174 
       (.I0(t_reg_n_65),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_243_n_0 ),
        .O(\mem[62][7]_i_174_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_175 
       (.I0(t_reg_n_74),
        .I1(\mem[62][7]_i_127_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_129_n_0 ),
        .O(\mem[62][7]_i_175_n_0 ));
  LUT5 #(
    .INIT(32'h9AAAAAAA)) 
    \mem[62][7]_i_176 
       (.I0(t_reg_n_75),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_176_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_177 
       (.I0(t_reg_n_76),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_177_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_178 
       (.I0(t_reg_n_77),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_178_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAAAA9)) 
    \mem[62][7]_i_179 
       (.I0(t_reg_n_90),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_179_n_0 ));
  LUT5 #(
    .INIT(32'h9AAAAAAA)) 
    \mem[62][7]_i_180 
       (.I0(t_reg_n_91),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_180_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_181 
       (.I0(t_reg_n_92),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_181_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_182 
       (.I0(t_reg_n_93),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_182_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAAAA9)) 
    \mem[62][7]_i_183 
       (.I0(t_reg_n_66),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_183_n_0 ));
  LUT5 #(
    .INIT(32'h9AAAAAAA)) 
    \mem[62][7]_i_184 
       (.I0(t_reg_n_67),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_184_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_185 
       (.I0(t_reg_n_68),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_185_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_186 
       (.I0(t_reg_n_69),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_186_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAAAA9)) 
    \mem[62][7]_i_187 
       (.I0(t_reg_n_82),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_187_n_0 ));
  LUT5 #(
    .INIT(32'h9AAAAAAA)) 
    \mem[62][7]_i_188 
       (.I0(t_reg_n_83),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_188_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_189 
       (.I0(t_reg_n_84),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_189_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_190 
       (.I0(t_reg_n_85),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_190_n_0 ));
  LUT5 #(
    .INIT(32'hAAA9AAAA)) 
    \mem[62][7]_i_191 
       (.I0(t_reg_n_78),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_191_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_192 
       (.I0(t_reg_n_79),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_192_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_193 
       (.I0(t_reg_n_80),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_193_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_194 
       (.I0(t_reg_n_81),
        .I1(\mem[62][7]_i_244_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_194_n_0 ));
  LUT5 #(
    .INIT(32'hAAA9AAAA)) 
    \mem[62][7]_i_195 
       (.I0(t_reg_n_94),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_195_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_196 
       (.I0(t_reg_n_95),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_196_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_197 
       (.I0(t_reg_n_96),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_197_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_198 
       (.I0(t_reg_n_97),
        .I1(\mem[62][7]_i_245_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_198_n_0 ));
  LUT5 #(
    .INIT(32'hAAA9AAAA)) 
    \mem[62][7]_i_199 
       (.I0(t_reg_n_70),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_199_n_0 ));
  LUT6 #(
    .INIT(64'h4000000000000000)) 
    \mem[62][7]_i_2 
       (.I0(ptr[0]),
        .I1(\ptr_reg[1]_rep_n_0 ),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[62][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h55FF55FF55FF57F7)) 
    \mem[62][7]_i_20 
       (.I0(\mem[62][7]_i_50_n_0 ),
        .I1(finish3[47]),
        .I2(\mem[62][7]_i_52_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_54_n_0 ),
        .O(\mem[62][7]_i_20_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_200 
       (.I0(t_reg_n_71),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_200_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_201 
       (.I0(t_reg_n_72),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_201_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_202 
       (.I0(t_reg_n_73),
        .I1(\mem[62][7]_i_246_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_202_n_0 ));
  LUT5 #(
    .INIT(32'hAAA9AAAA)) 
    \mem[62][7]_i_203 
       (.I0(t_reg_n_86),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_203_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_204 
       (.I0(t_reg_n_87),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_204_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_205 
       (.I0(t_reg_n_88),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_205_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAA9AA)) 
    \mem[62][7]_i_206 
       (.I0(t_reg_n_89),
        .I1(\mem[62][7]_i_247_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_206_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAAAA9)) 
    \mem[62][7]_i_207 
       (.I0(t_reg_n_98),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_207_n_0 ));
  LUT5 #(
    .INIT(32'h9AAAAAAA)) 
    \mem[62][7]_i_208 
       (.I0(t_reg_n_99),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_208_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_209 
       (.I0(t_reg_n_100),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_209_n_0 ));
  LUT5 #(
    .INIT(32'hA9AAAAAA)) 
    \mem[62][7]_i_210 
       (.I0(t_reg_n_101),
        .I1(\mem[62][7]_i_248_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_210_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_212 
       (.I0(\mem[62][7]_i_257_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_258_n_0 ),
        .I3(\mem[62][7]_i_227_n_0 ),
        .O(\mem[62][7]_i_212_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_213 
       (.I0(\mem[62][7]_i_259_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_260_n_0 ),
        .I3(\mem[62][7]_i_258_n_0 ),
        .O(\mem[62][7]_i_213_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_214 
       (.I0(\mem[62][7]_i_261_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_262_n_0 ),
        .I3(\mem[62][7]_i_260_n_0 ),
        .O(\mem[62][7]_i_214_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_215 
       (.I0(\mem[62][7]_i_263_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_264_n_0 ),
        .I3(\mem[62][7]_i_262_n_0 ),
        .O(\mem[62][7]_i_215_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_216 
       (.I0(\mem[62][7]_i_227_n_0 ),
        .I1(\mem[62][7]_i_258_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_257_n_0 ),
        .O(\mem[62][7]_i_216_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_217 
       (.I0(\mem[62][7]_i_258_n_0 ),
        .I1(\mem[62][7]_i_260_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_259_n_0 ),
        .O(\mem[62][7]_i_217_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_218 
       (.I0(\mem[62][7]_i_260_n_0 ),
        .I1(\mem[62][7]_i_262_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_261_n_0 ),
        .O(\mem[62][7]_i_218_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_219 
       (.I0(\mem[62][7]_i_262_n_0 ),
        .I1(\mem[62][7]_i_264_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_263_n_0 ),
        .O(\mem[62][7]_i_219_n_0 ));
  LUT6 #(
    .INIT(64'hAA00AA00AA00A808)) 
    \mem[62][7]_i_22 
       (.I0(\mem[62][7]_i_50_n_0 ),
        .I1(finish3[47]),
        .I2(\mem[62][7]_i_52_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_54_n_0 ),
        .O(\mem[62][7]_i_22_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_220 
       (.I0(\mem[62][7]_i_234_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_265_n_0 ),
        .O(\mem[62][7]_i_220_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_221 
       (.I0(\mem[62][7]_i_236_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_266_n_0 ),
        .O(\mem[62][7]_i_221_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_222 
       (.I0(\mem[62][7]_i_265_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_267_n_0 ),
        .O(\mem[62][7]_i_222_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_223 
       (.I0(\mem[62][7]_i_266_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_268_n_0 ),
        .O(\mem[62][7]_i_223_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_224 
       (.I0(\mem[62][7]_i_267_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_269_n_0 ),
        .O(\mem[62][7]_i_224_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_225 
       (.I0(\mem[62][7]_i_268_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_270_n_0 ),
        .O(\mem[62][7]_i_225_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_226 
       (.I0(\mem[62][7]_i_269_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_271_n_0 ),
        .O(\mem[62][7]_i_226_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_227 
       (.I0(\mem[62][7]_i_270_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_272_n_0 ),
        .O(\mem[62][7]_i_227_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_228 
       (.I0(\mem[62][7]_i_241_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_273_n_0 ),
        .O(\mem[62][7]_i_228_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_229 
       (.I0(\mem[62][7]_i_242_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_274_n_0 ),
        .O(\mem[62][7]_i_229_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_23 
       (.I0(\mem[62][7]_i_56_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_57_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_59_n_0 ),
        .O(\mem[62][7]_i_23_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_230 
       (.I0(\mem[62][7]_i_273_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_275_n_0 ),
        .O(\mem[62][7]_i_230_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_231 
       (.I0(\mem[62][7]_i_274_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_237_n_0 ),
        .O(\mem[62][7]_i_231_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_232 
       (.I0(\mem[62][7]_i_275_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_233_n_0 ),
        .O(\mem[62][7]_i_232_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_233 
       (.I0(\mem[62][7]_i_276_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_277_n_0 ),
        .O(\mem[62][7]_i_233_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_234 
       (.I0(\mem[62][7]_i_278_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_279_n_0 ),
        .O(\mem[62][7]_i_234_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_235 
       (.I0(\mem[62][7]_i_280_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_281_n_0 ),
        .O(\mem[62][7]_i_235_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_236 
       (.I0(\mem[62][7]_i_282_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_283_n_0 ),
        .O(\mem[62][7]_i_236_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_237 
       (.I0(\mem[62][7]_i_284_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_282_n_0 ),
        .O(\mem[62][7]_i_237_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_238 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[43]),
        .O(\mem[62][7]_i_238_n_0 ));
  LUT6 #(
    .INIT(64'hFBF8FFFF0B080000)) 
    \mem[62][7]_i_239 
       (.I0(\mem[62][7]_i_285_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(\mem[62][7]_i_286_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_239_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_24 
       (.I0(\mem[62][7]_i_60_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_61_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_62_n_0 ),
        .O(\mem[62][7]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hFBF8FFFF0B080000)) 
    \mem[62][7]_i_240 
       (.I0(\mem[62][7]_i_287_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(\mem[62][7]_i_288_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(finish3[48]),
        .O(\mem[62][7]_i_240_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_241 
       (.I0(\mem[62][7]_i_289_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_290_n_0 ),
        .O(\mem[62][7]_i_241_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_242 
       (.I0(\mem[62][7]_i_291_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_284_n_0 ),
        .O(\mem[62][7]_i_242_n_0 ));
  LUT6 #(
    .INIT(64'h0101010101010140)) 
    \mem[62][7]_i_243 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_243_n_0 ));
  LUT6 #(
    .INIT(64'hDDDDDDDFFFFFFFFB)) 
    \mem[62][7]_i_244 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_27_n_0 ),
        .I5(\mem[62][7]_i_53_n_0 ),
        .O(\mem[62][7]_i_244_n_0 ));
  LUT6 #(
    .INIT(64'hFDFDFDFDFDFDFD7F)) 
    \mem[62][7]_i_245 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_27_n_0 ),
        .O(\mem[62][7]_i_245_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFAAABFFFE)) 
    \mem[62][7]_i_246 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(\mem[62][7]_i_53_n_0 ),
        .O(\mem[62][7]_i_246_n_0 ));
  LUT6 #(
    .INIT(64'h7777777FFFFFFFF7)) 
    \mem[62][7]_i_247 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_25_n_0 ),
        .I5(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_247_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFAAABFFFE)) 
    \mem[62][7]_i_248 
       (.I0(\mem[62][7]_i_52_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(\mem[62][7]_i_53_n_0 ),
        .O(\mem[62][7]_i_248_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_249 
       (.I0(\mem[62][7]_i_292_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_293_n_0 ),
        .I3(\mem[62][7]_i_264_n_0 ),
        .O(\mem[62][7]_i_249_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \mem[62][7]_i_25 
       (.I0(shq0[1]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[1] ),
        .O(\mem[62][7]_i_25_n_0 ));
  LUT4 #(
    .INIT(16'h57DF)) 
    \mem[62][7]_i_250 
       (.I0(\mem[62][7]_i_294_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_295_n_0 ),
        .I3(\mem[62][7]_i_293_n_0 ),
        .O(\mem[62][7]_i_250_n_0 ));
  LUT6 #(
    .INIT(64'h575D577FDF5DDF7F)) 
    \mem[62][7]_i_251 
       (.I0(\mem[62][7]_i_296_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_297_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_298_n_0 ),
        .I5(\mem[62][7]_i_299_n_0 ),
        .O(\mem[62][7]_i_251_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \mem[62][7]_i_252 
       (.I0(\mem[62][6]_i_82_n_0 ),
        .O(\mem[62][7]_i_252_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_253 
       (.I0(\mem[62][7]_i_264_n_0 ),
        .I1(\mem[62][7]_i_293_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_292_n_0 ),
        .O(\mem[62][7]_i_253_n_0 ));
  LUT4 #(
    .INIT(16'hAC00)) 
    \mem[62][7]_i_254 
       (.I0(\mem[62][7]_i_293_n_0 ),
        .I1(\mem[62][7]_i_295_n_0 ),
        .I2(\mem[62][7]_i_12_n_0 ),
        .I3(\mem[62][7]_i_294_n_0 ),
        .O(\mem[62][7]_i_254_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0FC0C00000000)) 
    \mem[62][7]_i_255 
       (.I0(\mem[62][7]_i_299_n_0 ),
        .I1(\mem[62][7]_i_298_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_297_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_296_n_0 ),
        .O(\mem[62][7]_i_255_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \mem[62][7]_i_256 
       (.I0(\mem[62][6]_i_82_n_0 ),
        .I1(\mem[62][7]_i_300_n_0 ),
        .O(\mem[62][7]_i_256_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_257 
       (.I0(\mem[62][7]_i_271_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_301_n_0 ),
        .O(\mem[62][7]_i_257_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_258 
       (.I0(\mem[62][7]_i_272_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_302_n_0 ),
        .O(\mem[62][7]_i_258_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_259 
       (.I0(\mem[62][7]_i_301_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_303_n_0 ),
        .O(\mem[62][7]_i_259_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_26 
       (.I0(\mem[62][7]_i_63_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_64_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_65_n_0 ),
        .O(\mem[62][7]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_260 
       (.I0(\mem[62][7]_i_302_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_304_n_0 ),
        .O(\mem[62][7]_i_260_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_261 
       (.I0(\mem[62][7]_i_303_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_305_n_0 ),
        .O(\mem[62][7]_i_261_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_262 
       (.I0(\mem[62][7]_i_304_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_306_n_0 ),
        .O(\mem[62][7]_i_262_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_263 
       (.I0(\mem[62][7]_i_305_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_307_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_308_n_0 ),
        .O(\mem[62][7]_i_263_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_264 
       (.I0(\mem[62][7]_i_306_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_309_n_0 ),
        .O(\mem[62][7]_i_264_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_265 
       (.I0(\mem[62][7]_i_277_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_310_n_0 ),
        .O(\mem[62][7]_i_265_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_266 
       (.I0(\mem[62][7]_i_281_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_311_n_0 ),
        .O(\mem[62][7]_i_266_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_267 
       (.I0(\mem[62][7]_i_279_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_312_n_0 ),
        .O(\mem[62][7]_i_267_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_268 
       (.I0(\mem[62][7]_i_283_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_313_n_0 ),
        .O(\mem[62][7]_i_268_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_269 
       (.I0(\mem[62][7]_i_310_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_314_n_0 ),
        .O(\mem[62][7]_i_269_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \mem[62][7]_i_27 
       (.I0(shq0[2]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[2] ),
        .O(\mem[62][7]_i_27_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_270 
       (.I0(\mem[62][7]_i_311_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_315_n_0 ),
        .O(\mem[62][7]_i_270_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_271 
       (.I0(\mem[62][7]_i_312_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_316_n_0 ),
        .O(\mem[62][7]_i_271_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_272 
       (.I0(\mem[62][7]_i_313_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_317_n_0 ),
        .O(\mem[62][7]_i_272_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_273 
       (.I0(\mem[62][7]_i_318_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_276_n_0 ),
        .O(\mem[62][7]_i_273_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_274 
       (.I0(\mem[62][7]_i_319_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_280_n_0 ),
        .O(\mem[62][7]_i_274_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_275 
       (.I0(\mem[62][7]_i_290_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_278_n_0 ),
        .O(\mem[62][7]_i_275_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_276 
       (.I0(finish3[37]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[45]),
        .O(\mem[62][7]_i_276_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_277 
       (.I0(finish3[33]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[41]),
        .O(\mem[62][7]_i_277_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_278 
       (.I0(finish3[35]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[43]),
        .O(\mem[62][7]_i_278_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_279 
       (.I0(\mem[62][7]_i_320_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[39]),
        .O(\mem[62][7]_i_279_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_28 
       (.I0(\mem[62][7]_i_66_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_67_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_68_n_0 ),
        .O(\mem[62][7]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_280 
       (.I0(finish3[36]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[44]),
        .O(\mem[62][7]_i_280_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_281 
       (.I0(finish3[32]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[40]),
        .O(\mem[62][7]_i_281_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_282 
       (.I0(finish3[34]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[42]),
        .O(\mem[62][7]_i_282_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_283 
       (.I0(\mem[62][7]_i_321_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[38]),
        .O(\mem[62][7]_i_283_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_284 
       (.I0(finish3[38]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[46]),
        .O(\mem[62][7]_i_284_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_285 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[45]),
        .O(\mem[62][7]_i_285_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_286 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[41]),
        .O(\mem[62][7]_i_286_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_287 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[44]),
        .O(\mem[62][7]_i_287_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_288 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[40]),
        .O(\mem[62][7]_i_288_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF1000)) 
    \mem[62][7]_i_289 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[43]),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(finish3[48]),
        .O(\mem[62][7]_i_289_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_29 
       (.I0(\mem[62][7]_i_69_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_70_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_71_n_0 ),
        .O(\mem[62][7]_i_29_n_0 ));
  LUT6 #(
    .INIT(64'hFF00FB0BFF00F808)) 
    \mem[62][7]_i_290 
       (.I0(finish3[39]),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[47]),
        .O(\mem[62][7]_i_290_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF1000)) 
    \mem[62][7]_i_291 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[42]),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(finish3[48]),
        .O(\mem[62][7]_i_291_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_292 
       (.I0(\mem[62][7]_i_307_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_308_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_322_n_0 ),
        .O(\mem[62][7]_i_292_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_293 
       (.I0(\mem[62][7]_i_309_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_299_n_0 ),
        .O(\mem[62][7]_i_293_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_294 
       (.I0(\mem[62][7]_i_322_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(\mem[62][7]_i_308_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_29_n_0 ),
        .O(\mem[62][7]_i_294_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_295 
       (.I0(\mem[62][7]_i_299_n_0 ),
        .I1(shq0[1]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[1] ),
        .I5(\mem[62][7]_i_297_n_0 ),
        .O(\mem[62][7]_i_295_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_296 
       (.I0(\mem[62][7]_i_308_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_29_n_0 ),
        .I3(\mem[62][7]_i_25_n_0 ),
        .I4(\mem[62][7]_i_323_n_0 ),
        .O(\mem[62][7]_i_296_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_297 
       (.I0(\mem[62][7]_i_324_n_0 ),
        .I1(\mem[62][7]_i_59_n_0 ),
        .I2(\mem[62][7]_i_27_n_0 ),
        .I3(\mem[62][7]_i_325_n_0 ),
        .I4(\mem[62][7]_i_58_n_0 ),
        .I5(\mem[62][7]_i_62_n_0 ),
        .O(\mem[62][7]_i_297_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_298 
       (.I0(\mem[62][7]_i_326_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_65_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_28_n_0 ),
        .O(\mem[62][7]_i_298_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_299 
       (.I0(\mem[62][7]_i_327_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_326_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_65_n_0 ),
        .O(\mem[62][7]_i_299_n_0 ));
  LUT3 #(
    .INIT(8'hB8)) 
    \mem[62][7]_i_3 
       (.I0(Q[7]),
        .I1(\mem[62][7]_i_6_n_0 ),
        .I2(\mem[62][7]_i_7_n_0 ),
        .O(\mem[62][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_30 
       (.I0(\mem[62][7]_i_72_n_0 ),
        .I1(\mem[62][7]_i_73_n_0 ),
        .I2(\mem[62][7]_i_58_n_0 ),
        .I3(\mem[62][7]_i_74_n_0 ),
        .I4(\mem[62][7]_i_53_n_0 ),
        .I5(\mem[62][7]_i_75_n_0 ),
        .O(\mem[62][7]_i_30_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_300 
       (.I0(\mem[62][7]_i_13_n_0 ),
        .I1(shq0[0]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg_n_0_[0] ),
        .I4(\shq1_reg_n_0_[0] ),
        .I5(\mem[62][6]_i_7_n_0 ),
        .O(\mem[62][7]_i_300_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_301 
       (.I0(\mem[62][7]_i_314_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_328_n_0 ),
        .O(\mem[62][7]_i_301_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_302 
       (.I0(\mem[62][7]_i_315_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_329_n_0 ),
        .O(\mem[62][7]_i_302_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_303 
       (.I0(\mem[62][7]_i_316_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_307_n_0 ),
        .O(\mem[62][7]_i_303_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_304 
       (.I0(\mem[62][7]_i_317_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_330_n_0 ),
        .O(\mem[62][7]_i_304_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_305 
       (.I0(\mem[62][7]_i_328_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_331_n_0 ),
        .O(\mem[62][7]_i_305_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_306 
       (.I0(\mem[62][7]_i_329_n_0 ),
        .I1(shq0[2]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[2] ),
        .I5(\mem[62][7]_i_327_n_0 ),
        .O(\mem[62][7]_i_306_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_307 
       (.I0(\mem[62][7]_i_71_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_332_n_0 ),
        .O(\mem[62][7]_i_307_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_308 
       (.I0(\mem[62][7]_i_333_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_334_n_0 ),
        .O(\mem[62][7]_i_308_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_309 
       (.I0(\mem[62][7]_i_330_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_324_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_59_n_0 ),
        .O(\mem[62][7]_i_309_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_31 
       (.I0(\mem[62][7]_i_76_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_77_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_78_n_0 ),
        .O(\mem[62][7]_i_31_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_310 
       (.I0(\mem[62][7]_i_335_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[37]),
        .O(\mem[62][7]_i_310_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_311 
       (.I0(\mem[62][7]_i_336_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[36]),
        .O(\mem[62][7]_i_311_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_312 
       (.I0(\mem[62][7]_i_332_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[35]),
        .O(\mem[62][7]_i_312_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_313 
       (.I0(\mem[62][7]_i_337_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[34]),
        .O(\mem[62][7]_i_313_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_314 
       (.I0(\mem[62][7]_i_338_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[33]),
        .O(\mem[62][7]_i_314_n_0 ));
  LUT6 #(
    .INIT(64'hBB88BB8BBB88B888)) 
    \mem[62][7]_i_315 
       (.I0(\mem[62][7]_i_339_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_53_n_0 ),
        .I3(finish3[48]),
        .I4(\mem[62][7]_i_52_n_0 ),
        .I5(finish3[32]),
        .O(\mem[62][7]_i_315_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_316 
       (.I0(\mem[62][7]_i_334_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_320_n_0 ),
        .O(\mem[62][7]_i_316_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_317 
       (.I0(\mem[62][7]_i_59_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_321_n_0 ),
        .O(\mem[62][7]_i_317_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF1000)) 
    \mem[62][7]_i_318 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[41]),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(finish3[48]),
        .O(\mem[62][7]_i_318_n_0 ));
  LUT5 #(
    .INIT(32'hFEFF1000)) 
    \mem[62][7]_i_319 
       (.I0(\mem[62][7]_i_53_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(finish3[40]),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(finish3[48]),
        .O(\mem[62][7]_i_319_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_32 
       (.I0(\mem[62][7]_i_79_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(\mem[62][7]_i_80_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_81_n_0 ),
        .O(\mem[62][7]_i_32_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_320 
       (.I0(finish3[47]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[31]),
        .O(\mem[62][7]_i_320_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_321 
       (.I0(finish3[46]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[30]),
        .O(\mem[62][7]_i_321_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_322 
       (.I0(\mem[62][7]_i_331_n_0 ),
        .I1(\mem[62][7]_i_27_n_0 ),
        .I2(\mem[62][7]_i_340_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_78_n_0 ),
        .O(\mem[62][7]_i_322_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[62][7]_i_323 
       (.I0(\mem[62][7]_i_340_n_0 ),
        .I1(\mem[62][7]_i_58_n_0 ),
        .I2(\mem[62][7]_i_78_n_0 ),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_32_n_0 ),
        .O(\mem[62][7]_i_323_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_324 
       (.I0(\mem[62][7]_i_56_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[14]),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(finish3[46]),
        .O(\mem[62][7]_i_324_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_325 
       (.I0(\mem[62][7]_i_60_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[10]),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(finish3[42]),
        .O(\mem[62][7]_i_325_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_326 
       (.I0(\mem[62][7]_i_63_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[12]),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(finish3[44]),
        .O(\mem[62][7]_i_326_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_327 
       (.I0(\mem[62][7]_i_68_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_339_n_0 ),
        .O(\mem[62][7]_i_327_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_328 
       (.I0(\mem[62][7]_i_78_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_335_n_0 ),
        .O(\mem[62][7]_i_328_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_329 
       (.I0(\mem[62][7]_i_65_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_336_n_0 ),
        .O(\mem[62][7]_i_329_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_330 
       (.I0(\mem[62][7]_i_62_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_337_n_0 ),
        .O(\mem[62][7]_i_330_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_331 
       (.I0(\mem[62][7]_i_81_n_0 ),
        .I1(shq0[3]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[3] ),
        .I5(\mem[62][7]_i_338_n_0 ),
        .O(\mem[62][7]_i_331_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_332 
       (.I0(finish3[43]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[27]),
        .O(\mem[62][7]_i_332_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_333 
       (.I0(\mem[62][7]_i_74_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[15]),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(finish3[47]),
        .O(\mem[62][7]_i_333_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_334 
       (.I0(finish3[39]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[23]),
        .O(\mem[62][7]_i_334_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_335 
       (.I0(finish3[45]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[29]),
        .O(\mem[62][7]_i_335_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_336 
       (.I0(finish3[44]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[28]),
        .O(\mem[62][7]_i_336_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_337 
       (.I0(finish3[42]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[26]),
        .O(\mem[62][7]_i_337_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_338 
       (.I0(finish3[41]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[25]),
        .O(\mem[62][7]_i_338_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_339 
       (.I0(finish3[40]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[24]),
        .O(\mem[62][7]_i_339_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[62][7]_i_340 
       (.I0(\mem[62][7]_i_76_n_0 ),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[13]),
        .I3(\mem[62][7]_i_127_n_0 ),
        .I4(finish3[45]),
        .O(\mem[62][7]_i_340_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFAFFCFFFFFFF)) 
    \mem[62][7]_i_4 
       (.I0(\mem[62][7]_i_8_n_0 ),
        .I1(\mem[62][7]_i_9_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\phase_reg[1]_rep_n_0 ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[62][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h505F03F3FFFFFFFF)) 
    \mem[62][7]_i_42 
       (.I0(finish3[48]),
        .I1(\mem[62][7]_i_107_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_108_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_109_n_0 ),
        .O(\mem[62][7]_i_42_n_0 ));
  LUT6 #(
    .INIT(64'h505F03F3FFFFFFFF)) 
    \mem[62][7]_i_43 
       (.I0(\mem[62][7]_i_108_n_0 ),
        .I1(\mem[62][7]_i_110_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_107_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_111_n_0 ),
        .O(\mem[62][7]_i_43_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \mem[62][7]_i_44 
       (.I0(\mem[62][7]_i_112_n_0 ),
        .I1(\mem[62][7]_i_113_n_0 ),
        .O(\mem[62][7]_i_44_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \mem[62][7]_i_45 
       (.I0(\mem[62][7]_i_114_n_0 ),
        .I1(\mem[62][7]_i_115_n_0 ),
        .O(\mem[62][7]_i_45_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0FC0C00000000)) 
    \mem[62][7]_i_46 
       (.I0(finish3[48]),
        .I1(\mem[62][7]_i_107_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_108_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_109_n_0 ),
        .O(\mem[62][7]_i_46_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0FC0C00000000)) 
    \mem[62][7]_i_47 
       (.I0(\mem[62][7]_i_108_n_0 ),
        .I1(\mem[62][7]_i_110_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_107_n_0 ),
        .I4(\mem[62][7]_i_12_n_0 ),
        .I5(\mem[62][7]_i_111_n_0 ),
        .O(\mem[62][7]_i_47_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \mem[62][7]_i_48 
       (.I0(\mem[62][7]_i_113_n_0 ),
        .I1(\mem[62][7]_i_112_n_0 ),
        .O(\mem[62][7]_i_48_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \mem[62][7]_i_49 
       (.I0(\mem[62][7]_i_115_n_0 ),
        .I1(\mem[62][7]_i_114_n_0 ),
        .O(\mem[62][7]_i_49_n_0 ));
  LUT6 #(
    .INIT(64'h00000000F2FFF222)) 
    \mem[62][7]_i_5 
       (.I0(finish2),
        .I1(relu),
        .I2(\mem[62][7]_i_11_n_0 ),
        .I3(\mem[62][7]_i_12_n_0 ),
        .I4(\mem[62][7]_i_13_n_0 ),
        .I5(\mem[62][7]_i_14_n_0 ),
        .O(\mem[62][7]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hF0E2F0E2F0F3F0C0)) 
    \mem[62][7]_i_50 
       (.I0(\mem[62][7]_i_116_n_0 ),
        .I1(\mem[62][7]_i_25_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_27_n_0 ),
        .I4(\mem[62][7]_i_117_n_0 ),
        .I5(\mem[62][7]_i_12_n_0 ),
        .O(\mem[62][7]_i_50_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \mem[62][7]_i_52 
       (.I0(shq0[5]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[5] ),
        .O(\mem[62][7]_i_52_n_0 ));
  LUT4 #(
    .INIT(16'hAEA2)) 
    \mem[62][7]_i_53 
       (.I0(\shq1_reg_n_0_[4] ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(shq0[4]),
        .O(\mem[62][7]_i_53_n_0 ));
  LUT4 #(
    .INIT(16'hFEFF)) 
    \mem[62][7]_i_54 
       (.I0(\mem[62][7]_i_27_n_0 ),
        .I1(\mem[62][7]_i_12_n_0 ),
        .I2(\mem[62][7]_i_25_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .O(\mem[62][7]_i_54_n_0 ));
  LUT6 #(
    .INIT(64'hAA3F3FFFFFFFFFFF)) 
    \mem[62][7]_i_55 
       (.I0(\mem[62][7]_i_127_n_0 ),
        .I1(\mem[62][7]_i_52_n_0 ),
        .I2(\mem[62][7]_i_128_n_0 ),
        .I3(\mem[62][7]_i_58_n_0 ),
        .I4(\mem[62][7]_i_129_n_0 ),
        .I5(\mem[62][7]_i_53_n_0 ),
        .O(\mem[62][7]_i_55_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_56 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[30]),
        .O(\mem[62][7]_i_56_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_57 
       (.I0(finish3[14]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[46]),
        .O(\mem[62][7]_i_57_n_0 ));
  LUT4 #(
    .INIT(16'h04F7)) 
    \mem[62][7]_i_58 
       (.I0(shq0[3]),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg[0]_rep__0_n_0 ),
        .I3(\shq1_reg_n_0_[3] ),
        .O(\mem[62][7]_i_58_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_59 
       (.I0(finish3[38]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[22]),
        .O(\mem[62][7]_i_59_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    \mem[62][7]_i_6 
       (.I0(q_pair),
        .I1(step),
        .I2(\ptr_reg[0]_rep_1 ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_2 ),
        .O(\mem[62][7]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_60 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[26]),
        .O(\mem[62][7]_i_60_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_61 
       (.I0(finish3[10]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[42]),
        .O(\mem[62][7]_i_61_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_62 
       (.I0(finish3[34]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[18]),
        .O(\mem[62][7]_i_62_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_63 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[28]),
        .O(\mem[62][7]_i_63_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_64 
       (.I0(finish3[12]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[44]),
        .O(\mem[62][7]_i_64_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_65 
       (.I0(finish3[36]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[20]),
        .O(\mem[62][7]_i_65_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_66 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[24]),
        .O(\mem[62][7]_i_66_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_67 
       (.I0(finish3[8]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[40]),
        .O(\mem[62][7]_i_67_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_68 
       (.I0(finish3[32]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[16]),
        .O(\mem[62][7]_i_68_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_69 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[27]),
        .O(\mem[62][7]_i_69_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_7 
       (.I0(\mem_reg[62][7]_i_15_n_0 ),
        .I1(\mem_reg[62][7]_i_16_n_0 ),
        .I2(sel0),
        .I3(\mem_reg[62][7]_i_17_n_0 ),
        .I4(ptr[4]),
        .I5(\mem_reg[62][7]_i_18_n_0 ),
        .O(\mem[62][7]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_70 
       (.I0(finish3[11]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[43]),
        .O(\mem[62][7]_i_70_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_71 
       (.I0(finish3[35]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[19]),
        .O(\mem[62][7]_i_71_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_72 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[23]),
        .O(\mem[62][7]_i_72_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_73 
       (.I0(finish3[7]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[39]),
        .O(\mem[62][7]_i_73_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_74 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[31]),
        .O(\mem[62][7]_i_74_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_75 
       (.I0(finish3[15]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[47]),
        .O(\mem[62][7]_i_75_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_76 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[29]),
        .O(\mem[62][7]_i_76_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_77 
       (.I0(finish3[13]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[45]),
        .O(\mem[62][7]_i_77_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_78 
       (.I0(finish3[37]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[21]),
        .O(\mem[62][7]_i_78_n_0 ));
  LUT6 #(
    .INIT(64'hAABAFFBFAA8A0080)) 
    \mem[62][7]_i_79 
       (.I0(finish3[48]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[25]),
        .O(\mem[62][7]_i_79_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \mem[62][7]_i_8 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(sel0__0),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(\q_dst_reg_n_0_[4] ),
        .O(\mem[62][7]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFEFAAEA0020AA2A)) 
    \mem[62][7]_i_80 
       (.I0(finish3[9]),
        .I1(shq0[5]),
        .I2(\phase_reg[1]_rep_n_0 ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\shq1_reg_n_0_[5] ),
        .I5(finish3[41]),
        .O(\mem[62][7]_i_80_n_0 ));
  LUT5 #(
    .INIT(32'hF0BBF088)) 
    \mem[62][7]_i_81 
       (.I0(finish3[33]),
        .I1(\mem[62][7]_i_53_n_0 ),
        .I2(finish3[48]),
        .I3(\mem[62][7]_i_52_n_0 ),
        .I4(finish3[17]),
        .O(\mem[62][7]_i_81_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_82 
       (.I0(\mem_reg[51]_11 [7]),
        .I1(\mem_reg[50]_12 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[49]_13 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[48]_14 [7]),
        .O(\mem[62][7]_i_82_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_83 
       (.I0(\mem_reg[55]_7 [7]),
        .I1(\mem_reg[54]_8 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[53]_9 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[52]_10 [7]),
        .O(\mem[62][7]_i_83_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_84 
       (.I0(\mem_reg[59]_3 [7]),
        .I1(\mem_reg[58]_4 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[57]_5 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[56]_6 [7]),
        .O(\mem[62][7]_i_84_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_85 
       (.I0(\mem_reg[63]_69 [7]),
        .I1(\mem_reg[62]_0 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[61]_1 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[60]_2 [7]),
        .O(\mem[62][7]_i_85_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_86 
       (.I0(\mem_reg[35]_27 [7]),
        .I1(\mem_reg[34]_28 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[33]_29 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[32]_30 [7]),
        .O(\mem[62][7]_i_86_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_87 
       (.I0(\mem_reg[39]_23 [7]),
        .I1(\mem_reg[38]_24 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[37]_25 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[36]_26 [7]),
        .O(\mem[62][7]_i_87_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_88 
       (.I0(\mem_reg[43]_19 [7]),
        .I1(\mem_reg[42]_20 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[41]_21 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[40]_22 [7]),
        .O(\mem[62][7]_i_88_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_89 
       (.I0(\mem_reg[47]_15 [7]),
        .I1(\mem_reg[46]_16 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[45]_17 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[44]_18 [7]),
        .O(\mem[62][7]_i_89_n_0 ));
  LUT6 #(
    .INIT(64'hF77F7F7FFFFFFFFF)) 
    \mem[62][7]_i_9 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[2] ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\q_dst_reg_n_0_[1] ),
        .I5(\q_dst_reg_n_0_[3] ),
        .O(\mem[62][7]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_90 
       (.I0(\mem_reg[19]_43 [7]),
        .I1(\mem_reg[18]_44 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[17]_45 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[16]_46 [7]),
        .O(\mem[62][7]_i_90_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_91 
       (.I0(\mem_reg[23]_39 [7]),
        .I1(\mem_reg[22]_40 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[21]_41 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[20]_42 [7]),
        .O(\mem[62][7]_i_91_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_92 
       (.I0(\mem_reg[27]_35 [7]),
        .I1(\mem_reg[26]_36 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[25]_37 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[24]_38 [7]),
        .O(\mem[62][7]_i_92_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_93 
       (.I0(\mem_reg[31]_31 [7]),
        .I1(\mem_reg[30]_32 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[29]_33 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[28]_34 [7]),
        .O(\mem[62][7]_i_93_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_94 
       (.I0(\mem_reg[3]_59 [7]),
        .I1(\mem_reg[2]_60 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[1]_61 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[0]_62 [7]),
        .O(\mem[62][7]_i_94_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_95 
       (.I0(\mem_reg[7]_55 [7]),
        .I1(\mem_reg[6]_56 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[5]_57 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[4]_58 [7]),
        .O(\mem[62][7]_i_95_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_96 
       (.I0(\mem_reg[11]_51 [7]),
        .I1(\mem_reg[10]_52 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[9]_53 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[8]_54 [7]),
        .O(\mem[62][7]_i_96_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \mem[62][7]_i_97 
       (.I0(\mem_reg[15]_47 [7]),
        .I1(\mem_reg[14]_48 [7]),
        .I2(\ptr_reg[1]_rep_n_0 ),
        .I3(\mem_reg[13]_49 [7]),
        .I4(ptr[0]),
        .I5(\mem_reg[12]_50 [7]),
        .O(\mem[62][7]_i_97_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \mem[62][7]_i_99 
       (.I0(\mem[62][7]_i_148_n_0 ),
        .I1(\mem[62][7]_i_149_n_0 ),
        .O(\mem[62][7]_i_99_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[63][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[63][7]_i_2_n_0 ),
        .I2(\mem_reg[63]_69 [0]),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[63][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[63][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[63][7]_i_2_n_0 ),
        .I2(\mem_reg[63]_69 [1]),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[63][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[63][2]_i_1 
       (.I0(\mem_reg[63]_69 [2]),
        .I1(\mem[63][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[63][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[63][3]_i_1 
       (.I0(\mem_reg[63]_69 [3]),
        .I1(\mem[63][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[63][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[63][4]_i_1 
       (.I0(\mem[63][7]_i_2_n_0 ),
        .I1(\mem_reg[63]_69 [4]),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[63][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[63][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[63][7]_i_2_n_0 ),
        .I2(\mem_reg[63]_69 [5]),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[63][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[63][6]_i_1 
       (.I0(\mem[63][7]_i_2_n_0 ),
        .I1(\mem_reg[63]_69 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[63][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[63][7]_i_1 
       (.I0(\mem_reg[63]_69 [7]),
        .I1(\mem[63][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[63][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[63][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \mem[63][7]_i_2 
       (.I0(\ptr_reg[1]_rep_n_0 ),
        .I1(ptr[0]),
        .I2(ptr[2]),
        .I3(ptr[3]),
        .I4(sel0),
        .I5(ptr[4]),
        .O(\mem[63][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hBFFF0000BFFFBFFF)) 
    \mem[63][7]_i_3 
       (.I0(\mem[60][7]_i_6_n_0 ),
        .I1(sel0__0),
        .I2(\mem[15][7]_i_5_n_0 ),
        .I3(\mem[51][7]_i_5_n_0 ),
        .I4(\mem[62][7]_i_8_n_0 ),
        .I5(\mem[51][7]_i_8_n_0 ),
        .O(\mem[63][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[6][0]_i_1 
       (.I0(\mem_reg[6]_56 [0]),
        .I1(\mem[6][7]_i_2_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[6][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[6][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[6][7]_i_2_n_0 ),
        .I2(\mem_reg[6]_56 [1]),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[6][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[6][2]_i_1 
       (.I0(\mem[6][7]_i_2_n_0 ),
        .I1(\mem_reg[6]_56 [2]),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[6][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h4EFF4E00)) 
    \mem[6][3]_i_1 
       (.I0(\mem[6][7]_i_2_n_0 ),
        .I1(\mem_reg[6]_56 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[6][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[6][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[6][7]_i_2_n_0 ),
        .I2(\mem_reg[6]_56 [4]),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[6][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[6][5]_i_1 
       (.I0(\mem_reg[6]_56 [5]),
        .I1(\mem[6][7]_i_2_n_0 ),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[6][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[6][6]_i_1 
       (.I0(\mem_reg[6]_56 [6]),
        .I1(\mem[6][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[6][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[6][7]_i_1 
       (.I0(\mem_reg[6]_56 [7]),
        .I1(\mem[6][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[6][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[6][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000040000)) 
    \mem[6][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[2]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[0]),
        .O(\mem[6][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000EFFFEFFFEFFF)) 
    \mem[6][7]_i_3 
       (.I0(\q_dst_reg_n_0_[3] ),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\mem[22][7]_i_6_n_0 ),
        .I3(\mem[14][7]_i_4_n_0 ),
        .I4(\mem[30][7]_i_5_n_0 ),
        .I5(\mem[39][7]_i_6_n_0 ),
        .O(\mem[6][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[7][0]_i_1 
       (.I0(\mem[62][0]_i_3_n_0 ),
        .I1(\mem[7][7]_i_3_n_0 ),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[7][7]_i_2_n_0 ),
        .I4(\mem_reg[7]_55 [0]),
        .O(\mem[7][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[7][1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\mem[7][7]_i_3_n_0 ),
        .I2(\mem[62][1]_i_2_n_0 ),
        .I3(\mem[7][7]_i_2_n_0 ),
        .I4(\mem_reg[7]_55 [1]),
        .O(\mem[7][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[7][2]_i_1 
       (.I0(\mem[62][2]_i_3_n_0 ),
        .I1(\mem[7][7]_i_3_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[7][7]_i_2_n_0 ),
        .I4(\mem_reg[7]_55 [2]),
        .O(\mem[7][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF4E004E)) 
    \mem[7][3]_i_1 
       (.I0(\mem[7][7]_i_2_n_0 ),
        .I1(\mem_reg[7]_55 [3]),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[7][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[7][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \mem[7][4]_i_1 
       (.I0(\mem[62][4]_i_3_n_0 ),
        .I1(\mem[7][7]_i_3_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[7][7]_i_2_n_0 ),
        .I4(\mem_reg[7]_55 [4]),
        .O(\mem[7][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    \mem[7][5]_i_1 
       (.I0(\mem[7][7]_i_2_n_0 ),
        .I1(\mem_reg[7]_55 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[7][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[7][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFFE400E4)) 
    \mem[7][6]_i_1 
       (.I0(\mem[7][7]_i_2_n_0 ),
        .I1(\mem_reg[7]_55 [6]),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[7][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[7][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFF00E4E4)) 
    \mem[7][7]_i_1 
       (.I0(\mem[7][7]_i_2_n_0 ),
        .I1(\mem_reg[7]_55 [7]),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[62][7]_i_5_n_0 ),
        .I4(\mem[7][7]_i_3_n_0 ),
        .O(\mem[7][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0004000000000000)) 
    \mem[7][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[7][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0404040404040455)) 
    \mem[7][7]_i_3 
       (.I0(\mem[7][7]_i_4_n_0 ),
        .I1(\mem[39][7]_i_6_n_0 ),
        .I2(\mem[31][7]_i_6_n_0 ),
        .I3(\mem[31][7]_i_4_n_0 ),
        .I4(\q_dst_reg_n_0_[3] ),
        .I5(\q_dst_reg_n_0_[4] ),
        .O(\mem[7][7]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \mem[7][7]_i_4 
       (.I0(\q_dst_reg_n_0_[2] ),
        .I1(\q_dst_reg_n_0_[1] ),
        .O(\mem[7][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[8][0]_i_1 
       (.I0(\mem[62][0]_i_2_n_0 ),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem_reg[8]_54 [0]),
        .I3(\mem[8][4]_i_2_n_0 ),
        .I4(\mem[8][7]_i_3_n_0 ),
        .I5(\mem[62][0]_i_3_n_0 ),
        .O(\mem[8][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[8][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem_reg[8]_54 [1]),
        .I3(\mem[8][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[8][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[8][2]_i_1 
       (.I0(\mem_reg[8]_54 [2]),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[8][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[8][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[8][3]_i_1 
       (.I0(\mem_reg[8]_54 [3]),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[8][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[8][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hB800FFFFB800B800)) 
    \mem[8][4]_i_1 
       (.I0(\mem[62][4]_i_2_n_0 ),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem_reg[8]_54 [4]),
        .I3(\mem[8][4]_i_2_n_0 ),
        .I4(\mem[8][7]_i_3_n_0 ),
        .I5(\mem[62][4]_i_3_n_0 ),
        .O(\mem[8][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF700F7F7F7F7F7F7)) 
    \mem[8][4]_i_2 
       (.I0(\mem[56][7]_i_4_n_0 ),
        .I1(\mem[9][7]_i_5_n_0 ),
        .I2(\mem[8][4]_i_3_n_0 ),
        .I3(\mem[8][4]_i_4_n_0 ),
        .I4(\result0[21]_i_3_n_0 ),
        .I5(\mem[8][4]_i_5_n_0 ),
        .O(\mem[8][4]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'h7F)) 
    \mem[8][4]_i_3 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .O(\mem[8][4]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \mem[8][4]_i_4 
       (.I0(\q_dst_reg_n_0_[0] ),
        .I1(\q_dst_reg_n_0_[3] ),
        .O(\mem[8][4]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \mem[8][4]_i_5 
       (.I0(\q_dst_reg_n_0_[1] ),
        .I1(\q_dst_reg_n_0_[2] ),
        .I2(\q_dst_reg_n_0_[4] ),
        .I3(sel0__0),
        .O(\mem[8][4]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[8][5]_i_1 
       (.I0(\mem[8][7]_i_2_n_0 ),
        .I1(\mem_reg[8]_54 [5]),
        .I2(\mem[62][5]_i_2_n_0 ),
        .I3(\mem[8][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[8][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[8][6]_i_1 
       (.I0(\mem_reg[8]_54 [6]),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[8][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[8][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[8][7]_i_1 
       (.I0(\mem_reg[8]_54 [7]),
        .I1(\mem[8][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[8][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[8][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000100)) 
    \mem[8][7]_i_2 
       (.I0(ptr[0]),
        .I1(sel0),
        .I2(ptr[4]),
        .I3(ptr[3]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[8][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0FBBFFBBFFBBFFBB)) 
    \mem[8][7]_i_3 
       (.I0(\mem[9][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\result1[21]_i_3_n_0 ),
        .I3(\q_dst_reg_n_0_[0] ),
        .I4(\mem[56][7]_i_4_n_0 ),
        .I5(\mem[9][7]_i_5_n_0 ),
        .O(\mem[8][7]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hE4FFE400)) 
    \mem[9][0]_i_1 
       (.I0(\mem[9][7]_i_2_n_0 ),
        .I1(\mem_reg[9]_53 [0]),
        .I2(\mem[62][0]_i_2_n_0 ),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][0]_i_3_n_0 ),
        .O(\mem[9][0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[9][1]_i_1 
       (.I0(\mem[62][1]_i_2_n_0 ),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem_reg[9]_53 [1]),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][1]_i_3_n_0 ),
        .O(\mem[9][1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[9][2]_i_1 
       (.I0(\mem_reg[9]_53 [2]),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem[62][2]_i_2_n_0 ),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][2]_i_3_n_0 ),
        .O(\mem[9][2]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2EFF2E00)) 
    \mem[9][3]_i_1 
       (.I0(\mem_reg[9]_53 [3]),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem[62][3]_i_2_n_0 ),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][3]_i_3_n_0 ),
        .O(\mem[9][3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[9][4]_i_1 
       (.I0(\mem_reg[9]_53 [4]),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem[62][4]_i_2_n_0 ),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][4]_i_3_n_0 ),
        .O(\mem[9][4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \mem[9][5]_i_1 
       (.I0(\mem[62][5]_i_2_n_0 ),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem_reg[9]_53 [5]),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][5]_i_3_n_0 ),
        .O(\mem[9][5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[9][6]_i_1 
       (.I0(\mem_reg[9]_53 [6]),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem[62][6]_i_2_n_0 ),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][6]_i_3_n_0 ),
        .O(\mem[9][6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \mem[9][7]_i_1 
       (.I0(\mem_reg[9]_53 [7]),
        .I1(\mem[9][7]_i_2_n_0 ),
        .I2(\mem[62][7]_i_3_n_0 ),
        .I3(\mem[9][7]_i_3_n_0 ),
        .I4(\mem[62][7]_i_5_n_0 ),
        .O(\mem[9][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000008)) 
    \mem[9][7]_i_2 
       (.I0(ptr[3]),
        .I1(ptr[0]),
        .I2(sel0),
        .I3(ptr[4]),
        .I4(\ptr_reg[1]_rep_n_0 ),
        .I5(ptr[2]),
        .O(\mem[9][7]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hB3BFBFBFBFBFBFBF)) 
    \mem[9][7]_i_3 
       (.I0(\mem[9][7]_i_4_n_0 ),
        .I1(\q_dst_reg_n_0_[3] ),
        .I2(\q_dst_reg_n_0_[0] ),
        .I3(\phase_reg[0]_rep__0_n_0 ),
        .I4(\phase_reg[1]_rep__0_n_0 ),
        .I5(\mem[9][7]_i_5_n_0 ),
        .O(\mem[9][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFB)) 
    \mem[9][7]_i_4 
       (.I0(\phase_reg[0]_rep_n_0 ),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(sel0__0),
        .I3(\q_dst_reg_n_0_[4] ),
        .I4(\q_dst_reg_n_0_[2] ),
        .I5(\q_dst_reg_n_0_[1] ),
        .O(\mem[9][7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h4100000000000011)) 
    \mem[9][7]_i_5 
       (.I0(sel0__0),
        .I1(\q_dst_reg_n_0_[4] ),
        .I2(\q_dst_reg_n_0_[3] ),
        .I3(\q_dst_reg_n_0_[1] ),
        .I4(\q_dst_reg_n_0_[0] ),
        .I5(\q_dst_reg_n_0_[2] ),
        .O(\mem[9][7]_i_5_n_0 ));
  FDRE \mem_reg[0][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][0]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [0]),
        .R(1'b0));
  FDRE \mem_reg[0][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][1]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [1]),
        .R(1'b0));
  FDRE \mem_reg[0][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][2]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [2]),
        .R(1'b0));
  FDRE \mem_reg[0][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][3]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [3]),
        .R(1'b0));
  FDRE \mem_reg[0][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][4]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [4]),
        .R(1'b0));
  FDRE \mem_reg[0][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][5]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [5]),
        .R(1'b0));
  FDRE \mem_reg[0][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][6]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [6]),
        .R(1'b0));
  FDRE \mem_reg[0][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[0][7]_i_1_n_0 ),
        .Q(\mem_reg[0]_62 [7]),
        .R(1'b0));
  FDRE \mem_reg[10][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][0]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [0]),
        .R(1'b0));
  FDRE \mem_reg[10][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][1]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [1]),
        .R(1'b0));
  FDRE \mem_reg[10][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][2]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [2]),
        .R(1'b0));
  FDRE \mem_reg[10][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][3]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [3]),
        .R(1'b0));
  FDRE \mem_reg[10][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][4]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [4]),
        .R(1'b0));
  FDRE \mem_reg[10][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][5]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [5]),
        .R(1'b0));
  FDRE \mem_reg[10][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][6]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [6]),
        .R(1'b0));
  FDRE \mem_reg[10][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[10][7]_i_1_n_0 ),
        .Q(\mem_reg[10]_52 [7]),
        .R(1'b0));
  FDRE \mem_reg[11][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][0]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [0]),
        .R(1'b0));
  FDRE \mem_reg[11][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][1]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [1]),
        .R(1'b0));
  FDRE \mem_reg[11][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][2]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [2]),
        .R(1'b0));
  FDRE \mem_reg[11][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][3]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [3]),
        .R(1'b0));
  FDRE \mem_reg[11][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][4]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [4]),
        .R(1'b0));
  FDRE \mem_reg[11][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][5]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [5]),
        .R(1'b0));
  FDRE \mem_reg[11][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][6]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [6]),
        .R(1'b0));
  FDRE \mem_reg[11][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[11][7]_i_1_n_0 ),
        .Q(\mem_reg[11]_51 [7]),
        .R(1'b0));
  FDRE \mem_reg[12][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][0]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [0]),
        .R(1'b0));
  FDRE \mem_reg[12][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][1]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [1]),
        .R(1'b0));
  FDRE \mem_reg[12][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][2]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [2]),
        .R(1'b0));
  FDRE \mem_reg[12][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][3]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [3]),
        .R(1'b0));
  FDRE \mem_reg[12][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][4]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [4]),
        .R(1'b0));
  FDRE \mem_reg[12][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][5]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [5]),
        .R(1'b0));
  FDRE \mem_reg[12][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][6]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [6]),
        .R(1'b0));
  FDRE \mem_reg[12][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[12][7]_i_1_n_0 ),
        .Q(\mem_reg[12]_50 [7]),
        .R(1'b0));
  FDRE \mem_reg[13][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][0]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [0]),
        .R(1'b0));
  FDRE \mem_reg[13][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][1]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [1]),
        .R(1'b0));
  FDRE \mem_reg[13][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][2]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [2]),
        .R(1'b0));
  FDRE \mem_reg[13][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][3]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [3]),
        .R(1'b0));
  FDRE \mem_reg[13][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][4]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [4]),
        .R(1'b0));
  FDRE \mem_reg[13][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][5]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [5]),
        .R(1'b0));
  FDRE \mem_reg[13][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][6]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [6]),
        .R(1'b0));
  FDRE \mem_reg[13][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[13][7]_i_1_n_0 ),
        .Q(\mem_reg[13]_49 [7]),
        .R(1'b0));
  FDRE \mem_reg[14][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][0]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [0]),
        .R(1'b0));
  FDRE \mem_reg[14][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][1]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [1]),
        .R(1'b0));
  FDRE \mem_reg[14][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][2]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [2]),
        .R(1'b0));
  FDRE \mem_reg[14][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][3]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [3]),
        .R(1'b0));
  FDRE \mem_reg[14][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][4]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [4]),
        .R(1'b0));
  FDRE \mem_reg[14][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][5]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [5]),
        .R(1'b0));
  FDRE \mem_reg[14][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][6]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [6]),
        .R(1'b0));
  FDRE \mem_reg[14][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[14][7]_i_1_n_0 ),
        .Q(\mem_reg[14]_48 [7]),
        .R(1'b0));
  FDRE \mem_reg[15][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][0]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [0]),
        .R(1'b0));
  FDRE \mem_reg[15][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][1]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [1]),
        .R(1'b0));
  FDRE \mem_reg[15][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][2]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [2]),
        .R(1'b0));
  FDRE \mem_reg[15][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][3]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [3]),
        .R(1'b0));
  FDRE \mem_reg[15][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][4]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [4]),
        .R(1'b0));
  FDRE \mem_reg[15][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][5]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [5]),
        .R(1'b0));
  FDRE \mem_reg[15][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][6]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [6]),
        .R(1'b0));
  FDRE \mem_reg[15][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[15][7]_i_1_n_0 ),
        .Q(\mem_reg[15]_47 [7]),
        .R(1'b0));
  FDRE \mem_reg[16][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][0]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [0]),
        .R(1'b0));
  FDRE \mem_reg[16][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][1]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [1]),
        .R(1'b0));
  FDRE \mem_reg[16][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][2]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [2]),
        .R(1'b0));
  FDRE \mem_reg[16][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][3]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [3]),
        .R(1'b0));
  FDRE \mem_reg[16][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][4]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [4]),
        .R(1'b0));
  FDRE \mem_reg[16][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][5]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [5]),
        .R(1'b0));
  FDRE \mem_reg[16][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][6]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [6]),
        .R(1'b0));
  FDRE \mem_reg[16][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[16][7]_i_1_n_0 ),
        .Q(\mem_reg[16]_46 [7]),
        .R(1'b0));
  FDRE \mem_reg[17][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][0]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [0]),
        .R(1'b0));
  FDRE \mem_reg[17][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][1]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [1]),
        .R(1'b0));
  FDRE \mem_reg[17][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][2]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [2]),
        .R(1'b0));
  FDRE \mem_reg[17][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][3]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [3]),
        .R(1'b0));
  FDRE \mem_reg[17][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][4]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [4]),
        .R(1'b0));
  FDRE \mem_reg[17][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][5]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [5]),
        .R(1'b0));
  FDRE \mem_reg[17][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][6]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [6]),
        .R(1'b0));
  FDRE \mem_reg[17][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[17][7]_i_1_n_0 ),
        .Q(\mem_reg[17]_45 [7]),
        .R(1'b0));
  FDRE \mem_reg[18][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][0]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [0]),
        .R(1'b0));
  FDRE \mem_reg[18][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][1]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [1]),
        .R(1'b0));
  FDRE \mem_reg[18][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][2]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [2]),
        .R(1'b0));
  FDRE \mem_reg[18][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][3]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [3]),
        .R(1'b0));
  FDRE \mem_reg[18][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][4]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [4]),
        .R(1'b0));
  FDRE \mem_reg[18][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][5]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [5]),
        .R(1'b0));
  FDRE \mem_reg[18][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][6]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [6]),
        .R(1'b0));
  FDRE \mem_reg[18][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[18][7]_i_1_n_0 ),
        .Q(\mem_reg[18]_44 [7]),
        .R(1'b0));
  FDRE \mem_reg[19][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][0]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [0]),
        .R(1'b0));
  FDRE \mem_reg[19][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][1]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [1]),
        .R(1'b0));
  FDRE \mem_reg[19][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][2]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [2]),
        .R(1'b0));
  FDRE \mem_reg[19][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][3]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [3]),
        .R(1'b0));
  FDRE \mem_reg[19][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][4]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [4]),
        .R(1'b0));
  FDRE \mem_reg[19][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][5]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [5]),
        .R(1'b0));
  FDRE \mem_reg[19][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][6]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [6]),
        .R(1'b0));
  FDRE \mem_reg[19][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[19][7]_i_1_n_0 ),
        .Q(\mem_reg[19]_43 [7]),
        .R(1'b0));
  FDRE \mem_reg[1][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][0]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [0]),
        .R(1'b0));
  FDRE \mem_reg[1][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][1]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [1]),
        .R(1'b0));
  FDRE \mem_reg[1][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][2]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [2]),
        .R(1'b0));
  FDRE \mem_reg[1][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][3]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [3]),
        .R(1'b0));
  FDRE \mem_reg[1][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][4]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [4]),
        .R(1'b0));
  FDRE \mem_reg[1][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][5]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [5]),
        .R(1'b0));
  FDRE \mem_reg[1][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][6]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [6]),
        .R(1'b0));
  FDRE \mem_reg[1][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[1][7]_i_1_n_0 ),
        .Q(\mem_reg[1]_61 [7]),
        .R(1'b0));
  FDRE \mem_reg[20][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][0]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [0]),
        .R(1'b0));
  FDRE \mem_reg[20][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][1]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [1]),
        .R(1'b0));
  FDRE \mem_reg[20][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][2]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [2]),
        .R(1'b0));
  FDRE \mem_reg[20][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][3]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [3]),
        .R(1'b0));
  FDRE \mem_reg[20][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][4]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [4]),
        .R(1'b0));
  FDRE \mem_reg[20][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][5]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [5]),
        .R(1'b0));
  FDRE \mem_reg[20][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][6]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [6]),
        .R(1'b0));
  FDRE \mem_reg[20][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[20][7]_i_1_n_0 ),
        .Q(\mem_reg[20]_42 [7]),
        .R(1'b0));
  FDRE \mem_reg[21][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][0]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [0]),
        .R(1'b0));
  FDRE \mem_reg[21][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][1]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [1]),
        .R(1'b0));
  FDRE \mem_reg[21][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][2]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [2]),
        .R(1'b0));
  FDRE \mem_reg[21][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][3]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [3]),
        .R(1'b0));
  FDRE \mem_reg[21][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][4]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [4]),
        .R(1'b0));
  FDRE \mem_reg[21][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][5]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [5]),
        .R(1'b0));
  FDRE \mem_reg[21][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][6]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [6]),
        .R(1'b0));
  FDRE \mem_reg[21][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[21][7]_i_1_n_0 ),
        .Q(\mem_reg[21]_41 [7]),
        .R(1'b0));
  FDRE \mem_reg[22][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][0]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [0]),
        .R(1'b0));
  FDRE \mem_reg[22][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][1]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [1]),
        .R(1'b0));
  FDRE \mem_reg[22][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][2]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [2]),
        .R(1'b0));
  FDRE \mem_reg[22][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][3]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [3]),
        .R(1'b0));
  FDRE \mem_reg[22][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][4]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [4]),
        .R(1'b0));
  FDRE \mem_reg[22][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][5]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [5]),
        .R(1'b0));
  FDRE \mem_reg[22][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][6]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [6]),
        .R(1'b0));
  FDRE \mem_reg[22][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[22][7]_i_1_n_0 ),
        .Q(\mem_reg[22]_40 [7]),
        .R(1'b0));
  FDRE \mem_reg[23][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][0]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [0]),
        .R(1'b0));
  FDRE \mem_reg[23][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][1]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [1]),
        .R(1'b0));
  FDRE \mem_reg[23][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][2]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [2]),
        .R(1'b0));
  FDRE \mem_reg[23][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][3]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [3]),
        .R(1'b0));
  FDRE \mem_reg[23][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][4]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [4]),
        .R(1'b0));
  FDRE \mem_reg[23][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][5]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [5]),
        .R(1'b0));
  FDRE \mem_reg[23][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][6]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [6]),
        .R(1'b0));
  FDRE \mem_reg[23][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[23][7]_i_1_n_0 ),
        .Q(\mem_reg[23]_39 [7]),
        .R(1'b0));
  FDRE \mem_reg[24][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][0]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [0]),
        .R(1'b0));
  FDRE \mem_reg[24][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][1]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [1]),
        .R(1'b0));
  FDRE \mem_reg[24][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][2]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [2]),
        .R(1'b0));
  FDRE \mem_reg[24][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][3]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [3]),
        .R(1'b0));
  FDRE \mem_reg[24][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][4]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [4]),
        .R(1'b0));
  FDRE \mem_reg[24][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][5]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [5]),
        .R(1'b0));
  FDRE \mem_reg[24][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][6]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [6]),
        .R(1'b0));
  FDRE \mem_reg[24][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[24][7]_i_1_n_0 ),
        .Q(\mem_reg[24]_38 [7]),
        .R(1'b0));
  FDRE \mem_reg[25][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][0]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [0]),
        .R(1'b0));
  FDRE \mem_reg[25][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][1]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [1]),
        .R(1'b0));
  FDRE \mem_reg[25][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][2]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [2]),
        .R(1'b0));
  FDRE \mem_reg[25][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][3]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [3]),
        .R(1'b0));
  FDRE \mem_reg[25][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][4]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [4]),
        .R(1'b0));
  FDRE \mem_reg[25][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][5]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [5]),
        .R(1'b0));
  FDRE \mem_reg[25][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][6]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [6]),
        .R(1'b0));
  FDRE \mem_reg[25][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[25][7]_i_1_n_0 ),
        .Q(\mem_reg[25]_37 [7]),
        .R(1'b0));
  FDRE \mem_reg[26][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][0]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [0]),
        .R(1'b0));
  FDRE \mem_reg[26][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][1]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [1]),
        .R(1'b0));
  FDRE \mem_reg[26][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][2]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [2]),
        .R(1'b0));
  FDRE \mem_reg[26][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][3]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [3]),
        .R(1'b0));
  FDRE \mem_reg[26][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][4]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [4]),
        .R(1'b0));
  FDRE \mem_reg[26][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][5]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [5]),
        .R(1'b0));
  FDRE \mem_reg[26][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][6]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [6]),
        .R(1'b0));
  FDRE \mem_reg[26][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[26][7]_i_1_n_0 ),
        .Q(\mem_reg[26]_36 [7]),
        .R(1'b0));
  FDRE \mem_reg[27][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][0]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [0]),
        .R(1'b0));
  FDRE \mem_reg[27][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][1]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [1]),
        .R(1'b0));
  FDRE \mem_reg[27][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][2]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [2]),
        .R(1'b0));
  FDRE \mem_reg[27][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][3]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [3]),
        .R(1'b0));
  FDRE \mem_reg[27][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][4]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [4]),
        .R(1'b0));
  FDRE \mem_reg[27][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][5]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [5]),
        .R(1'b0));
  FDRE \mem_reg[27][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][6]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [6]),
        .R(1'b0));
  FDRE \mem_reg[27][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[27][7]_i_1_n_0 ),
        .Q(\mem_reg[27]_35 [7]),
        .R(1'b0));
  FDRE \mem_reg[28][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][0]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [0]),
        .R(1'b0));
  FDRE \mem_reg[28][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][1]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [1]),
        .R(1'b0));
  FDRE \mem_reg[28][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][2]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [2]),
        .R(1'b0));
  FDRE \mem_reg[28][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][3]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [3]),
        .R(1'b0));
  FDRE \mem_reg[28][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][4]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [4]),
        .R(1'b0));
  FDRE \mem_reg[28][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][5]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [5]),
        .R(1'b0));
  FDRE \mem_reg[28][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][6]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [6]),
        .R(1'b0));
  FDRE \mem_reg[28][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[28][7]_i_1_n_0 ),
        .Q(\mem_reg[28]_34 [7]),
        .R(1'b0));
  FDRE \mem_reg[29][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][0]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [0]),
        .R(1'b0));
  FDRE \mem_reg[29][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][1]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [1]),
        .R(1'b0));
  FDRE \mem_reg[29][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][2]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [2]),
        .R(1'b0));
  FDRE \mem_reg[29][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][3]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [3]),
        .R(1'b0));
  FDRE \mem_reg[29][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][4]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [4]),
        .R(1'b0));
  FDRE \mem_reg[29][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][5]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [5]),
        .R(1'b0));
  FDRE \mem_reg[29][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][6]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [6]),
        .R(1'b0));
  FDRE \mem_reg[29][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[29][7]_i_1_n_0 ),
        .Q(\mem_reg[29]_33 [7]),
        .R(1'b0));
  FDRE \mem_reg[2][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][0]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [0]),
        .R(1'b0));
  FDRE \mem_reg[2][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][1]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [1]),
        .R(1'b0));
  FDRE \mem_reg[2][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][2]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [2]),
        .R(1'b0));
  FDRE \mem_reg[2][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][3]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [3]),
        .R(1'b0));
  FDRE \mem_reg[2][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][4]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [4]),
        .R(1'b0));
  FDRE \mem_reg[2][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][5]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [5]),
        .R(1'b0));
  FDRE \mem_reg[2][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][6]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [6]),
        .R(1'b0));
  FDRE \mem_reg[2][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[2][7]_i_1_n_0 ),
        .Q(\mem_reg[2]_60 [7]),
        .R(1'b0));
  FDRE \mem_reg[30][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][0]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [0]),
        .R(1'b0));
  FDRE \mem_reg[30][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][1]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [1]),
        .R(1'b0));
  FDRE \mem_reg[30][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][2]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [2]),
        .R(1'b0));
  FDRE \mem_reg[30][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][3]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [3]),
        .R(1'b0));
  FDRE \mem_reg[30][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][4]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [4]),
        .R(1'b0));
  FDRE \mem_reg[30][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][5]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [5]),
        .R(1'b0));
  FDRE \mem_reg[30][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][6]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [6]),
        .R(1'b0));
  FDRE \mem_reg[30][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[30][7]_i_1_n_0 ),
        .Q(\mem_reg[30]_32 [7]),
        .R(1'b0));
  FDRE \mem_reg[31][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][0]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [0]),
        .R(1'b0));
  FDRE \mem_reg[31][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][1]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [1]),
        .R(1'b0));
  FDRE \mem_reg[31][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][2]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [2]),
        .R(1'b0));
  FDRE \mem_reg[31][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][3]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [3]),
        .R(1'b0));
  FDRE \mem_reg[31][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][4]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [4]),
        .R(1'b0));
  FDRE \mem_reg[31][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][5]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [5]),
        .R(1'b0));
  FDRE \mem_reg[31][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][6]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [6]),
        .R(1'b0));
  FDRE \mem_reg[31][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[31][7]_i_1_n_0 ),
        .Q(\mem_reg[31]_31 [7]),
        .R(1'b0));
  FDRE \mem_reg[32][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][0]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [0]),
        .R(1'b0));
  FDRE \mem_reg[32][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][1]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [1]),
        .R(1'b0));
  FDRE \mem_reg[32][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][2]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [2]),
        .R(1'b0));
  FDRE \mem_reg[32][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][3]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [3]),
        .R(1'b0));
  FDRE \mem_reg[32][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][4]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [4]),
        .R(1'b0));
  FDRE \mem_reg[32][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][5]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [5]),
        .R(1'b0));
  FDRE \mem_reg[32][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][6]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [6]),
        .R(1'b0));
  FDRE \mem_reg[32][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[32][7]_i_1_n_0 ),
        .Q(\mem_reg[32]_30 [7]),
        .R(1'b0));
  FDRE \mem_reg[33][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][0]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [0]),
        .R(1'b0));
  FDRE \mem_reg[33][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][1]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [1]),
        .R(1'b0));
  FDRE \mem_reg[33][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][2]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [2]),
        .R(1'b0));
  FDRE \mem_reg[33][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][3]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [3]),
        .R(1'b0));
  FDRE \mem_reg[33][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][4]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [4]),
        .R(1'b0));
  FDRE \mem_reg[33][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][5]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [5]),
        .R(1'b0));
  FDRE \mem_reg[33][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][6]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [6]),
        .R(1'b0));
  FDRE \mem_reg[33][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[33][7]_i_1_n_0 ),
        .Q(\mem_reg[33]_29 [7]),
        .R(1'b0));
  FDRE \mem_reg[34][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][0]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [0]),
        .R(1'b0));
  FDRE \mem_reg[34][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][1]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [1]),
        .R(1'b0));
  FDRE \mem_reg[34][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][2]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [2]),
        .R(1'b0));
  FDRE \mem_reg[34][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][3]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [3]),
        .R(1'b0));
  FDRE \mem_reg[34][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][4]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [4]),
        .R(1'b0));
  FDRE \mem_reg[34][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][5]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [5]),
        .R(1'b0));
  FDRE \mem_reg[34][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][6]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [6]),
        .R(1'b0));
  FDRE \mem_reg[34][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[34][7]_i_1_n_0 ),
        .Q(\mem_reg[34]_28 [7]),
        .R(1'b0));
  FDRE \mem_reg[35][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][0]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [0]),
        .R(1'b0));
  FDRE \mem_reg[35][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][1]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [1]),
        .R(1'b0));
  FDRE \mem_reg[35][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][2]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [2]),
        .R(1'b0));
  FDRE \mem_reg[35][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][3]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [3]),
        .R(1'b0));
  FDRE \mem_reg[35][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][4]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [4]),
        .R(1'b0));
  FDRE \mem_reg[35][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][5]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [5]),
        .R(1'b0));
  FDRE \mem_reg[35][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][6]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [6]),
        .R(1'b0));
  FDRE \mem_reg[35][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[35][7]_i_1_n_0 ),
        .Q(\mem_reg[35]_27 [7]),
        .R(1'b0));
  FDRE \mem_reg[36][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][0]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [0]),
        .R(1'b0));
  FDRE \mem_reg[36][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][1]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [1]),
        .R(1'b0));
  FDRE \mem_reg[36][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][2]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [2]),
        .R(1'b0));
  FDRE \mem_reg[36][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][3]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [3]),
        .R(1'b0));
  FDRE \mem_reg[36][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][4]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [4]),
        .R(1'b0));
  FDRE \mem_reg[36][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][5]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [5]),
        .R(1'b0));
  FDRE \mem_reg[36][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][6]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [6]),
        .R(1'b0));
  FDRE \mem_reg[36][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[36][7]_i_1_n_0 ),
        .Q(\mem_reg[36]_26 [7]),
        .R(1'b0));
  FDRE \mem_reg[37][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][0]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [0]),
        .R(1'b0));
  FDRE \mem_reg[37][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][1]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [1]),
        .R(1'b0));
  FDRE \mem_reg[37][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][2]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [2]),
        .R(1'b0));
  FDRE \mem_reg[37][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][3]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [3]),
        .R(1'b0));
  FDRE \mem_reg[37][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][4]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [4]),
        .R(1'b0));
  FDRE \mem_reg[37][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][5]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [5]),
        .R(1'b0));
  FDRE \mem_reg[37][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][6]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [6]),
        .R(1'b0));
  FDRE \mem_reg[37][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[37][7]_i_1_n_0 ),
        .Q(\mem_reg[37]_25 [7]),
        .R(1'b0));
  FDRE \mem_reg[38][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][0]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [0]),
        .R(1'b0));
  FDRE \mem_reg[38][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][1]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [1]),
        .R(1'b0));
  FDRE \mem_reg[38][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][2]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [2]),
        .R(1'b0));
  FDRE \mem_reg[38][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][3]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [3]),
        .R(1'b0));
  FDRE \mem_reg[38][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][4]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [4]),
        .R(1'b0));
  FDRE \mem_reg[38][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][5]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [5]),
        .R(1'b0));
  FDRE \mem_reg[38][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][6]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [6]),
        .R(1'b0));
  FDRE \mem_reg[38][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[38][7]_i_1_n_0 ),
        .Q(\mem_reg[38]_24 [7]),
        .R(1'b0));
  FDRE \mem_reg[39][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][0]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [0]),
        .R(1'b0));
  FDRE \mem_reg[39][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][1]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [1]),
        .R(1'b0));
  FDRE \mem_reg[39][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][2]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [2]),
        .R(1'b0));
  FDRE \mem_reg[39][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][3]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [3]),
        .R(1'b0));
  FDRE \mem_reg[39][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][4]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [4]),
        .R(1'b0));
  FDRE \mem_reg[39][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][5]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [5]),
        .R(1'b0));
  FDRE \mem_reg[39][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][6]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [6]),
        .R(1'b0));
  FDRE \mem_reg[39][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[39][7]_i_1_n_0 ),
        .Q(\mem_reg[39]_23 [7]),
        .R(1'b0));
  FDRE \mem_reg[3][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][0]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [0]),
        .R(1'b0));
  FDRE \mem_reg[3][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][1]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [1]),
        .R(1'b0));
  FDRE \mem_reg[3][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][2]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [2]),
        .R(1'b0));
  FDRE \mem_reg[3][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][3]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [3]),
        .R(1'b0));
  FDRE \mem_reg[3][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][4]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [4]),
        .R(1'b0));
  FDRE \mem_reg[3][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][5]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [5]),
        .R(1'b0));
  FDRE \mem_reg[3][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][6]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [6]),
        .R(1'b0));
  FDRE \mem_reg[3][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[3][7]_i_1_n_0 ),
        .Q(\mem_reg[3]_59 [7]),
        .R(1'b0));
  FDRE \mem_reg[40][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][0]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [0]),
        .R(1'b0));
  FDRE \mem_reg[40][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][1]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [1]),
        .R(1'b0));
  FDRE \mem_reg[40][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][2]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [2]),
        .R(1'b0));
  FDRE \mem_reg[40][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][3]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [3]),
        .R(1'b0));
  FDRE \mem_reg[40][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][4]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [4]),
        .R(1'b0));
  FDRE \mem_reg[40][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][5]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [5]),
        .R(1'b0));
  FDRE \mem_reg[40][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][6]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [6]),
        .R(1'b0));
  FDRE \mem_reg[40][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[40][7]_i_1_n_0 ),
        .Q(\mem_reg[40]_22 [7]),
        .R(1'b0));
  FDRE \mem_reg[41][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][0]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [0]),
        .R(1'b0));
  FDRE \mem_reg[41][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][1]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [1]),
        .R(1'b0));
  FDRE \mem_reg[41][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][2]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [2]),
        .R(1'b0));
  FDRE \mem_reg[41][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][3]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [3]),
        .R(1'b0));
  FDRE \mem_reg[41][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][4]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [4]),
        .R(1'b0));
  FDRE \mem_reg[41][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][5]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [5]),
        .R(1'b0));
  FDRE \mem_reg[41][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][6]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [6]),
        .R(1'b0));
  FDRE \mem_reg[41][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[41][7]_i_1_n_0 ),
        .Q(\mem_reg[41]_21 [7]),
        .R(1'b0));
  FDRE \mem_reg[42][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][0]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [0]),
        .R(1'b0));
  FDRE \mem_reg[42][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][1]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [1]),
        .R(1'b0));
  FDRE \mem_reg[42][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][2]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [2]),
        .R(1'b0));
  FDRE \mem_reg[42][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][3]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [3]),
        .R(1'b0));
  FDRE \mem_reg[42][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][4]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [4]),
        .R(1'b0));
  FDRE \mem_reg[42][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][5]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [5]),
        .R(1'b0));
  FDRE \mem_reg[42][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][6]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [6]),
        .R(1'b0));
  FDRE \mem_reg[42][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[42][7]_i_1_n_0 ),
        .Q(\mem_reg[42]_20 [7]),
        .R(1'b0));
  FDRE \mem_reg[43][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][0]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [0]),
        .R(1'b0));
  FDRE \mem_reg[43][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][1]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [1]),
        .R(1'b0));
  FDRE \mem_reg[43][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][2]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [2]),
        .R(1'b0));
  FDRE \mem_reg[43][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][3]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [3]),
        .R(1'b0));
  FDRE \mem_reg[43][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][4]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [4]),
        .R(1'b0));
  FDRE \mem_reg[43][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][5]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [5]),
        .R(1'b0));
  FDRE \mem_reg[43][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][6]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [6]),
        .R(1'b0));
  FDRE \mem_reg[43][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[43][7]_i_1_n_0 ),
        .Q(\mem_reg[43]_19 [7]),
        .R(1'b0));
  FDRE \mem_reg[44][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][0]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [0]),
        .R(1'b0));
  FDRE \mem_reg[44][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][1]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [1]),
        .R(1'b0));
  FDRE \mem_reg[44][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][2]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [2]),
        .R(1'b0));
  FDRE \mem_reg[44][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][3]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [3]),
        .R(1'b0));
  FDRE \mem_reg[44][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][4]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [4]),
        .R(1'b0));
  FDRE \mem_reg[44][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][5]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [5]),
        .R(1'b0));
  FDRE \mem_reg[44][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][6]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [6]),
        .R(1'b0));
  FDRE \mem_reg[44][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[44][7]_i_1_n_0 ),
        .Q(\mem_reg[44]_18 [7]),
        .R(1'b0));
  FDRE \mem_reg[45][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][0]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [0]),
        .R(1'b0));
  FDRE \mem_reg[45][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][1]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [1]),
        .R(1'b0));
  FDRE \mem_reg[45][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][2]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [2]),
        .R(1'b0));
  FDRE \mem_reg[45][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][3]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [3]),
        .R(1'b0));
  FDRE \mem_reg[45][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][4]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [4]),
        .R(1'b0));
  FDRE \mem_reg[45][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][5]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [5]),
        .R(1'b0));
  FDRE \mem_reg[45][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][6]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [6]),
        .R(1'b0));
  FDRE \mem_reg[45][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[45][7]_i_1_n_0 ),
        .Q(\mem_reg[45]_17 [7]),
        .R(1'b0));
  FDRE \mem_reg[46][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][0]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [0]),
        .R(1'b0));
  FDRE \mem_reg[46][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][1]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [1]),
        .R(1'b0));
  FDRE \mem_reg[46][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][2]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [2]),
        .R(1'b0));
  FDRE \mem_reg[46][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][3]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [3]),
        .R(1'b0));
  FDRE \mem_reg[46][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][4]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [4]),
        .R(1'b0));
  FDRE \mem_reg[46][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][5]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [5]),
        .R(1'b0));
  FDRE \mem_reg[46][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][6]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [6]),
        .R(1'b0));
  FDRE \mem_reg[46][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[46][7]_i_1_n_0 ),
        .Q(\mem_reg[46]_16 [7]),
        .R(1'b0));
  FDRE \mem_reg[47][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][0]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [0]),
        .R(1'b0));
  FDRE \mem_reg[47][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][1]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [1]),
        .R(1'b0));
  FDRE \mem_reg[47][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][2]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [2]),
        .R(1'b0));
  FDRE \mem_reg[47][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][3]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [3]),
        .R(1'b0));
  FDRE \mem_reg[47][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][4]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [4]),
        .R(1'b0));
  FDRE \mem_reg[47][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][5]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [5]),
        .R(1'b0));
  FDRE \mem_reg[47][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][6]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [6]),
        .R(1'b0));
  FDRE \mem_reg[47][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[47][7]_i_1_n_0 ),
        .Q(\mem_reg[47]_15 [7]),
        .R(1'b0));
  FDRE \mem_reg[48][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][0]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [0]),
        .R(1'b0));
  FDRE \mem_reg[48][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][1]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [1]),
        .R(1'b0));
  FDRE \mem_reg[48][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][2]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [2]),
        .R(1'b0));
  FDRE \mem_reg[48][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][3]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [3]),
        .R(1'b0));
  FDRE \mem_reg[48][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][4]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [4]),
        .R(1'b0));
  FDRE \mem_reg[48][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][5]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [5]),
        .R(1'b0));
  FDRE \mem_reg[48][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][6]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [6]),
        .R(1'b0));
  FDRE \mem_reg[48][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[48][7]_i_1_n_0 ),
        .Q(\mem_reg[48]_14 [7]),
        .R(1'b0));
  FDRE \mem_reg[49][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][0]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [0]),
        .R(1'b0));
  FDRE \mem_reg[49][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][1]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [1]),
        .R(1'b0));
  FDRE \mem_reg[49][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][2]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [2]),
        .R(1'b0));
  FDRE \mem_reg[49][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][3]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [3]),
        .R(1'b0));
  FDRE \mem_reg[49][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][4]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [4]),
        .R(1'b0));
  FDRE \mem_reg[49][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][5]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [5]),
        .R(1'b0));
  FDRE \mem_reg[49][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][6]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [6]),
        .R(1'b0));
  FDRE \mem_reg[49][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[49][7]_i_1_n_0 ),
        .Q(\mem_reg[49]_13 [7]),
        .R(1'b0));
  FDRE \mem_reg[4][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][0]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [0]),
        .R(1'b0));
  FDRE \mem_reg[4][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][1]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [1]),
        .R(1'b0));
  FDRE \mem_reg[4][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][2]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [2]),
        .R(1'b0));
  FDRE \mem_reg[4][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][3]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [3]),
        .R(1'b0));
  FDRE \mem_reg[4][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][4]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [4]),
        .R(1'b0));
  FDRE \mem_reg[4][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][5]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [5]),
        .R(1'b0));
  FDRE \mem_reg[4][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][6]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [6]),
        .R(1'b0));
  FDRE \mem_reg[4][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[4][7]_i_1_n_0 ),
        .Q(\mem_reg[4]_58 [7]),
        .R(1'b0));
  FDRE \mem_reg[50][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][0]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [0]),
        .R(1'b0));
  FDRE \mem_reg[50][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][1]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [1]),
        .R(1'b0));
  FDRE \mem_reg[50][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][2]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [2]),
        .R(1'b0));
  FDRE \mem_reg[50][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][3]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [3]),
        .R(1'b0));
  FDRE \mem_reg[50][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][4]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [4]),
        .R(1'b0));
  FDRE \mem_reg[50][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][5]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [5]),
        .R(1'b0));
  FDRE \mem_reg[50][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][6]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [6]),
        .R(1'b0));
  FDRE \mem_reg[50][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[50][7]_i_1_n_0 ),
        .Q(\mem_reg[50]_12 [7]),
        .R(1'b0));
  FDRE \mem_reg[51][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][0]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [0]),
        .R(1'b0));
  FDRE \mem_reg[51][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][1]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [1]),
        .R(1'b0));
  FDRE \mem_reg[51][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][2]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [2]),
        .R(1'b0));
  FDRE \mem_reg[51][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][3]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [3]),
        .R(1'b0));
  FDRE \mem_reg[51][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][4]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [4]),
        .R(1'b0));
  FDRE \mem_reg[51][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][5]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [5]),
        .R(1'b0));
  FDRE \mem_reg[51][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][6]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [6]),
        .R(1'b0));
  FDRE \mem_reg[51][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[51][7]_i_1_n_0 ),
        .Q(\mem_reg[51]_11 [7]),
        .R(1'b0));
  FDRE \mem_reg[52][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][0]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [0]),
        .R(1'b0));
  FDRE \mem_reg[52][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][1]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [1]),
        .R(1'b0));
  FDRE \mem_reg[52][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][2]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [2]),
        .R(1'b0));
  FDRE \mem_reg[52][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][3]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [3]),
        .R(1'b0));
  FDRE \mem_reg[52][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][4]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [4]),
        .R(1'b0));
  FDRE \mem_reg[52][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][5]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [5]),
        .R(1'b0));
  FDRE \mem_reg[52][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][6]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [6]),
        .R(1'b0));
  FDRE \mem_reg[52][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[52][7]_i_1_n_0 ),
        .Q(\mem_reg[52]_10 [7]),
        .R(1'b0));
  FDRE \mem_reg[53][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][0]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [0]),
        .R(1'b0));
  FDRE \mem_reg[53][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][1]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [1]),
        .R(1'b0));
  FDRE \mem_reg[53][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][2]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [2]),
        .R(1'b0));
  FDRE \mem_reg[53][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][3]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [3]),
        .R(1'b0));
  FDRE \mem_reg[53][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][4]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [4]),
        .R(1'b0));
  FDRE \mem_reg[53][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][5]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [5]),
        .R(1'b0));
  FDRE \mem_reg[53][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][6]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [6]),
        .R(1'b0));
  FDRE \mem_reg[53][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[53][7]_i_1_n_0 ),
        .Q(\mem_reg[53]_9 [7]),
        .R(1'b0));
  FDRE \mem_reg[54][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][0]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [0]),
        .R(1'b0));
  FDRE \mem_reg[54][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][1]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [1]),
        .R(1'b0));
  FDRE \mem_reg[54][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][2]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [2]),
        .R(1'b0));
  FDRE \mem_reg[54][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][3]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [3]),
        .R(1'b0));
  FDRE \mem_reg[54][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][4]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [4]),
        .R(1'b0));
  FDRE \mem_reg[54][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][5]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [5]),
        .R(1'b0));
  FDRE \mem_reg[54][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][6]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [6]),
        .R(1'b0));
  FDRE \mem_reg[54][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[54][7]_i_1_n_0 ),
        .Q(\mem_reg[54]_8 [7]),
        .R(1'b0));
  FDRE \mem_reg[55][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][0]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [0]),
        .R(1'b0));
  FDRE \mem_reg[55][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][1]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [1]),
        .R(1'b0));
  FDRE \mem_reg[55][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][2]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [2]),
        .R(1'b0));
  FDRE \mem_reg[55][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][3]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [3]),
        .R(1'b0));
  FDRE \mem_reg[55][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][4]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [4]),
        .R(1'b0));
  FDRE \mem_reg[55][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][5]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [5]),
        .R(1'b0));
  FDRE \mem_reg[55][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][6]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [6]),
        .R(1'b0));
  FDRE \mem_reg[55][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[55][7]_i_1_n_0 ),
        .Q(\mem_reg[55]_7 [7]),
        .R(1'b0));
  FDRE \mem_reg[56][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][0]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [0]),
        .R(1'b0));
  FDRE \mem_reg[56][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][1]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [1]),
        .R(1'b0));
  FDRE \mem_reg[56][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][2]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [2]),
        .R(1'b0));
  FDRE \mem_reg[56][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][3]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [3]),
        .R(1'b0));
  FDRE \mem_reg[56][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][4]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [4]),
        .R(1'b0));
  FDRE \mem_reg[56][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][5]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [5]),
        .R(1'b0));
  FDRE \mem_reg[56][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][6]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [6]),
        .R(1'b0));
  FDRE \mem_reg[56][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[56][7]_i_1_n_0 ),
        .Q(\mem_reg[56]_6 [7]),
        .R(1'b0));
  FDRE \mem_reg[57][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][0]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [0]),
        .R(1'b0));
  FDRE \mem_reg[57][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][1]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [1]),
        .R(1'b0));
  FDRE \mem_reg[57][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][2]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [2]),
        .R(1'b0));
  FDRE \mem_reg[57][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][3]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [3]),
        .R(1'b0));
  FDRE \mem_reg[57][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][4]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [4]),
        .R(1'b0));
  FDRE \mem_reg[57][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][5]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [5]),
        .R(1'b0));
  FDRE \mem_reg[57][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][6]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [6]),
        .R(1'b0));
  FDRE \mem_reg[57][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[57][7]_i_1_n_0 ),
        .Q(\mem_reg[57]_5 [7]),
        .R(1'b0));
  FDRE \mem_reg[58][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][0]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [0]),
        .R(1'b0));
  FDRE \mem_reg[58][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][1]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [1]),
        .R(1'b0));
  FDRE \mem_reg[58][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][2]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [2]),
        .R(1'b0));
  FDRE \mem_reg[58][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][3]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [3]),
        .R(1'b0));
  FDRE \mem_reg[58][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][4]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [4]),
        .R(1'b0));
  FDRE \mem_reg[58][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][5]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [5]),
        .R(1'b0));
  FDRE \mem_reg[58][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][6]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [6]),
        .R(1'b0));
  FDRE \mem_reg[58][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[58][7]_i_1_n_0 ),
        .Q(\mem_reg[58]_4 [7]),
        .R(1'b0));
  FDRE \mem_reg[59][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][0]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [0]),
        .R(1'b0));
  FDRE \mem_reg[59][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][1]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [1]),
        .R(1'b0));
  FDRE \mem_reg[59][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][2]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [2]),
        .R(1'b0));
  FDRE \mem_reg[59][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][3]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [3]),
        .R(1'b0));
  FDRE \mem_reg[59][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][4]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [4]),
        .R(1'b0));
  FDRE \mem_reg[59][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][5]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [5]),
        .R(1'b0));
  FDRE \mem_reg[59][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][6]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [6]),
        .R(1'b0));
  FDRE \mem_reg[59][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[59][7]_i_1_n_0 ),
        .Q(\mem_reg[59]_3 [7]),
        .R(1'b0));
  FDRE \mem_reg[5][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][0]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [0]),
        .R(1'b0));
  FDRE \mem_reg[5][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][1]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [1]),
        .R(1'b0));
  FDRE \mem_reg[5][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][2]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [2]),
        .R(1'b0));
  FDRE \mem_reg[5][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][3]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [3]),
        .R(1'b0));
  FDRE \mem_reg[5][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][4]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [4]),
        .R(1'b0));
  FDRE \mem_reg[5][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][5]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [5]),
        .R(1'b0));
  FDRE \mem_reg[5][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][6]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [6]),
        .R(1'b0));
  FDRE \mem_reg[5][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[5][7]_i_1_n_0 ),
        .Q(\mem_reg[5]_57 [7]),
        .R(1'b0));
  FDRE \mem_reg[60][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][0]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [0]),
        .R(1'b0));
  FDRE \mem_reg[60][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][1]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [1]),
        .R(1'b0));
  FDRE \mem_reg[60][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][2]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [2]),
        .R(1'b0));
  FDRE \mem_reg[60][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][3]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [3]),
        .R(1'b0));
  FDRE \mem_reg[60][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][4]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [4]),
        .R(1'b0));
  FDRE \mem_reg[60][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][5]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [5]),
        .R(1'b0));
  FDRE \mem_reg[60][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][6]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [6]),
        .R(1'b0));
  FDRE \mem_reg[60][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[60][7]_i_1_n_0 ),
        .Q(\mem_reg[60]_2 [7]),
        .R(1'b0));
  FDRE \mem_reg[61][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][0]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [0]),
        .R(1'b0));
  FDRE \mem_reg[61][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][1]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [1]),
        .R(1'b0));
  FDRE \mem_reg[61][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][2]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [2]),
        .R(1'b0));
  FDRE \mem_reg[61][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][3]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [3]),
        .R(1'b0));
  FDRE \mem_reg[61][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][4]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [4]),
        .R(1'b0));
  FDRE \mem_reg[61][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][5]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [5]),
        .R(1'b0));
  FDRE \mem_reg[61][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][6]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [6]),
        .R(1'b0));
  FDRE \mem_reg[61][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[61][7]_i_1_n_0 ),
        .Q(\mem_reg[61]_1 [7]),
        .R(1'b0));
  FDRE \mem_reg[62][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[0]),
        .Q(\mem_reg[62]_0 [0]),
        .R(1'b0));
  MUXF7 \mem_reg[62][0]_i_20 
       (.I0(\mem[62][0]_i_28_n_0 ),
        .I1(\mem[62][0]_i_29_n_0 ),
        .O(\mem_reg[62][0]_i_20_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][0]_i_21 
       (.I0(\mem[62][0]_i_30_n_0 ),
        .I1(\mem[62][0]_i_31_n_0 ),
        .O(\mem_reg[62][0]_i_21_n_0 ),
        .S(ptr[2]));
  MUXF8 \mem_reg[62][0]_i_8 
       (.I0(\mem_reg[62][0]_i_20_n_0 ),
        .I1(\mem_reg[62][0]_i_21_n_0 ),
        .O(\mem_reg[62][0]_i_8_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[1]),
        .Q(\mem_reg[62]_0 [1]),
        .R(1'b0));
  MUXF7 \mem_reg[62][1]_i_20 
       (.I0(\mem[62][1]_i_26_n_0 ),
        .I1(\mem[62][1]_i_27_n_0 ),
        .O(\mem_reg[62][1]_i_20_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][1]_i_21 
       (.I0(\mem[62][1]_i_28_n_0 ),
        .I1(\mem[62][1]_i_29_n_0 ),
        .O(\mem_reg[62][1]_i_21_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][1]_i_22 
       (.I0(\mem[62][1]_i_30_n_0 ),
        .I1(\mem[62][1]_i_31_n_0 ),
        .O(\mem_reg[62][1]_i_22_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][1]_i_23 
       (.I0(\mem[62][1]_i_32_n_0 ),
        .I1(\mem[62][1]_i_33_n_0 ),
        .O(\mem_reg[62][1]_i_23_n_0 ),
        .S(ptr[2]));
  MUXF8 \mem_reg[62][1]_i_8 
       (.I0(\mem_reg[62][1]_i_20_n_0 ),
        .I1(\mem_reg[62][1]_i_21_n_0 ),
        .O(\mem_reg[62][1]_i_8_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][1]_i_9 
       (.I0(\mem_reg[62][1]_i_22_n_0 ),
        .I1(\mem_reg[62][1]_i_23_n_0 ),
        .O(\mem_reg[62][1]_i_9_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[2]),
        .Q(\mem_reg[62]_0 [2]),
        .R(1'b0));
  MUXF7 \mem_reg[62][2]_i_11 
       (.I0(\mem[62][2]_i_21_n_0 ),
        .I1(\mem[62][2]_i_22_n_0 ),
        .O(\mem_reg[62][2]_i_11_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_12 
       (.I0(\mem[62][2]_i_23_n_0 ),
        .I1(\mem[62][2]_i_24_n_0 ),
        .O(\mem_reg[62][2]_i_12_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_13 
       (.I0(\mem[62][2]_i_25_n_0 ),
        .I1(\mem[62][2]_i_26_n_0 ),
        .O(\mem_reg[62][2]_i_13_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_14 
       (.I0(\mem[62][2]_i_27_n_0 ),
        .I1(\mem[62][2]_i_28_n_0 ),
        .O(\mem_reg[62][2]_i_14_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_15 
       (.I0(\mem[62][2]_i_29_n_0 ),
        .I1(\mem[62][2]_i_30_n_0 ),
        .O(\mem_reg[62][2]_i_15_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_16 
       (.I0(\mem[62][2]_i_31_n_0 ),
        .I1(\mem[62][2]_i_32_n_0 ),
        .O(\mem_reg[62][2]_i_16_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_17 
       (.I0(\mem[62][2]_i_33_n_0 ),
        .I1(\mem[62][2]_i_34_n_0 ),
        .O(\mem_reg[62][2]_i_17_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][2]_i_18 
       (.I0(\mem[62][2]_i_35_n_0 ),
        .I1(\mem[62][2]_i_36_n_0 ),
        .O(\mem_reg[62][2]_i_18_n_0 ),
        .S(ptr[2]));
  MUXF8 \mem_reg[62][2]_i_6 
       (.I0(\mem_reg[62][2]_i_11_n_0 ),
        .I1(\mem_reg[62][2]_i_12_n_0 ),
        .O(\mem_reg[62][2]_i_6_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][2]_i_7 
       (.I0(\mem_reg[62][2]_i_13_n_0 ),
        .I1(\mem_reg[62][2]_i_14_n_0 ),
        .O(\mem_reg[62][2]_i_7_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][2]_i_8 
       (.I0(\mem_reg[62][2]_i_15_n_0 ),
        .I1(\mem_reg[62][2]_i_16_n_0 ),
        .O(\mem_reg[62][2]_i_8_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][2]_i_9 
       (.I0(\mem_reg[62][2]_i_17_n_0 ),
        .I1(\mem_reg[62][2]_i_18_n_0 ),
        .O(\mem_reg[62][2]_i_9_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[3]),
        .Q(\mem_reg[62]_0 [3]),
        .R(1'b0));
  MUXF7 \mem_reg[62][3]_i_11 
       (.I0(\mem[62][3]_i_21_n_0 ),
        .I1(\mem[62][3]_i_22_n_0 ),
        .O(\mem_reg[62][3]_i_11_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_12 
       (.I0(\mem[62][3]_i_23_n_0 ),
        .I1(\mem[62][3]_i_24_n_0 ),
        .O(\mem_reg[62][3]_i_12_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_13 
       (.I0(\mem[62][3]_i_25_n_0 ),
        .I1(\mem[62][3]_i_26_n_0 ),
        .O(\mem_reg[62][3]_i_13_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_14 
       (.I0(\mem[62][3]_i_27_n_0 ),
        .I1(\mem[62][3]_i_28_n_0 ),
        .O(\mem_reg[62][3]_i_14_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_15 
       (.I0(\mem[62][3]_i_29_n_0 ),
        .I1(\mem[62][3]_i_30_n_0 ),
        .O(\mem_reg[62][3]_i_15_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_16 
       (.I0(\mem[62][3]_i_31_n_0 ),
        .I1(\mem[62][3]_i_32_n_0 ),
        .O(\mem_reg[62][3]_i_16_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_17 
       (.I0(\mem[62][3]_i_33_n_0 ),
        .I1(\mem[62][3]_i_34_n_0 ),
        .O(\mem_reg[62][3]_i_17_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][3]_i_18 
       (.I0(\mem[62][3]_i_35_n_0 ),
        .I1(\mem[62][3]_i_36_n_0 ),
        .O(\mem_reg[62][3]_i_18_n_0 ),
        .S(ptr[2]));
  CARRY4 \mem_reg[62][3]_i_37 
       (.CI(1'b0),
        .CO({\mem_reg[62][3]_i_37_n_0 ,\mem_reg[62][3]_i_37_n_1 ,\mem_reg[62][3]_i_37_n_2 ,\mem_reg[62][3]_i_37_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_102,t_reg_n_103,t_reg_n_104,t_reg_n_105}),
        .O(finish3[3:0]),
        .S({\mem[62][3]_i_38_n_0 ,\mem[62][3]_i_39_n_0 ,\mem[62][3]_i_40_n_0 ,\mem[62][3]_i_41_n_0 }));
  MUXF8 \mem_reg[62][3]_i_6 
       (.I0(\mem_reg[62][3]_i_11_n_0 ),
        .I1(\mem_reg[62][3]_i_12_n_0 ),
        .O(\mem_reg[62][3]_i_6_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][3]_i_7 
       (.I0(\mem_reg[62][3]_i_13_n_0 ),
        .I1(\mem_reg[62][3]_i_14_n_0 ),
        .O(\mem_reg[62][3]_i_7_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][3]_i_8 
       (.I0(\mem_reg[62][3]_i_15_n_0 ),
        .I1(\mem_reg[62][3]_i_16_n_0 ),
        .O(\mem_reg[62][3]_i_8_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][3]_i_9 
       (.I0(\mem_reg[62][3]_i_17_n_0 ),
        .I1(\mem_reg[62][3]_i_18_n_0 ),
        .O(\mem_reg[62][3]_i_9_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[4]),
        .Q(\mem_reg[62]_0 [4]),
        .R(1'b0));
  MUXF7 \mem_reg[62][4]_i_19 
       (.I0(\mem[62][4]_i_25_n_0 ),
        .I1(\mem[62][4]_i_26_n_0 ),
        .O(\mem_reg[62][4]_i_19_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][4]_i_20 
       (.I0(\mem[62][4]_i_27_n_0 ),
        .I1(\mem[62][4]_i_28_n_0 ),
        .O(\mem_reg[62][4]_i_20_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][4]_i_21 
       (.I0(\mem[62][4]_i_29_n_0 ),
        .I1(\mem[62][4]_i_30_n_0 ),
        .O(\mem_reg[62][4]_i_21_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][4]_i_22 
       (.I0(\mem[62][4]_i_31_n_0 ),
        .I1(\mem[62][4]_i_32_n_0 ),
        .O(\mem_reg[62][4]_i_22_n_0 ),
        .S(ptr[2]));
  MUXF8 \mem_reg[62][4]_i_8 
       (.I0(\mem_reg[62][4]_i_19_n_0 ),
        .I1(\mem_reg[62][4]_i_20_n_0 ),
        .O(\mem_reg[62][4]_i_8_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][4]_i_9 
       (.I0(\mem_reg[62][4]_i_21_n_0 ),
        .I1(\mem_reg[62][4]_i_22_n_0 ),
        .O(\mem_reg[62][4]_i_9_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[5]),
        .Q(\mem_reg[62]_0 [5]),
        .R(1'b0));
  MUXF7 \mem_reg[62][5]_i_11 
       (.I0(\mem[62][5]_i_21_n_0 ),
        .I1(\mem[62][5]_i_22_n_0 ),
        .O(\mem_reg[62][5]_i_11_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_12 
       (.I0(\mem[62][5]_i_23_n_0 ),
        .I1(\mem[62][5]_i_24_n_0 ),
        .O(\mem_reg[62][5]_i_12_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_13 
       (.I0(\mem[62][5]_i_25_n_0 ),
        .I1(\mem[62][5]_i_26_n_0 ),
        .O(\mem_reg[62][5]_i_13_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_14 
       (.I0(\mem[62][5]_i_27_n_0 ),
        .I1(\mem[62][5]_i_28_n_0 ),
        .O(\mem_reg[62][5]_i_14_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_15 
       (.I0(\mem[62][5]_i_29_n_0 ),
        .I1(\mem[62][5]_i_30_n_0 ),
        .O(\mem_reg[62][5]_i_15_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_16 
       (.I0(\mem[62][5]_i_31_n_0 ),
        .I1(\mem[62][5]_i_32_n_0 ),
        .O(\mem_reg[62][5]_i_16_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_17 
       (.I0(\mem[62][5]_i_33_n_0 ),
        .I1(\mem[62][5]_i_34_n_0 ),
        .O(\mem_reg[62][5]_i_17_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][5]_i_18 
       (.I0(\mem[62][5]_i_35_n_0 ),
        .I1(\mem[62][5]_i_36_n_0 ),
        .O(\mem_reg[62][5]_i_18_n_0 ),
        .S(ptr[2]));
  MUXF8 \mem_reg[62][5]_i_6 
       (.I0(\mem_reg[62][5]_i_11_n_0 ),
        .I1(\mem_reg[62][5]_i_12_n_0 ),
        .O(\mem_reg[62][5]_i_6_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][5]_i_7 
       (.I0(\mem_reg[62][5]_i_13_n_0 ),
        .I1(\mem_reg[62][5]_i_14_n_0 ),
        .O(\mem_reg[62][5]_i_7_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][5]_i_8 
       (.I0(\mem_reg[62][5]_i_15_n_0 ),
        .I1(\mem_reg[62][5]_i_16_n_0 ),
        .O(\mem_reg[62][5]_i_8_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][5]_i_9 
       (.I0(\mem_reg[62][5]_i_17_n_0 ),
        .I1(\mem_reg[62][5]_i_18_n_0 ),
        .O(\mem_reg[62][5]_i_9_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[6]),
        .Q(\mem_reg[62]_0 [6]),
        .R(1'b0));
  MUXF8 \mem_reg[62][6]_i_10 
       (.I0(\mem_reg[62][6]_i_21_n_0 ),
        .I1(\mem_reg[62][6]_i_22_n_0 ),
        .O(\mem_reg[62][6]_i_10_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][6]_i_11 
       (.I0(\mem_reg[62][6]_i_23_n_0 ),
        .I1(\mem_reg[62][6]_i_24_n_0 ),
        .O(\mem_reg[62][6]_i_11_n_0 ),
        .S(ptr[3]));
  CARRY4 \mem_reg[62][6]_i_12 
       (.CI(\mem_reg[62][6]_i_25_n_0 ),
        .CO({\mem_reg[62][6]_i_12_n_0 ,\mem_reg[62][6]_i_12_n_1 ,\mem_reg[62][6]_i_12_n_2 ,\mem_reg[62][6]_i_12_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][6]_i_26_n_0 ,\mem[62][6]_i_27_n_0 ,\mem[62][6]_i_28_n_0 ,\mem[62][6]_i_29_n_0 }),
        .O(\NLW_mem_reg[62][6]_i_12_O_UNCONNECTED [3:0]),
        .S({\mem[62][6]_i_30_n_0 ,\mem[62][6]_i_31_n_0 ,\mem[62][6]_i_32_n_0 ,\mem[62][6]_i_33_n_0 }));
  MUXF7 \mem_reg[62][6]_i_17 
       (.I0(\mem[62][6]_i_36_n_0 ),
        .I1(\mem[62][6]_i_37_n_0 ),
        .O(\mem_reg[62][6]_i_17_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_18 
       (.I0(\mem[62][6]_i_38_n_0 ),
        .I1(\mem[62][6]_i_39_n_0 ),
        .O(\mem_reg[62][6]_i_18_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_19 
       (.I0(\mem[62][6]_i_40_n_0 ),
        .I1(\mem[62][6]_i_41_n_0 ),
        .O(\mem_reg[62][6]_i_19_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_20 
       (.I0(\mem[62][6]_i_42_n_0 ),
        .I1(\mem[62][6]_i_43_n_0 ),
        .O(\mem_reg[62][6]_i_20_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_21 
       (.I0(\mem[62][6]_i_44_n_0 ),
        .I1(\mem[62][6]_i_45_n_0 ),
        .O(\mem_reg[62][6]_i_21_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_22 
       (.I0(\mem[62][6]_i_46_n_0 ),
        .I1(\mem[62][6]_i_47_n_0 ),
        .O(\mem_reg[62][6]_i_22_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_23 
       (.I0(\mem[62][6]_i_48_n_0 ),
        .I1(\mem[62][6]_i_49_n_0 ),
        .O(\mem_reg[62][6]_i_23_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][6]_i_24 
       (.I0(\mem[62][6]_i_50_n_0 ),
        .I1(\mem[62][6]_i_51_n_0 ),
        .O(\mem_reg[62][6]_i_24_n_0 ),
        .S(ptr[2]));
  CARRY4 \mem_reg[62][6]_i_25 
       (.CI(\mem_reg[62][6]_i_52_n_0 ),
        .CO({\mem_reg[62][6]_i_25_n_0 ,\mem_reg[62][6]_i_25_n_1 ,\mem_reg[62][6]_i_25_n_2 ,\mem_reg[62][6]_i_25_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][6]_i_53_n_0 ,\mem[62][6]_i_54_n_0 ,\mem[62][6]_i_55_n_0 ,\mem[62][6]_i_56_n_0 }),
        .O(\NLW_mem_reg[62][6]_i_25_O_UNCONNECTED [3:0]),
        .S({\mem[62][6]_i_57_n_0 ,\mem[62][6]_i_58_n_0 ,\mem[62][6]_i_59_n_0 ,\mem[62][6]_i_60_n_0 }));
  CARRY4 \mem_reg[62][6]_i_5 
       (.CI(\mem_reg[62][6]_i_12_n_0 ),
        .CO({\NLW_mem_reg[62][6]_i_5_CO_UNCONNECTED [3:2],finish10_in,\mem_reg[62][6]_i_5_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\mem[62][6]_i_13_n_0 }),
        .O(\NLW_mem_reg[62][6]_i_5_O_UNCONNECTED [3:0]),
        .S({1'b0,1'b0,\mem[62][6]_i_14_n_0 ,\mem[62][6]_i_15_n_0 }));
  CARRY4 \mem_reg[62][6]_i_52 
       (.CI(\mem_reg[62][6]_i_61_n_0 ),
        .CO({\mem_reg[62][6]_i_52_n_0 ,\mem_reg[62][6]_i_52_n_1 ,\mem_reg[62][6]_i_52_n_2 ,\mem_reg[62][6]_i_52_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][6]_i_62_n_0 ,\mem[62][6]_i_63_n_0 ,\mem[62][6]_i_64_n_0 ,\mem[62][6]_i_65_n_0 }),
        .O(\NLW_mem_reg[62][6]_i_52_O_UNCONNECTED [3:0]),
        .S({\mem[62][6]_i_66_n_0 ,\mem[62][6]_i_67_n_0 ,\mem[62][6]_i_68_n_0 ,\mem[62][6]_i_69_n_0 }));
  CARRY4 \mem_reg[62][6]_i_61 
       (.CI(\mem_reg[62][6]_i_70_n_0 ),
        .CO({\mem_reg[62][6]_i_61_n_0 ,\mem_reg[62][6]_i_61_n_1 ,\mem_reg[62][6]_i_61_n_2 ,\mem_reg[62][6]_i_61_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][6]_i_71_n_0 ,\mem[62][6]_i_72_n_0 ,\mem[62][6]_i_73_n_0 ,\mem[62][6]_i_74_n_0 }),
        .O(\NLW_mem_reg[62][6]_i_61_O_UNCONNECTED [3:0]),
        .S({\mem[62][6]_i_75_n_0 ,\mem[62][6]_i_76_n_0 ,\mem[62][6]_i_77_n_0 ,\mem[62][6]_i_78_n_0 }));
  CARRY4 \mem_reg[62][6]_i_70 
       (.CI(1'b0),
        .CO({\mem_reg[62][6]_i_70_n_0 ,\mem_reg[62][6]_i_70_n_1 ,\mem_reg[62][6]_i_70_n_2 ,\mem_reg[62][6]_i_70_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][6]_i_79_n_0 ,\mem[62][6]_i_80_n_0 ,\mem[62][6]_i_81_n_0 ,\mem[62][6]_i_82_n_0 }),
        .O(\NLW_mem_reg[62][6]_i_70_O_UNCONNECTED [3:0]),
        .S({\mem[62][6]_i_83_n_0 ,\mem[62][6]_i_84_n_0 ,\mem[62][6]_i_85_n_0 ,\mem[62][6]_i_86_n_0 }));
  MUXF8 \mem_reg[62][6]_i_8 
       (.I0(\mem_reg[62][6]_i_17_n_0 ),
        .I1(\mem_reg[62][6]_i_18_n_0 ),
        .O(\mem_reg[62][6]_i_8_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][6]_i_9 
       (.I0(\mem_reg[62][6]_i_19_n_0 ),
        .I1(\mem_reg[62][6]_i_20_n_0 ),
        .O(\mem_reg[62][6]_i_9_n_0 ),
        .S(ptr[3]));
  FDRE \mem_reg[62][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(p_0_in__0[7]),
        .Q(\mem_reg[62]_0 [7]),
        .R(1'b0));
  CARRY4 \mem_reg[62][7]_i_10 
       (.CI(\mem_reg[62][7]_i_19_n_0 ),
        .CO({\NLW_mem_reg[62][7]_i_10_CO_UNCONNECTED [3:2],finish2,\mem_reg[62][7]_i_10_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,\mem[62][7]_i_20_n_0 }),
        .O(\NLW_mem_reg[62][7]_i_10_O_UNCONNECTED [3:0]),
        .S({1'b0,1'b0,finish3[48],\mem[62][7]_i_22_n_0 }));
  CARRY4 \mem_reg[62][7]_i_118 
       (.CI(\mem_reg[62][7]_i_132_n_0 ),
        .CO({\mem_reg[62][7]_i_118_n_0 ,\mem_reg[62][7]_i_118_n_1 ,\mem_reg[62][7]_i_118_n_2 ,\mem_reg[62][7]_i_118_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_168_n_0 ,\mem[62][7]_i_169_n_0 ,\mem[62][7]_i_170_n_0 ,t_reg_n_65}),
        .O(finish3[43:40]),
        .S({\mem[62][7]_i_171_n_0 ,\mem[62][7]_i_172_n_0 ,\mem[62][7]_i_173_n_0 ,\mem[62][7]_i_174_n_0 }));
  CARRY4 \mem_reg[62][7]_i_130 
       (.CI(\mem_reg[62][7]_i_134_n_0 ),
        .CO({\mem_reg[62][7]_i_130_n_0 ,\mem_reg[62][7]_i_130_n_1 ,\mem_reg[62][7]_i_130_n_2 ,\mem_reg[62][7]_i_130_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_74,t_reg_n_75,t_reg_n_76,t_reg_n_77}),
        .O(finish3[31:28]),
        .S({\mem[62][7]_i_175_n_0 ,\mem[62][7]_i_176_n_0 ,\mem[62][7]_i_177_n_0 ,\mem[62][7]_i_178_n_0 }));
  CARRY4 \mem_reg[62][7]_i_131 
       (.CI(\mem_reg[62][7]_i_135_n_0 ),
        .CO({\mem_reg[62][7]_i_131_n_0 ,\mem_reg[62][7]_i_131_n_1 ,\mem_reg[62][7]_i_131_n_2 ,\mem_reg[62][7]_i_131_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_90,t_reg_n_91,t_reg_n_92,t_reg_n_93}),
        .O(finish3[15:12]),
        .S({\mem[62][7]_i_179_n_0 ,\mem[62][7]_i_180_n_0 ,\mem[62][7]_i_181_n_0 ,\mem[62][7]_i_182_n_0 }));
  CARRY4 \mem_reg[62][7]_i_132 
       (.CI(\mem_reg[62][7]_i_136_n_0 ),
        .CO({\mem_reg[62][7]_i_132_n_0 ,\mem_reg[62][7]_i_132_n_1 ,\mem_reg[62][7]_i_132_n_2 ,\mem_reg[62][7]_i_132_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_66,t_reg_n_67,t_reg_n_68,t_reg_n_69}),
        .O(finish3[39:36]),
        .S({\mem[62][7]_i_183_n_0 ,\mem[62][7]_i_184_n_0 ,\mem[62][7]_i_185_n_0 ,\mem[62][7]_i_186_n_0 }));
  CARRY4 \mem_reg[62][7]_i_133 
       (.CI(\mem_reg[62][7]_i_137_n_0 ),
        .CO({\mem_reg[62][7]_i_133_n_0 ,\mem_reg[62][7]_i_133_n_1 ,\mem_reg[62][7]_i_133_n_2 ,\mem_reg[62][7]_i_133_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_82,t_reg_n_83,t_reg_n_84,t_reg_n_85}),
        .O(finish3[23:20]),
        .S({\mem[62][7]_i_187_n_0 ,\mem[62][7]_i_188_n_0 ,\mem[62][7]_i_189_n_0 ,\mem[62][7]_i_190_n_0 }));
  CARRY4 \mem_reg[62][7]_i_134 
       (.CI(\mem_reg[62][7]_i_133_n_0 ),
        .CO({\mem_reg[62][7]_i_134_n_0 ,\mem_reg[62][7]_i_134_n_1 ,\mem_reg[62][7]_i_134_n_2 ,\mem_reg[62][7]_i_134_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_78,t_reg_n_79,t_reg_n_80,t_reg_n_81}),
        .O(finish3[27:24]),
        .S({\mem[62][7]_i_191_n_0 ,\mem[62][7]_i_192_n_0 ,\mem[62][7]_i_193_n_0 ,\mem[62][7]_i_194_n_0 }));
  CARRY4 \mem_reg[62][7]_i_135 
       (.CI(\mem_reg[62][7]_i_138_n_0 ),
        .CO({\mem_reg[62][7]_i_135_n_0 ,\mem_reg[62][7]_i_135_n_1 ,\mem_reg[62][7]_i_135_n_2 ,\mem_reg[62][7]_i_135_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_94,t_reg_n_95,t_reg_n_96,t_reg_n_97}),
        .O(finish3[11:8]),
        .S({\mem[62][7]_i_195_n_0 ,\mem[62][7]_i_196_n_0 ,\mem[62][7]_i_197_n_0 ,\mem[62][7]_i_198_n_0 }));
  CARRY4 \mem_reg[62][7]_i_136 
       (.CI(\mem_reg[62][7]_i_130_n_0 ),
        .CO({\mem_reg[62][7]_i_136_n_0 ,\mem_reg[62][7]_i_136_n_1 ,\mem_reg[62][7]_i_136_n_2 ,\mem_reg[62][7]_i_136_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_70,t_reg_n_71,t_reg_n_72,t_reg_n_73}),
        .O(finish3[35:32]),
        .S({\mem[62][7]_i_199_n_0 ,\mem[62][7]_i_200_n_0 ,\mem[62][7]_i_201_n_0 ,\mem[62][7]_i_202_n_0 }));
  CARRY4 \mem_reg[62][7]_i_137 
       (.CI(\mem_reg[62][7]_i_131_n_0 ),
        .CO({\mem_reg[62][7]_i_137_n_0 ,\mem_reg[62][7]_i_137_n_1 ,\mem_reg[62][7]_i_137_n_2 ,\mem_reg[62][7]_i_137_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_86,t_reg_n_87,t_reg_n_88,t_reg_n_89}),
        .O(finish3[19:16]),
        .S({\mem[62][7]_i_203_n_0 ,\mem[62][7]_i_204_n_0 ,\mem[62][7]_i_205_n_0 ,\mem[62][7]_i_206_n_0 }));
  CARRY4 \mem_reg[62][7]_i_138 
       (.CI(\mem_reg[62][3]_i_37_n_0 ),
        .CO({\mem_reg[62][7]_i_138_n_0 ,\mem_reg[62][7]_i_138_n_1 ,\mem_reg[62][7]_i_138_n_2 ,\mem_reg[62][7]_i_138_n_3 }),
        .CYINIT(1'b0),
        .DI({t_reg_n_98,t_reg_n_99,t_reg_n_100,t_reg_n_101}),
        .O(finish3[7:4]),
        .S({\mem[62][7]_i_207_n_0 ,\mem[62][7]_i_208_n_0 ,\mem[62][7]_i_209_n_0 ,\mem[62][7]_i_210_n_0 }));
  CARRY4 \mem_reg[62][7]_i_139 
       (.CI(\mem_reg[62][7]_i_211_n_0 ),
        .CO({\mem_reg[62][7]_i_139_n_0 ,\mem_reg[62][7]_i_139_n_1 ,\mem_reg[62][7]_i_139_n_2 ,\mem_reg[62][7]_i_139_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_212_n_0 ,\mem[62][7]_i_213_n_0 ,\mem[62][7]_i_214_n_0 ,\mem[62][7]_i_215_n_0 }),
        .O(\NLW_mem_reg[62][7]_i_139_O_UNCONNECTED [3:0]),
        .S({\mem[62][7]_i_216_n_0 ,\mem[62][7]_i_217_n_0 ,\mem[62][7]_i_218_n_0 ,\mem[62][7]_i_219_n_0 }));
  MUXF8 \mem_reg[62][7]_i_15 
       (.I0(\mem_reg[62][7]_i_33_n_0 ),
        .I1(\mem_reg[62][7]_i_34_n_0 ),
        .O(\mem_reg[62][7]_i_15_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][7]_i_16 
       (.I0(\mem_reg[62][7]_i_35_n_0 ),
        .I1(\mem_reg[62][7]_i_36_n_0 ),
        .O(\mem_reg[62][7]_i_16_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][7]_i_17 
       (.I0(\mem_reg[62][7]_i_37_n_0 ),
        .I1(\mem_reg[62][7]_i_38_n_0 ),
        .O(\mem_reg[62][7]_i_17_n_0 ),
        .S(ptr[3]));
  MUXF8 \mem_reg[62][7]_i_18 
       (.I0(\mem_reg[62][7]_i_39_n_0 ),
        .I1(\mem_reg[62][7]_i_40_n_0 ),
        .O(\mem_reg[62][7]_i_18_n_0 ),
        .S(ptr[3]));
  CARRY4 \mem_reg[62][7]_i_19 
       (.CI(\mem_reg[62][7]_i_41_n_0 ),
        .CO({\mem_reg[62][7]_i_19_n_0 ,\mem_reg[62][7]_i_19_n_1 ,\mem_reg[62][7]_i_19_n_2 ,\mem_reg[62][7]_i_19_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_42_n_0 ,\mem[62][7]_i_43_n_0 ,\mem[62][7]_i_44_n_0 ,\mem[62][7]_i_45_n_0 }),
        .O(\NLW_mem_reg[62][7]_i_19_O_UNCONNECTED [3:0]),
        .S({\mem[62][7]_i_46_n_0 ,\mem[62][7]_i_47_n_0 ,\mem[62][7]_i_48_n_0 ,\mem[62][7]_i_49_n_0 }));
  CARRY4 \mem_reg[62][7]_i_21 
       (.CI(\mem_reg[62][7]_i_51_n_0 ),
        .CO(\NLW_mem_reg[62][7]_i_21_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_mem_reg[62][7]_i_21_O_UNCONNECTED [3:1],finish3[48]}),
        .S({1'b0,1'b0,1'b0,\mem[62][7]_i_55_n_0 }));
  CARRY4 \mem_reg[62][7]_i_211 
       (.CI(1'b0),
        .CO({\mem_reg[62][7]_i_211_n_0 ,\mem_reg[62][7]_i_211_n_1 ,\mem_reg[62][7]_i_211_n_2 ,\mem_reg[62][7]_i_211_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_249_n_0 ,\mem[62][7]_i_250_n_0 ,\mem[62][7]_i_251_n_0 ,\mem[62][7]_i_252_n_0 }),
        .O(\NLW_mem_reg[62][7]_i_211_O_UNCONNECTED [3:0]),
        .S({\mem[62][7]_i_253_n_0 ,\mem[62][7]_i_254_n_0 ,\mem[62][7]_i_255_n_0 ,\mem[62][7]_i_256_n_0 }));
  MUXF7 \mem_reg[62][7]_i_33 
       (.I0(\mem[62][7]_i_82_n_0 ),
        .I1(\mem[62][7]_i_83_n_0 ),
        .O(\mem_reg[62][7]_i_33_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_34 
       (.I0(\mem[62][7]_i_84_n_0 ),
        .I1(\mem[62][7]_i_85_n_0 ),
        .O(\mem_reg[62][7]_i_34_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_35 
       (.I0(\mem[62][7]_i_86_n_0 ),
        .I1(\mem[62][7]_i_87_n_0 ),
        .O(\mem_reg[62][7]_i_35_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_36 
       (.I0(\mem[62][7]_i_88_n_0 ),
        .I1(\mem[62][7]_i_89_n_0 ),
        .O(\mem_reg[62][7]_i_36_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_37 
       (.I0(\mem[62][7]_i_90_n_0 ),
        .I1(\mem[62][7]_i_91_n_0 ),
        .O(\mem_reg[62][7]_i_37_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_38 
       (.I0(\mem[62][7]_i_92_n_0 ),
        .I1(\mem[62][7]_i_93_n_0 ),
        .O(\mem_reg[62][7]_i_38_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_39 
       (.I0(\mem[62][7]_i_94_n_0 ),
        .I1(\mem[62][7]_i_95_n_0 ),
        .O(\mem_reg[62][7]_i_39_n_0 ),
        .S(ptr[2]));
  MUXF7 \mem_reg[62][7]_i_40 
       (.I0(\mem[62][7]_i_96_n_0 ),
        .I1(\mem[62][7]_i_97_n_0 ),
        .O(\mem_reg[62][7]_i_40_n_0 ),
        .S(ptr[2]));
  CARRY4 \mem_reg[62][7]_i_41 
       (.CI(\mem_reg[62][7]_i_98_n_0 ),
        .CO({\mem_reg[62][7]_i_41_n_0 ,\mem_reg[62][7]_i_41_n_1 ,\mem_reg[62][7]_i_41_n_2 ,\mem_reg[62][7]_i_41_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_99_n_0 ,\mem[62][7]_i_100_n_0 ,\mem[62][7]_i_101_n_0 ,\mem[62][7]_i_102_n_0 }),
        .O(\NLW_mem_reg[62][7]_i_41_O_UNCONNECTED [3:0]),
        .S({\mem[62][7]_i_103_n_0 ,\mem[62][7]_i_104_n_0 ,\mem[62][7]_i_105_n_0 ,\mem[62][7]_i_106_n_0 }));
  CARRY4 \mem_reg[62][7]_i_51 
       (.CI(\mem_reg[62][7]_i_118_n_0 ),
        .CO({\mem_reg[62][7]_i_51_n_0 ,\mem_reg[62][7]_i_51_n_1 ,\mem_reg[62][7]_i_51_n_2 ,\mem_reg[62][7]_i_51_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_119_n_0 ,\mem[62][7]_i_120_n_0 ,\mem[62][7]_i_121_n_0 ,\mem[62][7]_i_122_n_0 }),
        .O(finish3[47:44]),
        .S({\mem[62][7]_i_123_n_0 ,\mem[62][7]_i_124_n_0 ,\mem[62][7]_i_125_n_0 ,\mem[62][7]_i_126_n_0 }));
  CARRY4 \mem_reg[62][7]_i_98 
       (.CI(\mem_reg[62][7]_i_139_n_0 ),
        .CO({\mem_reg[62][7]_i_98_n_0 ,\mem_reg[62][7]_i_98_n_1 ,\mem_reg[62][7]_i_98_n_2 ,\mem_reg[62][7]_i_98_n_3 }),
        .CYINIT(1'b0),
        .DI({\mem[62][7]_i_140_n_0 ,\mem[62][7]_i_141_n_0 ,\mem[62][7]_i_142_n_0 ,\mem[62][7]_i_143_n_0 }),
        .O(\NLW_mem_reg[62][7]_i_98_O_UNCONNECTED [3:0]),
        .S({\mem[62][7]_i_144_n_0 ,\mem[62][7]_i_145_n_0 ,\mem[62][7]_i_146_n_0 ,\mem[62][7]_i_147_n_0 }));
  FDRE \mem_reg[63][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][0]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [0]),
        .R(1'b0));
  FDRE \mem_reg[63][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][1]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [1]),
        .R(1'b0));
  FDRE \mem_reg[63][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][2]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [2]),
        .R(1'b0));
  FDRE \mem_reg[63][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][3]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [3]),
        .R(1'b0));
  FDRE \mem_reg[63][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][4]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [4]),
        .R(1'b0));
  FDRE \mem_reg[63][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][5]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [5]),
        .R(1'b0));
  FDRE \mem_reg[63][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][6]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [6]),
        .R(1'b0));
  FDRE \mem_reg[63][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[63][7]_i_1_n_0 ),
        .Q(\mem_reg[63]_69 [7]),
        .R(1'b0));
  FDRE \mem_reg[6][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][0]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [0]),
        .R(1'b0));
  FDRE \mem_reg[6][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][1]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [1]),
        .R(1'b0));
  FDRE \mem_reg[6][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][2]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [2]),
        .R(1'b0));
  FDRE \mem_reg[6][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][3]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [3]),
        .R(1'b0));
  FDRE \mem_reg[6][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][4]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [4]),
        .R(1'b0));
  FDRE \mem_reg[6][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][5]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [5]),
        .R(1'b0));
  FDRE \mem_reg[6][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][6]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [6]),
        .R(1'b0));
  FDRE \mem_reg[6][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[6][7]_i_1_n_0 ),
        .Q(\mem_reg[6]_56 [7]),
        .R(1'b0));
  FDRE \mem_reg[7][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][0]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [0]),
        .R(1'b0));
  FDRE \mem_reg[7][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][1]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [1]),
        .R(1'b0));
  FDRE \mem_reg[7][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][2]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [2]),
        .R(1'b0));
  FDRE \mem_reg[7][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][3]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [3]),
        .R(1'b0));
  FDRE \mem_reg[7][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][4]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [4]),
        .R(1'b0));
  FDRE \mem_reg[7][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][5]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [5]),
        .R(1'b0));
  FDRE \mem_reg[7][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][6]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [6]),
        .R(1'b0));
  FDRE \mem_reg[7][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[7][7]_i_1_n_0 ),
        .Q(\mem_reg[7]_55 [7]),
        .R(1'b0));
  FDRE \mem_reg[8][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][0]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [0]),
        .R(1'b0));
  FDRE \mem_reg[8][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][1]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [1]),
        .R(1'b0));
  FDRE \mem_reg[8][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][2]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [2]),
        .R(1'b0));
  FDRE \mem_reg[8][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][3]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [3]),
        .R(1'b0));
  FDRE \mem_reg[8][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][4]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [4]),
        .R(1'b0));
  FDRE \mem_reg[8][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][5]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [5]),
        .R(1'b0));
  FDRE \mem_reg[8][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][6]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [6]),
        .R(1'b0));
  FDRE \mem_reg[8][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[8][7]_i_1_n_0 ),
        .Q(\mem_reg[8]_54 [7]),
        .R(1'b0));
  FDRE \mem_reg[9][0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][0]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [0]),
        .R(1'b0));
  FDRE \mem_reg[9][1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][1]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [1]),
        .R(1'b0));
  FDRE \mem_reg[9][2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][2]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [2]),
        .R(1'b0));
  FDRE \mem_reg[9][3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][3]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [3]),
        .R(1'b0));
  FDRE \mem_reg[9][4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][4]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [4]),
        .R(1'b0));
  FDRE \mem_reg[9][5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][5]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [5]),
        .R(1'b0));
  FDRE \mem_reg[9][6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][6]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [6]),
        .R(1'b0));
  FDRE \mem_reg[9][7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\mem[9][7]_i_1_n_0 ),
        .Q(\mem_reg[9]_53 [7]),
        .R(1'b0));
  FDRE \mq0_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[0]),
        .Q(mq0[0]),
        .R(rst));
  FDRE \mq0_reg[10] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[10]),
        .Q(mq0[10]),
        .R(rst));
  FDRE \mq0_reg[11] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[11]),
        .Q(mq0[11]),
        .R(rst));
  FDRE \mq0_reg[12] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[12]),
        .Q(mq0[12]),
        .R(rst));
  FDRE \mq0_reg[13] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[13]),
        .Q(mq0[13]),
        .R(rst));
  FDRE \mq0_reg[14] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[14]),
        .Q(mq0[14]),
        .R(rst));
  FDRE \mq0_reg[15] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[15]),
        .Q(mq0[15]),
        .R(rst));
  FDRE \mq0_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[1]),
        .Q(mq0[1]),
        .R(rst));
  FDRE \mq0_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[2]),
        .Q(mq0[2]),
        .R(rst));
  FDRE \mq0_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[3]),
        .Q(mq0[3]),
        .R(rst));
  FDRE \mq0_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[4]),
        .Q(mq0[4]),
        .R(rst));
  FDRE \mq0_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[5]),
        .Q(mq0[5]),
        .R(rst));
  FDRE \mq0_reg[6] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[6]),
        .Q(mq0[6]),
        .R(rst));
  FDRE \mq0_reg[7] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[7]),
        .Q(mq0[7]),
        .R(rst));
  FDRE \mq0_reg[8] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[8]),
        .Q(mq0[8]),
        .R(rst));
  FDRE \mq0_reg[9] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_0[9]),
        .Q(mq0[9]),
        .R(rst));
  FDRE \mq1_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[0]),
        .Q(mq1[0]),
        .R(rst));
  FDRE \mq1_reg[10] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[10]),
        .Q(mq1[10]),
        .R(rst));
  FDRE \mq1_reg[11] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[11]),
        .Q(mq1[11]),
        .R(rst));
  FDRE \mq1_reg[12] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[12]),
        .Q(mq1[12]),
        .R(rst));
  FDRE \mq1_reg[13] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[13]),
        .Q(mq1[13]),
        .R(rst));
  FDRE \mq1_reg[14] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[14]),
        .Q(mq1[14]),
        .R(rst));
  FDRE \mq1_reg[15] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[15]),
        .Q(mq1[15]),
        .R(rst));
  FDRE \mq1_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[1]),
        .Q(mq1[1]),
        .R(rst));
  FDRE \mq1_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[2]),
        .Q(mq1[2]),
        .R(rst));
  FDRE \mq1_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[3]),
        .Q(mq1[3]),
        .R(rst));
  FDRE \mq1_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[4]),
        .Q(mq1[4]),
        .R(rst));
  FDRE \mq1_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[5]),
        .Q(mq1[5]),
        .R(rst));
  FDRE \mq1_reg[6] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[6]),
        .Q(mq1[6]),
        .R(rst));
  FDRE \mq1_reg[7] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[7]),
        .Q(mq1[7]),
        .R(rst));
  FDRE \mq1_reg[8] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[8]),
        .Q(mq1[8]),
        .R(rst));
  FDRE \mq1_reg[9] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(m0_1[9]),
        .Q(mq1[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'h06)) 
    \optr[0]_i_1 
       (.I0(optr_reg[0]),
        .I1(Q[1]),
        .I2(q_pair_reg),
        .O(p_0_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT4 #(
    .INIT(16'h0451)) 
    \optr[1]_i_1 
       (.I0(q_pair_reg),
        .I1(Q[1]),
        .I2(optr_reg[0]),
        .I3(optr_reg[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h0000758A)) 
    \optr[2]_i_1 
       (.I0(optr_reg[1]),
        .I1(optr_reg[0]),
        .I2(Q[1]),
        .I3(optr_reg[2]),
        .I4(q_pair_reg),
        .O(p_0_in[2]));
  LUT6 #(
    .INIT(64'h000000005DFFA200)) 
    \optr[3]_i_1 
       (.I0(optr_reg[2]),
        .I1(Q[1]),
        .I2(optr_reg[0]),
        .I3(optr_reg[1]),
        .I4(optr_reg[3]),
        .I5(q_pair_reg),
        .O(p_0_in[3]));
  LUT6 #(
    .INIT(64'hFFFFFFFF02000000)) 
    \optr[4]_i_1 
       (.I0(q_single_i_2_n_0),
        .I1(\phase_reg[1]_rep__0_n_0 ),
        .I2(\phase_reg[0]_rep_n_0 ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_1 ),
        .I5(q_pair_reg),
        .O(\optr[4]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0078)) 
    \optr[4]_i_2 
       (.I0(optr_reg[3]),
        .I1(\optr[4]_i_4_n_0 ),
        .I2(optr_reg[4]),
        .I3(q_pair_reg),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h0000040000000000)) 
    \optr[4]_i_3 
       (.I0(q_pair),
        .I1(step),
        .I2(\ptr_reg[0]_rep_2 ),
        .I3(\ptr_reg[0]_rep_1 ),
        .I4(\ptr_reg[0]_rep_0 ),
        .I5(Q[0]),
        .O(q_pair_reg));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'hA200)) 
    \optr[4]_i_4 
       (.I0(optr_reg[2]),
        .I1(Q[1]),
        .I2(optr_reg[0]),
        .I3(optr_reg[1]),
        .O(\optr[4]_i_4_n_0 ));
  FDRE \optr_reg[0] 
       (.C(s_axi_aclk),
        .CE(\optr[4]_i_1_n_0 ),
        .D(p_0_in[0]),
        .Q(optr_reg[0]),
        .R(rst));
  FDRE \optr_reg[1] 
       (.C(s_axi_aclk),
        .CE(\optr[4]_i_1_n_0 ),
        .D(p_0_in[1]),
        .Q(optr_reg[1]),
        .R(rst));
  FDRE \optr_reg[2] 
       (.C(s_axi_aclk),
        .CE(\optr[4]_i_1_n_0 ),
        .D(p_0_in[2]),
        .Q(optr_reg[2]),
        .R(rst));
  FDRE \optr_reg[3] 
       (.C(s_axi_aclk),
        .CE(\optr[4]_i_1_n_0 ),
        .D(p_0_in[3]),
        .Q(optr_reg[3]),
        .R(rst));
  FDRE \optr_reg[4] 
       (.C(s_axi_aclk),
        .CE(\optr[4]_i_1_n_0 ),
        .D(p_0_in[4]),
        .Q(optr_reg[4]),
        .R(rst));
  FDRE ovf0_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ovf0_reg_0),
        .Q(ovf0),
        .R(rst));
  LUT6 #(
    .INIT(64'hD7555555C3000000)) 
    ovf1_i_1
       (.I0(ovf10_out),
        .I1(\acc1_reg[21]_i_3_n_1 ),
        .I2(s1__0[21]),
        .I3(q_pair),
        .I4(step),
        .I5(ovf1),
        .O(ovf1_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    ovf1_i_2
       (.I0(\ptr_reg[0]_rep_0 ),
        .I1(\ptr_reg[0]_rep_1 ),
        .I2(\ptr_reg[0]_rep_2 ),
        .I3(step),
        .I4(q_pair),
        .O(ovf10_out));
  FDRE ovf1_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ovf1_i_1_n_0),
        .Q(ovf1),
        .R(rst));
  LUT6 #(
    .INIT(64'h020000000E0C0C0C)) 
    \phase[0]_i_1 
       (.I0(q_single_i_2_n_0),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_1 ),
        .I5(q_single_reg_n_0),
        .O(\phase[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h020000000E0C0C0C)) 
    \phase[0]_rep_i_1 
       (.I0(q_single_i_2_n_0),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_1 ),
        .I5(q_single_reg_n_0),
        .O(\phase[0]_rep_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h020000000E0C0C0C)) 
    \phase[0]_rep_i_1__0 
       (.I0(q_single_i_2_n_0),
        .I1(\phase_reg[1]_rep_n_0 ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_1 ),
        .I5(q_single_reg_n_0),
        .O(\phase[0]_rep_i_1__0_n_0 ));
  LUT3 #(
    .INIT(8'h1C)) 
    \phase[1]_i_1 
       (.I0(q_single_reg_n_0),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg_n_0_[1] ),
        .O(\phase[1]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h1C)) 
    \phase[1]_rep_i_1 
       (.I0(q_single_reg_n_0),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg_n_0_[1] ),
        .O(\phase[1]_rep_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h1C)) 
    \phase[1]_rep_i_1__0 
       (.I0(q_single_reg_n_0),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .I2(\phase_reg_n_0_[1] ),
        .O(\phase[1]_rep_i_1__0_n_0 ));
  (* ORIG_CELL_NAME = "phase_reg[0]" *) 
  FDRE \phase_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\phase[0]_i_1_n_0 ),
        .Q(\phase_reg_n_0_[0] ),
        .R(rst));
  (* ORIG_CELL_NAME = "phase_reg[0]" *) 
  FDRE \phase_reg[0]_rep 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\phase[0]_rep_i_1_n_0 ),
        .Q(\phase_reg[0]_rep_n_0 ),
        .R(rst));
  (* ORIG_CELL_NAME = "phase_reg[0]" *) 
  FDRE \phase_reg[0]_rep__0 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\phase[0]_rep_i_1__0_n_0 ),
        .Q(\phase_reg[0]_rep__0_n_0 ),
        .R(rst));
  (* ORIG_CELL_NAME = "phase_reg[1]" *) 
  FDRE \phase_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\phase[1]_i_1_n_0 ),
        .Q(\phase_reg_n_0_[1] ),
        .R(rst));
  (* ORIG_CELL_NAME = "phase_reg[1]" *) 
  FDRE \phase_reg[1]_rep 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\phase[1]_rep_i_1_n_0 ),
        .Q(\phase_reg[1]_rep_n_0 ),
        .R(rst));
  (* ORIG_CELL_NAME = "phase_reg[1]" *) 
  FDRE \phase_reg[1]_rep__0 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\phase[1]_rep_i_1__0_n_0 ),
        .Q(\phase_reg[1]_rep__0_n_0 ),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \pptr[0]_i_1 
       (.I0(\ptr_reg[0]_rep_2 ),
        .I1(\pptr_reg_n_0_[0] ),
        .O(\pptr[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'h60)) 
    \pptr[1]_i_1 
       (.I0(\pptr_reg_n_0_[0] ),
        .I1(\pptr_reg_n_0_[1] ),
        .I2(\ptr_reg[0]_rep_2 ),
        .O(\pptr[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h2A80)) 
    \pptr[2]_i_1 
       (.I0(\ptr_reg[0]_rep_2 ),
        .I1(\pptr_reg_n_0_[1] ),
        .I2(\pptr_reg_n_0_[0] ),
        .I3(\pptr_reg_n_0_[2] ),
        .O(\pptr[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000400)) 
    \pptr[3]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\ptr_reg[0]_rep_2 ),
        .I3(\ptr_reg[0]_rep_1 ),
        .I4(\ptr_reg[0]_rep_0 ),
        .I5(\pptr[3]_i_3_n_0 ),
        .O(pptr));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h2AAA8000)) 
    \pptr[3]_i_2 
       (.I0(\ptr_reg[0]_rep_2 ),
        .I1(\pptr_reg_n_0_[0] ),
        .I2(\pptr_reg_n_0_[1] ),
        .I3(\pptr_reg_n_0_[2] ),
        .I4(\pptr_reg_n_0_[3] ),
        .O(\pptr[3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h002A0000)) 
    \pptr[3]_i_3 
       (.I0(q_single_i_2_n_0),
        .I1(\pptr_reg_n_0_[3] ),
        .I2(\pptr_reg_n_0_[2] ),
        .I3(\ptr_reg[0]_rep_1 ),
        .I4(\ptr_reg[0]_rep_0 ),
        .O(\pptr[3]_i_3_n_0 ));
  FDRE \pptr_reg[0] 
       (.C(s_axi_aclk),
        .CE(pptr),
        .D(\pptr[0]_i_1_n_0 ),
        .Q(\pptr_reg_n_0_[0] ),
        .R(rst));
  FDRE \pptr_reg[1] 
       (.C(s_axi_aclk),
        .CE(pptr),
        .D(\pptr[1]_i_1_n_0 ),
        .Q(\pptr_reg_n_0_[1] ),
        .R(rst));
  FDRE \pptr_reg[2] 
       (.C(s_axi_aclk),
        .CE(pptr),
        .D(\pptr[2]_i_1_n_0 ),
        .Q(\pptr_reg_n_0_[2] ),
        .R(rst));
  FDRE \pptr_reg[3] 
       (.C(s_axi_aclk),
        .CE(pptr),
        .D(\pptr[3]_i_2_n_0 ),
        .Q(\pptr_reg_n_0_[3] ),
        .R(rst));
  LUT5 #(
    .INIT(32'h00000004)) 
    \prm[0][7]_i_1 
       (.I0(\pptr_reg_n_0_[3] ),
        .I1(\pptr[3]_i_3_n_0 ),
        .I2(\pptr_reg_n_0_[1] ),
        .I3(\pptr_reg_n_0_[0] ),
        .I4(\pptr_reg_n_0_[2] ),
        .O(prm));
  LUT5 #(
    .INIT(32'h00400000)) 
    \prm[10][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr_reg_n_0_[3] ),
        .I2(\pptr[3]_i_3_n_0 ),
        .I3(\pptr_reg_n_0_[0] ),
        .I4(\pptr_reg_n_0_[1] ),
        .O(\prm[10][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h40000000)) 
    \prm[11][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr_reg_n_0_[3] ),
        .I2(\pptr[3]_i_3_n_0 ),
        .I3(\pptr_reg_n_0_[1] ),
        .I4(\pptr_reg_n_0_[0] ),
        .O(\prm[11][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00000020)) 
    \prm[1][7]_i_1 
       (.I0(\pptr_reg_n_0_[0] ),
        .I1(\pptr_reg_n_0_[1] ),
        .I2(\pptr[3]_i_3_n_0 ),
        .I3(\pptr_reg_n_0_[2] ),
        .I4(\pptr_reg_n_0_[3] ),
        .O(\prm[1][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00100000)) 
    \prm[2][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr_reg_n_0_[3] ),
        .I2(\pptr[3]_i_3_n_0 ),
        .I3(\pptr_reg_n_0_[0] ),
        .I4(\pptr_reg_n_0_[1] ),
        .O(\prm[2][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00000080)) 
    \prm[3][7]_i_1 
       (.I0(\pptr[3]_i_3_n_0 ),
        .I1(\pptr_reg_n_0_[1] ),
        .I2(\pptr_reg_n_0_[0] ),
        .I3(\pptr_reg_n_0_[2] ),
        .I4(\pptr_reg_n_0_[3] ),
        .O(\prm[3][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00000008)) 
    \prm[4][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr[3]_i_3_n_0 ),
        .I2(\pptr_reg_n_0_[3] ),
        .I3(\pptr_reg_n_0_[0] ),
        .I4(\pptr_reg_n_0_[1] ),
        .O(\prm[4][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00080000)) 
    \prm[5][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr[3]_i_3_n_0 ),
        .I2(\pptr_reg_n_0_[3] ),
        .I3(\pptr_reg_n_0_[1] ),
        .I4(\pptr_reg_n_0_[0] ),
        .O(\prm[5][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00000800)) 
    \prm[6][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr[3]_i_3_n_0 ),
        .I2(\pptr_reg_n_0_[3] ),
        .I3(\pptr_reg_n_0_[1] ),
        .I4(\pptr_reg_n_0_[0] ),
        .O(\prm[6][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h40000000)) 
    \prm[7][7]_i_1 
       (.I0(\pptr_reg_n_0_[3] ),
        .I1(\pptr[3]_i_3_n_0 ),
        .I2(\pptr_reg_n_0_[2] ),
        .I3(\pptr_reg_n_0_[1] ),
        .I4(\pptr_reg_n_0_[0] ),
        .O(\prm[7][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00000008)) 
    \prm[8][7]_i_1 
       (.I0(\pptr[3]_i_3_n_0 ),
        .I1(\pptr_reg_n_0_[3] ),
        .I2(\pptr_reg_n_0_[2] ),
        .I3(\pptr_reg_n_0_[0] ),
        .I4(\pptr_reg_n_0_[1] ),
        .O(\prm[8][7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00400000)) 
    \prm[9][7]_i_1 
       (.I0(\pptr_reg_n_0_[2] ),
        .I1(\pptr_reg_n_0_[3] ),
        .I2(\pptr_reg_n_0_[0] ),
        .I3(\pptr_reg_n_0_[1] ),
        .I4(\pptr[3]_i_3_n_0 ),
        .O(\prm[9][7]_i_1_n_0 ));
  FDRE \prm_reg[0][0] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[0]),
        .Q(\prm_reg[0]_66 [0]),
        .R(1'b0));
  FDRE \prm_reg[0][1] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[1]),
        .Q(\prm_reg[0]_66 [1]),
        .R(1'b0));
  FDRE \prm_reg[0][2] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[2]),
        .Q(\prm_reg[0]_66 [2]),
        .R(1'b0));
  FDRE \prm_reg[0][3] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[3]),
        .Q(\prm_reg[0]_66 [3]),
        .R(1'b0));
  FDRE \prm_reg[0][4] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[4]),
        .Q(\prm_reg[0]_66 [4]),
        .R(1'b0));
  FDRE \prm_reg[0][5] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[5]),
        .Q(\prm_reg[0]_66 [5]),
        .R(1'b0));
  FDRE \prm_reg[0][6] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[6]),
        .Q(\prm_reg[0]_66 [6]),
        .R(1'b0));
  FDRE \prm_reg[0][7] 
       (.C(s_axi_aclk),
        .CE(prm),
        .D(Q[7]),
        .Q(\prm_reg[0]_66 [7]),
        .R(1'b0));
  FDRE \prm_reg[10][0] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(m0_1[8]),
        .R(1'b0));
  FDRE \prm_reg[10][1] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(m0_1[9]),
        .R(1'b0));
  FDRE \prm_reg[10][2] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(m0_1[10]),
        .R(1'b0));
  FDRE \prm_reg[10][3] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(m0_1[11]),
        .R(1'b0));
  FDRE \prm_reg[10][4] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(m0_1[12]),
        .R(1'b0));
  FDRE \prm_reg[10][5] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(m0_1[13]),
        .R(1'b0));
  FDRE \prm_reg[10][6] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(m0_1[14]),
        .R(1'b0));
  FDRE \prm_reg[10][7] 
       (.C(s_axi_aclk),
        .CE(\prm[10][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(m0_1[15]),
        .R(1'b0));
  FDRE \prm_reg[11][0] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg_n_0_[11][0] ),
        .R(1'b0));
  FDRE \prm_reg[11][1] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg_n_0_[11][1] ),
        .R(1'b0));
  FDRE \prm_reg[11][2] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg_n_0_[11][2] ),
        .R(1'b0));
  FDRE \prm_reg[11][3] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg_n_0_[11][3] ),
        .R(1'b0));
  FDRE \prm_reg[11][4] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg_n_0_[11][4] ),
        .R(1'b0));
  FDRE \prm_reg[11][5] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg_n_0_[11][5] ),
        .R(1'b0));
  FDRE \prm_reg[11][6] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg_n_0_[11][6] ),
        .R(1'b0));
  FDRE \prm_reg[11][7] 
       (.C(s_axi_aclk),
        .CE(\prm[11][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg_n_0_[11][7] ),
        .R(1'b0));
  FDRE \prm_reg[1][0] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg[1]_67 [0]),
        .R(1'b0));
  FDRE \prm_reg[1][1] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg[1]_67 [1]),
        .R(1'b0));
  FDRE \prm_reg[1][2] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg[1]_67 [2]),
        .R(1'b0));
  FDRE \prm_reg[1][3] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg[1]_67 [3]),
        .R(1'b0));
  FDRE \prm_reg[1][4] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg[1]_67 [4]),
        .R(1'b0));
  FDRE \prm_reg[1][5] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg[1]_67 [5]),
        .R(1'b0));
  FDRE \prm_reg[1][6] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg[1]_67 [6]),
        .R(1'b0));
  FDRE \prm_reg[1][7] 
       (.C(s_axi_aclk),
        .CE(\prm[1][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg[1]_67 [7]),
        .R(1'b0));
  FDRE \prm_reg[2][0] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg[2]_68 [0]),
        .R(1'b0));
  FDRE \prm_reg[2][1] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg[2]_68 [1]),
        .R(1'b0));
  FDRE \prm_reg[2][2] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg[2]_68 [2]),
        .R(1'b0));
  FDRE \prm_reg[2][3] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg[2]_68 [3]),
        .R(1'b0));
  FDRE \prm_reg[2][4] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg[2]_68 [4]),
        .R(1'b0));
  FDRE \prm_reg[2][5] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg[2]_68 [5]),
        .R(1'b0));
  FDRE \prm_reg[2][6] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg[2]_68 [6]),
        .R(1'b0));
  FDRE \prm_reg[2][7] 
       (.C(s_axi_aclk),
        .CE(\prm[2][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg[2]_68 [7]),
        .R(1'b0));
  FDRE \prm_reg[3][0] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(m0_0[0]),
        .R(1'b0));
  FDRE \prm_reg[3][1] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(m0_0[1]),
        .R(1'b0));
  FDRE \prm_reg[3][2] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(m0_0[2]),
        .R(1'b0));
  FDRE \prm_reg[3][3] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(m0_0[3]),
        .R(1'b0));
  FDRE \prm_reg[3][4] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(m0_0[4]),
        .R(1'b0));
  FDRE \prm_reg[3][5] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(m0_0[5]),
        .R(1'b0));
  FDRE \prm_reg[3][6] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(m0_0[6]),
        .R(1'b0));
  FDRE \prm_reg[3][7] 
       (.C(s_axi_aclk),
        .CE(\prm[3][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(m0_0[7]),
        .R(1'b0));
  FDRE \prm_reg[4][0] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(m0_0[8]),
        .R(1'b0));
  FDRE \prm_reg[4][1] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(m0_0[9]),
        .R(1'b0));
  FDRE \prm_reg[4][2] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(m0_0[10]),
        .R(1'b0));
  FDRE \prm_reg[4][3] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(m0_0[11]),
        .R(1'b0));
  FDRE \prm_reg[4][4] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(m0_0[12]),
        .R(1'b0));
  FDRE \prm_reg[4][5] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(m0_0[13]),
        .R(1'b0));
  FDRE \prm_reg[4][6] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(m0_0[14]),
        .R(1'b0));
  FDRE \prm_reg[4][7] 
       (.C(s_axi_aclk),
        .CE(\prm[4][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(m0_0[15]),
        .R(1'b0));
  FDRE \prm_reg[5][0] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg_n_0_[5][0] ),
        .R(1'b0));
  FDRE \prm_reg[5][1] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg_n_0_[5][1] ),
        .R(1'b0));
  FDRE \prm_reg[5][2] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg_n_0_[5][2] ),
        .R(1'b0));
  FDRE \prm_reg[5][3] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg_n_0_[5][3] ),
        .R(1'b0));
  FDRE \prm_reg[5][4] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg_n_0_[5][4] ),
        .R(1'b0));
  FDRE \prm_reg[5][5] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg_n_0_[5][5] ),
        .R(1'b0));
  FDRE \prm_reg[5][6] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg_n_0_[5][6] ),
        .R(1'b0));
  FDRE \prm_reg[5][7] 
       (.C(s_axi_aclk),
        .CE(\prm[5][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg_n_0_[5][7] ),
        .R(1'b0));
  FDRE \prm_reg[6][0] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg[6]_63 [0]),
        .R(1'b0));
  FDRE \prm_reg[6][1] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg[6]_63 [1]),
        .R(1'b0));
  FDRE \prm_reg[6][2] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg[6]_63 [2]),
        .R(1'b0));
  FDRE \prm_reg[6][3] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg[6]_63 [3]),
        .R(1'b0));
  FDRE \prm_reg[6][4] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg[6]_63 [4]),
        .R(1'b0));
  FDRE \prm_reg[6][5] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg[6]_63 [5]),
        .R(1'b0));
  FDRE \prm_reg[6][6] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg[6]_63 [6]),
        .R(1'b0));
  FDRE \prm_reg[6][7] 
       (.C(s_axi_aclk),
        .CE(\prm[6][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg[6]_63 [7]),
        .R(1'b0));
  FDRE \prm_reg[7][0] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg[7]_64 [0]),
        .R(1'b0));
  FDRE \prm_reg[7][1] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg[7]_64 [1]),
        .R(1'b0));
  FDRE \prm_reg[7][2] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg[7]_64 [2]),
        .R(1'b0));
  FDRE \prm_reg[7][3] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg[7]_64 [3]),
        .R(1'b0));
  FDRE \prm_reg[7][4] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg[7]_64 [4]),
        .R(1'b0));
  FDRE \prm_reg[7][5] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg[7]_64 [5]),
        .R(1'b0));
  FDRE \prm_reg[7][6] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg[7]_64 [6]),
        .R(1'b0));
  FDRE \prm_reg[7][7] 
       (.C(s_axi_aclk),
        .CE(\prm[7][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg[7]_64 [7]),
        .R(1'b0));
  FDRE \prm_reg[8][0] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(\prm_reg[8]_65 [0]),
        .R(1'b0));
  FDRE \prm_reg[8][1] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(\prm_reg[8]_65 [1]),
        .R(1'b0));
  FDRE \prm_reg[8][2] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(\prm_reg[8]_65 [2]),
        .R(1'b0));
  FDRE \prm_reg[8][3] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(\prm_reg[8]_65 [3]),
        .R(1'b0));
  FDRE \prm_reg[8][4] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(\prm_reg[8]_65 [4]),
        .R(1'b0));
  FDRE \prm_reg[8][5] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(\prm_reg[8]_65 [5]),
        .R(1'b0));
  FDRE \prm_reg[8][6] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(\prm_reg[8]_65 [6]),
        .R(1'b0));
  FDRE \prm_reg[8][7] 
       (.C(s_axi_aclk),
        .CE(\prm[8][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(\prm_reg[8]_65 [7]),
        .R(1'b0));
  FDRE \prm_reg[9][0] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[0]),
        .Q(m0_1[0]),
        .R(1'b0));
  FDRE \prm_reg[9][1] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[1]),
        .Q(m0_1[1]),
        .R(1'b0));
  FDRE \prm_reg[9][2] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[2]),
        .Q(m0_1[2]),
        .R(1'b0));
  FDRE \prm_reg[9][3] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[3]),
        .Q(m0_1[3]),
        .R(1'b0));
  FDRE \prm_reg[9][4] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[4]),
        .Q(m0_1[4]),
        .R(1'b0));
  FDRE \prm_reg[9][5] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[5]),
        .Q(m0_1[5]),
        .R(1'b0));
  FDRE \prm_reg[9][6] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[6]),
        .Q(m0_1[6]),
        .R(1'b0));
  FDRE \prm_reg[9][7] 
       (.C(s_axi_aclk),
        .CE(\prm[9][7]_i_1_n_0 ),
        .D(Q[7]),
        .Q(m0_1[7]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h5454545454545444)) 
    \ptr[0]_i_1 
       (.I0(ptr[0]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(p_0_in__1[0]));
  LUT6 #(
    .INIT(64'h5454545454545444)) 
    \ptr[0]_rep_i_1 
       (.I0(ptr[0]),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(q_pair),
        .I3(\acc0_reg[21]_2 ),
        .I4(\acc0_reg[21]_1 ),
        .I5(\acc0_reg[21]_0 ),
        .O(\ptr[0]_rep_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0EE0)) 
    \ptr[1]_i_1 
       (.I0(q_pair),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(ptr[1]),
        .I3(ptr[0]),
        .O(p_0_in__1[1]));
  LUT4 #(
    .INIT(16'h0EE0)) 
    \ptr[1]_rep_i_1 
       (.I0(q_pair),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(ptr[1]),
        .I3(\ptr_reg[0]_rep_n_0 ),
        .O(\ptr[1]_rep_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0EE0)) 
    \ptr[1]_rep_i_1__0 
       (.I0(q_pair),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(ptr[1]),
        .I3(ptr[0]),
        .O(\ptr[1]_rep_i_1__0_n_0 ));
  LUT5 #(
    .INIT(32'h78787800)) 
    \ptr[2]_i_1 
       (.I0(\ptr_reg[0]_rep_n_0 ),
        .I1(ptr[1]),
        .I2(ptr[2]),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(q_pair),
        .O(p_0_in__1[2]));
  LUT6 #(
    .INIT(64'h0EE0E0E0E0E0E0E0)) 
    \ptr[3]_i_1 
       (.I0(core_mac2),
        .I1(\ptr_reg[0]_rep_0 ),
        .I2(ptr[3]),
        .I3(\ptr_reg[0]_rep_n_0 ),
        .I4(ptr[2]),
        .I5(ptr[1]),
        .O(p_0_in__1[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'hAAA8)) 
    \ptr[3]_i_2 
       (.I0(q_pair),
        .I1(\acc0_reg[21]_2 ),
        .I2(\acc0_reg[21]_1 ),
        .I3(\acc0_reg[21]_0 ),
        .O(core_mac2));
  LUT5 #(
    .INIT(32'hF000FE00)) 
    \ptr[4]_i_1 
       (.I0(\ptr_reg[0]_rep_0 ),
        .I1(\ptr_reg[0]_rep_1 ),
        .I2(q_pair),
        .I3(step),
        .I4(\ptr_reg[0]_rep_2 ),
        .O(\ptr[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h000000006AAAAAAA)) 
    \ptr[4]_i_2 
       (.I0(ptr[4]),
        .I1(ptr[1]),
        .I2(ptr[2]),
        .I3(\ptr_reg[0]_rep_n_0 ),
        .I4(ptr[3]),
        .I5(\q_n_reg[0] ),
        .O(p_0_in__1[4]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h000001FF)) 
    \ptr[4]_i_3 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .I3(q_pair),
        .I4(\ptr_reg[0]_rep_0 ),
        .O(\q_n_reg[0] ));
  (* ORIG_CELL_NAME = "ptr_reg[0]" *) 
  FDRE \ptr_reg[0] 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(p_0_in__1[0]),
        .Q(ptr[0]),
        .R(rst));
  (* ORIG_CELL_NAME = "ptr_reg[0]" *) 
  FDRE \ptr_reg[0]_rep 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(\ptr[0]_rep_i_1_n_0 ),
        .Q(\ptr_reg[0]_rep_n_0 ),
        .R(rst));
  (* ORIG_CELL_NAME = "ptr_reg[1]" *) 
  FDRE \ptr_reg[1] 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(p_0_in__1[1]),
        .Q(ptr[1]),
        .R(rst));
  (* ORIG_CELL_NAME = "ptr_reg[1]" *) 
  FDRE \ptr_reg[1]_rep 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(\ptr[1]_rep_i_1_n_0 ),
        .Q(\ptr_reg[1]_rep_n_0 ),
        .R(rst));
  (* ORIG_CELL_NAME = "ptr_reg[1]" *) 
  FDRE \ptr_reg[1]_rep__0 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(\ptr[1]_rep_i_1__0_n_0 ),
        .Q(\ptr_reg[1]_rep__0_n_0 ),
        .R(rst));
  FDRE \ptr_reg[2] 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(p_0_in__1[2]),
        .Q(ptr[2]),
        .R(rst));
  FDRE \ptr_reg[3] 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(p_0_in__1[3]),
        .Q(ptr[3]),
        .R(rst));
  FDRE \ptr_reg[4] 
       (.C(s_axi_aclk),
        .CE(\ptr[4]_i_1_n_0 ),
        .D(p_0_in__1[4]),
        .Q(ptr[4]),
        .R(rst));
  LUT1 #(
    .INIT(2'h1)) 
    \q_dst[5]_i_1 
       (.I0(sel0),
        .O(\q_dst[5]_i_1_n_0 ));
  FDRE \q_dst_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(optr_reg[0]),
        .Q(\q_dst_reg_n_0_[0] ),
        .R(rst));
  FDRE \q_dst_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(optr_reg[1]),
        .Q(\q_dst_reg_n_0_[1] ),
        .R(rst));
  FDRE \q_dst_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(optr_reg[2]),
        .Q(\q_dst_reg_n_0_[2] ),
        .R(rst));
  FDRE \q_dst_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(optr_reg[3]),
        .Q(\q_dst_reg_n_0_[3] ),
        .R(rst));
  FDRE \q_dst_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(optr_reg[4]),
        .Q(\q_dst_reg_n_0_[4] ),
        .R(rst));
  FDRE \q_dst_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(\q_dst[5]_i_1_n_0 ),
        .Q(sel0__0),
        .R(rst));
  FDRE q_relu_reg
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(Q[0]),
        .Q(relu),
        .R(rst));
  LUT5 #(
    .INIT(32'h02000000)) 
    q_single_i_1
       (.I0(q_single_i_2_n_0),
        .I1(\phase_reg[1]_rep__0_n_0 ),
        .I2(\phase_reg[0]_rep_n_0 ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_1 ),
        .O(shq1));
  LUT5 #(
    .INIT(32'h55540000)) 
    q_single_i_2
       (.I0(q_pair),
        .I1(\acc0_reg[21]_2 ),
        .I2(\acc0_reg[21]_1 ),
        .I3(\acc0_reg[21]_0 ),
        .I4(\ptr_reg[0]_rep_2 ),
        .O(q_single_i_2_n_0));
  FDRE q_single_reg
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(Q[1]),
        .Q(q_single_reg_n_0),
        .R(rst));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[0]_i_1 
       (.I0(\mem[62][0]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[0]),
        .O(\result0[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[10]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[10]),
        .O(\result0[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[11]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[11]),
        .O(\result0[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[12]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[12]),
        .O(\result0[12]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[13]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[13]),
        .O(\result0[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[14]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[14]),
        .O(\result0[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[15]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[15]),
        .O(\result0[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[16]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[16]),
        .O(\result0[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[17]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[17]),
        .O(\result0[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[18]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[18]),
        .O(\result0[18]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[19]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[19]),
        .O(\result0[19]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[1]),
        .O(\result0[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[20]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[20]),
        .O(\result0[20]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAAAAAAABAAA)) 
    \result0[21]_i_1 
       (.I0(\result0[21]_i_3_n_0 ),
        .I1(q_pair),
        .I2(step),
        .I3(\ptr_reg[0]_rep_2 ),
        .I4(\ptr_reg[0]_rep_0 ),
        .I5(\ptr_reg[0]_rep_1 ),
        .O(\result0[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[21]_i_2 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[21]),
        .O(\result0[21]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \result0[21]_i_3 
       (.I0(\phase_reg[1]_rep__0_n_0 ),
        .I1(\phase_reg[0]_rep__0_n_0 ),
        .O(\result0[21]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[2]_i_1 
       (.I0(\mem[62][2]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[2]),
        .O(\result0[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[3]_i_1 
       (.I0(\mem[62][3]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[3]),
        .O(\result0[3]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[4]_i_1 
       (.I0(\mem[62][4]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[4]),
        .O(\result0[4]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[5]_i_1 
       (.I0(\mem[62][5]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[5]),
        .O(\result0[5]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[6]_i_1 
       (.I0(\mem[62][6]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[6]),
        .O(\result0[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[7]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[7]),
        .O(\result0[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[8]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[8]),
        .O(\result0[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT4 #(
    .INIT(16'hFB08)) 
    \result0[9]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc0__0[9]),
        .O(\result0[9]_i_1_n_0 ));
  FDRE \result0_reg[0] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[0]_i_1_n_0 ),
        .Q(result0[0]),
        .R(rst));
  FDRE \result0_reg[10] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[10]_i_1_n_0 ),
        .Q(result0[10]),
        .R(rst));
  FDRE \result0_reg[11] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[11]_i_1_n_0 ),
        .Q(result0[11]),
        .R(rst));
  FDRE \result0_reg[12] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[12]_i_1_n_0 ),
        .Q(result0[12]),
        .R(rst));
  FDRE \result0_reg[13] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[13]_i_1_n_0 ),
        .Q(result0[13]),
        .R(rst));
  FDRE \result0_reg[14] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[14]_i_1_n_0 ),
        .Q(result0[14]),
        .R(rst));
  FDRE \result0_reg[15] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[15]_i_1_n_0 ),
        .Q(result0[15]),
        .R(rst));
  FDRE \result0_reg[16] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[16]_i_1_n_0 ),
        .Q(result0[16]),
        .R(rst));
  FDRE \result0_reg[17] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[17]_i_1_n_0 ),
        .Q(result0[17]),
        .R(rst));
  FDRE \result0_reg[18] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[18]_i_1_n_0 ),
        .Q(result0[18]),
        .R(rst));
  FDRE \result0_reg[19] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[19]_i_1_n_0 ),
        .Q(result0[19]),
        .R(rst));
  FDRE \result0_reg[1] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[1]_i_1_n_0 ),
        .Q(result0[1]),
        .R(rst));
  FDRE \result0_reg[20] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[20]_i_1_n_0 ),
        .Q(result0[20]),
        .R(rst));
  FDRE \result0_reg[21] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[21]_i_2_n_0 ),
        .Q(result0[21]),
        .R(rst));
  FDRE \result0_reg[2] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[2]_i_1_n_0 ),
        .Q(result0[2]),
        .R(rst));
  FDRE \result0_reg[3] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[3]_i_1_n_0 ),
        .Q(result0[3]),
        .R(rst));
  FDRE \result0_reg[4] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[4]_i_1_n_0 ),
        .Q(result0[4]),
        .R(rst));
  FDRE \result0_reg[5] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[5]_i_1_n_0 ),
        .Q(result0[5]),
        .R(rst));
  FDRE \result0_reg[6] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[6]_i_1_n_0 ),
        .Q(result0[6]),
        .R(rst));
  FDRE \result0_reg[7] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[7]_i_1_n_0 ),
        .Q(result0[7]),
        .R(rst));
  FDRE \result0_reg[8] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[8]_i_1_n_0 ),
        .Q(result0[8]),
        .R(rst));
  FDRE \result0_reg[9] 
       (.C(s_axi_aclk),
        .CE(\result0[21]_i_1_n_0 ),
        .D(\result0[9]_i_1_n_0 ),
        .Q(result0[9]),
        .R(rst));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[0]_i_1 
       (.I0(\mem[62][0]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[0]),
        .O(\result1[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[10]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[10]),
        .O(\result1[10]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[11]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[11]),
        .O(\result1[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[12]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[12]),
        .O(\result1[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[13]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[13]),
        .O(\result1[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[14]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[14]),
        .O(\result1[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[15]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[15]),
        .O(\result1[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[16]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[16]),
        .O(\result1[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[17]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[17]),
        .O(\result1[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[18]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[18]),
        .O(\result1[18]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[19]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[19]),
        .O(\result1[19]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[1]_i_1 
       (.I0(\mem[62][1]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[1]),
        .O(\result1[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[20]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[20]),
        .O(\result1[20]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000040)) 
    \result1[21]_i_1 
       (.I0(q_pair),
        .I1(step),
        .I2(\ptr_reg[0]_rep_2 ),
        .I3(\ptr_reg[0]_rep_0 ),
        .I4(\ptr_reg[0]_rep_1 ),
        .I5(\result1[21]_i_3_n_0 ),
        .O(\result1[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[21]_i_2 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[21]),
        .O(\result1[21]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \result1[21]_i_3 
       (.I0(\phase_reg[1]_rep_n_0 ),
        .I1(\phase_reg[0]_rep_n_0 ),
        .O(\result1[21]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[2]_i_1 
       (.I0(\mem[62][2]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[2]),
        .O(\result1[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[3]_i_1 
       (.I0(\mem[62][3]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[3]),
        .O(\result1[3]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[4]_i_1 
       (.I0(\mem[62][4]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[4]),
        .O(\result1[4]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[5]_i_1 
       (.I0(\mem[62][5]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[5]),
        .O(\result1[5]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[6]_i_1 
       (.I0(\mem[62][6]_i_3_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[6]),
        .O(\result1[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[7]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[7]),
        .O(\result1[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[8]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[8]),
        .O(\result1[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT4 #(
    .INIT(16'hBF80)) 
    \result1[9]_i_1 
       (.I0(\mem[62][7]_i_5_n_0 ),
        .I1(\phase_reg_n_0_[1] ),
        .I2(\phase_reg_n_0_[0] ),
        .I3(acc1__0[9]),
        .O(\result1[9]_i_1_n_0 ));
  FDRE \result1_reg[0] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[0]_i_1_n_0 ),
        .Q(result1[0]),
        .R(rst));
  FDRE \result1_reg[10] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[10]_i_1_n_0 ),
        .Q(result1[10]),
        .R(rst));
  FDRE \result1_reg[11] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[11]_i_1_n_0 ),
        .Q(result1[11]),
        .R(rst));
  FDRE \result1_reg[12] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[12]_i_1_n_0 ),
        .Q(result1[12]),
        .R(rst));
  FDRE \result1_reg[13] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[13]_i_1_n_0 ),
        .Q(result1[13]),
        .R(rst));
  FDRE \result1_reg[14] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[14]_i_1_n_0 ),
        .Q(result1[14]),
        .R(rst));
  FDRE \result1_reg[15] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[15]_i_1_n_0 ),
        .Q(result1[15]),
        .R(rst));
  FDRE \result1_reg[16] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[16]_i_1_n_0 ),
        .Q(result1[16]),
        .R(rst));
  FDRE \result1_reg[17] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[17]_i_1_n_0 ),
        .Q(result1[17]),
        .R(rst));
  FDRE \result1_reg[18] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[18]_i_1_n_0 ),
        .Q(result1[18]),
        .R(rst));
  FDRE \result1_reg[19] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[19]_i_1_n_0 ),
        .Q(result1[19]),
        .R(rst));
  FDRE \result1_reg[1] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[1]_i_1_n_0 ),
        .Q(result1[1]),
        .R(rst));
  FDRE \result1_reg[20] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[20]_i_1_n_0 ),
        .Q(result1[20]),
        .R(rst));
  FDRE \result1_reg[21] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[21]_i_2_n_0 ),
        .Q(result1[21]),
        .R(rst));
  FDRE \result1_reg[2] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[2]_i_1_n_0 ),
        .Q(result1[2]),
        .R(rst));
  FDRE \result1_reg[3] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[3]_i_1_n_0 ),
        .Q(result1[3]),
        .R(rst));
  FDRE \result1_reg[4] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[4]_i_1_n_0 ),
        .Q(result1[4]),
        .R(rst));
  FDRE \result1_reg[5] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[5]_i_1_n_0 ),
        .Q(result1[5]),
        .R(rst));
  FDRE \result1_reg[6] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[6]_i_1_n_0 ),
        .Q(result1[6]),
        .R(rst));
  FDRE \result1_reg[7] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[7]_i_1_n_0 ),
        .Q(result1[7]),
        .R(rst));
  FDRE \result1_reg[8] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[8]_i_1_n_0 ),
        .Q(result1[8]),
        .R(rst));
  FDRE \result1_reg[9] 
       (.C(s_axi_aclk),
        .CE(\result1[21]_i_1_n_0 ),
        .D(\result1[9]_i_1_n_0 ),
        .Q(result1[9]),
        .R(rst));
  LUT1 #(
    .INIT(2'h1)) 
    s_axi_awready_i_1
       (.I0(s_axi_aresetn),
        .O(rst));
  LUT6 #(
    .INIT(64'h1310101010101010)) 
    \s_axi_rdata[0]_i_1 
       (.I0(\s_axi_rdata[0]_i_2_n_0 ),
        .I1(\s_axi_rdata_reg[0] ),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[2]),
        .I4(s_axi_araddr[1]),
        .I5(result1[0]),
        .O(D[0]));
  LUT4 #(
    .INIT(16'h5F30)) 
    \s_axi_rdata[0]_i_2 
       (.I0(ovf0),
        .I1(result0[0]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000080)) 
    \s_axi_rdata[10]_i_1 
       (.I0(result1[10]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[10]_i_2_n_0 ),
        .O(D[10]));
  LUT6 #(
    .INIT(64'h0000000038301810)) 
    \s_axi_rdata[10]_i_2 
       (.I0(s_axi_araddr[0]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(result0[10]),
        .I4(steps_reg[6]),
        .I5(s_axi_araddr[1]),
        .O(\s_axi_rdata[10]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[11]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[11]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[11]),
        .I4(steps_reg[7]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[11]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000080)) 
    \s_axi_rdata[12]_i_1 
       (.I0(result1[12]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[12]_i_2_n_0 ),
        .O(D[12]));
  LUT6 #(
    .INIT(64'h0000000038301810)) 
    \s_axi_rdata[12]_i_2 
       (.I0(s_axi_araddr[0]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(result0[12]),
        .I4(steps_reg[8]),
        .I5(s_axi_araddr[1]),
        .O(\s_axi_rdata[12]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[13]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[13]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[13]),
        .I4(steps_reg[9]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[13]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000080)) 
    \s_axi_rdata[14]_i_1 
       (.I0(result1[14]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[14]_i_2_n_0 ),
        .O(D[14]));
  LUT6 #(
    .INIT(64'h0000000038301810)) 
    \s_axi_rdata[14]_i_2 
       (.I0(s_axi_araddr[0]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(result0[14]),
        .I4(steps_reg[10]),
        .I5(s_axi_araddr[1]),
        .O(\s_axi_rdata[14]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[15]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[15]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[15]),
        .I4(steps_reg[11]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[15]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[16]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[16]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[16]),
        .I4(steps_reg[12]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[16]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[17]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[17]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[17]),
        .I4(steps_reg[13]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[17]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[18]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[18]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[18]),
        .I4(steps_reg[14]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[18]));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[19]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[19]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[19]),
        .I4(steps_reg[15]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[19]));
  LUT6 #(
    .INIT(64'h1310101010101010)) 
    \s_axi_rdata[1]_i_1 
       (.I0(\s_axi_rdata[1]_i_2_n_0 ),
        .I1(\s_axi_rdata_reg[1] ),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[2]),
        .I4(s_axi_araddr[1]),
        .I5(result1[1]),
        .O(D[1]));
  LUT4 #(
    .INIT(16'h5F30)) 
    \s_axi_rdata[1]_i_2 
       (.I0(ovf1),
        .I1(result0[1]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000080)) 
    \s_axi_rdata[20]_i_1 
       (.I0(result1[20]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[20]_i_2_n_0 ),
        .O(D[20]));
  LUT6 #(
    .INIT(64'h0000000038301810)) 
    \s_axi_rdata[20]_i_2 
       (.I0(s_axi_araddr[0]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(result0[20]),
        .I4(steps_reg[16]),
        .I5(s_axi_araddr[1]),
        .O(\s_axi_rdata[20]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[21]_i_1 
       (.I0(steps_reg[17]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[21]));
  LUT6 #(
    .INIT(64'hFFFFFFFF55550040)) 
    \s_axi_rdata[22]_i_1 
       (.I0(s_axi_araddr[1]),
        .I1(steps_reg[18]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[2]),
        .I4(\s_axi_rdata[30]_i_2_n_0 ),
        .I5(\s_axi_rdata[30]_i_3_n_0 ),
        .O(D[22]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[23]_i_1 
       (.I0(steps_reg[19]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[23]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[24]_i_1 
       (.I0(steps_reg[20]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[24]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[25]_i_1 
       (.I0(steps_reg[21]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[25]));
  LUT6 #(
    .INIT(64'hFFFFFFFF55550040)) 
    \s_axi_rdata[26]_i_1 
       (.I0(s_axi_araddr[1]),
        .I1(steps_reg[22]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[2]),
        .I4(\s_axi_rdata[30]_i_2_n_0 ),
        .I5(\s_axi_rdata[30]_i_3_n_0 ),
        .O(D[26]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[27]_i_1 
       (.I0(steps_reg[23]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[27]));
  LUT6 #(
    .INIT(64'hFFFFFFFF55550040)) 
    \s_axi_rdata[28]_i_1 
       (.I0(s_axi_araddr[1]),
        .I1(steps_reg[24]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[2]),
        .I4(\s_axi_rdata[30]_i_2_n_0 ),
        .I5(\s_axi_rdata[30]_i_3_n_0 ),
        .O(D[28]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[29]_i_1 
       (.I0(steps_reg[25]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[29]));
  LUT6 #(
    .INIT(64'h1310101010101010)) 
    \s_axi_rdata[2]_i_1 
       (.I0(\s_axi_rdata[2]_i_2_n_0 ),
        .I1(\s_axi_rdata_reg[2] ),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[2]),
        .I4(s_axi_araddr[1]),
        .I5(result1[2]),
        .O(D[2]));
  LUT4 #(
    .INIT(16'h5F30)) 
    \s_axi_rdata[2]_i_2 
       (.I0(ptr[0]),
        .I1(result0[2]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55550040)) 
    \s_axi_rdata[30]_i_1 
       (.I0(s_axi_araddr[1]),
        .I1(steps_reg[26]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[2]),
        .I4(\s_axi_rdata[30]_i_2_n_0 ),
        .I5(\s_axi_rdata[30]_i_3_n_0 ),
        .O(D[30]));
  LUT4 #(
    .INIT(16'h2404)) 
    \s_axi_rdata[30]_i_2 
       (.I0(s_axi_araddr[2]),
        .I1(s_axi_araddr[3]),
        .I2(s_axi_araddr[0]),
        .I3(result0[21]),
        .O(\s_axi_rdata[30]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h10000000)) 
    \s_axi_rdata[30]_i_3 
       (.I0(s_axi_araddr[0]),
        .I1(s_axi_araddr[3]),
        .I2(result1[21]),
        .I3(s_axi_araddr[2]),
        .I4(s_axi_araddr[1]),
        .O(\s_axi_rdata[30]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00200000)) 
    \s_axi_rdata[31]_i_2 
       (.I0(steps_reg[27]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(s_axi_araddr[1]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[31]_i_3_n_0 ),
        .O(D[31]));
  LUT6 #(
    .INIT(64'h0300080800000000)) 
    \s_axi_rdata[31]_i_3 
       (.I0(result0[21]),
        .I1(s_axi_araddr[0]),
        .I2(s_axi_araddr[3]),
        .I3(result1[21]),
        .I4(s_axi_araddr[1]),
        .I5(s_axi_araddr[2]),
        .O(\s_axi_rdata[31]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'h00AA00AA0000CF00)) 
    \s_axi_rdata[3]_i_1 
       (.I0(\s_axi_rdata[3]_i_2_n_0 ),
        .I1(steps_reg[0]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[1]),
        .I5(s_axi_araddr[2]),
        .O(D[3]));
  LUT5 #(
    .INIT(32'hFCA00CA0)) 
    \s_axi_rdata[3]_i_2 
       (.I0(result0[3]),
        .I1(result1[3]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[1]),
        .I4(ptr[1]),
        .O(\s_axi_rdata[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00AA00AA0000CF00)) 
    \s_axi_rdata[4]_i_1 
       (.I0(\s_axi_rdata[4]_i_2_n_0 ),
        .I1(steps_reg[1]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[1]),
        .I5(s_axi_araddr[2]),
        .O(D[4]));
  LUT5 #(
    .INIT(32'hFCA00CA0)) 
    \s_axi_rdata[4]_i_2 
       (.I0(result0[4]),
        .I1(result1[4]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[1]),
        .I4(ptr[2]),
        .O(\s_axi_rdata[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h00AA00AA0000CF00)) 
    \s_axi_rdata[5]_i_1 
       (.I0(\s_axi_rdata[5]_i_2_n_0 ),
        .I1(steps_reg[2]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[1]),
        .I5(s_axi_araddr[2]),
        .O(D[5]));
  LUT5 #(
    .INIT(32'hFCA00CA0)) 
    \s_axi_rdata[5]_i_2 
       (.I0(result0[5]),
        .I1(result1[5]),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[1]),
        .I4(ptr[3]),
        .O(\s_axi_rdata[5]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h1310101010101010)) 
    \s_axi_rdata[6]_i_1 
       (.I0(\s_axi_rdata[6]_i_2_n_0 ),
        .I1(\s_axi_rdata_reg[6] ),
        .I2(s_axi_araddr[0]),
        .I3(s_axi_araddr[2]),
        .I4(s_axi_araddr[1]),
        .I5(result1[6]),
        .O(D[6]));
  LUT4 #(
    .INIT(16'h5F30)) 
    \s_axi_rdata[6]_i_2 
       (.I0(ptr[4]),
        .I1(result0[6]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[6]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[7]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[7]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[7]),
        .I4(steps_reg[3]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[7]));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000080)) 
    \s_axi_rdata[8]_i_1 
       (.I0(result1[8]),
        .I1(s_axi_araddr[1]),
        .I2(s_axi_araddr[2]),
        .I3(s_axi_araddr[3]),
        .I4(s_axi_araddr[0]),
        .I5(\s_axi_rdata[8]_i_2_n_0 ),
        .O(D[8]));
  LUT6 #(
    .INIT(64'h0000000038301810)) 
    \s_axi_rdata[8]_i_2 
       (.I0(s_axi_araddr[0]),
        .I1(s_axi_araddr[2]),
        .I2(s_axi_araddr[3]),
        .I3(result0[8]),
        .I4(steps_reg[4]),
        .I5(s_axi_araddr[1]),
        .O(\s_axi_rdata[8]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFF888F888F888)) 
    \s_axi_rdata[9]_i_1 
       (.I0(\s_axi_rdata_reg[7] ),
        .I1(result1[9]),
        .I2(\s_axi_rdata_reg[7]_0 ),
        .I3(result0[9]),
        .I4(steps_reg[5]),
        .I5(\s_axi_rdata_reg[7]_1 ),
        .O(D[9]));
  FDRE sel_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(sel_reg_0),
        .Q(sel0),
        .R(rst));
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq0[0]_i_1 
       (.I0(\prm_reg_n_0_[5][7] ),
        .I1(\prm_reg_n_0_[5][4] ),
        .I2(\prm_reg_n_0_[5][5] ),
        .I3(\prm_reg_n_0_[5][6] ),
        .I4(\prm_reg_n_0_[5][0] ),
        .O(clip_shift_return[0]));
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq0[1]_i_1 
       (.I0(\prm_reg_n_0_[5][7] ),
        .I1(\prm_reg_n_0_[5][4] ),
        .I2(\prm_reg_n_0_[5][5] ),
        .I3(\prm_reg_n_0_[5][6] ),
        .I4(\prm_reg_n_0_[5][1] ),
        .O(clip_shift_return[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq0[2]_i_1 
       (.I0(\prm_reg_n_0_[5][7] ),
        .I1(\prm_reg_n_0_[5][4] ),
        .I2(\prm_reg_n_0_[5][5] ),
        .I3(\prm_reg_n_0_[5][6] ),
        .I4(\prm_reg_n_0_[5][2] ),
        .O(clip_shift_return[2]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq0[3]_i_1 
       (.I0(\prm_reg_n_0_[5][7] ),
        .I1(\prm_reg_n_0_[5][4] ),
        .I2(\prm_reg_n_0_[5][5] ),
        .I3(\prm_reg_n_0_[5][6] ),
        .I4(\prm_reg_n_0_[5][3] ),
        .O(clip_shift_return[3]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \shq0[4]_i_1 
       (.I0(\prm_reg_n_0_[5][7] ),
        .I1(\prm_reg_n_0_[5][4] ),
        .I2(\prm_reg_n_0_[5][5] ),
        .I3(\prm_reg_n_0_[5][6] ),
        .O(\shq0[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hFE)) 
    \shq0[5]_i_1 
       (.I0(\prm_reg_n_0_[5][7] ),
        .I1(\prm_reg_n_0_[5][6] ),
        .I2(\prm_reg_n_0_[5][5] ),
        .O(clip_shift_return[5]));
  FDRE \shq0_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift_return[0]),
        .Q(shq0[0]),
        .R(rst));
  FDRE \shq0_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift_return[1]),
        .Q(shq0[1]),
        .R(rst));
  FDRE \shq0_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift_return[2]),
        .Q(shq0[2]),
        .R(rst));
  FDRE \shq0_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift_return[3]),
        .Q(shq0[3]),
        .R(rst));
  FDRE \shq0_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(\shq0[4]_i_1_n_0 ),
        .Q(shq0[4]),
        .R(rst));
  FDRE \shq0_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift_return[5]),
        .Q(shq0[5]),
        .R(rst));
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq1[0]_i_1 
       (.I0(\prm_reg_n_0_[11][7] ),
        .I1(\prm_reg_n_0_[11][4] ),
        .I2(\prm_reg_n_0_[11][5] ),
        .I3(\prm_reg_n_0_[11][6] ),
        .I4(\prm_reg_n_0_[11][0] ),
        .O(clip_shift0_return[0]));
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq1[1]_i_1 
       (.I0(\prm_reg_n_0_[11][7] ),
        .I1(\prm_reg_n_0_[11][4] ),
        .I2(\prm_reg_n_0_[11][5] ),
        .I3(\prm_reg_n_0_[11][6] ),
        .I4(\prm_reg_n_0_[11][1] ),
        .O(clip_shift0_return[1]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq1[2]_i_1 
       (.I0(\prm_reg_n_0_[11][7] ),
        .I1(\prm_reg_n_0_[11][4] ),
        .I2(\prm_reg_n_0_[11][5] ),
        .I3(\prm_reg_n_0_[11][6] ),
        .I4(\prm_reg_n_0_[11][2] ),
        .O(clip_shift0_return[2]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'hFFFFFFEA)) 
    \shq1[3]_i_1 
       (.I0(\prm_reg_n_0_[11][7] ),
        .I1(\prm_reg_n_0_[11][4] ),
        .I2(\prm_reg_n_0_[11][5] ),
        .I3(\prm_reg_n_0_[11][6] ),
        .I4(\prm_reg_n_0_[11][3] ),
        .O(clip_shift0_return[3]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \shq1[4]_i_1 
       (.I0(\prm_reg_n_0_[11][7] ),
        .I1(\prm_reg_n_0_[11][4] ),
        .I2(\prm_reg_n_0_[11][5] ),
        .I3(\prm_reg_n_0_[11][6] ),
        .O(\shq1[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hFE)) 
    \shq1[5]_i_1 
       (.I0(\prm_reg_n_0_[11][7] ),
        .I1(\prm_reg_n_0_[11][6] ),
        .I2(\prm_reg_n_0_[11][5] ),
        .O(clip_shift0_return[5]));
  FDRE \shq1_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift0_return[0]),
        .Q(\shq1_reg_n_0_[0] ),
        .R(rst));
  FDRE \shq1_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift0_return[1]),
        .Q(\shq1_reg_n_0_[1] ),
        .R(rst));
  FDRE \shq1_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift0_return[2]),
        .Q(\shq1_reg_n_0_[2] ),
        .R(rst));
  FDRE \shq1_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift0_return[3]),
        .Q(\shq1_reg_n_0_[3] ),
        .R(rst));
  FDRE \shq1_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(\shq1[4]_i_1_n_0 ),
        .Q(\shq1_reg_n_0_[4] ),
        .R(rst));
  FDRE \shq1_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(clip_shift0_return[5]),
        .Q(\shq1_reg_n_0_[5] ),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hFE)) 
    \steps[0]_i_1 
       (.I0(\acc0_reg[21]_0 ),
        .I1(\acc0_reg[21]_1 ),
        .I2(\acc0_reg[21]_2 ),
        .O(step));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-12 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(0),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(1),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    t_reg
       (.A({A[24],A[24],A[24],A[24],A[24],A}),
        .ACIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ACOUT(NLW_t_reg_ACOUT_UNCONNECTED[29:0]),
        .ALUMODE({1'b0,1'b0,1'b0,1'b0}),
        .B({1'b0,1'b0,t_reg_i_2_n_0,t_reg_i_3_n_0,t_reg_i_4_n_0,t_reg_i_5_n_0,t_reg_i_6_n_0,t_reg_i_7_n_0,t_reg_i_8_n_0,t_reg_i_9_n_0,t_reg_i_10_n_0,t_reg_i_11_n_0,t_reg_i_12_n_0,t_reg_i_13_n_0,t_reg_i_14_n_0,t_reg_i_15_n_0,t_reg_i_16_n_0,t_reg_i_17_n_0}),
        .BCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BCOUT(NLW_t_reg_BCOUT_UNCONNECTED[17:0]),
        .C({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .CARRYCASCIN(1'b0),
        .CARRYCASCOUT(NLW_t_reg_CARRYCASCOUT_UNCONNECTED),
        .CARRYIN(1'b0),
        .CARRYINSEL({1'b0,1'b0,1'b0}),
        .CARRYOUT(NLW_t_reg_CARRYOUT_UNCONNECTED[3:0]),
        .CEA1(1'b0),
        .CEA2(1'b0),
        .CEAD(1'b0),
        .CEALUMODE(1'b0),
        .CEB1(1'b0),
        .CEB2(1'b0),
        .CEC(1'b0),
        .CECARRYIN(1'b0),
        .CECTRL(1'b0),
        .CED(1'b0),
        .CEINMODE(1'b0),
        .CEM(1'b0),
        .CEP(CEP),
        .CLK(s_axi_aclk),
        .D({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .INMODE({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MULTSIGNIN(1'b0),
        .MULTSIGNOUT(NLW_t_reg_MULTSIGNOUT_UNCONNECTED),
        .OPMODE({1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b1}),
        .OVERFLOW(NLW_t_reg_OVERFLOW_UNCONNECTED),
        .P({NLW_t_reg_P_UNCONNECTED[47:42],t_reg_n_64,t_reg_n_65,t_reg_n_66,t_reg_n_67,t_reg_n_68,t_reg_n_69,t_reg_n_70,t_reg_n_71,t_reg_n_72,t_reg_n_73,t_reg_n_74,t_reg_n_75,t_reg_n_76,t_reg_n_77,t_reg_n_78,t_reg_n_79,t_reg_n_80,t_reg_n_81,t_reg_n_82,t_reg_n_83,t_reg_n_84,t_reg_n_85,t_reg_n_86,t_reg_n_87,t_reg_n_88,t_reg_n_89,t_reg_n_90,t_reg_n_91,t_reg_n_92,t_reg_n_93,t_reg_n_94,t_reg_n_95,t_reg_n_96,t_reg_n_97,t_reg_n_98,t_reg_n_99,t_reg_n_100,t_reg_n_101,t_reg_n_102,t_reg_n_103,t_reg_n_104,t_reg_n_105}),
        .PATTERNBDETECT(NLW_t_reg_PATTERNBDETECT_UNCONNECTED),
        .PATTERNDETECT(NLW_t_reg_PATTERNDETECT_UNCONNECTED),
        .PCIN({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .PCOUT(NLW_t_reg_PCOUT_UNCONNECTED[47:0]),
        .RSTA(1'b0),
        .RSTALLCARRYIN(1'b0),
        .RSTALUMODE(1'b0),
        .RSTB(1'b0),
        .RSTC(1'b0),
        .RSTCTRL(1'b0),
        .RSTD(1'b0),
        .RSTINMODE(1'b0),
        .RSTM(1'b0),
        .RSTP(rst),
        .UNDERFLOW(NLW_t_reg_UNDERFLOW_UNCONNECTED));
  LUT2 #(
    .INIT(4'h6)) 
    t_reg_i_1
       (.I0(\phase_reg[1]_rep__0_n_0 ),
        .I1(\phase_reg[0]_rep_n_0 ),
        .O(CEP));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_10
       (.I0(mq0[7]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[7]),
        .O(t_reg_i_10_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_11
       (.I0(mq0[6]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[6]),
        .O(t_reg_i_11_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_12
       (.I0(mq0[5]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[5]),
        .O(t_reg_i_12_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_13
       (.I0(mq0[4]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[4]),
        .O(t_reg_i_13_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_14
       (.I0(mq0[3]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[3]),
        .O(t_reg_i_14_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_15
       (.I0(mq0[2]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[2]),
        .O(t_reg_i_15_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_16
       (.I0(mq0[1]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[1]),
        .O(t_reg_i_16_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_17
       (.I0(mq0[0]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[0]),
        .O(t_reg_i_17_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_18
       (.I0(vq0[24]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[24] ),
        .O(A[24]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_19
       (.I0(vq0[23]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[23] ),
        .O(A[23]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_2
       (.I0(mq0[15]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[15]),
        .O(t_reg_i_2_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_20
       (.I0(vq0[22]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[22] ),
        .O(A[22]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_21
       (.I0(vq0[21]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[21] ),
        .O(A[21]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_22
       (.I0(vq0[20]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[20] ),
        .O(A[20]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_23
       (.I0(vq0[19]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[19] ),
        .O(A[19]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_24
       (.I0(vq0[18]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[18] ),
        .O(A[18]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_25
       (.I0(vq0[17]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[17] ),
        .O(A[17]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_26
       (.I0(vq0[16]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[16] ),
        .O(A[16]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_27
       (.I0(vq0[15]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[15] ),
        .O(A[15]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_28
       (.I0(vq0[14]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[14] ),
        .O(A[14]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_29
       (.I0(vq0[13]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[13] ),
        .O(A[13]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_3
       (.I0(mq0[14]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[14]),
        .O(t_reg_i_3_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_30
       (.I0(vq0[12]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[12] ),
        .O(A[12]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_31
       (.I0(vq0[11]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[11] ),
        .O(A[11]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_32
       (.I0(vq0[10]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[10] ),
        .O(A[10]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_33
       (.I0(vq0[9]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[9] ),
        .O(A[9]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_34
       (.I0(vq0[8]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[8] ),
        .O(A[8]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_35
       (.I0(vq0[7]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[7] ),
        .O(A[7]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_36
       (.I0(vq0[6]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[6] ),
        .O(A[6]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_37
       (.I0(vq0[5]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[5] ),
        .O(A[5]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_38
       (.I0(vq0[4]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[4] ),
        .O(A[4]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_39
       (.I0(vq0[3]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[3] ),
        .O(A[3]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_4
       (.I0(mq0[13]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[13]),
        .O(t_reg_i_4_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_40
       (.I0(vq0[2]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[2] ),
        .O(A[2]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_41
       (.I0(vq0[1]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[1] ),
        .O(A[1]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_42
       (.I0(vq0[0]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(\vq1_reg_n_0_[0] ),
        .O(A[0]));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_5
       (.I0(mq0[12]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[12]),
        .O(t_reg_i_5_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_6
       (.I0(mq0[11]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[11]),
        .O(t_reg_i_6_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_7
       (.I0(mq0[10]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[10]),
        .O(t_reg_i_7_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_8
       (.I0(mq0[9]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[9]),
        .O(t_reg_i_8_n_0));
  LUT4 #(
    .INIT(16'hFB08)) 
    t_reg_i_9
       (.I0(mq0[8]),
        .I1(\phase_reg[0]_rep_n_0 ),
        .I2(\phase_reg[1]_rep__0_n_0 ),
        .I3(mq1[8]),
        .O(t_reg_i_9_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[11]_i_2 
       (.I0(acc0__0[11]),
        .I1(\prm_reg[1]_67 [3]),
        .O(\vq0[11]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[11]_i_3 
       (.I0(acc0__0[10]),
        .I1(\prm_reg[1]_67 [2]),
        .O(\vq0[11]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[11]_i_4 
       (.I0(acc0__0[9]),
        .I1(\prm_reg[1]_67 [1]),
        .O(\vq0[11]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[11]_i_5 
       (.I0(acc0__0[8]),
        .I1(\prm_reg[1]_67 [0]),
        .O(\vq0[11]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[15]_i_2 
       (.I0(acc0__0[15]),
        .I1(\prm_reg[1]_67 [7]),
        .O(\vq0[15]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[15]_i_3 
       (.I0(acc0__0[14]),
        .I1(\prm_reg[1]_67 [6]),
        .O(\vq0[15]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[15]_i_4 
       (.I0(acc0__0[13]),
        .I1(\prm_reg[1]_67 [5]),
        .O(\vq0[15]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[15]_i_5 
       (.I0(acc0__0[12]),
        .I1(\prm_reg[1]_67 [4]),
        .O(\vq0[15]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[19]_i_2 
       (.I0(acc0__0[19]),
        .I1(\prm_reg[2]_68 [3]),
        .O(\vq0[19]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[19]_i_3 
       (.I0(acc0__0[18]),
        .I1(\prm_reg[2]_68 [2]),
        .O(\vq0[19]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[19]_i_4 
       (.I0(acc0__0[17]),
        .I1(\prm_reg[2]_68 [1]),
        .O(\vq0[19]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[19]_i_5 
       (.I0(acc0__0[16]),
        .I1(\prm_reg[2]_68 [0]),
        .O(\vq0[19]_i_5_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \vq0[23]_i_2 
       (.I0(\prm_reg[2]_68 [5]),
        .O(\vq0[23]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \vq0[23]_i_3 
       (.I0(\prm_reg[2]_68 [6]),
        .I1(\prm_reg[2]_68 [7]),
        .O(\vq0[23]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \vq0[23]_i_4 
       (.I0(\prm_reg[2]_68 [5]),
        .I1(\prm_reg[2]_68 [6]),
        .O(\vq0[23]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[23]_i_5 
       (.I0(\prm_reg[2]_68 [5]),
        .I1(acc0__0[21]),
        .O(\vq0[23]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[23]_i_6 
       (.I0(acc0__0[20]),
        .I1(\prm_reg[2]_68 [4]),
        .O(\vq0[23]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[3]_i_2 
       (.I0(acc0__0[3]),
        .I1(\prm_reg[0]_66 [3]),
        .O(\vq0[3]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[3]_i_3 
       (.I0(acc0__0[2]),
        .I1(\prm_reg[0]_66 [2]),
        .O(\vq0[3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[3]_i_4 
       (.I0(acc0__0[1]),
        .I1(\prm_reg[0]_66 [1]),
        .O(\vq0[3]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[3]_i_5 
       (.I0(acc0__0[0]),
        .I1(\prm_reg[0]_66 [0]),
        .O(\vq0[3]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[7]_i_2 
       (.I0(acc0__0[7]),
        .I1(\prm_reg[0]_66 [7]),
        .O(\vq0[7]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[7]_i_3 
       (.I0(acc0__0[6]),
        .I1(\prm_reg[0]_66 [6]),
        .O(\vq0[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[7]_i_4 
       (.I0(acc0__0[5]),
        .I1(\prm_reg[0]_66 [5]),
        .O(\vq0[7]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq0[7]_i_5 
       (.I0(acc0__0[4]),
        .I1(\prm_reg[0]_66 [4]),
        .O(\vq0[7]_i_5_n_0 ));
  FDRE \vq0_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[0]),
        .Q(vq0[0]),
        .R(rst));
  FDRE \vq0_reg[10] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[10]),
        .Q(vq0[10]),
        .R(rst));
  FDRE \vq0_reg[11] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[11]),
        .Q(vq0[11]),
        .R(rst));
  CARRY4 \vq0_reg[11]_i_1 
       (.CI(\vq0_reg[7]_i_1_n_0 ),
        .CO({\vq0_reg[11]_i_1_n_0 ,\vq0_reg[11]_i_1_n_1 ,\vq0_reg[11]_i_1_n_2 ,\vq0_reg[11]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[11:8]),
        .O(v0[11:8]),
        .S({\vq0[11]_i_2_n_0 ,\vq0[11]_i_3_n_0 ,\vq0[11]_i_4_n_0 ,\vq0[11]_i_5_n_0 }));
  FDRE \vq0_reg[12] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[12]),
        .Q(vq0[12]),
        .R(rst));
  FDRE \vq0_reg[13] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[13]),
        .Q(vq0[13]),
        .R(rst));
  FDRE \vq0_reg[14] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[14]),
        .Q(vq0[14]),
        .R(rst));
  FDRE \vq0_reg[15] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[15]),
        .Q(vq0[15]),
        .R(rst));
  CARRY4 \vq0_reg[15]_i_1 
       (.CI(\vq0_reg[11]_i_1_n_0 ),
        .CO({\vq0_reg[15]_i_1_n_0 ,\vq0_reg[15]_i_1_n_1 ,\vq0_reg[15]_i_1_n_2 ,\vq0_reg[15]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[15:12]),
        .O(v0[15:12]),
        .S({\vq0[15]_i_2_n_0 ,\vq0[15]_i_3_n_0 ,\vq0[15]_i_4_n_0 ,\vq0[15]_i_5_n_0 }));
  FDRE \vq0_reg[16] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[16]),
        .Q(vq0[16]),
        .R(rst));
  FDRE \vq0_reg[17] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[17]),
        .Q(vq0[17]),
        .R(rst));
  FDRE \vq0_reg[18] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[18]),
        .Q(vq0[18]),
        .R(rst));
  FDRE \vq0_reg[19] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[19]),
        .Q(vq0[19]),
        .R(rst));
  CARRY4 \vq0_reg[19]_i_1 
       (.CI(\vq0_reg[15]_i_1_n_0 ),
        .CO({\vq0_reg[19]_i_1_n_0 ,\vq0_reg[19]_i_1_n_1 ,\vq0_reg[19]_i_1_n_2 ,\vq0_reg[19]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[19:16]),
        .O(v0[19:16]),
        .S({\vq0[19]_i_2_n_0 ,\vq0[19]_i_3_n_0 ,\vq0[19]_i_4_n_0 ,\vq0[19]_i_5_n_0 }));
  FDRE \vq0_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[1]),
        .Q(vq0[1]),
        .R(rst));
  FDRE \vq0_reg[20] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[20]),
        .Q(vq0[20]),
        .R(rst));
  FDRE \vq0_reg[21] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[21]),
        .Q(vq0[21]),
        .R(rst));
  FDRE \vq0_reg[22] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[22]),
        .Q(vq0[22]),
        .R(rst));
  FDRE \vq0_reg[23] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[23]),
        .Q(vq0[23]),
        .R(rst));
  CARRY4 \vq0_reg[23]_i_1 
       (.CI(\vq0_reg[19]_i_1_n_0 ),
        .CO({\vq0_reg[23]_i_1_n_0 ,\vq0_reg[23]_i_1_n_1 ,\vq0_reg[23]_i_1_n_2 ,\vq0_reg[23]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({\prm_reg[2]_68 [6:5],\vq0[23]_i_2_n_0 ,acc0__0[20]}),
        .O(v0[23:20]),
        .S({\vq0[23]_i_3_n_0 ,\vq0[23]_i_4_n_0 ,\vq0[23]_i_5_n_0 ,\vq0[23]_i_6_n_0 }));
  FDRE \vq0_reg[24] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[24]),
        .Q(vq0[24]),
        .R(rst));
  CARRY4 \vq0_reg[24]_i_1 
       (.CI(\vq0_reg[23]_i_1_n_0 ),
        .CO(\NLW_vq0_reg[24]_i_1_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_vq0_reg[24]_i_1_O_UNCONNECTED [3:1],v0[24]}),
        .S({1'b0,1'b0,1'b0,1'b1}));
  FDRE \vq0_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[2]),
        .Q(vq0[2]),
        .R(rst));
  FDRE \vq0_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[3]),
        .Q(vq0[3]),
        .R(rst));
  CARRY4 \vq0_reg[3]_i_1 
       (.CI(1'b0),
        .CO({\vq0_reg[3]_i_1_n_0 ,\vq0_reg[3]_i_1_n_1 ,\vq0_reg[3]_i_1_n_2 ,\vq0_reg[3]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[3:0]),
        .O(v0[3:0]),
        .S({\vq0[3]_i_2_n_0 ,\vq0[3]_i_3_n_0 ,\vq0[3]_i_4_n_0 ,\vq0[3]_i_5_n_0 }));
  FDRE \vq0_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[4]),
        .Q(vq0[4]),
        .R(rst));
  FDRE \vq0_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[5]),
        .Q(vq0[5]),
        .R(rst));
  FDRE \vq0_reg[6] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[6]),
        .Q(vq0[6]),
        .R(rst));
  FDRE \vq0_reg[7] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[7]),
        .Q(vq0[7]),
        .R(rst));
  CARRY4 \vq0_reg[7]_i_1 
       (.CI(\vq0_reg[3]_i_1_n_0 ),
        .CO({\vq0_reg[7]_i_1_n_0 ,\vq0_reg[7]_i_1_n_1 ,\vq0_reg[7]_i_1_n_2 ,\vq0_reg[7]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc0__0[7:4]),
        .O(v0[7:4]),
        .S({\vq0[7]_i_2_n_0 ,\vq0[7]_i_3_n_0 ,\vq0[7]_i_4_n_0 ,\vq0[7]_i_5_n_0 }));
  FDRE \vq0_reg[8] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[8]),
        .Q(vq0[8]),
        .R(rst));
  FDRE \vq0_reg[9] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v0[9]),
        .Q(vq0[9]),
        .R(rst));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[11]_i_2 
       (.I0(acc1__0[11]),
        .I1(\prm_reg[7]_64 [3]),
        .O(\vq1[11]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[11]_i_3 
       (.I0(acc1__0[10]),
        .I1(\prm_reg[7]_64 [2]),
        .O(\vq1[11]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[11]_i_4 
       (.I0(acc1__0[9]),
        .I1(\prm_reg[7]_64 [1]),
        .O(\vq1[11]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[11]_i_5 
       (.I0(acc1__0[8]),
        .I1(\prm_reg[7]_64 [0]),
        .O(\vq1[11]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[15]_i_2 
       (.I0(acc1__0[15]),
        .I1(\prm_reg[7]_64 [7]),
        .O(\vq1[15]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[15]_i_3 
       (.I0(acc1__0[14]),
        .I1(\prm_reg[7]_64 [6]),
        .O(\vq1[15]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[15]_i_4 
       (.I0(acc1__0[13]),
        .I1(\prm_reg[7]_64 [5]),
        .O(\vq1[15]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[15]_i_5 
       (.I0(acc1__0[12]),
        .I1(\prm_reg[7]_64 [4]),
        .O(\vq1[15]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[19]_i_2 
       (.I0(acc1__0[19]),
        .I1(\prm_reg[8]_65 [3]),
        .O(\vq1[19]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[19]_i_3 
       (.I0(acc1__0[18]),
        .I1(\prm_reg[8]_65 [2]),
        .O(\vq1[19]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[19]_i_4 
       (.I0(acc1__0[17]),
        .I1(\prm_reg[8]_65 [1]),
        .O(\vq1[19]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[19]_i_5 
       (.I0(acc1__0[16]),
        .I1(\prm_reg[8]_65 [0]),
        .O(\vq1[19]_i_5_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \vq1[23]_i_2 
       (.I0(\prm_reg[8]_65 [5]),
        .O(\vq1[23]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \vq1[23]_i_3 
       (.I0(\prm_reg[8]_65 [6]),
        .I1(\prm_reg[8]_65 [7]),
        .O(\vq1[23]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \vq1[23]_i_4 
       (.I0(\prm_reg[8]_65 [5]),
        .I1(\prm_reg[8]_65 [6]),
        .O(\vq1[23]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[23]_i_5 
       (.I0(\prm_reg[8]_65 [5]),
        .I1(acc1__0[21]),
        .O(\vq1[23]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[23]_i_6 
       (.I0(acc1__0[20]),
        .I1(\prm_reg[8]_65 [4]),
        .O(\vq1[23]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[3]_i_2 
       (.I0(acc1__0[3]),
        .I1(\prm_reg[6]_63 [3]),
        .O(\vq1[3]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[3]_i_3 
       (.I0(acc1__0[2]),
        .I1(\prm_reg[6]_63 [2]),
        .O(\vq1[3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[3]_i_4 
       (.I0(acc1__0[1]),
        .I1(\prm_reg[6]_63 [1]),
        .O(\vq1[3]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[3]_i_5 
       (.I0(acc1__0[0]),
        .I1(\prm_reg[6]_63 [0]),
        .O(\vq1[3]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[7]_i_2 
       (.I0(acc1__0[7]),
        .I1(\prm_reg[6]_63 [7]),
        .O(\vq1[7]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[7]_i_3 
       (.I0(acc1__0[6]),
        .I1(\prm_reg[6]_63 [6]),
        .O(\vq1[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[7]_i_4 
       (.I0(acc1__0[5]),
        .I1(\prm_reg[6]_63 [5]),
        .O(\vq1[7]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \vq1[7]_i_5 
       (.I0(acc1__0[4]),
        .I1(\prm_reg[6]_63 [4]),
        .O(\vq1[7]_i_5_n_0 ));
  FDRE \vq1_reg[0] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[0]),
        .Q(\vq1_reg_n_0_[0] ),
        .R(rst));
  FDRE \vq1_reg[10] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[10]),
        .Q(\vq1_reg_n_0_[10] ),
        .R(rst));
  FDRE \vq1_reg[11] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[11]),
        .Q(\vq1_reg_n_0_[11] ),
        .R(rst));
  CARRY4 \vq1_reg[11]_i_1 
       (.CI(\vq1_reg[7]_i_1_n_0 ),
        .CO({\vq1_reg[11]_i_1_n_0 ,\vq1_reg[11]_i_1_n_1 ,\vq1_reg[11]_i_1_n_2 ,\vq1_reg[11]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[11:8]),
        .O(v1[11:8]),
        .S({\vq1[11]_i_2_n_0 ,\vq1[11]_i_3_n_0 ,\vq1[11]_i_4_n_0 ,\vq1[11]_i_5_n_0 }));
  FDRE \vq1_reg[12] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[12]),
        .Q(\vq1_reg_n_0_[12] ),
        .R(rst));
  FDRE \vq1_reg[13] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[13]),
        .Q(\vq1_reg_n_0_[13] ),
        .R(rst));
  FDRE \vq1_reg[14] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[14]),
        .Q(\vq1_reg_n_0_[14] ),
        .R(rst));
  FDRE \vq1_reg[15] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[15]),
        .Q(\vq1_reg_n_0_[15] ),
        .R(rst));
  CARRY4 \vq1_reg[15]_i_1 
       (.CI(\vq1_reg[11]_i_1_n_0 ),
        .CO({\vq1_reg[15]_i_1_n_0 ,\vq1_reg[15]_i_1_n_1 ,\vq1_reg[15]_i_1_n_2 ,\vq1_reg[15]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[15:12]),
        .O(v1[15:12]),
        .S({\vq1[15]_i_2_n_0 ,\vq1[15]_i_3_n_0 ,\vq1[15]_i_4_n_0 ,\vq1[15]_i_5_n_0 }));
  FDRE \vq1_reg[16] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[16]),
        .Q(\vq1_reg_n_0_[16] ),
        .R(rst));
  FDRE \vq1_reg[17] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[17]),
        .Q(\vq1_reg_n_0_[17] ),
        .R(rst));
  FDRE \vq1_reg[18] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[18]),
        .Q(\vq1_reg_n_0_[18] ),
        .R(rst));
  FDRE \vq1_reg[19] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[19]),
        .Q(\vq1_reg_n_0_[19] ),
        .R(rst));
  CARRY4 \vq1_reg[19]_i_1 
       (.CI(\vq1_reg[15]_i_1_n_0 ),
        .CO({\vq1_reg[19]_i_1_n_0 ,\vq1_reg[19]_i_1_n_1 ,\vq1_reg[19]_i_1_n_2 ,\vq1_reg[19]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[19:16]),
        .O(v1[19:16]),
        .S({\vq1[19]_i_2_n_0 ,\vq1[19]_i_3_n_0 ,\vq1[19]_i_4_n_0 ,\vq1[19]_i_5_n_0 }));
  FDRE \vq1_reg[1] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[1]),
        .Q(\vq1_reg_n_0_[1] ),
        .R(rst));
  FDRE \vq1_reg[20] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[20]),
        .Q(\vq1_reg_n_0_[20] ),
        .R(rst));
  FDRE \vq1_reg[21] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[21]),
        .Q(\vq1_reg_n_0_[21] ),
        .R(rst));
  FDRE \vq1_reg[22] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[22]),
        .Q(\vq1_reg_n_0_[22] ),
        .R(rst));
  FDRE \vq1_reg[23] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[23]),
        .Q(\vq1_reg_n_0_[23] ),
        .R(rst));
  CARRY4 \vq1_reg[23]_i_1 
       (.CI(\vq1_reg[19]_i_1_n_0 ),
        .CO({\vq1_reg[23]_i_1_n_0 ,\vq1_reg[23]_i_1_n_1 ,\vq1_reg[23]_i_1_n_2 ,\vq1_reg[23]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({\prm_reg[8]_65 [6:5],\vq1[23]_i_2_n_0 ,acc1__0[20]}),
        .O(v1[23:20]),
        .S({\vq1[23]_i_3_n_0 ,\vq1[23]_i_4_n_0 ,\vq1[23]_i_5_n_0 ,\vq1[23]_i_6_n_0 }));
  FDRE \vq1_reg[24] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[24]),
        .Q(\vq1_reg_n_0_[24] ),
        .R(rst));
  CARRY4 \vq1_reg[24]_i_1 
       (.CI(\vq1_reg[23]_i_1_n_0 ),
        .CO(\NLW_vq1_reg[24]_i_1_CO_UNCONNECTED [3:0]),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_vq1_reg[24]_i_1_O_UNCONNECTED [3:1],v1[24]}),
        .S({1'b0,1'b0,1'b0,1'b1}));
  FDRE \vq1_reg[2] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[2]),
        .Q(\vq1_reg_n_0_[2] ),
        .R(rst));
  FDRE \vq1_reg[3] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[3]),
        .Q(\vq1_reg_n_0_[3] ),
        .R(rst));
  CARRY4 \vq1_reg[3]_i_1 
       (.CI(1'b0),
        .CO({\vq1_reg[3]_i_1_n_0 ,\vq1_reg[3]_i_1_n_1 ,\vq1_reg[3]_i_1_n_2 ,\vq1_reg[3]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[3:0]),
        .O(v1[3:0]),
        .S({\vq1[3]_i_2_n_0 ,\vq1[3]_i_3_n_0 ,\vq1[3]_i_4_n_0 ,\vq1[3]_i_5_n_0 }));
  FDRE \vq1_reg[4] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[4]),
        .Q(\vq1_reg_n_0_[4] ),
        .R(rst));
  FDRE \vq1_reg[5] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[5]),
        .Q(\vq1_reg_n_0_[5] ),
        .R(rst));
  FDRE \vq1_reg[6] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[6]),
        .Q(\vq1_reg_n_0_[6] ),
        .R(rst));
  FDRE \vq1_reg[7] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[7]),
        .Q(\vq1_reg_n_0_[7] ),
        .R(rst));
  CARRY4 \vq1_reg[7]_i_1 
       (.CI(\vq1_reg[3]_i_1_n_0 ),
        .CO({\vq1_reg[7]_i_1_n_0 ,\vq1_reg[7]_i_1_n_1 ,\vq1_reg[7]_i_1_n_2 ,\vq1_reg[7]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(acc1__0[7:4]),
        .O(v1[7:4]),
        .S({\vq1[7]_i_2_n_0 ,\vq1[7]_i_3_n_0 ,\vq1[7]_i_4_n_0 ,\vq1[7]_i_5_n_0 }));
  FDRE \vq1_reg[8] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[8]),
        .Q(\vq1_reg_n_0_[8] ),
        .R(rst));
  FDRE \vq1_reg[9] 
       (.C(s_axi_aclk),
        .CE(shq1),
        .D(v1[9]),
        .Q(\vq1_reg_n_0_[9] ),
        .R(rst));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
