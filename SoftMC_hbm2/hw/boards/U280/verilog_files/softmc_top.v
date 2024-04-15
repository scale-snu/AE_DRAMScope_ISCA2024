`timescale 1ps / 1ps

`include "softmc_define.vh"

module softMC_top
#(
  parameter RA_WIDTH        = 14,
  parameter CA_WIDTH        = 4,
  parameter BA_WIDTH        = 2,
  parameter BG_WIDTH        = 2,
  parameter PC_WIDTH        = 1,
//  parameter CH_WIDTH        = 3,
  parameter SID_WIDTH       = 1,
  parameter CKE_WIDTH       = 1,
  parameter DQ_WIDTH        = 256,
  parameter C_WIDTH         = 8,
  parameter PAR             = 1'b1,
  parameter RL              = 18,
  parameter WL              = 7,
  parameter PCIE_DATA_WIDTH = 512
)
(


  output   hbm_cattrip_output,

  input    sys_clk_p,
  input    sys_clk_n,
  input    sys_rst_n,

`ifndef SIMULATION
  input    APB_0_PCLK_p,
  input    APB_0_PCLK_n,
  //input    APB_0_PRESET_N,
  input    AXI_ACLK_IN_0_p,
  input    AXI_ACLK_IN_0_n, 
  //input    AXI_ARESET_N_0,

  // PCIe interface
  output  [7:0]    pci_exp_txp,
  output  [7:0]    pci_exp_txn,
  input   [7:0]    pci_exp_rxp,
  input   [7:0]    pci_exp_rxn
`else
  input    APB_0_PCLK,
  input    APB_0_PRESET_N,
  input    AXI_ACLK_IN_0, 
  input    AXI_ARESET_N_0,

  // XDMA signals
  input            xdma_axi_clk, // 250MHz
  input            xdma_axi_resetn,
  input            user_lnk_up,

  // AXI streaming ports  (master, slave from SoftMC's point of view)
  input  [PCIE_DATA_WIDTH-1:0]   s_axis_h2c_tdata,
//  input                          s_axis_h2c_tlast,
  input                          s_axis_h2c_tvalid,
  output                         s_axis_h2c_tready,
//  input  [PCIE_DATA_WIDTH/8-1:0] s_axis_h2c_tkeep,
  output [PCIE_DATA_WIDTH-1:0]   m_axis_c2h_tdata,
//  output                         m_axis_c2h_tlast,
  output                         m_axis_c2h_tvalid,
  input                          m_axis_c2h_tready
//  output [PCIE_DATA_WIDTH/8-1:0] m_axis_c2h_tkeep
`endif
);

  ////////////////////////////////////////////////////////////////////////////////
  // Localparams
  ////////////////////////////////////////////////////////////////////////////////
  localparam MMCM_CLKFBOUT_MULT_F  = 9; // 450 Mhz
  localparam MMCM_CLKOUT0_DIVIDE_F = 2;
  localparam MMCM_DIVCLK_DIVIDE    = 1;
  localparam MMCM_CLKIN1_PERIOD    = 10.000; // 100 Mhz
  /*
  localparam MMCM_CLKFBOUT_MULT_F  = 11.875; // 450 Mhz
  localparam MMCM_CLKOUT0_DIVIDE_F = 4.750;
  localparam MMCM_DIVCLK_DIVIDE    = 1;
  localparam MMCM_CLKIN1_PERIOD    = 10.000; // 100 Mhz
  */
  localparam MMCM1_CLKFBOUT_MULT_F  = 9;
  localparam MMCM1_CLKOUT0_DIVIDE_F = 2;
  localparam MMCM1_DIVCLK_DIVIDE    = 1;
  localparam MMCM1_CLKIN1_PERIOD    = 10.000;


  ////////////////////////////////////////////////////////////////////////////////
  // Wire and Reg Delcaration
  ////////////////////////////////////////////////////////////////////////////////
  OBUF
    HBM_CATRIP_INST
  (
    .I (1'b0),
    .O (hbm_cattrip_output)
  ); 

  // Reset
`ifndef SIMULATION

  wire          APB_0_PRESET_N;
  wire          AXI_ARESET_N_0;
  assign APB_0_PRESET_N = xdma_axi_resetn;
  assign AXI_ARESET_N_0 = xdma_axi_resetn;

/*
  reg          APB_0_PRESET_N;
  reg          AXI_ARESET_N_0;
   wire       xdma_axi_clk;
   */
`endif


  // 250 test
 

  // App Command Interface
  wire                app_en;
  wire                app_ack;
  wire [31:0]         app_instr; 
  wire                iq_full;

  // DFI INTERFACE SIGNALS
  wire                dfi_0_clk;
  wire                dfi_0_rst_n;
  wire                dfi_0_out_rst_n;
  wire [3:0]          dfi_0_dw_rddata_valid;
  wire [DQ_WIDTH-1:0] dfi_0_dw_rddata_p0;
  wire [DQ_WIDTH-1:0] dfi_0_dw_rddata_p1;
  reg	                dfi_0_init_start;
  reg	 [1:0]          dfi_0_aw_ck_p0;
  reg  [1:0]          dfi_0_aw_cke_p0;
  wire [11:0]         dfi_0_aw_row_p0;
  wire [15:0]	        dfi_0_aw_col_p0;
  wire [DQ_WIDTH-1:0]	dfi_0_dw_wrdata_p0;
  reg  [1:0]		      dfi_0_aw_ck_p1;
  reg  [1:0]		      dfi_0_aw_cke_p1;
  wire [11:0]	        dfi_0_aw_row_p1;
  wire [15:0]	        dfi_0_aw_col_p1;
  wire [DQ_WIDTH-1:0]	dfi_0_dw_wrdata_p1;
  wire                dfi_0_init_complete;

  // Data Read Back Interface
  wire                rdback_fifo_rd_en_pc0;
  wire                rdback_fifo_rd_en_pc1;
  wire                rdback_fifo_empty_pc0;
  wire                rdback_fifo_empty_pc1;
  wire [DQ_WIDTH-1:0] rdback_data_pc0;
  wire [DQ_WIDTH-1:0] rdback_data_pc1;

  ////////////////////////////////////////////////////////////////////////////////
  // Wire Declaration for AXI ACLK
  ////////////////////////////////////////////////////////////////////////////////
  (* keep = "TRUE" *)   wire          AXI_ACLK_IN_0_buf;
  (* keep = "TRUE" *)   wire          AXI_ACLK0_st0_buf;
  wire AXI_ACLK0_st0;

  wire          MMCM_LOCK_0;

  ////////////////////////////////////////////////////////////////////////////////
  // Reg Declaration for AXI Reset
  ////////////////////////////////////////////////////////////////////////////////
  reg  [3:0]    cnt_rst_0;
  reg           axi_rst_0_r1_n;
  reg           axi_rst_0_mmcm_n;
  (* keep = "TRUE" *) reg           axi_rst_st0_n;
  (* ASYNC_REG = "TRUE" *) reg           axi_rst0_st0_r1_n, axi_rst0_st0_r2_n;
  (* keep = "TRUE" *) reg           axi_rst0_st0_n;


  ////////////////////////////////////////////////////////////////////////////////
  // Instantiating BUFG for AXI Clock
  ////////////////////////////////////////////////////////////////////////////////
  (* ASYNC_REG = "TRUE" *) reg           w_rst_sys_rst_0_r1;
  (* ASYNC_REG = "TRUE" *) reg           w_rst_sys_rst_0_r2;
  (* ASYNC_REG = "TRUE" *) reg           w_rst_sys_rst_1_r1;
  (* ASYNC_REG = "TRUE" *) reg           w_rst_sys_rst_1_r2;
  wire	[3:0]		w_rst_sys_rst_0;
  wire	[3:0]		w_rst_sys_rst_1;

  (* keep = "TRUE" *) wire      APB_0_PCLK_IBUF;
  (* keep = "TRUE" *) wire      APB_0_PCLK_BUF;
  (* keep = "TRUE" *) wire      APB_0_PRESET_N_sync;

`ifndef SIMULATION

  IBUFDS #(
    .CAPACITANCE("DONT_CARE"),
    .DIFF_TERM("FALSE"), 
    .IBUF_DELAY_VALUE("0"), 
    .IFD_DELAY_VALUE("AUTO"), 
    .IOSTANDARD("DEFAULT")
  )
    APB_0_PCLK_ibufds
  (
    .O                  ( APB_0_PCLK_BUF    ),
    .I                  ( APB_0_PCLK_p      ),
    .IB                 (APB_0_PCLK_n       )
  );
`else
  BUFG
    u_APB_0_PCLK_BUFG
  (
    .I (APB_0_PCLK),
    .O (APB_0_PCLK_BUF)
  );
`endif


  reg	[7:0]	cnt_apb_rst_p2l_st0;
  wire		w_apb_0_reset_n_inv_st0;
  reg			r_apb_preset_n_p2l_st0; 
  assign	w_apb_0_reset_n_inv_st0 = APB_0_PRESET_N && ~w_rst_sys_rst_0[0];
  always @ ( posedge APB_0_PCLK_BUF or negedge  w_apb_0_reset_n_inv_st0 ) begin
    if( w_apb_0_reset_n_inv_st0 == 1'b0 ) begin
        cnt_apb_rst_p2l_st0 <= 8'd0;
        r_apb_preset_n_p2l_st0 <= 1'd0;
    end
    else begin
      if( cnt_apb_rst_p2l_st0 >= 8'd200 ) begin
        r_apb_preset_n_p2l_st0	<= 1'd1;
        cnt_apb_rst_p2l_st0		<= cnt_apb_rst_p2l_st0;
      end
      else begin
        cnt_apb_rst_p2l_st0		<= cnt_apb_rst_p2l_st0 + 8'd1;
        r_apb_preset_n_p2l_st0 <= 1'b0;
      end
    end
  end

  assign APB_0_PRESET_N_sync = r_apb_preset_n_p2l_st0 ;

`ifndef SIMULATION

  IBUFDS #(
    .CAPACITANCE("DONT_CARE"),
    .DIFF_TERM("FALSE"), 
    .IBUF_DELAY_VALUE("0"), 
    .IFD_DELAY_VALUE("AUTO"), 
    .IOSTANDARD("DEFAULT")
  )
    AXI_ACLK_IN_ibufds
  (
    .O             ( AXI_ACLK_IN_0_buf    ),
    .I                  ( AXI_ACLK_IN_0_p  ),
    .IB                 (AXI_ACLK_IN_0_n  )
  );
`else
  BUFG
    u_AXI_ACLK_IN_0
  (
    .I (AXI_ACLK_IN_0),
    .O (AXI_ACLK_IN_0_buf)
  );
`endif
  ////////////////////////////////////////////////////////////////////////////////
  // Reset logic for AXI_0
  ////////////////////////////////////////////////////////////////////////////////
  assign w_rst_sys_rst_0 = 4'h0; // add this for reset from example_top_syn.sv

  always @ (posedge AXI_ACLK_IN_0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      axi_rst_0_r1_n <= 1'b0;
    end else begin
      axi_rst_0_r1_n <= 1'b1;
    end
  end

  always @ (posedge AXI_ACLK_IN_0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      cnt_rst_0 <= 4'hA;
    end
    else begin
      if (~axi_rst_0_r1_n) begin
        cnt_rst_0 <= 4'hA;
      end
      else if (cnt_rst_0 != 4'h0) begin
        cnt_rst_0 <= cnt_rst_0 - 1'b1;
      end
      else begin
        cnt_rst_0 <= cnt_rst_0;
      end
    end
  end

  always @ (posedge AXI_ACLK_IN_0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      axi_rst_0_mmcm_n  <= 1'b0;
    end
    else begin
      if (cnt_rst_0 != 4'h0) begin
        axi_rst_0_mmcm_n <= 1'b0;
      end
      else begin
        axi_rst_0_mmcm_n <= 1'b1;
      end
    end
  end

  always @ (posedge AXI_ACLK_IN_0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      w_rst_sys_rst_0_r1 <= 1'b0;
      w_rst_sys_rst_0_r2 <= 1'b0;
    end
    else begin
      w_rst_sys_rst_0_r1 <= w_rst_sys_rst_0[1];
      w_rst_sys_rst_0_r2 <= w_rst_sys_rst_0_r1;
    end
  end

  always @ (posedge AXI_ACLK_IN_0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      axi_rst_st0_n <= 1'b0;
    end
    else begin
      axi_rst_st0_n <= axi_rst_0_mmcm_n & MMCM_LOCK_0 & (~w_rst_sys_rst_0_r2);
    end
  end

  always @ (posedge AXI_ACLK0_st0_buf or negedge AXI_ARESET_N_0) begin 
    if (~AXI_ARESET_N_0) begin
      axi_rst0_st0_r1_n <= 1'b0;
      axi_rst0_st0_r2_n <= 1'b0;
    end
    else begin
      axi_rst0_st0_r1_n <= axi_rst_st0_n;
      axi_rst0_st0_r2_n <= axi_rst0_st0_r1_n;
    end
  end

  always @ (posedge AXI_ACLK0_st0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      axi_rst0_st0_n <= 1'b0;
    end
    else begin
      axi_rst0_st0_n <= axi_rst0_st0_r2_n;
    end
  end

  reg [7:0] cnt_rst_0_0;
  reg       axi_rst_0_mmcm_n_0;

  always @ (posedge AXI_ACLK_IN_0_buf or negedge AXI_ARESET_N_0) begin
    if (~AXI_ARESET_N_0) begin
      cnt_rst_0_0        <= 8'h00;
      axi_rst_0_mmcm_n_0 <= 1'b0;
    end
    else begin
      if (~axi_rst_0_r1_n) begin
        if( cnt_rst_0_0 >= 8'd100 ) begin
          cnt_rst_0_0 <= cnt_rst_0_0;
          axi_rst_0_mmcm_n_0 <= 1'b0;
        end
        else begin
          cnt_rst_0_0 <= cnt_rst_0_0 + 1;
          axi_rst_0_mmcm_n_0 <= axi_rst_0_mmcm_n_0;
        end
      end
      else begin
        cnt_rst_0_0 <= 'd0;
        axi_rst_0_mmcm_n_0 <= 1'b1;
      end
    end
  end


  ////////////////////////////////////////////////////////////////////////////////
  // Instantiating MMCM for AXI clock generation
  ////////////////////////////////////////////////////////////////////////////////
  `ifndef SIMULATION  
    clk_wiz_0 
      clknetwork
    (
      .clk_out1   ( AXI_ACLK0_st0_buf         ),
      .reset      ( ~axi_rst_0_mmcm_n_0   ),
      .locked     ( MMCM_LOCK_0           ),
      .clk_in1    ( AXI_ACLK_IN_0_buf     )
    );
  `else
    MMCME4_ADV
    #(
      .BANDWIDTH            ("OPTIMIZED"),
      .CLKOUT4_CASCADE      ("FALSE"),
      .COMPENSATION         ("INTERNAL"), //  "AUTO"
      .STARTUP_WAIT         ("FALSE"),
      .DIVCLK_DIVIDE        (MMCM_DIVCLK_DIVIDE),
      .CLKFBOUT_MULT_F      (MMCM_CLKFBOUT_MULT_F),
      .CLKFBOUT_PHASE       (0.000),
      .CLKFBOUT_USE_FINE_PS ("FALSE"),
      .CLKOUT0_DIVIDE_F     (MMCM_CLKOUT0_DIVIDE_F),
      .CLKOUT0_PHASE        (0.000),
      .CLKOUT0_DUTY_CYCLE   (0.500),
      .CLKOUT0_USE_FINE_PS  ("FALSE"),
      .CLKOUT1_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
      .CLKOUT2_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
      .CLKOUT3_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
      .CLKOUT4_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
      .CLKOUT5_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
      .CLKOUT6_DIVIDE       (MMCM_CLKOUT0_DIVIDE_F),
      .CLKIN1_PERIOD        (MMCM_CLKIN1_PERIOD),
      .REF_JITTER1          (0.010)
    )
      u_mmcm_0
    (
      // Output clocks
      .CLKOUT0             (AXI_ACLK0_st0),     // 450 MHz
      // Input clock control
      .CLKIN1              (AXI_ACLK_IN_0_buf), // 100 MHz
      .CLKIN2              (1'b0),
      // Other control and status signals
      .LOCKED              (MMCM_LOCK_0),
      .PWRDWN              (1'b0),
      .RST                 (~axi_rst_0_mmcm_n_0),
      .CDDCREQ             (1'b0),
      .CLKINSEL            (1'b1),
      .DADDR               (7'b0),
      .DCLK                (1'b0),
      .DEN                 (1'b0),
      .DI                  (16'b0),
      .DWE                 (1'b0),
      .PSCLK               (1'b0),
      .PSEN                (1'b0),
      .PSINCDEC            (1'b0)
    );

    BUFG
      u_AXI_ACLK0_st0
    (
      .I (AXI_ACLK0_st0),
      .O (AXI_ACLK0_st0_buf)
    );
  `endif

  ////////////////////////////////////////////////////////////////////////////////
  // Instantiating HBM PHY
  ////////////////////////////////////////////////////////////////////////////////
  hbm_0
    u_hbm_0
  (
    .HBM_REF_CLK_0                 (HBM_REF_CLK_0            )
    ,.dfi_0_clk                    (dfi_0_clk                )
    ,.dfi_0_rst_n                  (dfi_0_rst_n              )
    ,.dfi_0_init_start             (dfi_0_init_start         )
    ,.dfi_0_aw_ck_p0               (dfi_0_aw_ck_p0           )
    ,.dfi_0_aw_cke_p0              (dfi_0_aw_cke_p0          )
    ,.dfi_0_aw_row_p0              (dfi_0_aw_row_p0          )
    ,.dfi_0_aw_col_p0              (dfi_0_aw_col_p0          )
    ,.dfi_0_dw_wrdata_p0           (dfi_0_dw_wrdata_p0       )
    ,.dfi_0_dw_wrdata_mask_p0      (32'h0000_0000)
    ,.dfi_0_dw_wrdata_dbi_p0       (32'h0000_0000)
    ,.dfi_0_dw_wrdata_par_p0       (8'h00)
    ,.dfi_0_dw_wrdata_dq_en_p0     (8'h00)
    ,.dfi_0_dw_wrdata_par_en_p0    (8'h00)
    ,.dfi_0_aw_ck_p1               (dfi_0_aw_ck_p1           )
    ,.dfi_0_aw_cke_p1              (dfi_0_aw_cke_p1          )
    ,.dfi_0_aw_row_p1              (dfi_0_aw_row_p1          )
    ,.dfi_0_aw_col_p1              (dfi_0_aw_col_p1          )
    ,.dfi_0_dw_wrdata_p1           (dfi_0_dw_wrdata_p1       )
    ,.dfi_0_dw_wrdata_mask_p1      (32'h0000_0000)
    ,.dfi_0_dw_wrdata_dbi_p1       (32'h0000_0000)
    ,.dfi_0_dw_wrdata_par_p1       (8'h00)
    ,.dfi_0_dw_wrdata_dq_en_p1     (8'h00)
    ,.dfi_0_dw_wrdata_par_en_p1    (8'h00)
    ,.dfi_0_aw_ck_dis              (1'b0)
    ,.dfi_0_lp_pwr_e_req           (1'b0)
    ,.dfi_0_lp_sr_e_req            (1'b0)
    ,.dfi_0_lp_pwr_x_req           (1'b0)
    ,.dfi_0_aw_tx_indx_ld          (1'b0)
    ,.dfi_0_dw_tx_indx_ld          (1'b0)
    ,.dfi_0_dw_rx_indx_ld          (1'b0)
    ,.dfi_0_ctrlupd_ack            (1'b0)
    ,.dfi_0_phyupd_req             (1'b0)
    ,.dfi_0_dw_wrdata_dqs_p0       (8'hff)
    ,.dfi_0_dw_wrdata_dqs_p1       (8'hff)
    
    ,.APB_0_PCLK                   (APB_0_PCLK_BUF           )
    ,.APB_0_PRESET_N               (APB_0_PRESET_N_sync      )

    ,.dfi_0_dw_rddata_p0           (dfi_0_dw_rddata_p0       )
    ,.dfi_0_dw_rddata_dm_p0        ()
    ,.dfi_0_dw_rddata_dbi_p0       ()
    ,.dfi_0_dw_rddata_par_p0       ()
    ,.dfi_0_dw_rddata_p1           (dfi_0_dw_rddata_p1       )
    ,.dfi_0_dw_rddata_dm_p1        ()
    ,.dfi_0_dw_rddata_dbi_p1       ()
    ,.dfi_0_dw_rddata_par_p1       ()
    ,.dfi_0_dbi_byte_disable       ()
    ,.dfi_0_dw_rddata_valid        (dfi_0_dw_rddata_valid    )
    ,.dfi_0_dw_derr_n              ()
    ,.dfi_0_aw_aerr_n              ()
    ,.dfi_0_ctrlupd_req            ()
    ,.dfi_0_phyupd_ack             ()
    ,.dfi_0_clk_init               ()
    ,.dfi_0_init_complete          (dfi_0_init_complete      )
    ,.dfi_0_out_rst_n              (dfi_0_out_rst_n          )
    
    ,.apb_complete_0               ()
    
    ,.DRAM_0_STAT_CATTRIP          ()
    ,.DRAM_0_STAT_TEMP             ()
  );


  assign HBM_REF_CLK_0 = AXI_ACLK_IN_0_buf;
  
  assign dfi_0_clk = AXI_ACLK0_st0_buf;
  assign dfi_0_rst_n = axi_rst0_st0_n;

  always @(posedge dfi_0_clk or negedge dfi_0_rst_n) begin
    if (~dfi_0_rst_n) begin
      dfi_0_init_start <= 1'b0;
    end
    else if (dfi_0_out_rst_n == 1'b1) begin
      dfi_0_init_start <= 1'b1;
    end  
  end




  ////////////////////////////////////////////////////////////////////////////////
  // Counter to wait for driving CKE signal  
  ////////////////////////////////////////////////////////////////////////////////

  reg [3:0] cke_cnt;

  always @ (posedge dfi_0_clk or negedge dfi_0_rst_n) begin
    if (~dfi_0_rst_n) begin
      cke_cnt <= 4'h0;
    end else if (dfi_0_init_complete == 1'b1 && cke_cnt != 4'hf) begin
      cke_cnt <= cke_cnt + 1'b1;
    end
  end

  always @ (posedge dfi_0_clk or negedge dfi_0_rst_n) begin
    if (~dfi_0_rst_n) begin
      dfi_0_aw_cke_p0 <= 2'b00;
      dfi_0_aw_cke_p1 <= 2'b00;
      dfi_0_aw_ck_p0  <= 2'b00;
      dfi_0_aw_ck_p1  <= 2'b00;
    end else if (cke_cnt == 4'he) begin
      dfi_0_aw_cke_p0 <= 2'b11;
      dfi_0_aw_cke_p1 <= 2'b11;
      dfi_0_aw_ck_p0  <= 2'b01;
      dfi_0_aw_ck_p1  <= 2'b01;
    end
  end


  softMC
  #(
    .RA_WIDTH              ( RA_WIDTH              ),
    .CA_WIDTH              ( CA_WIDTH              ),
    .BA_WIDTH              ( BA_WIDTH              ),
    .BG_WIDTH              ( BG_WIDTH              ),
    .PC_WIDTH              ( PC_WIDTH              ),
    .SID_WIDTH             ( SID_WIDTH             ),
    .DQ_WIDTH              ( DQ_WIDTH              ),
    .WL                    ( WL                    )
  )
    u_softmc
  (
    .clk                   ( dfi_0_clk             ),
    .rstn                  ( dfi_0_rst_n           ),
    //.clk                   ( xdma_axi_clk          ),
    //.rstn                  ( xdma_axi_resetn       ),
    //.clk                   ( AXI_ACLK_IN_0_buf     ),
    //.rstn                  ( AXI_ARESET_N_0        ),
    .app_en                ( app_en                ),
    .app_ack               ( app_ack               ),
    .app_instr             ( app_instr             ),
    .iq_full               ( iq_full               ),
    
    // DFI Interface
    .dfi_0_aw_row_p0       ( dfi_0_aw_row_p0       ),
    .dfi_0_aw_col_p0       ( dfi_0_aw_col_p0       ),
    .dfi_0_dw_wrdata_p0    ( dfi_0_dw_wrdata_p0    ),
    .dfi_0_aw_row_p1       ( dfi_0_aw_row_p1       ),
    .dfi_0_aw_col_p1       ( dfi_0_aw_col_p1       ),
    .dfi_0_dw_wrdata_p1    ( dfi_0_dw_wrdata_p1    ),
    .dfi_0_dw_rddata_p0    ( dfi_0_dw_rddata_p0    ),
    .dfi_0_dw_rddata_p1    ( dfi_0_dw_rddata_p1    ),
    .dfi_0_dw_rddata_valid ( dfi_0_dw_rddata_valid ),
    .dfi_0_aw_ck_dis       ( dfi_0_aw_ck_dis       ),
    
    // Data Read Back Interface
    .rdback_fifo_rd_en_pc0 ( rdback_fifo_rd_en_pc0 ),
    .rdback_fifo_rd_en_pc1 ( rdback_fifo_rd_en_pc1 ),
    .rdback_fifo_empty_pc0 ( rdback_fifo_empty_pc0 ),
    .rdback_fifo_empty_pc1 ( rdback_fifo_empty_pc1 ),
    .rdback_data_pc0       ( rdback_data_pc0       ),
    .rdback_data_pc1       ( rdback_data_pc1       )
  );

`ifndef SIMULATION
  // XDMA PCIe Endpoint
  xilinx_dma_pcie_ep
//  #(
//    .DQ_WIDTH ( DQ_WIDTH )
//  )
    xdma_pcie_ep
  (
    // SYS Inteface
    .sys_clk_n             ( sys_clk_n             ),
    .sys_clk_p             ( sys_clk_p             ),
    .sys_rst_n             ( sys_rst_n             ),
    // PCI-Express Serial Interface
    .pci_exp_txn           ( pci_exp_txn           ),
    .pci_exp_txp           ( pci_exp_txp           ),
    .pci_exp_rxn           ( pci_exp_rxn           ),
    .pci_exp_rxp           ( pci_exp_rxp           ),

    // SoftMC signals
    //.dfi_0_clk             ( AXI_ACLK_IN_0_buf             ), // 450MHz
    //.dfi_0_rst_n           ( AXI_ARESET_N_0           ),
    .dfi_0_clk             ( dfi_0_clk             ), // 450MHz
    .dfi_0_rst_n           ( dfi_0_rst_n           ),
    //.dfi_0_clk             ( xdma_axi_clk             ), // 450MHz
    //.dfi_0_rst_n           ( xdma_axi_resetn           ),

    .xdma_axi_clk          ( xdma_axi_clk          ),
    .xdma_axi_resetn       ( xdma_axi_resetn       ),

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
`else
  // XDMA adapter
  xdma_adapter
  #(
    .C_DATA_WIDTH     ( PCIE_DATA_WIDTH  ),  
    .C_M_AXI_ID_WIDTH ( 4                ),
    .DQ_WIDTH         ( DQ_WIDTH         )
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
`endif

// debug mark
// (* MARK_DEBUG="true" *)


endmodule
