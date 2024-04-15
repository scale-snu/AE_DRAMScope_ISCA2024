`timescale 1ps / 1ps

module maint_ctrl_top #(parameter PC_WIDTH = 1, TCQ = 100, tCK = 4000, nCK_PER_CLK = 2, MAINT_PRESCALER_PERIOD = 100000) (
   input clk,
	 input rstn,
	 
	 
	 //Auto-refresh
	 input autoref_en,
	 input[27:0] autoref_interval,
	 input autoref_ack,
	 output autoref_req
    );
	 
	 /*** MAINTENANCE CONTROLLER ***/
	 wire maint_prescaler_tick;
	 maint_ctrl #(.TCQ(TCQ), .tCK(tCK), .nCK_PER_CLK(nCK_PER_CLK), .MAINT_PRESCALER_PERIOD(MAINT_PRESCALER_PERIOD)) i_maint_ctrl(
		.clk(clk),
		.rstn(rstn),
	
	
		.maint_prescaler_tick(maint_prescaler_tick)
	);
	 
	autoref_ctrl #(.TCQ(TCQ)) i_autoref_ctrl (
		.clk(clk),
		.rstn(rstn),
		
		.autoref_en(autoref_en),
		.autoref_interval(autoref_interval),
		.maint_prescaler_tick(maint_prescaler_tick),
		
		.autoref_ack(autoref_ack),
		.autoref_req(autoref_req)
	);

endmodule

module maint_ctrl #(parameter TCQ = 100, tCK = 4000, nCK_PER_CLK = 2, MAINT_PRESCALER_PERIOD = 100000) (
	input clk,
	input rstn,
	
	output maint_prescaler_tick
);

	function integer clogb2 (input integer size); // ceiling logb2
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
            size = size >> 1;
    end
	endfunction // clogb2
	
  
  localparam MAINT_PRESCALER_DIV = MAINT_PRESCALER_PERIOD/(tCK * nCK_PER_CLK);  // Round down.
	localparam MAINT_PRESCALER_WIDTH = clogb2(MAINT_PRESCALER_DIV + 1);
	localparam ONE = 1;
	
  wire[10:0] prescale_div;
  assign prescale_div = MAINT_PRESCALER_DIV;
  wire[10:0] prescale_width;
  assign prescale_width = MAINT_PRESCALER_WIDTH;


	// Maintenance and periodic read prescaler.  Nominally 200 nS.
	reg maint_prescaler_tick_r_lcl;
	reg [MAINT_PRESCALER_WIDTH-1:0] maint_prescaler_r;
	reg [MAINT_PRESCALER_WIDTH-1:0] maint_prescaler_ns;
	
	wire maint_prescaler_tick_ns = (maint_prescaler_r == ONE[MAINT_PRESCALER_WIDTH-1:0]);
	always @* begin
    if(!rstn) begin
			maint_prescaler_ns = MAINT_PRESCALER_DIV[MAINT_PRESCALER_WIDTH-1:0];
    end
    else begin
		  maint_prescaler_ns = maint_prescaler_r;
		  if (maint_prescaler_tick_ns)
			  maint_prescaler_ns = MAINT_PRESCALER_DIV[MAINT_PRESCALER_WIDTH-1:0];
		  else if (|maint_prescaler_r)
			  maint_prescaler_ns = maint_prescaler_r - ONE[MAINT_PRESCALER_WIDTH-1:0];
    end
	end
	
	always @(posedge clk) maint_prescaler_r <= maint_prescaler_ns;

	always @(posedge clk) maint_prescaler_tick_r_lcl <= maint_prescaler_tick_ns;
								  
	assign maint_prescaler_tick = maint_prescaler_tick_r_lcl;

endmodule

// auto-refresh controller
module autoref_ctrl #(parameter TCQ = 100) (
	input clk,
	input rstn,
	
	input autoref_en,
	input[27:0] autoref_interval,
	input autoref_ack,
	output autoref_req,
	
	input maint_prescaler_tick
);

	localparam ONE = 1;
	 
	reg [27:0] autoref_timer_r, autoref_timer;
	reg autoref_request_r;
	reg ref_en_r;
	 
	always @* begin
		autoref_timer = autoref_timer_r;
		
		if(autoref_ack || (~ref_en_r && autoref_en)) begin
			autoref_timer = autoref_interval;
		end
		else if (|autoref_timer_r && maint_prescaler_tick) begin
			autoref_timer = autoref_timer_r - ONE[0+:28];
		end
	end //always
	 
	wire autoref_timer_one = maint_prescaler_tick && (autoref_timer_r == ONE[0+:28]);
	 
	wire autoref_request = rstn && autoref_en && (
								(~autoref_ack && (autoref_request_r || autoref_timer_one)));
	 
	always @(posedge clk) begin // #TCQ
    if(!rstn) begin
      autoref_timer_r     <= 28'd0;
      autoref_request_r   <= 1'b0;
      ref_en_r            <= 1'b0;
    end
    else begin
      autoref_timer_r <= autoref_timer;
		  autoref_request_r <= autoref_request;
		  ref_en_r <= autoref_en;
    end
	end //always
	
	assign autoref_req = autoref_request_r;

endmodule
