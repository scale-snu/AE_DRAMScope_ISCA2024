//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : The Xilinx PCI Express DMA 
// File       : xdma_app.v
// Version    : 4.1
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps
module xdma_adapter
#(
  parameter TCQ                         = 1,
  parameter C_M_AXI_ID_WIDTH            = 4,
  parameter PL_LINK_CAP_MAX_LINK_WIDTH  = 8,
  parameter C_DATA_WIDTH                = 512,
  parameter C_M_AXI_DATA_WIDTH          = C_DATA_WIDTH,
  parameter C_S_AXI_DATA_WIDTH          = C_DATA_WIDTH,
  parameter C_S_AXIS_DATA_WIDTH         = C_DATA_WIDTH,
  parameter C_M_AXIS_DATA_WIDTH         = C_DATA_WIDTH,
  parameter C_M_AXIS_RQ_USER_WIDTH      = ((C_DATA_WIDTH == 512) ? 137 : 62),
  parameter C_S_AXIS_CQP_USER_WIDTH     = ((C_DATA_WIDTH == 512) ? 183 : 88),
  parameter C_M_AXIS_RC_USER_WIDTH      = ((C_DATA_WIDTH == 512) ? 161 : 75),
  parameter C_S_AXIS_CC_USER_WIDTH      = ((C_DATA_WIDTH == 512) ?  81 : 33),
  parameter C_S_KEEP_WIDTH              = C_S_AXI_DATA_WIDTH / 32,
  parameter C_M_KEEP_WIDTH              = (C_M_AXI_DATA_WIDTH / 32),
  parameter C_XDMA_NUM_CHNL             = 1,
  parameter DQ_WIDTH                    =256
)
(
  // AXI streaming ports  (master, slave from SoftMC's point of view)
  // 250MHz
  input  [C_DATA_WIDTH-1:0]       s_axis_h2c_tdata,
//  input                           s_axis_h2c_tlast,
  input                           s_axis_h2c_tvalid,
  output                          s_axis_h2c_tready,
//  input  [C_DATA_WIDTH/8-1:0]     s_axis_h2c_tkeep,
  output [C_DATA_WIDTH-1:0]       m_axis_c2h_tdata,  
//  output                          m_axis_c2h_tlast,
  output                          m_axis_c2h_tvalid,
  input                           m_axis_c2h_tready,
//  output [C_DATA_WIDTH/8-1:0]     m_axis_c2h_tkeep,

  // XDMA signals
  input                           xdma_axi_clk, // 250MHz
  input                           xdma_axi_resetn,
  input                           user_lnk_up,

  // SoftMC signals
  input                           dfi_0_clk, // 450MHz
  input                           dfi_0_rst_n,
    // App Command Interface
  output reg                      app_en,
  input                           app_ack,
  output reg [31:0]               app_instr, 
  input                           iq_full,
    //Data read back Interface
  output                          rdback_fifo_rd_en_pc0,
  output                          rdback_fifo_rd_en_pc1,
  input                           rdback_fifo_empty_pc0,
  input                           rdback_fifo_empty_pc1,
  input [DQ_WIDTH-1:0]            rdback_data_pc0,
  input [DQ_WIDTH-1:0]            rdback_data_pc1
);

  wire   xdma_axi_ready;
  assign xdma_axi_ready = xdma_axi_resetn & user_lnk_up;

  // AXI streaming ports  (master, slave from SoftMC's point of view)
  // 450MHz
  wire [C_DATA_WIDTH-1:0]   s_axis_h2c_tdata_dfi;
  wire                      s_axis_h2c_tlast_dfi;
  wire                      s_axis_h2c_tvalid_dfi;
  wire                      s_axis_h2c_tready_dfi;
  wire [C_DATA_WIDTH/8-1:0] s_axis_h2c_tkeep_dfi;
  wire [C_DATA_WIDTH-1:0]   m_axis_c2h_tdata_dfi;  
  wire                      m_axis_c2h_tlast_dfi;
  wire                      m_axis_c2h_tvalid_dfi;
  wire                      m_axis_c2h_tready_dfi;
  wire [C_DATA_WIDTH/8-1:0] m_axis_c2h_tkeep_dfi;

  // fifo 250MHz
  wire [C_DATA_WIDTH-1:0]   s_axis_h2c_tdata_fifo;
  wire                      s_axis_h2c_tlast_fifo;
  wire                      s_axis_h2c_tvalid_fifo;
  wire                      s_axis_h2c_tready_fifo;
  wire [C_DATA_WIDTH/8-1:0] s_axis_h2c_tkeep_fifo;
  wire [C_DATA_WIDTH-1:0]   m_axis_c2h_tdata_fifo;  
  wire                      m_axis_c2h_tlast_fifo;
  wire                      m_axis_c2h_tvalid_fifo;
  wire                      m_axis_c2h_tready_fifo;
  wire [C_DATA_WIDTH/8-1:0] m_axis_c2h_tkeep_fifo;


  //**************************************
  // Host -> SoftMC (AXI-Stream Slave)
  //**************************************
  assign s_axis_h2c_tready_dfi = (!iq_full) & (!app_en | app_ack);

  always@(posedge dfi_0_clk or negedge dfi_0_rst_n) begin
    if(~dfi_0_rst_n) begin
      app_en    <= 1'b0;
      app_instr <= 32'h0000;
    end
    else begin
      if(s_axis_h2c_tvalid_dfi & s_axis_h2c_tready_dfi) begin
        app_en    <= 1'b1;
        app_instr <= s_axis_h2c_tdata_dfi[31:0];
      end
      else begin
        app_en    <= 1'b0;
        app_instr <= 32'h0000;
      end
    end
  end

  
  //**************************************
  // SoftMC -> Host (AXI-Stream Master)
  //**************************************
  
  reg rdback_data_pc0_valid;
  reg rdback_data_pc1_valid;

  assign m_axis_c2h_tvalid_dfi = rdback_data_pc0_valid | rdback_data_pc1_valid;
  assign m_axis_c2h_tdata_dfi [255:0]   = rdback_data_pc0_valid ? rdback_data_pc0 : {256{1'b0}};
  assign m_axis_c2h_tdata_dfi [511:256] = rdback_data_pc1_valid ? rdback_data_pc1 : {256{1'b0}};

  assign rdback_fifo_rd_en_pc0 = !rdback_fifo_empty_pc0 & ((!rdback_data_pc0_valid) | (rdback_data_pc0_valid & m_axis_c2h_tready_dfi));
  assign rdback_fifo_rd_en_pc1 = !rdback_fifo_empty_pc1 & ((!rdback_data_pc1_valid) | (rdback_data_pc1_valid & m_axis_c2h_tready_dfi));

  always@(posedge dfi_0_clk or negedge dfi_0_rst_n) begin
    if(!dfi_0_rst_n) begin
      rdback_data_pc0_valid <= 1'b0;
    end
    else begin
      if(rdback_fifo_rd_en_pc0) begin
        rdback_data_pc0_valid <= 1'b1;
      end
      else begin
        if(m_axis_c2h_tready_dfi) begin
          rdback_data_pc0_valid <= 1'b0;
        end
        else begin
          rdback_data_pc0_valid <= rdback_data_pc0_valid;
        end
      end
    end
  end

  always@(posedge dfi_0_clk or negedge dfi_0_rst_n) begin
    if(!dfi_0_rst_n) begin
      rdback_data_pc1_valid <= 1'b0;
    end
    else begin
      if(rdback_fifo_rd_en_pc1) begin
        rdback_data_pc1_valid <= 1'b1;
      end
      else begin
        if(m_axis_c2h_tready_dfi) begin
          rdback_data_pc1_valid <= 1'b0;
        end
        else begin
          rdback_data_pc1_valid <= rdback_data_pc1_valid;
        end
      end
    end
  end

  // AXI-Stream Clock Converter (Host -> SoftMC)
  axis_clock_converter_0
    h2c_axis_clock_converter
  (
    .s_axis_aclk    ( xdma_axi_clk           ),
    .m_axis_aclk    ( dfi_0_clk              ),
    .s_axis_aresetn ( xdma_axi_ready         ),
    .m_axis_aresetn ( dfi_0_rst_n            ),
    .s_axis_tready  ( s_axis_h2c_tready ),
    .m_axis_tready  ( s_axis_h2c_tready_dfi  ),
    .s_axis_tvalid  ( s_axis_h2c_tvalid      ),
    .s_axis_tdata   ( s_axis_h2c_tdata       ),
//    .s_axis_tkeep   ( s_axis_h2c_tkeep           ),
//    .s_axis_tlast   ( s_axis_h2c_tlast            ),
    .m_axis_tvalid  ( s_axis_h2c_tvalid_dfi  ),
    .m_axis_tdata   ( s_axis_h2c_tdata_dfi   )
//    .m_axis_tkeep   ( s_axis_h2c_tkeep_dfi  ),
//    .m_axis_tlast   ( s_axis_h2c_tlast_dfi   )
  );


  // AXI-Stream Clock Converter (SoftMC -> Host)
  axis_clock_converter_0
    c2h_axis_clock_converter
  (
    .s_axis_aclk    ( dfi_0_clk              ),
    .m_axis_aclk    ( xdma_axi_clk           ),
    .s_axis_aresetn ( dfi_0_rst_n            ),
    .m_axis_aresetn ( xdma_axi_ready         ),
    .s_axis_tready  ( m_axis_c2h_tready_dfi  ),
    .m_axis_tready  ( m_axis_c2h_tready           ),
    .s_axis_tvalid  ( m_axis_c2h_tvalid_dfi  ),
    .s_axis_tdata   ( m_axis_c2h_tdata_dfi   ),
//    .s_axis_tkeep   ( m_axis_c2h_tkeep_dfi   ),
//    .s_axis_tlast   ( m_axis_c2h_tlast_dfi   ),
    .m_axis_tvalid  ( m_axis_c2h_tvalid           ),
    .m_axis_tdata   ( m_axis_c2h_tdata            )
//    .m_axis_tkeep   ( m_axis_c2h_tkeep            ),
//    .m_axis_tlast   ( m_axis_c2h_tlast            )
  );



endmodule
