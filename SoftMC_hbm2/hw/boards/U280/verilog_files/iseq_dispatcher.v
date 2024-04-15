`timescale 1ns / 1ps

module iseq_dispatcher #
(
  parameter RA_WIDTH  = 13,
  parameter CA_WIDTH  = 4,
  parameter BA_WIDTH  = 2,
  parameter BG_WIDTH  = 2,
  parameter PC_WIDTH  = 1,
//  parameter CH_WIDTH  = 3,
  parameter SID_WIDTH = 1,
  parameter CKE_WIDTH = 1,
  parameter DQ_WIDTH  = 256,
	parameter WL        = 7,
`ifndef SIMULATION
  parameter HAMMER_BASE = 16'd1000,
`else
  parameter HAMMER_BASE = 16'd10,
`endif
  parameter WAIT_END    = 32'h4000_0020, // tRC = 48ns
  parameter WAIT_RAS    = 32'h4000_0015, // 1xtRAS, 14 tCK x 2.5 = 35 ns 
  //parameter WAIT_RAS    = 32'h4000_002A, // 3xtRAS, 42 tCK x 2.5 = 105 ns 
  //parameter WAIT_RAS    = 32'h4000_0046, // 5xtRAS, 70 tCK x 2.5 = 175 ns 
  //parameter WAIT_RAS    = 32'h4000_8FC, // 3.9 us
  //parameter WAIT_RAS    = 32'h4000_1248, // 7.8 us
  parameter WAIT_RP     = 32'h4000_000A // 
)
(
  input          clk,
	input          rstn,

	input          process_iseq,
	output         dispatcher_busy,
  input          rdback_fifo_full,	

	input  [31:0]  instr0_fifo_data,
	input  [31:0]  instr1_fifo_data,
	input  [31:0]  instr2_fifo_data,	
	input  [31:0]  instr3_fifo_data,
	input          instr0_fifo_empty,
	input          instr1_fifo_empty,
	input          instr2_fifo_empty,
	input          instr3_fifo_empty,
	output         instr0_fifo_rd,
	output         instr1_fifo_rd,
  output         instr2_fifo_rd,
	output         instr3_fifo_rd,

  // auto-refresh
  output         aref_set_interval,
  output [27:0]  aref_interval,
  output         aref_set_trfc,
  output [27:0]  aref_trfc,

	//DFI Interface
	// DFI Control/Address
  output [11:0]  dfi_0_aw_row_p0,
  output [15:0]  dfi_0_aw_col_p0,
  output [255:0] dfi_0_dw_wrdata_p0,

  output [11:0]  dfi_0_aw_row_p1,
  output [15:0]  dfi_0_aw_col_p1,
  output [255:0] dfi_0_dw_wrdata_p1
);

	wire instr0_disp_en, instr1_disp_en, instr2_disp_en, instr3_disp_en;
	wire instr0_disp_ack, instr1_disp_ack, instr2_disp_ack, instr3_disp_ack;
	reg dispatcher_busy_r, dispatcher_busy_ns;
	
	//check conditions and start transaction
	always@* begin
    dispatcher_busy_ns = rstn & process_iseq | (dispatcher_busy_r & 
                        (~(instr0_fifo_empty & instr1_fifo_empty & instr2_fifo_empty & instr3_fifo_empty) 
									      | instr0_disp_en | instr1_disp_en | instr2_disp_en | instr3_disp_en));
  end

	always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      dispatcher_busy_r  <= 1'b0;
    end
    else begin
      dispatcher_busy_r <= dispatcher_busy_ns;
    end
  end
			
	
	wire [31:0] instr0, instr1, instr2, instr3;
	
	wire instr0_ready, instr1_ready, instr2_ready, instr3_ready;


///////////////////////////////////////////////////////////
// Rowhammer logics
///////////////////////////////////////////////////////////
  reg [19:0] hammer_count, hammer_count_ns;
  reg [31:0] instr0_fifo_data_in, instr1_fifo_data_in, instr2_fifo_data_in, instr3_fifo_data_in;
  reg [31:0] instr0_fifo_r, instr1_fifo_r, instr2_fifo_r, instr3_fifo_r;
  reg        hammer_last;
  reg [31:0] hammer_instr;
  reg [2:0]  hammer_ptr, hammer_ptr_r;

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      hammer_last <= 1'b0;
    end
    else begin
      if(hammer_count == 20'd20) begin
        hammer_last <= 1'b1;
      end
      else begin
        if(hammer_last) begin
          if(hammer_count == 20'd0) begin //& hammer_ptr == 3'b100) begin
            case(hammer_ptr_r)
              3'b000: begin
                if(instr0_ready & dispatcher_busy_ns) begin
                  hammer_last <= 1'b0;
                end
                else if(instr0_fifo_data_in == WAIT_END) begin
                  hammer_last <= 1'b0;
                end
                else begin
                  hammer_last <= hammer_last;
                end
              end
              3'b001: begin
                if(instr1_ready & dispatcher_busy_ns) begin
                  hammer_last <= 1'b0;
                end
                else if(instr1_fifo_data_in == WAIT_END) begin
                  hammer_last <= 1'b0;
                end
                else begin
                  hammer_last <= hammer_last;
                end
              end
              3'b010: begin
                if(instr2_ready & dispatcher_busy_ns) begin
                  hammer_last <= 1'b0;
                end
                else if(instr2_fifo_data_in == WAIT_END) begin
                  hammer_last <= 1'b0;
                end
                else begin
                  hammer_last <= hammer_last;
                end
              end
              3'b011: begin
                if(instr3_ready & dispatcher_busy_ns) begin
                  hammer_last <= 1'b0;
                end
                else if(instr3_fifo_data_in == WAIT_END) begin
                  hammer_last <= 1'b0;
                end
                else begin
                  hammer_last <= hammer_last;
                end
              end
              default:;
            endcase
          end
        end
        else begin
          hammer_last <= hammer_last;
        end
      end
    end
  end
          

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      instr0_fifo_r <= 32'd0;
      instr1_fifo_r <= 32'd0;
      instr2_fifo_r <= 32'd0;
      instr3_fifo_r <= 32'd0;
    end
    else begin
      if(hammer_ptr != 3'b100) begin
        case(hammer_ptr)
          3'b000: begin
            instr0_fifo_r <= WAIT_END;
            instr1_fifo_r <= instr1_fifo_data;
            instr2_fifo_r <= instr2_fifo_data;
            instr3_fifo_r <= instr3_fifo_data;
          end
          3'b001: begin
            //instr0_fifo_r <= instr0_fifo_r;
            instr0_fifo_r <= WAIT_RP;
            instr1_fifo_r <= WAIT_END;
            instr2_fifo_r <= instr2_fifo_data;
            instr3_fifo_r <= instr3_fifo_data;
          end
          3'b010: begin
            instr0_fifo_r <= {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
            instr1_fifo_r <= WAIT_RP;
            instr2_fifo_r <= WAIT_END;
            instr3_fifo_r <= instr3_fifo_data;
          end
          3'b011: begin
            instr0_fifo_r <= WAIT_RAS;
            instr1_fifo_r <= {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
            instr2_fifo_r <= WAIT_RP;
            instr3_fifo_r <= WAIT_END;
          end
          default: begin
            instr0_fifo_r <= instr0_fifo_r;
            instr1_fifo_r <= instr1_fifo_r;
            instr2_fifo_r <= instr2_fifo_r;
            instr3_fifo_r <= instr3_fifo_r;
          end
        endcase
      end
      else begin
        instr0_fifo_r <= instr0_fifo_r;
        instr1_fifo_r <= instr1_fifo_r;
        instr2_fifo_r <= instr2_fifo_r;
        instr3_fifo_r <= instr3_fifo_r;
      end
    end
  end


  // change instrs
  always@* begin
    // start
    if(hammer_count == 20'd0 & hammer_count_ns == 20'd0) begin
      if(instr0_fifo_data[31:28] == `ROWHAMMER & instr0_ready) begin
        instr0_fifo_data_in = {`ACT, 5'h1, instr0_fifo_data[22:0]}; // act
        instr1_fifo_data_in = WAIT_RAS;                      // wait
        instr2_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
        instr3_fifo_data_in = WAIT_RP;                      // wait
      end
      else if(instr1_fifo_data[31:28] == `ROWHAMMER & instr1_ready) begin
        instr0_fifo_data_in = instr0_fifo_data; 
        instr1_fifo_data_in = {`ACT, 5'h1, instr1_fifo_data[22:0]}; // act
        instr2_fifo_data_in = WAIT_RAS;                      // wait
        instr3_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
      end
      else if(instr2_fifo_data[31:28] == `ROWHAMMER & instr2_ready) begin
        instr0_fifo_data_in = instr0_fifo_data; 
        instr1_fifo_data_in = instr1_fifo_data; 
        instr2_fifo_data_in = {`ACT, 5'h1, instr2_fifo_data[22:0]}; // act
        instr3_fifo_data_in = WAIT_RAS;                      // wait
      end
      else if(instr3_fifo_data[31:28] == `ROWHAMMER & instr3_ready) begin
        instr0_fifo_data_in = instr0_fifo_data;
        instr1_fifo_data_in = instr1_fifo_data;
        instr2_fifo_data_in = instr2_fifo_data;
        instr3_fifo_data_in = {`ACT, 5'h1, instr3_fifo_data[22:0]}; // act
      end
      else begin
        instr0_fifo_data_in = hammer_last ? instr0_fifo_r : instr0_fifo_data;
        instr1_fifo_data_in = hammer_last ? instr1_fifo_r : instr1_fifo_data;
        instr2_fifo_data_in = hammer_last ? instr2_fifo_r : instr2_fifo_data;
        instr3_fifo_data_in = hammer_last ? instr3_fifo_r : instr3_fifo_data;
      end
    end
    else if(hammer_count == 20'd0 && hammer_count_ns == 20'd1) begin
      case(hammer_ptr)
        3'b000: begin
          instr0_fifo_data_in = WAIT_END;   
          instr1_fifo_data_in = instr1_fifo_r;  //_data;  
          instr2_fifo_data_in = instr2_fifo_r;  
          instr3_fifo_data_in = instr3_fifo_r;  
        end
        3'b001: begin
          instr0_fifo_data_in = WAIT_RP;  // wait 
          instr1_fifo_data_in = WAIT_END; 
          instr2_fifo_data_in = instr2_fifo_r;                 
          instr3_fifo_data_in = instr3_fifo_r; 
        end
        3'b010: begin
          instr0_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
          instr1_fifo_data_in = WAIT_RP;
          instr2_fifo_data_in = WAIT_END; 
          instr3_fifo_data_in = instr3_fifo_r; 
        end
        3'b011: begin
          instr0_fifo_data_in = WAIT_RAS;                  // wait
          instr1_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
          instr2_fifo_data_in = WAIT_RP;
          instr3_fifo_data_in = WAIT_END; 
        end
        default: begin
          instr0_fifo_data_in = instr0_fifo_r;
          instr1_fifo_data_in = instr1_fifo_r;
          instr2_fifo_data_in = instr2_fifo_r;
          instr3_fifo_data_in = instr3_fifo_r;
        end
      endcase
    end
    else begin
      case(hammer_ptr)
        3'b000: begin
          instr0_fifo_data_in = {`ACT, 5'h1, hammer_instr[22:0]}; // act
          instr1_fifo_data_in = WAIT_RAS;                  // wait
          instr2_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
          instr3_fifo_data_in = WAIT_RP;  
        end
        3'b001: begin
          instr0_fifo_data_in = WAIT_RP;  
          instr1_fifo_data_in = {`ACT, 5'h1, hammer_instr[22:0]}; // act
          instr2_fifo_data_in = WAIT_RAS;                  // wait
          instr3_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
        end
        3'b010: begin
          instr0_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
          instr1_fifo_data_in = WAIT_RP;
          instr2_fifo_data_in = {`ACT, 5'h1, hammer_instr[22:0]}; // act
          instr3_fifo_data_in = WAIT_RAS; 
        end
        3'b011: begin
          instr0_fifo_data_in = WAIT_RAS;                  // wait
          instr1_fifo_data_in = {`PRE, 5'h1, hammer_instr[22:RA_WIDTH], {RA_WIDTH{1'b0}}};
          instr2_fifo_data_in = WAIT_RP;
          instr3_fifo_data_in = {`ACT, 5'h1, hammer_instr[22:0]}; // act
        end
        default: begin
          instr0_fifo_data_in = instr0_fifo_data;
          instr1_fifo_data_in = instr1_fifo_data;
          instr2_fifo_data_in = instr2_fifo_data;
          instr3_fifo_data_in = instr3_fifo_data;
        end
      endcase
    end
  end

  // manage hc count
  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      hammer_count <= 20'd0;
    end
    else begin
      if(hammer_count == 20'd0 & hammer_count_ns == 20'd0) begin
        if(instr0_fifo_data[31:28] == `ROWHAMMER & instr0_ready) begin
          hammer_count <= {instr0_fifo_data[27:23]} * HAMMER_BASE - 20'd1;
        end
        else if(instr1_fifo_data[31:28] == `ROWHAMMER & instr1_ready) begin
          hammer_count <= instr1_fifo_data[27:23] * HAMMER_BASE;
        end
        else if(instr2_fifo_data[31:28] == `ROWHAMMER & instr2_ready) begin
          hammer_count <= instr2_fifo_data[27:23] * HAMMER_BASE;
        end
        else if(instr3_fifo_data[31:28] == `ROWHAMMER & instr3_ready) begin
          hammer_count <= instr3_fifo_data[27:23] * HAMMER_BASE;
        end
        else begin
          hammer_count <= hammer_count;
        end
      end
      else begin
        case(hammer_ptr)
          3'b000: begin
            if(instr0_ready & dispatcher_busy_ns) begin
              hammer_count <= hammer_count -1;
            end
            else begin
              hammer_count <= hammer_count;
            end
          end
          3'b001: begin
            if(instr1_ready & dispatcher_busy_ns) begin
              hammer_count <= hammer_count -1;
            end
            else begin
              hammer_count <= hammer_count;
            end
          end
          3'b010: begin
            if(instr2_ready & dispatcher_busy_ns) begin
              hammer_count <= hammer_count -1;
            end
            else begin
              hammer_count <= hammer_count;
            end
          end
          3'b011: begin
            if(instr3_ready & dispatcher_busy_ns) begin
              hammer_count <= hammer_count -1;
            end
            else begin
              hammer_count <= hammer_count;
            end
          end
          default: begin
            hammer_count <= 20'd0;
          end
        endcase
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      hammer_count_ns <= 20'd0;
    end
    else begin
      hammer_count_ns <= hammer_count;
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      hammer_instr <= 32'd0;
    end
    else begin
      if(hammer_count == 20'd0) begin
        if(instr0_fifo_data[31:28] == `ROWHAMMER & instr0_ready) begin
          hammer_instr <= instr0_fifo_data;
        end
        else if(instr1_fifo_data[31:28] == `ROWHAMMER & instr1_ready) begin
          hammer_instr <= instr1_fifo_data;
        end
        else if(instr2_fifo_data[31:28] == `ROWHAMMER & instr2_ready) begin
          hammer_instr <= instr2_fifo_data;
        end
        else if(instr3_fifo_data[31:28] == `ROWHAMMER & instr3_ready) begin
          hammer_instr <= instr3_fifo_data;
        end
        else begin
          hammer_instr <= 32'd0;
        end
      end
      else begin
        hammer_instr <= hammer_instr;
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      hammer_ptr_r <= 3'b000;
    end
    else begin
      if(hammer_ptr != 3'b100) begin
        hammer_ptr_r <= hammer_ptr;
      end
      else begin
        hammer_ptr_r <= hammer_ptr_r;
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      hammer_ptr <= 3'b100;
    end
    else begin
      if(hammer_count == 20'd0) begin
        if(instr0_fifo_data[31:28] == `ROWHAMMER & instr0_ready) begin
          hammer_ptr <= 3'b000;
        end
        else if(instr1_fifo_data[31:28] == `ROWHAMMER & instr1_ready) begin
          hammer_ptr <= 3'b001;
        end
        else if(instr2_fifo_data[31:28] == `ROWHAMMER & instr2_ready) begin
          hammer_ptr <= 3'b010;
        end
        else if(instr3_fifo_data[31:28] == `ROWHAMMER & instr3_ready) begin
          hammer_ptr <= 3'b011;
        end
        else begin
          hammer_ptr <= 3'b100;
        end
      end
      else begin
        hammer_ptr <= hammer_ptr;
      end
    end
  end

  assign instr0_fifo_rd = ~(hammer_last & (hammer_ptr_r == 3'b000)) & (hammer_count == 20'd0 & ((hammer_ptr == 3'b011) | (hammer_ptr == 3'b100))) & instr0_ready & dispatcher_busy_ns;
	assign instr1_fifo_rd = ~(hammer_last & (hammer_ptr_r == 3'b001)) & (hammer_count == 20'd0 & ((hammer_ptr <= 3'b001) | (hammer_ptr == 3'b100))) & instr1_ready & dispatcher_busy_ns;
  assign instr2_fifo_rd = ~(hammer_last & (hammer_ptr_r == 3'b010)) & (hammer_count == 20'd0 & ((hammer_ptr <= 3'b010) | (hammer_ptr == 3'b100))) & instr2_ready & dispatcher_busy_ns;
	assign instr3_fifo_rd = ~(hammer_last & (hammer_ptr_r == 3'b011)) & (hammer_count == 20'd0 & ((hammer_ptr <= 3'b011) | (hammer_ptr == 3'b100))) & instr3_ready & dispatcher_busy_ns;
  
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

	//Command Dispatcher Instantiation
	pipe_reg
  #(
    .WIDTH(32)
  )
  i_instr0_reg
  (
    .clk       (clk                                   ),
    .rstn      (rstn                                  ),
    .ready_in  (instr0_disp_ack                       ),
    .valid_in  (dispatcher_busy_r & !instr0_fifo_empty),
    .data_in   (instr0_fifo_data_in                   ),
    .valid_out (instr0_disp_en                        ),
    .data_out  (instr0                                ),
    .ready_out (instr0_ready                          )
  );
	 
  pipe_reg
  #(
    .WIDTH(32)
  )
  i_instr1_reg
  (
    .clk       (clk                                   ),
    .rstn      (rstn                                  ),
    .ready_in  (instr1_disp_ack                       ),
    .valid_in  (dispatcher_busy_r & !instr1_fifo_empty),
    .data_in   (instr1_fifo_data_in                   ),
    .valid_out (instr1_disp_en                        ),
    .data_out  (instr1                                ),
    .ready_out (instr1_ready                          )
  );

  pipe_reg
  #(
    .WIDTH(32)
  )
  i_instr2_reg
  (
    .clk       (clk                                   ),
    .rstn      (rstn                                  ),
    .ready_in  (instr2_disp_ack                       ),
    .valid_in  (dispatcher_busy_r & !instr2_fifo_empty),
    .data_in   (instr2_fifo_data_in                   ),
    .valid_out (instr2_disp_en                        ),
    .data_out  (instr2                                ),
    .ready_out (instr2_ready                          )
  );
  
  pipe_reg
  #(
    .WIDTH(32)
  )
  i_instr3_reg
  (
    .clk       (clk                                   ),
    .rstn      (rstn                                  ),
    .ready_in  (instr3_disp_ack                       ),
    .valid_in  (dispatcher_busy_r & !instr3_fifo_empty),
    .data_in   (instr3_fifo_data_in                   ),
    .valid_out (instr3_disp_en                        ),
    .data_out  (instr3                                ),
    .ready_out (instr3_ready                          )
  );
	

  instr_dispatcher
  #(
    .RA_WIDTH           (RA_WIDTH          ),
    .CA_WIDTH           (CA_WIDTH          ),
    .BA_WIDTH           (BA_WIDTH          ),
    .BG_WIDTH           (BG_WIDTH          ),
    .PC_WIDTH           (PC_WIDTH          ),
    .SID_WIDTH          (SID_WIDTH         ),
    .DQ_WIDTH           (DQ_WIDTH          ),
    .WL                 (WL                )
  )
  i_instr_dispatcher
  (
    .clk                (clk               ),
    .rstn               (rstn              ),
    .rdback_fifo_full   (rdback_fifo_full  ),
    .en_in0             (instr0_disp_en    ),
    .ack_out0           (instr0_disp_ack   ),
    .instr_in0          (instr0            ),
    .en_in1             (instr1_disp_en    ), 
    .ack_out1           (instr1_disp_ack   ),
    .instr_in1          (instr1            ),
    .en_in2             (instr2_disp_en    ), 
    .ack_out2           (instr2_disp_ack   ),
    .instr_in2          (instr2            ),
    .en_in3             (instr3_disp_en    ), 
    .ack_out3           (instr3_disp_ack   ),
    .instr_in3          (instr3            ),
    
    // auto-refresh
    .aref_set_interval  (aref_set_interval ),
    .aref_interval      (aref_interval     ),
    .aref_set_trfc      (aref_set_trfc     ),
    .aref_trfc          (aref_trfc         ),

    // DFI Interface
    .dfi_0_aw_row_p0    (dfi_0_aw_row_p0   ),
    .dfi_0_aw_col_p0    (dfi_0_aw_col_p0   ),
    .dfi_0_dw_wrdata_p0 (dfi_0_dw_wrdata_p0),
    .dfi_0_aw_row_p1    (dfi_0_aw_row_p1   ),
    .dfi_0_aw_col_p1    (dfi_0_aw_col_p1   ),
    .dfi_0_dw_wrdata_p1 (dfi_0_dw_wrdata_p1)
    
  );

	assign dispatcher_busy = dispatcher_busy_r;

endmodule
