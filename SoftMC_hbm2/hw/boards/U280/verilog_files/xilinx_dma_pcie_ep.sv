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
// File       : xilinx_dma_pcie_ep.sv
// Version    : 4.1
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps
module xilinx_dma_pcie_ep
#(
  parameter PL_LINK_CAP_MAX_LINK_WIDTH = 8,        // 1- X1; 2 - X2; 4 - X4; 8 - X8
  parameter PL_SIM_FAST_LINK_TRAINING  = "FALSE",  // Simulation Speedup
  parameter PL_LINK_CAP_MAX_LINK_SPEED = 8,        // 1- GEN1; 2 - GEN2; 4 - GEN3
  parameter C_DATA_WIDTH               = 512 ,
  parameter EXT_PIPE_SIM               = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.
  parameter C_ROOT_PORT                = "FALSE",  // PCIe block is in root port mode
  parameter C_DEVICE_NUMBER            = 0,        // Device number for Root Port configurations only
  parameter AXIS_CCIX_RX_TDATA_WIDTH   = 256, 
  parameter AXIS_CCIX_TX_TDATA_WIDTH   = 256,
  parameter AXIS_CCIX_RX_TUSER_WIDTH   = 46,
  parameter AXIS_CCIX_TX_TUSER_WIDTH   = 46,
  parameter DQ_WIDTH                   = 256
)
(
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_txp,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_txn,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_rxp,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0] pci_exp_rxn,

  input                                   sys_clk_p,
  input                                   sys_clk_n,
  input                                   sys_rst_n,

  // SoftMC signals
  input                           dfi_0_clk, // 450MHz
  input                           dfi_0_rst_n,

  output                          xdma_axi_clk,
  output                          xdma_axi_resetn,
    // App Command Interface
  output reg                      app_en,
  input                           app_ack,
  output reg [31:0]               app_instr, 
  input                           iq_full,
    //Data read back Interface
  output reg                      rdback_fifo_rd_en_pc0,
  output reg                      rdback_fifo_rd_en_pc1,
  input                           rdback_fifo_empty_pc0,
  input                           rdback_fifo_empty_pc1,
  input [DQ_WIDTH-1:0]            rdback_data_pc0,
  input [DQ_WIDTH-1:0]            rdback_data_pc1
);

  //-----------------------------------------------------------------------------------------------------------------------

   
  // Local Parameters derived from user selection
  localparam integer USER_CLK_FREQ      = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? 5 : 4);
  localparam         TCQ                = 1;
  localparam         C_S_AXI_ID_WIDTH   = 4; 
  localparam         C_M_AXI_ID_WIDTH   = 4; 
  localparam         C_S_AXI_DATA_WIDTH = C_DATA_WIDTH;
  localparam         C_M_AXI_DATA_WIDTH = C_DATA_WIDTH;
  localparam         C_S_AXI_ADDR_WIDTH = 64;
  localparam         C_M_AXI_ADDR_WIDTH = 64;
  localparam         C_NUM_USR_IRQ	    = 1;

   
  // XDMA AXI Interface
  //wire                           xdma_axi_clk; // 250MHz
  //wire                           xdma_axi_resetn;
  wire                           user_lnk_up;
  
  // System Interface
  wire                           sys_clk;
  wire                           sys_clk_gt;
  wire                           sys_rst_n_c;



  // AXI streaming ports  (master, slave from SoftMC's point of view)
  wire [C_DATA_WIDTH-1:0]        s_axis_h2c_tdata;
  wire                           s_axis_h2c_tlast;
  wire                           s_axis_h2c_tvalid;
  wire                           s_axis_h2c_tready;
  wire [C_DATA_WIDTH/8-1:0]      s_axis_h2c_tkeep;
  wire [C_DATA_WIDTH-1:0]        m_axis_c2h_tdata; 
  wire                           m_axis_c2h_tlast;
  wire                           m_axis_c2h_tvalid;
  wire                           m_axis_c2h_tready;
  wire [C_DATA_WIDTH/8-1:0]      m_axis_c2h_tkeep; 

  wire                           free_run_clock;

  wire [5:0]                     cfg_ltssm_state;


  // Ref clock buffer
  IBUFDS_GTE4
  #(
    .REFCLK_HROW_CK_SEL ( 2'b00 )
  )
    refclk_ibuf
  (
    .O                  ( sys_clk_gt ),
    .ODIV2              ( sys_clk    ),
    .I                  ( sys_clk_p  ),
    .CEB                ( 1'b0),
    .IB                 ( sys_clk_n  )
  );

  // Reset buffer
  IBUF
    sys_reset_n_ibuf
  (
    .O ( sys_rst_n_c ),
    .I ( sys_rst_n   )
  );
     

  // Core Top Level Wrapper
  xdma_0
    u_xdma_0 
  (
    //---------------------------------------------------------------------------------------//
    //  PCI Express (pci_exp) Interface                                                      //
    //---------------------------------------------------------------------------------------//
    .sys_rst_n            ( sys_rst_n_c            ),

    .sys_clk              ( sys_clk                ),
    .sys_clk_gt           ( sys_clk_gt             ),

    // Tx
    .pci_exp_txn          ( pci_exp_txn            ),
    .pci_exp_txp          ( pci_exp_txp            ),

    // Rx
    .pci_exp_rxn          ( pci_exp_rxn            ),
    .pci_exp_rxp          ( pci_exp_rxp            ),

    // AXI streaming ports
    .s_axis_c2h_tdata_0   ( m_axis_c2h_tdata       ),  
//    .s_axis_c2h_tlast_0   ( m_axis_c2h_tlast       ),
    .s_axis_c2h_tlast_0   ( 1'b1                   ),
    .s_axis_c2h_tvalid_0  ( m_axis_c2h_tvalid      ), 
    .s_axis_c2h_tready_0  ( m_axis_c2h_tready      ),
//    .s_axis_c2h_tkeep_0   ( m_axis_c2h_tkeep       ),
    .s_axis_c2h_tkeep_0   ( {C_DATA_WIDTH/8{1'b1}} ),
    .m_axis_h2c_tdata_0   ( s_axis_h2c_tdata       ),
    .m_axis_h2c_tlast_0   ( s_axis_h2c_tlast       ),
//    .m_axis_h2c_tlast_0   (),
    .m_axis_h2c_tvalid_0  ( s_axis_h2c_tvalid      ),
    .m_axis_h2c_tready_0  ( s_axis_h2c_tready      ),
    .m_axis_h2c_tkeep_0   ( s_axis_h2c_tkeep       ),
//    .m_axis_h2c_tkeep_0   (),

    .usr_irq_req          ( {C_NUM_USR_IRQ{1'b0}}  ),
    .usr_irq_ack (),
    .msi_enable (),
    .msi_vector_width (),

    // Config managemnet interface
    .cfg_mgmt_addr        ( 19'b0                  ),
    .cfg_mgmt_write       ( 1'b0                   ),
    .cfg_mgmt_write_data  ( 32'b0                  ),
    .cfg_mgmt_byte_enable ( 4'b0                   ),
    .cfg_mgmt_read        ( 1'b0                   ),
    .cfg_mgmt_read_data (),
    .cfg_mgmt_read_write_done (),

    //-- AXI Global
    .axi_aclk             ( xdma_axi_clk           ),
    .axi_aresetn          ( xdma_axi_resetn        ),

    .user_lnk_up          ( user_lnk_up            )
  );


  // XDMA adapter
  xdma_adapter
  #(   
    .C_DATA_WIDTH     ( C_DATA_WIDTH ),
    .C_M_AXI_ID_WIDTH ( 4            ),
    .DQ_WIDTH         ( DQ_WIDTH     )
  )
    u_xdma_adapter
  (    
    // AXI streaming ports  (master, slave from SoftMC's point of view)
    // 250MHz
    .s_axis_h2c_tdata      ( s_axis_h2c_tdata      ),
//    .s_axis_h2c_tlast      ( s_axis_h2c_tlast      ),
    .s_axis_h2c_tvalid     ( s_axis_h2c_tvalid     ),
    .s_axis_h2c_tready     ( s_axis_h2c_tready     ),
//    .s_axis_h2c_tkeep      ( s_axis_h2c_tkeep      ),
    .m_axis_c2h_tdata      ( m_axis_c2h_tdata      ),
//    .m_axis_c2h_tlast      ( m_axis_c2h_tlast      ),
    .m_axis_c2h_tvalid     ( m_axis_c2h_tvalid     ),
    .m_axis_c2h_tready     ( m_axis_c2h_tready     ),
//    .m_axis_c2h_tkeep      ( m_axis_c2h_tkeep      ),
    // XDMA signals        
    .xdma_axi_clk          ( xdma_axi_clk          ), // 250MHz
    .xdma_axi_resetn       ( xdma_axi_resetn       ),
    .user_lnk_up           ( user_lnk_up           ),
    // SoftMC signals      
    .dfi_0_clk             ( dfi_0_clk             ), // 450MHz
    .dfi_0_rst_n           ( dfi_0_rst_n           ),
      // App Command Interface
    .app_en                ( app_en                ),
    .app_ack               ( app_ack               ),
    .app_instr             ( app_instr             ),
    .iq_full               ( iq_full               ),
      //Data read back Interface
    .rdback_fifo_rd_en_pc0 ( rdback_fifo_rd_en_pc0 ),
    .rdback_fifo_rd_en_pc1 ( rdback_fifo_rd_en_pc1 ),
    .rdback_fifo_empty_pc0 ( rdback_fifo_empty_pc0 ),
    .rdback_fifo_empty_pc1 ( rdback_fifo_empty_pc1 ),
    .rdback_data_pc0       ( rdback_data_pc0       ),
    .rdback_data_pc1       ( rdback_data_pc1       )
  );

endmodule
