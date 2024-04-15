`timescale 1ps / 1ps

`include "softmc_define.vh"

//NOTE: currently accepts only one instruction sequence, need to process it first to receive another
module softMC
#(
  RA_WIDTH  = 14, 
  CA_WIDTH  = 4, 
  BA_WIDTH  = 2, 
  BG_WIDTH  = 2, 
  PC_WIDTH  = 1, /*CH_WIDTH = 3,*/ 
  SID_WIDTH = 1, 
  DQ_WIDTH  = 256, 
  WL        = 7
) 
(
	input                 clk,
	input                 rstn,
	
	// App Command Interface
	input                 app_en,
	output                app_ack,
	input [31:0]          app_instr, 
	output                iq_full,

  // DFI Interface
  output [11:0]         dfi_0_aw_row_p0,
  output [15:0]         dfi_0_aw_col_p0,
  output [DQ_WIDTH-1:0] dfi_0_dw_wrdata_p0,
  output [11:0]         dfi_0_aw_row_p1,
  output [15:0]         dfi_0_aw_col_p1,
  output [DQ_WIDTH-1:0] dfi_0_dw_wrdata_p1,
  input  [DQ_WIDTH-1:0] dfi_0_dw_rddata_p0,
  input  [DQ_WIDTH-1:0] dfi_0_dw_rddata_p1,
  input  [3:0]          dfi_0_dw_rddata_valid,
  output                dfi_0_aw_ck_dis,

  // Data Read Back Interface
  input                 rdback_fifo_rd_en_pc0,
  input                 rdback_fifo_rd_en_pc1,
  output                rdback_fifo_empty_pc0,
  output                rdback_fifo_empty_pc1,
  output [DQ_WIDTH-1:0] rdback_data_pc0,
  output [DQ_WIDTH-1:0] rdback_data_pc1
);
`ifndef SIMULATION 
  localparam      CLK_FREQ = 125; // 125 MHz
`else
  localparam      CLK_FREQ = 450;
`endif
  localparam      tCK      = 1000000/CLK_FREQ/2; // ps
  localparam      nCK_PER_CLK = 2; // phy) 1:2 
  localparam      MAINT_PRESCALER_PERIOD = 100000;
  localparam      TCQ      = 100;

  // Instruction FIFO interface
  wire        instr0_fifo_en;
  wire        instr0_fifo_full;
  wire        instr0_fifo_empty;
  wire [31:0] instr0_fifo_din;
  wire [31:0] instr0_fifo_dout;
  wire        instr0_fifo_rd_en; 

  wire        instr1_fifo_en;
  wire        instr1_fifo_full;
  wire        instr1_fifo_empty;
  wire [31:0] instr1_fifo_din;
  wire [31:0] instr1_fifo_dout;
  wire        instr1_fifo_rd_en; 

  wire        instr2_fifo_en;
  wire        instr2_fifo_full;
  wire        instr2_fifo_empty;
  wire [31:0] instr2_fifo_din;
  wire [31:0] instr2_fifo_dout;
  wire        instr2_fifo_rd_en; 

  wire        instr3_fifo_en;
  wire        instr3_fifo_full;
  wire        instr3_fifo_empty;
  wire [31:0] instr3_fifo_din;
  wire [31:0] instr3_fifo_dout;
  wire        instr3_fifo_rd_en; 

  wire        process_iseq;

  // maint interface 
  wire        maint_en0;
  wire        maint_ack;
  wire [31:0] maint_instr;

  // Read Back FIFO interface
  wire [DQ_WIDTH-1:0] rdback_fifo_din_pc0;
  wire                rdback_fifo_wr_en_pc0;
  wire [DQ_WIDTH-1:0] rdback_fifo_dout_pc0;
  wire                rdback_fifo_full_pc0;
//  wire                rdback_fifo_almost_full_pc0;
  wire [DQ_WIDTH-1:0] rdback_fifo_din_pc1;
  wire                rdback_fifo_wr_en_pc1;
  wire [DQ_WIDTH-1:0] rdback_fifo_dout_pc1;
  wire                rdback_fifo_full_pc1;
//  wire                rdback_fifo_almost_full_pc1;
	 
  //MAINTENANCE module
  wire pr_rd_req, zq_req, autoref_req;
  wire pr_rd_ack, zq_ack, autoref_ack;
  
  //Auto-refresh signals
  wire aref_en;
  wire[27:0] aref_interval;
  wire[27:0] aref_trfc;
  wire aref_set_interval, aref_set_trfc;
  wire[27:0] aref_interval_in;
  wire[27:0] aref_trfc_in;
  /*
  maint_ctrl_top 
  #
  (
    .PC_WIDTH(PC_WIDTH), 
    .TCQ (TCQ),
    .tCK(tCK), 
    .nCK_PER_CLK(nCK_PER_CLK), 
    .MAINT_PRESCALER_PERIOD(MAINT_PRESCALER_PERIOD)
  ) 
    i_maint_ctrl
  (
    .clk(clk),
    .rstn(rstn),
    
    //Auto-refresh
    .autoref_en(aref_en),
    .autoref_interval(aref_interval),
    .autoref_ack(autoref_ack),
    .autoref_req(autoref_req)
  );
  
  maint_handler 
    i_maint_handler
  (
    .clk              (clk              ),
    .rstn             (rstn             ),
    
    .autoref_req      (autoref_req      ),
    
    .maint_instr_en   (maint_en         ),
    .maint_ack        (maint_ack        ),
    .maint_instr      (maint_instr      ),
    
    .autoref_ack      (autoref_ack      ),
    .trfc             (aref_trfc        )
  );
  
  autoref_config 
    i_aref_config
  (
    .clk              (clk              ),
    .rstn             (rstn             ),
  
    .set_interval     (aref_set_interval),
    .interval_in      (aref_interval_in ),
    .set_trfc         (aref_set_trfc    ),
    .trfc_in          (aref_trfc_in     ),
  
    .aref_en          (aref_en          ),
    .aref_interval    (aref_interval    ),
    .trfc             (aref_trfc        )
  );
  */
  instr_receiver
    u_instr_recv
  (
    .clk              (clk             ),
    .rstn             (rstn            ),
    .dispatcher_ready (!dispatcher_busy),
    .app_en           (app_en          ),
    .app_ack          (app_ack         ),
    .app_instr        (app_instr       ), 
    .maint_en         (maint_en        ),
    .maint_ack        (maint_ack       ),
    .maint_instr      (maint_instr     ),
    .instr0_fifo_en   (instr0_fifo_en  ),
    .instr0_fifo_data (instr0_fifo_din ),
    .instr1_fifo_en   (instr1_fifo_en  ),
    .instr1_fifo_data (instr1_fifo_din ),
    .instr2_fifo_en   (instr2_fifo_en  ),
    .instr2_fifo_data (instr2_fifo_din ),
    .instr3_fifo_en   (instr3_fifo_en  ),
    .instr3_fifo_data (instr3_fifo_din ),
    .process_iseq     (process_iseq    )
  );

  instr_fifo
    u_instr0_fifo
  (
    .clk         (clk               ), // input clk
    .srst        (!rstn             ), // input rst
    .din         (instr0_fifo_din   ), // input [31 : 0] din
    .wr_en       (instr0_fifo_en    ), // input wr_en
    .rd_en       (instr0_fifo_rd_en ), // input rd_en
    .dout        (instr0_fifo_dout  ), // output [31 : 0] dout
    .full        (instr0_fifo_full  ), // output full
    .empty       (instr0_fifo_empty ), // output empty
    .wr_rst_busy (), // output
    .rd_rst_busy ()  // output
  );

  instr_fifo
    u_instr1_fifo
  (
    .clk         (clk               ), // input clk
    .srst        (!rstn             ), // input rst
    .din         (instr1_fifo_din   ), // input [31 : 0] din
    .wr_en       (instr1_fifo_en    ), // input wr_en
    .rd_en       (instr1_fifo_rd_en ), // input rd_en
    .dout        (instr1_fifo_dout  ), // output [31 : 0] dout
    .full        (instr1_fifo_full  ), // output full
    .empty       (instr1_fifo_empty ), // output empty
    .wr_rst_busy (), // output
    .rd_rst_busy ()  // output
  );

  instr_fifo
    u_instr2_fifo
  (
    .clk         (clk               ), // input clk
    .srst        (!rstn             ), // input rst
    .din         (instr2_fifo_din   ), // input [31 : 0] din
    .wr_en       (instr2_fifo_en    ), // input wr_en
    .rd_en       (instr2_fifo_rd_en ), // input rd_en
    .dout        (instr2_fifo_dout  ), // output [31 : 0] dout
    .full        (instr2_fifo_full  ), // output full
    .empty       (instr2_fifo_empty ), // output empty
    .wr_rst_busy (), // output
    .rd_rst_busy ()  // output
  );

  instr_fifo
    u_instr3_fifo
  (
    .clk         (clk               ), // input clk
    .srst        (!rstn             ), // input rst
    .din         (instr3_fifo_din   ), // input [31 : 0] din
    .wr_en       (instr3_fifo_en    ), // input wr_en
    .rd_en       (instr3_fifo_rd_en ), // input rd_en
    .dout        (instr3_fifo_dout  ), // output [31 : 0] dout
    .full        (instr3_fifo_full  ), // output full
    .empty       (instr3_fifo_empty ), // output empty
    .wr_rst_busy (), // output
    .rd_rst_busy ()  // output
  );

  assign iq_full = instr0_fifo_full | instr1_fifo_full | instr2_fifo_full | instr3_fifo_full;

  // for debug
  /*
  wire [255:0] cmd0, cmd1;
  wire [3:0] valid_cmd;
*/

  iseq_dispatcher
  #(
    .RA_WIDTH           (RA_WIDTH           ),
    .CA_WIDTH           (CA_WIDTH           ),
    .BA_WIDTH           (BA_WIDTH           ),
    .BG_WIDTH           (BG_WIDTH           ),
    .PC_WIDTH           (PC_WIDTH           ),
    .SID_WIDTH          (SID_WIDTH          ),
    .DQ_WIDTH           (DQ_WIDTH           ),
    .WL                 (WL                 )
  )
    u_iseq_dispatcher
  (
    // for debug
    /*
    .cmd0(cmd0),
    .cmd1(cmd1),
    .valid_cmd(valid_cmd),
*/
    .clk                 (clk                ),
    .rstn                (rstn               ),
    .process_iseq        (process_iseq       ),
    .dispatcher_busy     (dispatcher_busy    ),
    .rdback_fifo_full    (dfi_0_aw_ck_dis    ),
    // FIFO Interface
    
    .instr0_fifo_rd      (instr0_fifo_rd_en  ),
    .instr0_fifo_empty   (instr0_fifo_empty  ),
    .instr0_fifo_data    (instr0_fifo_dout   ),
    .instr1_fifo_rd      (instr1_fifo_rd_en  ),
    .instr1_fifo_empty   (instr1_fifo_empty  ),
    .instr1_fifo_data    (instr1_fifo_dout   ),
    .instr2_fifo_rd      (instr2_fifo_rd_en  ),
    .instr2_fifo_empty   (instr2_fifo_empty  ),
    .instr2_fifo_data    (instr2_fifo_dout   ),
    .instr3_fifo_rd      (instr3_fifo_rd_en  ),
    .instr3_fifo_empty   (instr3_fifo_empty  ),
    .instr3_fifo_data    (instr3_fifo_dout   ),

    // auto-refresh
    
    .aref_set_interval   (aref_set_interval  ),
    .aref_interval       (aref_interval_in   ),
    .aref_set_trfc       (aref_set_trfc      ),
    .aref_trfc           (aref_trfc_in       ),
    
    // DFI Interface
    .dfi_0_aw_row_p0     (dfi_0_aw_row_p0    ), // 12
    .dfi_0_aw_col_p0     (dfi_0_aw_col_p0    ), // 16
    .dfi_0_dw_wrdata_p0  (dfi_0_dw_wrdata_p0 ), // 256
    .dfi_0_aw_row_p1     (dfi_0_aw_row_p1    ), // 12
    .dfi_0_aw_col_p1     (dfi_0_aw_col_p1    ), // 16
    .dfi_0_dw_wrdata_p1  (dfi_0_dw_wrdata_p1 )  // 256 => 64bit: [95:32] / 128bit : [127:0] 
  );


  rdback_fifo
    u_rdback_fifo_pc0
  (
    .clk         (clk                        ), // input clk
    .srst        (!rstn                      ), // input srst
    .din         (rdback_fifo_din_pc0        ), // input [255 : 0] din
    .wr_en       (rdback_fifo_wr_en_pc0      ), // input wr_en
    .rd_en       (rdback_fifo_rd_en_pc0      ), // input rd_en
    .dout        (rdback_fifo_dout_pc0       ), // output [255 : 0] dout
    .full        (rdback_fifo_full_pc0       ), // output full
//    .almost_full (rdback_fifo_almost_full_pc0), // output almost_full
    .empty       (rdback_fifo_empty_pc0      ), // output empty
    .wr_rst_busy (), // output
    .rd_rst_busy ()  // output
  );

  rdback_fifo
    u_rdback_fifo_pc1
  (
    .clk         (clk                        ), // input clk
    .srst        (!rstn                      ), // input srst
    .din         (rdback_fifo_din_pc1        ), // input [255 : 0] din
    .wr_en       (rdback_fifo_wr_en_pc1      ), // input wr_en
    .rd_en       (rdback_fifo_rd_en_pc1      ), // input rd_en
    .dout        (rdback_fifo_dout_pc1       ), // output [255 : 0] dout
    .full        (rdback_fifo_full_pc1       ), // output full
//    .almost_full (rdback_fifo_almost_full_pc1), // output almost_full
    .empty       (rdback_fifo_empty_pc1      ), // output empty
    .wr_rst_busy (), // output
    .rd_rst_busy ()  // output
  );


  assign rdback_data_pc0 = rdback_fifo_dout_pc0;
  assign rdback_data_pc1 = rdback_fifo_dout_pc1;

  read_capturer
  #(
    .DQ_WIDTH (DQ_WIDTH)
  )
    u_read_capturer
  (
    .clk                         (clk                        ),
    .rstn                        (rstn                       ),
    .dfi_0_dw_rddata_p0          (dfi_0_dw_rddata_p0         ),
    .dfi_0_dw_rddata_p1          (dfi_0_dw_rddata_p1         ),
    .dfi_0_dw_rddata_valid       (dfi_0_dw_rddata_valid      ),
    .dfi_0_aw_ck_dis             (dfi_0_aw_ck_dis            ),
//    .rdback_fifo_almost_full_pc0 (rdback_fifo_almost_full_pc0),
//    .rdback_fifo_almost_full_pc1 (rdback_fifo_almost_full_pc1),
    .rdback_fifo_full_pc0        (rdback_fifo_full_pc0       ),
    .rdback_fifo_full_pc1        (rdback_fifo_full_pc1       ),
    .rdback_fifo_wr_en_pc0       (rdback_fifo_wr_en_pc0      ),
    .rdback_fifo_wr_en_pc1       (rdback_fifo_wr_en_pc1      ),
    .rdback_fifo_din_pc0         (rdback_fifo_din_pc0        ),
    .rdback_fifo_din_pc1         (rdback_fifo_din_pc1        )
  );

endmodule

