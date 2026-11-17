// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Mon Nov 16 19:07:24 2026
// Host        : DESKTOP-VONROUT running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ system_tpu_0_sim_netlist.v
// Design      : system_tpu_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "system_tpu_0,tiny_tpu_axi,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "tiny_tpu_axi,Vivado 2019.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aclk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN system_ps7_0_FCLK_CLK0, INSERT_VIP 0" *) input s_axi_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_axi_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *) input [3:0]s_axi_awaddr;
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *) input [3:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *) input [2:0]s_axi_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *) input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *) output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *) output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *) output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *) output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 4, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN system_ps7_0_FCLK_CLK0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_rready;

  wire \<const0> ;
  wire s_axi_aclk;
  wire [3:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [3:0]s_axi_awaddr;
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

  assign s_axi_bresp[1] = \<const0> ;
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_rresp[1] = \<const0> ;
  assign s_axi_rresp[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_tiny_tpu_axi inst
       (.s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr[3:2]),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr[3:2]),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid_reg_0(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_tiny_tpu_axi
   (s_axi_wready,
    s_axi_awready,
    s_axi_arready,
    s_axi_rdata,
    s_axi_bvalid_reg_0,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_aclk,
    s_axi_awaddr,
    s_axi_awvalid,
    s_axi_araddr,
    s_axi_wvalid,
    s_axi_aresetn,
    s_axi_arvalid,
    s_axi_bready,
    s_axi_rready);
  output s_axi_wready;
  output s_axi_awready;
  output s_axi_arready;
  output [31:0]s_axi_rdata;
  output s_axi_bvalid_reg_0;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  input s_axi_aclk;
  input [1:0]s_axi_awaddr;
  input s_axi_awvalid;
  input [1:0]s_axi_araddr;
  input s_axi_wvalid;
  input s_axi_aresetn;
  input s_axi_arvalid;
  input s_axi_bready;
  input s_axi_rready;

  wire [3:0]B;
  wire [3:2]aw_addr;
  wire \aw_addr[2]_i_1_n_0 ;
  wire \aw_addr[3]_i_1_n_0 ;
  wire aw_have;
  wire aw_have_i_1_n_0;
  wire [1:0]cmd;
  wire [31:0]cmd_word;
  wire \cmd_word[10]_i_1_n_0 ;
  wire \cmd_word[11]_i_1_n_0 ;
  wire \cmd_word[12]_i_1_n_0 ;
  wire \cmd_word[13]_i_1_n_0 ;
  wire \cmd_word[14]_i_1_n_0 ;
  wire \cmd_word[15]_i_1_n_0 ;
  wire \cmd_word[16]_i_1_n_0 ;
  wire \cmd_word[17]_i_1_n_0 ;
  wire \cmd_word[18]_i_1_n_0 ;
  wire \cmd_word[19]_i_1_n_0 ;
  wire \cmd_word[20]_i_1_n_0 ;
  wire \cmd_word[21]_i_1_n_0 ;
  wire \cmd_word[22]_i_1_n_0 ;
  wire \cmd_word[23]_i_1_n_0 ;
  wire \cmd_word[24]_i_1_n_0 ;
  wire \cmd_word[25]_i_1_n_0 ;
  wire \cmd_word[26]_i_1_n_0 ;
  wire \cmd_word[27]_i_1_n_0 ;
  wire \cmd_word[28]_i_1_n_0 ;
  wire \cmd_word[29]_i_1_n_0 ;
  wire \cmd_word[30]_i_1_n_0 ;
  wire \cmd_word[31]_i_2_n_0 ;
  wire cmd_word_0;
  wire do_write;
  wire ovf;
  wire [15:0]result;
  wire rst;
  wire s_axi_aclk;
  wire [1:0]s_axi_araddr;
  wire s_axi_aresetn;
  wire s_axi_arready;
  wire s_axi_arready0__0;
  wire s_axi_arvalid;
  wire [1:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awready0;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire s_axi_bvalid_i_1_n_0;
  wire s_axi_bvalid_reg_0;
  wire [31:0]s_axi_rdata;
  wire \s_axi_rdata[0]_i_1_n_0 ;
  wire \s_axi_rdata[10]_i_1_n_0 ;
  wire \s_axi_rdata[11]_i_1_n_0 ;
  wire \s_axi_rdata[12]_i_1_n_0 ;
  wire \s_axi_rdata[13]_i_1_n_0 ;
  wire \s_axi_rdata[14]_i_1_n_0 ;
  wire \s_axi_rdata[15]_i_1_n_0 ;
  wire \s_axi_rdata[16]_i_1_n_0 ;
  wire \s_axi_rdata[17]_i_1_n_0 ;
  wire \s_axi_rdata[18]_i_1_n_0 ;
  wire \s_axi_rdata[19]_i_1_n_0 ;
  wire \s_axi_rdata[1]_i_1_n_0 ;
  wire \s_axi_rdata[20]_i_1_n_0 ;
  wire \s_axi_rdata[21]_i_1_n_0 ;
  wire \s_axi_rdata[22]_i_1_n_0 ;
  wire \s_axi_rdata[23]_i_1_n_0 ;
  wire \s_axi_rdata[24]_i_1_n_0 ;
  wire \s_axi_rdata[25]_i_1_n_0 ;
  wire \s_axi_rdata[26]_i_1_n_0 ;
  wire \s_axi_rdata[27]_i_1_n_0 ;
  wire \s_axi_rdata[28]_i_1_n_0 ;
  wire \s_axi_rdata[29]_i_1_n_0 ;
  wire \s_axi_rdata[2]_i_1_n_0 ;
  wire \s_axi_rdata[30]_i_1_n_0 ;
  wire \s_axi_rdata[31]_i_2_n_0 ;
  wire \s_axi_rdata[3]_i_1_n_0 ;
  wire \s_axi_rdata[4]_i_1_n_0 ;
  wire \s_axi_rdata[5]_i_1_n_0 ;
  wire \s_axi_rdata[6]_i_1_n_0 ;
  wire \s_axi_rdata[7]_i_1_n_0 ;
  wire \s_axi_rdata[8]_i_1_n_0 ;
  wire \s_axi_rdata[9]_i_1_n_0 ;
  wire s_axi_rready;
  wire s_axi_rvalid;
  wire s_axi_rvalid01_out;
  wire s_axi_rvalid_i_1_n_0;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire s_axi_wready0;
  wire s_axi_wvalid;
  wire u_pe_n_10;
  wire u_pe_n_11;
  wire u_pe_n_6;
  wire u_pe_n_7;
  wire [31:0]w_data;
  wire w_have_i_1_n_0;
  wire w_have_reg_n_0;
  wire w_take;

  LUT4 #(
    .INIT(16'hBF80)) 
    \aw_addr[2]_i_1 
       (.I0(s_axi_awaddr[0]),
        .I1(s_axi_awready),
        .I2(s_axi_awvalid),
        .I3(aw_addr[2]),
        .O(\aw_addr[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hBF80)) 
    \aw_addr[3]_i_1 
       (.I0(s_axi_awaddr[1]),
        .I1(s_axi_awready),
        .I2(s_axi_awvalid),
        .I3(aw_addr[3]),
        .O(\aw_addr[3]_i_1_n_0 ));
  FDRE \aw_addr_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\aw_addr[2]_i_1_n_0 ),
        .Q(aw_addr[2]),
        .R(rst));
  FDRE \aw_addr_reg[3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\aw_addr[3]_i_1_n_0 ),
        .Q(aw_addr[3]),
        .R(rst));
  LUT5 #(
    .INIT(32'h0000EA00)) 
    aw_have_i_1
       (.I0(aw_have),
        .I1(s_axi_awready),
        .I2(s_axi_awvalid),
        .I3(s_axi_aresetn),
        .I4(do_write),
        .O(aw_have_i_1_n_0));
  FDRE aw_have_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(aw_have_i_1_n_0),
        .Q(aw_have),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[10]_i_1 
       (.I0(w_data[10]),
        .I1(s_axi_wdata[10]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[11]_i_1 
       (.I0(w_data[11]),
        .I1(s_axi_wdata[11]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[12]_i_1 
       (.I0(w_data[12]),
        .I1(s_axi_wdata[12]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[13]_i_1 
       (.I0(w_data[13]),
        .I1(s_axi_wdata[13]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[14]_i_1 
       (.I0(w_data[14]),
        .I1(s_axi_wdata[14]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[15]_i_1 
       (.I0(w_data[15]),
        .I1(s_axi_wdata[15]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[16]_i_1 
       (.I0(w_data[16]),
        .I1(s_axi_wdata[16]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[17]_i_1 
       (.I0(w_data[17]),
        .I1(s_axi_wdata[17]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[18]_i_1 
       (.I0(w_data[18]),
        .I1(s_axi_wdata[18]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[18]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[19]_i_1 
       (.I0(w_data[19]),
        .I1(s_axi_wdata[19]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[19]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[20]_i_1 
       (.I0(w_data[20]),
        .I1(s_axi_wdata[20]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[20]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[21]_i_1 
       (.I0(w_data[21]),
        .I1(s_axi_wdata[21]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[22]_i_1 
       (.I0(w_data[22]),
        .I1(s_axi_wdata[22]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[22]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[23]_i_1 
       (.I0(w_data[23]),
        .I1(s_axi_wdata[23]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[23]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[24]_i_1 
       (.I0(w_data[24]),
        .I1(s_axi_wdata[24]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[24]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[25]_i_1 
       (.I0(w_data[25]),
        .I1(s_axi_wdata[25]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[25]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[26]_i_1 
       (.I0(w_data[26]),
        .I1(s_axi_wdata[26]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[26]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[27]_i_1 
       (.I0(w_data[27]),
        .I1(s_axi_wdata[27]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[27]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[28]_i_1 
       (.I0(w_data[28]),
        .I1(s_axi_wdata[28]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[28]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[29]_i_1 
       (.I0(w_data[29]),
        .I1(s_axi_wdata[29]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[29]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[30]_i_1 
       (.I0(w_data[30]),
        .I1(s_axi_wdata[30]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[30]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00002020000A202A)) 
    \cmd_word[31]_i_1 
       (.I0(do_write),
        .I1(aw_addr[3]),
        .I2(aw_have),
        .I3(s_axi_awaddr[1]),
        .I4(aw_addr[2]),
        .I5(s_axi_awaddr[0]),
        .O(cmd_word_0));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[31]_i_2 
       (.I0(w_data[31]),
        .I1(s_axi_wdata[31]),
        .I2(w_have_reg_n_0),
        .O(\cmd_word[31]_i_2_n_0 ));
  FDRE \cmd_word_reg[0] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(u_pe_n_11),
        .Q(cmd_word[0]),
        .R(rst));
  FDRE \cmd_word_reg[10] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[10]_i_1_n_0 ),
        .Q(cmd_word[10]),
        .R(rst));
  FDRE \cmd_word_reg[11] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[11]_i_1_n_0 ),
        .Q(cmd_word[11]),
        .R(rst));
  FDRE \cmd_word_reg[12] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[12]_i_1_n_0 ),
        .Q(cmd_word[12]),
        .R(rst));
  FDRE \cmd_word_reg[13] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[13]_i_1_n_0 ),
        .Q(cmd_word[13]),
        .R(rst));
  FDRE \cmd_word_reg[14] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[14]_i_1_n_0 ),
        .Q(cmd_word[14]),
        .R(rst));
  FDRE \cmd_word_reg[15] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[15]_i_1_n_0 ),
        .Q(cmd_word[15]),
        .R(rst));
  FDRE \cmd_word_reg[16] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[16]_i_1_n_0 ),
        .Q(cmd_word[16]),
        .R(rst));
  FDRE \cmd_word_reg[17] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[17]_i_1_n_0 ),
        .Q(cmd_word[17]),
        .R(rst));
  FDRE \cmd_word_reg[18] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[18]_i_1_n_0 ),
        .Q(cmd_word[18]),
        .R(rst));
  FDRE \cmd_word_reg[19] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[19]_i_1_n_0 ),
        .Q(cmd_word[19]),
        .R(rst));
  FDRE \cmd_word_reg[1] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(u_pe_n_10),
        .Q(cmd_word[1]),
        .R(rst));
  FDRE \cmd_word_reg[20] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[20]_i_1_n_0 ),
        .Q(cmd_word[20]),
        .R(rst));
  FDRE \cmd_word_reg[21] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[21]_i_1_n_0 ),
        .Q(cmd_word[21]),
        .R(rst));
  FDRE \cmd_word_reg[22] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[22]_i_1_n_0 ),
        .Q(cmd_word[22]),
        .R(rst));
  FDRE \cmd_word_reg[23] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[23]_i_1_n_0 ),
        .Q(cmd_word[23]),
        .R(rst));
  FDRE \cmd_word_reg[24] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[24]_i_1_n_0 ),
        .Q(cmd_word[24]),
        .R(rst));
  FDRE \cmd_word_reg[25] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[25]_i_1_n_0 ),
        .Q(cmd_word[25]),
        .R(rst));
  FDRE \cmd_word_reg[26] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[26]_i_1_n_0 ),
        .Q(cmd_word[26]),
        .R(rst));
  FDRE \cmd_word_reg[27] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[27]_i_1_n_0 ),
        .Q(cmd_word[27]),
        .R(rst));
  FDRE \cmd_word_reg[28] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[28]_i_1_n_0 ),
        .Q(cmd_word[28]),
        .R(rst));
  FDRE \cmd_word_reg[29] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[29]_i_1_n_0 ),
        .Q(cmd_word[29]),
        .R(rst));
  FDRE \cmd_word_reg[2] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(u_pe_n_7),
        .Q(cmd_word[2]),
        .R(rst));
  FDRE \cmd_word_reg[30] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[30]_i_1_n_0 ),
        .Q(cmd_word[30]),
        .R(rst));
  FDRE \cmd_word_reg[31] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(\cmd_word[31]_i_2_n_0 ),
        .Q(cmd_word[31]),
        .R(rst));
  FDRE \cmd_word_reg[3] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(u_pe_n_6),
        .Q(cmd_word[3]),
        .R(rst));
  FDRE \cmd_word_reg[4] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(B[0]),
        .Q(cmd_word[4]),
        .R(rst));
  FDRE \cmd_word_reg[5] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(B[1]),
        .Q(cmd_word[5]),
        .R(rst));
  FDRE \cmd_word_reg[6] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(B[2]),
        .Q(cmd_word[6]),
        .R(rst));
  FDRE \cmd_word_reg[7] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(B[3]),
        .Q(cmd_word[7]),
        .R(rst));
  FDRE \cmd_word_reg[8] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(cmd[0]),
        .Q(cmd_word[8]),
        .R(rst));
  FDRE \cmd_word_reg[9] 
       (.C(s_axi_aclk),
        .CE(cmd_word_0),
        .D(cmd[1]),
        .Q(cmd_word[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'h04)) 
    s_axi_arready0
       (.I0(s_axi_rvalid),
        .I1(s_axi_arvalid),
        .I2(s_axi_arready),
        .O(s_axi_arready0__0));
  FDRE s_axi_arready_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_arready0__0),
        .Q(s_axi_arready),
        .R(rst));
  LUT4 #(
    .INIT(16'h0015)) 
    s_axi_awready_i_2
       (.I0(s_axi_bvalid_reg_0),
        .I1(s_axi_awready),
        .I2(s_axi_awvalid),
        .I3(aw_have),
        .O(s_axi_awready0));
  FDRE s_axi_awready_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_awready0),
        .Q(s_axi_awready),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hAE)) 
    s_axi_bvalid_i_1
       (.I0(do_write),
        .I1(s_axi_bvalid_reg_0),
        .I2(s_axi_bready),
        .O(s_axi_bvalid_i_1_n_0));
  FDRE s_axi_bvalid_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_bvalid_i_1_n_0),
        .Q(s_axi_bvalid_reg_0),
        .R(rst));
  LUT5 #(
    .INIT(32'h30BB3088)) 
    \s_axi_rdata[0]_i_1 
       (.I0(result[0]),
        .I1(s_axi_araddr[0]),
        .I2(ovf),
        .I3(s_axi_araddr[1]),
        .I4(cmd_word[0]),
        .O(\s_axi_rdata[0]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[10]_i_1 
       (.I0(result[10]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[10]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[10]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[11]_i_1 
       (.I0(cmd_word[11]),
        .I1(s_axi_araddr[0]),
        .I2(result[11]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[11]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[12]_i_1 
       (.I0(result[12]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[12]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[12]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[13]_i_1 
       (.I0(cmd_word[13]),
        .I1(s_axi_araddr[0]),
        .I2(result[13]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[13]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[14]_i_1 
       (.I0(result[14]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[14]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[15]_i_1 
       (.I0(cmd_word[15]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[16]_i_1 
       (.I0(cmd_word[16]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[17]_i_1 
       (.I0(cmd_word[17]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[18]_i_1 
       (.I0(cmd_word[18]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[18]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[19]_i_1 
       (.I0(cmd_word[19]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[19]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[1]_i_1 
       (.I0(cmd_word[1]),
        .I1(s_axi_araddr[0]),
        .I2(result[1]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[20]_i_1 
       (.I0(result[15]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[20]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[20]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[21]_i_1 
       (.I0(cmd_word[21]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[21]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[22]_i_1 
       (.I0(result[15]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[22]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[22]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[23]_i_1 
       (.I0(cmd_word[23]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[23]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[24]_i_1 
       (.I0(cmd_word[24]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[24]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[25]_i_1 
       (.I0(cmd_word[25]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[25]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[26]_i_1 
       (.I0(result[15]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[26]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[26]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[27]_i_1 
       (.I0(cmd_word[27]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[27]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[28]_i_1 
       (.I0(result[15]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[28]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[28]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[29]_i_1 
       (.I0(cmd_word[29]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[29]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[2]_i_1 
       (.I0(result[2]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[2]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[30]_i_1 
       (.I0(result[15]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[30]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[30]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \s_axi_rdata[31]_i_1 
       (.I0(s_axi_arready),
        .I1(s_axi_arvalid),
        .O(s_axi_rvalid01_out));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[31]_i_2 
       (.I0(cmd_word[31]),
        .I1(s_axi_araddr[0]),
        .I2(result[15]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[31]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[3]_i_1 
       (.I0(cmd_word[3]),
        .I1(s_axi_araddr[0]),
        .I2(result[3]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[3]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[4]_i_1 
       (.I0(result[4]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[4]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[4]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[5]_i_1 
       (.I0(result[5]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[5]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[5]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[6]_i_1 
       (.I0(cmd_word[6]),
        .I1(s_axi_araddr[0]),
        .I2(result[6]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[6]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[7]_i_1 
       (.I0(cmd_word[7]),
        .I1(s_axi_araddr[0]),
        .I2(result[7]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[7]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hCCB8)) 
    \s_axi_rdata[8]_i_1 
       (.I0(result[8]),
        .I1(s_axi_araddr[0]),
        .I2(cmd_word[8]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[8]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h00E2)) 
    \s_axi_rdata[9]_i_1 
       (.I0(cmd_word[9]),
        .I1(s_axi_araddr[0]),
        .I2(result[9]),
        .I3(s_axi_araddr[1]),
        .O(\s_axi_rdata[9]_i_1_n_0 ));
  FDRE \s_axi_rdata_reg[0] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[0]_i_1_n_0 ),
        .Q(s_axi_rdata[0]),
        .R(rst));
  FDRE \s_axi_rdata_reg[10] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[10]_i_1_n_0 ),
        .Q(s_axi_rdata[10]),
        .R(rst));
  FDRE \s_axi_rdata_reg[11] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[11]_i_1_n_0 ),
        .Q(s_axi_rdata[11]),
        .R(rst));
  FDRE \s_axi_rdata_reg[12] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[12]_i_1_n_0 ),
        .Q(s_axi_rdata[12]),
        .R(rst));
  FDRE \s_axi_rdata_reg[13] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[13]_i_1_n_0 ),
        .Q(s_axi_rdata[13]),
        .R(rst));
  FDRE \s_axi_rdata_reg[14] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[14]_i_1_n_0 ),
        .Q(s_axi_rdata[14]),
        .R(rst));
  FDRE \s_axi_rdata_reg[15] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[15]_i_1_n_0 ),
        .Q(s_axi_rdata[15]),
        .R(rst));
  FDRE \s_axi_rdata_reg[16] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[16]_i_1_n_0 ),
        .Q(s_axi_rdata[16]),
        .R(rst));
  FDRE \s_axi_rdata_reg[17] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[17]_i_1_n_0 ),
        .Q(s_axi_rdata[17]),
        .R(rst));
  FDRE \s_axi_rdata_reg[18] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[18]_i_1_n_0 ),
        .Q(s_axi_rdata[18]),
        .R(rst));
  FDRE \s_axi_rdata_reg[19] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[19]_i_1_n_0 ),
        .Q(s_axi_rdata[19]),
        .R(rst));
  FDRE \s_axi_rdata_reg[1] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[1]_i_1_n_0 ),
        .Q(s_axi_rdata[1]),
        .R(rst));
  FDRE \s_axi_rdata_reg[20] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[20]_i_1_n_0 ),
        .Q(s_axi_rdata[20]),
        .R(rst));
  FDRE \s_axi_rdata_reg[21] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[21]_i_1_n_0 ),
        .Q(s_axi_rdata[21]),
        .R(rst));
  FDRE \s_axi_rdata_reg[22] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[22]_i_1_n_0 ),
        .Q(s_axi_rdata[22]),
        .R(rst));
  FDRE \s_axi_rdata_reg[23] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[23]_i_1_n_0 ),
        .Q(s_axi_rdata[23]),
        .R(rst));
  FDRE \s_axi_rdata_reg[24] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[24]_i_1_n_0 ),
        .Q(s_axi_rdata[24]),
        .R(rst));
  FDRE \s_axi_rdata_reg[25] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[25]_i_1_n_0 ),
        .Q(s_axi_rdata[25]),
        .R(rst));
  FDRE \s_axi_rdata_reg[26] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[26]_i_1_n_0 ),
        .Q(s_axi_rdata[26]),
        .R(rst));
  FDRE \s_axi_rdata_reg[27] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[27]_i_1_n_0 ),
        .Q(s_axi_rdata[27]),
        .R(rst));
  FDRE \s_axi_rdata_reg[28] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[28]_i_1_n_0 ),
        .Q(s_axi_rdata[28]),
        .R(rst));
  FDRE \s_axi_rdata_reg[29] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[29]_i_1_n_0 ),
        .Q(s_axi_rdata[29]),
        .R(rst));
  FDRE \s_axi_rdata_reg[2] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[2]_i_1_n_0 ),
        .Q(s_axi_rdata[2]),
        .R(rst));
  FDRE \s_axi_rdata_reg[30] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[30]_i_1_n_0 ),
        .Q(s_axi_rdata[30]),
        .R(rst));
  FDRE \s_axi_rdata_reg[31] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[31]_i_2_n_0 ),
        .Q(s_axi_rdata[31]),
        .R(rst));
  FDRE \s_axi_rdata_reg[3] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[3]_i_1_n_0 ),
        .Q(s_axi_rdata[3]),
        .R(rst));
  FDRE \s_axi_rdata_reg[4] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[4]_i_1_n_0 ),
        .Q(s_axi_rdata[4]),
        .R(rst));
  FDRE \s_axi_rdata_reg[5] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[5]_i_1_n_0 ),
        .Q(s_axi_rdata[5]),
        .R(rst));
  FDRE \s_axi_rdata_reg[6] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[6]_i_1_n_0 ),
        .Q(s_axi_rdata[6]),
        .R(rst));
  FDRE \s_axi_rdata_reg[7] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[7]_i_1_n_0 ),
        .Q(s_axi_rdata[7]),
        .R(rst));
  FDRE \s_axi_rdata_reg[8] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[8]_i_1_n_0 ),
        .Q(s_axi_rdata[8]),
        .R(rst));
  FDRE \s_axi_rdata_reg[9] 
       (.C(s_axi_aclk),
        .CE(s_axi_rvalid01_out),
        .D(\s_axi_rdata[9]_i_1_n_0 ),
        .Q(s_axi_rdata[9]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'h88F8)) 
    s_axi_rvalid_i_1
       (.I0(s_axi_arvalid),
        .I1(s_axi_arready),
        .I2(s_axi_rvalid),
        .I3(s_axi_rready),
        .O(s_axi_rvalid_i_1_n_0));
  FDRE s_axi_rvalid_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_rvalid_i_1_n_0),
        .Q(s_axi_rvalid),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'h01)) 
    s_axi_wready_i_1
       (.I0(s_axi_bvalid_reg_0),
        .I1(w_take),
        .I2(w_have_reg_n_0),
        .O(s_axi_wready0));
  FDRE s_axi_wready_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_wready0),
        .Q(s_axi_wready),
        .R(rst));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_tiny_tpu_pe u_pe
       (.B(B),
        .D({cmd,u_pe_n_10,u_pe_n_11}),
        .E(w_take),
        .Q(w_data[9:0]),
        .SR(rst),
        .aw_addr(aw_addr),
        .aw_have(aw_have),
        .\cmd_word_reg[0] (s_axi_awready),
        .\cmd_word_reg[0]_0 (s_axi_bvalid_reg_0),
        .do_write(do_write),
        .ovf(ovf),
        .\result_reg[0]_0 (w_have_reg_n_0),
        .\result_reg[15]_0 (result),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_wdata(s_axi_wdata[9:0]),
        .s_axi_wready(s_axi_wready),
        .s_axi_wvalid(s_axi_wvalid),
        .\w_data_reg[2] (u_pe_n_7),
        .\w_data_reg[3] (u_pe_n_6));
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
        .I1(s_axi_wready),
        .I2(s_axi_wvalid),
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

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_tiny_tpu_pe
   (ovf,
    SR,
    B,
    \w_data_reg[3] ,
    \w_data_reg[2] ,
    D,
    do_write,
    E,
    \result_reg[15]_0 ,
    s_axi_aclk,
    Q,
    s_axi_wdata,
    \result_reg[0]_0 ,
    aw_addr,
    aw_have,
    s_axi_awaddr,
    \cmd_word_reg[0] ,
    s_axi_awvalid,
    \cmd_word_reg[0]_0 ,
    s_axi_wready,
    s_axi_wvalid,
    s_axi_aresetn);
  output ovf;
  output [0:0]SR;
  output [3:0]B;
  output \w_data_reg[3] ;
  output \w_data_reg[2] ;
  output [3:0]D;
  output do_write;
  output [0:0]E;
  output [15:0]\result_reg[15]_0 ;
  input s_axi_aclk;
  input [9:0]Q;
  input [9:0]s_axi_wdata;
  input \result_reg[0]_0 ;
  input [1:0]aw_addr;
  input aw_have;
  input [1:0]s_axi_awaddr;
  input \cmd_word_reg[0] ;
  input s_axi_awvalid;
  input \cmd_word_reg[0]_0 ;
  input s_axi_wready;
  input s_axi_wvalid;
  input s_axi_aresetn;

  wire [3:0]B;
  wire [3:0]D;
  wire [0:0]E;
  wire [9:0]Q;
  wire [0:0]SR;
  wire [15:0]acc;
  wire \acc[0]_i_1_n_0 ;
  wire \acc[10]_i_1_n_0 ;
  wire \acc[11]_i_1_n_0 ;
  wire \acc[12]_i_1_n_0 ;
  wire \acc[13]_i_1_n_0 ;
  wire \acc[14]_i_1_n_0 ;
  wire \acc[15]_i_2_n_0 ;
  wire \acc[1]_i_1_n_0 ;
  wire \acc[2]_i_1_n_0 ;
  wire \acc[3]_i_1_n_0 ;
  wire \acc[4]_i_1_n_0 ;
  wire \acc[5]_i_1_n_0 ;
  wire \acc[6]_i_1_n_0 ;
  wire \acc[7]_i_1_n_0 ;
  wire \acc[8]_i_1_n_0 ;
  wire \acc[9]_i_1_n_0 ;
  wire acc_0;
  wire [1:0]aw_addr;
  wire aw_have;
  wire cmd_valid__0;
  wire \cmd_word_reg[0] ;
  wire \cmd_word_reg[0]_0 ;
  wire do_write;
  wire ovf;
  wire ovf_i_1_n_0;
  wire ovf_reg_i_2_n_3;
  wire [7:2]p_0_in;
  wire product__0_carry__0_i_1_n_0;
  wire product__0_carry__0_i_2_n_0;
  wire product__0_carry__0_i_3_n_0;
  wire product__0_carry__0_n_3;
  wire product__0_carry_i_10_n_0;
  wire product__0_carry_i_11_n_0;
  wire product__0_carry_i_12_n_0;
  wire product__0_carry_i_13_n_0;
  wire product__0_carry_i_14_n_0;
  wire product__0_carry_i_15_n_0;
  wire product__0_carry_i_16_n_0;
  wire product__0_carry_i_17_n_0;
  wire product__0_carry_i_18_n_0;
  wire product__0_carry_i_19_n_0;
  wire product__0_carry_i_1_n_0;
  wire product__0_carry_i_20_n_0;
  wire product__0_carry_i_2_n_0;
  wire product__0_carry_i_3_n_0;
  wire product__0_carry_i_4_n_0;
  wire product__0_carry_i_5_n_0;
  wire product__0_carry_i_6_n_0;
  wire product__0_carry_i_7_n_0;
  wire product__0_carry_i_8_n_0;
  wire product__0_carry_i_9_n_0;
  wire product__0_carry_n_0;
  wire product__0_carry_n_1;
  wire product__0_carry_n_2;
  wire product__0_carry_n_3;
  wire \result[15]_i_1_n_0 ;
  wire \result_reg[0]_0 ;
  wire [15:0]\result_reg[15]_0 ;
  wire s_axi_aclk;
  wire s_axi_aresetn;
  wire [1:0]s_axi_awaddr;
  wire s_axi_awvalid;
  wire [9:0]s_axi_wdata;
  wire s_axi_wready;
  wire s_axi_wvalid;
  wire [15:0]sum__0;
  wire sum_carry__0_i_1_n_0;
  wire sum_carry__0_i_2_n_0;
  wire sum_carry__0_i_3_n_0;
  wire sum_carry__0_i_4_n_0;
  wire sum_carry__0_n_0;
  wire sum_carry__0_n_1;
  wire sum_carry__0_n_2;
  wire sum_carry__0_n_3;
  wire sum_carry__1_i_1_n_0;
  wire sum_carry__1_i_2_n_0;
  wire sum_carry__1_i_3_n_0;
  wire sum_carry__1_i_4_n_0;
  wire sum_carry__1_i_5_n_0;
  wire sum_carry__1_n_0;
  wire sum_carry__1_n_1;
  wire sum_carry__1_n_2;
  wire sum_carry__1_n_3;
  wire sum_carry__2_i_1_n_0;
  wire sum_carry__2_i_2_n_0;
  wire sum_carry__2_i_3_n_0;
  wire sum_carry__2_i_4_n_0;
  wire sum_carry__2_n_0;
  wire sum_carry__2_n_1;
  wire sum_carry__2_n_2;
  wire sum_carry__2_n_3;
  wire sum_carry_i_1_n_0;
  wire sum_carry_i_2_n_0;
  wire sum_carry_i_3_n_0;
  wire sum_carry_i_4_n_0;
  wire sum_carry_i_5_n_0;
  wire sum_carry_n_0;
  wire sum_carry_n_1;
  wire sum_carry_n_2;
  wire sum_carry_n_3;
  wire \w_data_reg[2] ;
  wire \w_data_reg[3] ;
  wire [3:1]NLW_ovf_reg_i_2_CO_UNCONNECTED;
  wire [3:0]NLW_ovf_reg_i_2_O_UNCONNECTED;
  wire [3:1]NLW_product__0_carry__0_CO_UNCONNECTED;
  wire [3:2]NLW_product__0_carry__0_O_UNCONNECTED;

  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[0]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[0]),
        .O(\acc[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[10]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[10]),
        .O(\acc[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[11]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[11]),
        .O(\acc[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[12]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[12]),
        .O(\acc[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[13]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[13]),
        .O(\acc[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[14]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[14]),
        .O(\acc[14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h220A880A22A088A0)) 
    \acc[15]_i_1 
       (.I0(cmd_valid__0),
        .I1(Q[9]),
        .I2(s_axi_wdata[9]),
        .I3(\result_reg[0]_0 ),
        .I4(Q[8]),
        .I5(s_axi_wdata[8]),
        .O(acc_0));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[15]_i_2 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[15]),
        .O(\acc[15]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0044034700000000)) 
    \acc[15]_i_3 
       (.I0(aw_addr[1]),
        .I1(aw_have),
        .I2(s_axi_awaddr[1]),
        .I3(aw_addr[0]),
        .I4(s_axi_awaddr[0]),
        .I5(do_write),
        .O(cmd_valid__0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[1]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[1]),
        .O(\acc[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[2]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[2]),
        .O(\acc[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[3]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[3]),
        .O(\acc[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[4]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[4]),
        .O(\acc[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[5]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[5]),
        .O(\acc[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[6]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[6]),
        .O(\acc[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[7]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[7]),
        .O(\acc[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[8]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[8]),
        .O(\acc[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'hE400)) 
    \acc[9]_i_1 
       (.I0(\result_reg[0]_0 ),
        .I1(s_axi_wdata[9]),
        .I2(Q[9]),
        .I3(sum__0[9]),
        .O(\acc[9]_i_1_n_0 ));
  FDRE \acc_reg[0] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[0]_i_1_n_0 ),
        .Q(acc[0]),
        .R(SR));
  FDRE \acc_reg[10] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[10]_i_1_n_0 ),
        .Q(acc[10]),
        .R(SR));
  FDRE \acc_reg[11] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[11]_i_1_n_0 ),
        .Q(acc[11]),
        .R(SR));
  FDRE \acc_reg[12] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[12]_i_1_n_0 ),
        .Q(acc[12]),
        .R(SR));
  FDRE \acc_reg[13] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[13]_i_1_n_0 ),
        .Q(acc[13]),
        .R(SR));
  FDRE \acc_reg[14] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[14]_i_1_n_0 ),
        .Q(acc[14]),
        .R(SR));
  FDRE \acc_reg[15] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[15]_i_2_n_0 ),
        .Q(acc[15]),
        .R(SR));
  FDRE \acc_reg[1] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[1]_i_1_n_0 ),
        .Q(acc[1]),
        .R(SR));
  FDRE \acc_reg[2] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[2]_i_1_n_0 ),
        .Q(acc[2]),
        .R(SR));
  FDRE \acc_reg[3] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[3]_i_1_n_0 ),
        .Q(acc[3]),
        .R(SR));
  FDRE \acc_reg[4] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[4]_i_1_n_0 ),
        .Q(acc[4]),
        .R(SR));
  FDRE \acc_reg[5] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[5]_i_1_n_0 ),
        .Q(acc[5]),
        .R(SR));
  FDRE \acc_reg[6] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[6]_i_1_n_0 ),
        .Q(acc[6]),
        .R(SR));
  FDRE \acc_reg[7] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[7]_i_1_n_0 ),
        .Q(acc[7]),
        .R(SR));
  FDRE \acc_reg[8] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[8]_i_1_n_0 ),
        .Q(acc[8]),
        .R(SR));
  FDRE \acc_reg[9] 
       (.C(s_axi_aclk),
        .CE(acc_0),
        .D(\acc[9]_i_1_n_0 ),
        .Q(acc[9]),
        .R(SR));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[0]_i_1 
       (.I0(Q[0]),
        .I1(s_axi_wdata[0]),
        .I2(\result_reg[0]_0 ),
        .O(D[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[1]_i_1 
       (.I0(Q[1]),
        .I1(s_axi_wdata[1]),
        .I2(\result_reg[0]_0 ),
        .O(D[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[2]_i_1 
       (.I0(Q[2]),
        .I1(s_axi_wdata[2]),
        .I2(\result_reg[0]_0 ),
        .O(\w_data_reg[2] ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[3]_i_1 
       (.I0(Q[3]),
        .I1(s_axi_wdata[3]),
        .I2(\result_reg[0]_0 ),
        .O(\w_data_reg[3] ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[4]_i_1 
       (.I0(Q[4]),
        .I1(s_axi_wdata[4]),
        .I2(\result_reg[0]_0 ),
        .O(B[0]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[5]_i_1 
       (.I0(Q[5]),
        .I1(s_axi_wdata[5]),
        .I2(\result_reg[0]_0 ),
        .O(B[1]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[6]_i_1 
       (.I0(Q[6]),
        .I1(s_axi_wdata[6]),
        .I2(\result_reg[0]_0 ),
        .O(B[2]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[7]_i_1 
       (.I0(Q[7]),
        .I1(s_axi_wdata[7]),
        .I2(\result_reg[0]_0 ),
        .O(B[3]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[8]_i_1 
       (.I0(Q[8]),
        .I1(s_axi_wdata[8]),
        .I2(\result_reg[0]_0 ),
        .O(D[2]));
  LUT3 #(
    .INIT(8'hAC)) 
    \cmd_word[9]_i_1 
       (.I0(Q[9]),
        .I1(s_axi_wdata[9]),
        .I2(\result_reg[0]_0 ),
        .O(D[3]));
  LUT6 #(
    .INIT(64'hFF55FFFF00008200)) 
    ovf_i_1
       (.I0(cmd_valid__0),
        .I1(sum__0[15]),
        .I2(ovf_reg_i_2_n_3),
        .I3(D[3]),
        .I4(D[2]),
        .I5(ovf),
        .O(ovf_i_1_n_0));
  FDRE ovf_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ovf_i_1_n_0),
        .Q(ovf),
        .R(SR));
  CARRY4 ovf_reg_i_2
       (.CI(sum_carry__2_n_0),
        .CO({NLW_ovf_reg_i_2_CO_UNCONNECTED[3:1],ovf_reg_i_2_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_ovf_reg_i_2_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,1'b1}));
  CARRY4 product__0_carry
       (.CI(1'b0),
        .CO({product__0_carry_n_0,product__0_carry_n_1,product__0_carry_n_2,product__0_carry_n_3}),
        .CYINIT(1'b0),
        .DI({product__0_carry_i_1_n_0,product__0_carry_i_2_n_0,product__0_carry_i_3_n_0,1'b0}),
        .O(p_0_in[5:2]),
        .S({product__0_carry_i_4_n_0,product__0_carry_i_5_n_0,product__0_carry_i_6_n_0,product__0_carry_i_7_n_0}));
  CARRY4 product__0_carry__0
       (.CI(product__0_carry_n_0),
        .CO({NLW_product__0_carry__0_CO_UNCONNECTED[3:1],product__0_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,product__0_carry__0_i_1_n_0}),
        .O({NLW_product__0_carry__0_O_UNCONNECTED[3:2],p_0_in[7:6]}),
        .S({1'b0,1'b0,product__0_carry__0_i_2_n_0,product__0_carry__0_i_3_n_0}));
  LUT6 #(
    .INIT(64'h00008C73C03FC03F)) 
    product__0_carry__0_i_1
       (.I0(B[1]),
        .I1(B[2]),
        .I2(\w_data_reg[3] ),
        .I3(product__0_carry_i_13_n_0),
        .I4(B[3]),
        .I5(\w_data_reg[2] ),
        .O(product__0_carry__0_i_1_n_0));
  LUT6 #(
    .INIT(64'hF7FF77FFFFFF77FF)) 
    product__0_carry__0_i_2
       (.I0(B[3]),
        .I1(product__0_carry_i_13_n_0),
        .I2(B[1]),
        .I3(\w_data_reg[3] ),
        .I4(B[2]),
        .I5(\w_data_reg[2] ),
        .O(product__0_carry__0_i_2_n_0));
  LUT6 #(
    .INIT(64'h8F0FEDEDF7F73FBF)) 
    product__0_carry__0_i_3
       (.I0(\w_data_reg[2] ),
        .I1(B[2]),
        .I2(\w_data_reg[3] ),
        .I3(B[1]),
        .I4(product__0_carry_i_13_n_0),
        .I5(B[3]),
        .O(product__0_carry__0_i_3_n_0));
  LUT5 #(
    .INIT(32'h17E8E817)) 
    product__0_carry_i_1
       (.I0(product__0_carry_i_8_n_0),
        .I1(product__0_carry_i_9_n_0),
        .I2(product__0_carry_i_10_n_0),
        .I3(product__0_carry_i_11_n_0),
        .I4(product__0_carry_i_12_n_0),
        .O(product__0_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h88A8800080008000)) 
    product__0_carry_i_10
       (.I0(B[0]),
        .I1(\w_data_reg[2] ),
        .I2(D[0]),
        .I3(B[2]),
        .I4(D[1]),
        .I5(B[1]),
        .O(product__0_carry_i_10_n_0));
  LUT6 #(
    .INIT(64'hAC0CA00053F35FFF)) 
    product__0_carry_i_11
       (.I0(Q[5]),
        .I1(s_axi_wdata[5]),
        .I2(\result_reg[0]_0 ),
        .I3(Q[3]),
        .I4(s_axi_wdata[3]),
        .I5(product__0_carry_i_19_n_0),
        .O(product__0_carry_i_11_n_0));
  LUT6 #(
    .INIT(64'h88A0FFFF000088A0)) 
    product__0_carry_i_12
       (.I0(B[2]),
        .I1(Q[1]),
        .I2(s_axi_wdata[1]),
        .I3(\result_reg[0]_0 ),
        .I4(product__0_carry_i_18_n_0),
        .I5(product__0_carry_i_20_n_0),
        .O(product__0_carry_i_12_n_0));
  LUT6 #(
    .INIT(64'h5DDF455D455D0445)) 
    product__0_carry_i_13
       (.I0(product__0_carry_i_11_n_0),
        .I1(product__0_carry_i_20_n_0),
        .I2(product__0_carry_i_18_n_0),
        .I3(product__0_carry_i_17_n_0),
        .I4(product__0_carry_i_10_n_0),
        .I5(product__0_carry_i_8_n_0),
        .O(product__0_carry_i_13_n_0));
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_14
       (.I0(s_axi_wdata[3]),
        .I1(Q[3]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[6]),
        .I4(Q[6]),
        .O(product__0_carry_i_14_n_0));
  LUT6 #(
    .INIT(64'h0000000053F35FFF)) 
    product__0_carry_i_15
       (.I0(Q[5]),
        .I1(s_axi_wdata[5]),
        .I2(\result_reg[0]_0 ),
        .I3(Q[3]),
        .I4(s_axi_wdata[3]),
        .I5(product__0_carry_i_19_n_0),
        .O(product__0_carry_i_15_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_16
       (.I0(s_axi_wdata[1]),
        .I1(Q[1]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[5]),
        .I4(Q[5]),
        .O(product__0_carry_i_16_n_0));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_17
       (.I0(s_axi_wdata[1]),
        .I1(Q[1]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[6]),
        .I4(Q[6]),
        .O(product__0_carry_i_17_n_0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_18
       (.I0(s_axi_wdata[2]),
        .I1(Q[2]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[5]),
        .I4(Q[5]),
        .O(product__0_carry_i_18_n_0));
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_19
       (.I0(s_axi_wdata[2]),
        .I1(Q[2]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[6]),
        .I4(Q[6]),
        .O(product__0_carry_i_19_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    product__0_carry_i_2
       (.I0(product__0_carry_i_1_n_0),
        .O(product__0_carry_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_20
       (.I0(s_axi_wdata[3]),
        .I1(Q[3]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[4]),
        .I4(Q[4]),
        .O(product__0_carry_i_20_n_0));
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    product__0_carry_i_3
       (.I0(s_axi_wdata[0]),
        .I1(Q[0]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[7]),
        .I4(Q[7]),
        .O(product__0_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h6996966996699669)) 
    product__0_carry_i_4
       (.I0(product__0_carry_i_1_n_0),
        .I1(product__0_carry_i_13_n_0),
        .I2(product__0_carry_i_14_n_0),
        .I3(product__0_carry_i_15_n_0),
        .I4(\w_data_reg[2] ),
        .I5(B[3]),
        .O(product__0_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h665AAA5A66AAAAAA)) 
    product__0_carry_i_5
       (.I0(product__0_carry_i_1_n_0),
        .I1(Q[7]),
        .I2(s_axi_wdata[7]),
        .I3(\result_reg[0]_0 ),
        .I4(Q[1]),
        .I5(s_axi_wdata[1]),
        .O(product__0_carry_i_5_n_0));
  LUT4 #(
    .INIT(16'h6996)) 
    product__0_carry_i_6
       (.I0(product__0_carry_i_3_n_0),
        .I1(product__0_carry_i_9_n_0),
        .I2(product__0_carry_i_8_n_0),
        .I3(product__0_carry_i_10_n_0),
        .O(product__0_carry_i_6_n_0));
  LUT6 #(
    .INIT(64'h4777B88878887888)) 
    product__0_carry_i_7
       (.I0(\w_data_reg[2] ),
        .I1(B[0]),
        .I2(B[1]),
        .I3(D[1]),
        .I4(B[2]),
        .I5(D[0]),
        .O(product__0_carry_i_7_n_0));
  LUT6 #(
    .INIT(64'h00000000AC0CA000)) 
    product__0_carry_i_8
       (.I0(Q[6]),
        .I1(s_axi_wdata[6]),
        .I2(\result_reg[0]_0 ),
        .I3(Q[0]),
        .I4(s_axi_wdata[0]),
        .I5(product__0_carry_i_16_n_0),
        .O(product__0_carry_i_8_n_0));
  LUT6 #(
    .INIT(64'h775F88A088A0775F)) 
    product__0_carry_i_9
       (.I0(B[0]),
        .I1(Q[3]),
        .I2(s_axi_wdata[3]),
        .I3(\result_reg[0]_0 ),
        .I4(product__0_carry_i_17_n_0),
        .I5(product__0_carry_i_18_n_0),
        .O(product__0_carry_i_9_n_0));
  LUT6 #(
    .INIT(64'h88A000A088000000)) 
    \result[15]_i_1 
       (.I0(cmd_valid__0),
        .I1(Q[9]),
        .I2(s_axi_wdata[9]),
        .I3(\result_reg[0]_0 ),
        .I4(Q[8]),
        .I5(s_axi_wdata[8]),
        .O(\result[15]_i_1_n_0 ));
  FDRE \result_reg[0] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[0]),
        .Q(\result_reg[15]_0 [0]),
        .R(SR));
  FDRE \result_reg[10] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[10]),
        .Q(\result_reg[15]_0 [10]),
        .R(SR));
  FDRE \result_reg[11] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[11]),
        .Q(\result_reg[15]_0 [11]),
        .R(SR));
  FDRE \result_reg[12] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[12]),
        .Q(\result_reg[15]_0 [12]),
        .R(SR));
  FDRE \result_reg[13] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[13]),
        .Q(\result_reg[15]_0 [13]),
        .R(SR));
  FDRE \result_reg[14] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[14]),
        .Q(\result_reg[15]_0 [14]),
        .R(SR));
  FDRE \result_reg[15] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[15]),
        .Q(\result_reg[15]_0 [15]),
        .R(SR));
  FDRE \result_reg[1] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[1]),
        .Q(\result_reg[15]_0 [1]),
        .R(SR));
  FDRE \result_reg[2] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[2]),
        .Q(\result_reg[15]_0 [2]),
        .R(SR));
  FDRE \result_reg[3] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[3]),
        .Q(\result_reg[15]_0 [3]),
        .R(SR));
  FDRE \result_reg[4] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[4]),
        .Q(\result_reg[15]_0 [4]),
        .R(SR));
  FDRE \result_reg[5] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[5]),
        .Q(\result_reg[15]_0 [5]),
        .R(SR));
  FDRE \result_reg[6] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[6]),
        .Q(\result_reg[15]_0 [6]),
        .R(SR));
  FDRE \result_reg[7] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[7]),
        .Q(\result_reg[15]_0 [7]),
        .R(SR));
  FDRE \result_reg[8] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[8]),
        .Q(\result_reg[15]_0 [8]),
        .R(SR));
  FDRE \result_reg[9] 
       (.C(s_axi_aclk),
        .CE(\result[15]_i_1_n_0 ),
        .D(acc[9]),
        .Q(\result_reg[15]_0 [9]),
        .R(SR));
  LUT1 #(
    .INIT(2'h1)) 
    s_axi_awready_i_1
       (.I0(s_axi_aresetn),
        .O(SR));
  LUT6 #(
    .INIT(64'h00F800F800F80000)) 
    s_axi_bvalid_i_2
       (.I0(\cmd_word_reg[0] ),
        .I1(s_axi_awvalid),
        .I2(aw_have),
        .I3(\cmd_word_reg[0]_0 ),
        .I4(\result_reg[0]_0 ),
        .I5(E),
        .O(do_write));
  CARRY4 sum_carry
       (.CI(1'b0),
        .CO({sum_carry_n_0,sum_carry_n_1,sum_carry_n_2,sum_carry_n_3}),
        .CYINIT(1'b0),
        .DI(acc[3:0]),
        .O(sum__0[3:0]),
        .S({sum_carry_i_1_n_0,sum_carry_i_2_n_0,sum_carry_i_3_n_0,sum_carry_i_4_n_0}));
  CARRY4 sum_carry__0
       (.CI(sum_carry_n_0),
        .CO({sum_carry__0_n_0,sum_carry__0_n_1,sum_carry__0_n_2,sum_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({p_0_in[7],acc[6:4]}),
        .O(sum__0[7:4]),
        .S({sum_carry__0_i_1_n_0,sum_carry__0_i_2_n_0,sum_carry__0_i_3_n_0,sum_carry__0_i_4_n_0}));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry__0_i_1
       (.I0(p_0_in[7]),
        .I1(acc[7]),
        .O(sum_carry__0_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry__0_i_2
       (.I0(acc[6]),
        .I1(p_0_in[6]),
        .O(sum_carry__0_i_2_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry__0_i_3
       (.I0(acc[5]),
        .I1(p_0_in[5]),
        .O(sum_carry__0_i_3_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry__0_i_4
       (.I0(acc[4]),
        .I1(p_0_in[4]),
        .O(sum_carry__0_i_4_n_0));
  CARRY4 sum_carry__1
       (.CI(sum_carry__0_n_0),
        .CO({sum_carry__1_n_0,sum_carry__1_n_1,sum_carry__1_n_2,sum_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI({acc[10:8],sum_carry__1_i_1_n_0}),
        .O(sum__0[11:8]),
        .S({sum_carry__1_i_2_n_0,sum_carry__1_i_3_n_0,sum_carry__1_i_4_n_0,sum_carry__1_i_5_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    sum_carry__1_i_1
       (.I0(p_0_in[7]),
        .O(sum_carry__1_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__1_i_2
       (.I0(acc[10]),
        .I1(acc[11]),
        .O(sum_carry__1_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__1_i_3
       (.I0(acc[9]),
        .I1(acc[10]),
        .O(sum_carry__1_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__1_i_4
       (.I0(acc[8]),
        .I1(acc[9]),
        .O(sum_carry__1_i_4_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry__1_i_5
       (.I0(p_0_in[7]),
        .I1(acc[8]),
        .O(sum_carry__1_i_5_n_0));
  CARRY4 sum_carry__2
       (.CI(sum_carry__1_n_0),
        .CO({sum_carry__2_n_0,sum_carry__2_n_1,sum_carry__2_n_2,sum_carry__2_n_3}),
        .CYINIT(1'b0),
        .DI(acc[14:11]),
        .O(sum__0[15:12]),
        .S({sum_carry__2_i_1_n_0,sum_carry__2_i_2_n_0,sum_carry__2_i_3_n_0,sum_carry__2_i_4_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__2_i_1
       (.I0(acc[14]),
        .I1(acc[15]),
        .O(sum_carry__2_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__2_i_2
       (.I0(acc[13]),
        .I1(acc[14]),
        .O(sum_carry__2_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__2_i_3
       (.I0(acc[12]),
        .I1(acc[13]),
        .O(sum_carry__2_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    sum_carry__2_i_4
       (.I0(acc[11]),
        .I1(acc[12]),
        .O(sum_carry__2_i_4_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry_i_1
       (.I0(acc[3]),
        .I1(p_0_in[3]),
        .O(sum_carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    sum_carry_i_2
       (.I0(acc[2]),
        .I1(p_0_in[2]),
        .O(sum_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h6669969999999999)) 
    sum_carry_i_3
       (.I0(acc[1]),
        .I1(sum_carry_i_5_n_0),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[1]),
        .I4(Q[1]),
        .I5(B[0]),
        .O(sum_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h665AAA5A66AAAAAA)) 
    sum_carry_i_4
       (.I0(acc[0]),
        .I1(Q[4]),
        .I2(s_axi_wdata[4]),
        .I3(\result_reg[0]_0 ),
        .I4(Q[0]),
        .I5(s_axi_wdata[0]),
        .O(sum_carry_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h353FF5FF)) 
    sum_carry_i_5
       (.I0(s_axi_wdata[0]),
        .I1(Q[0]),
        .I2(\result_reg[0]_0 ),
        .I3(s_axi_wdata[5]),
        .I4(Q[5]),
        .O(sum_carry_i_5_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    \w_data[31]_i_1 
       (.I0(s_axi_wready),
        .I1(s_axi_wvalid),
        .O(E));
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
