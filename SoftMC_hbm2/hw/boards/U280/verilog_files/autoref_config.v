`timescale 1ns / 1ps
//Hasan

module autoref_config(
		input clk,
		input rstn,
		
		input set_interval,
		input[27:0] interval_in,
		input set_trfc,
		input[27:0] trfc_in,
		
		
		output reg aref_en,
		output reg[27:0] aref_interval,
		output reg[27:0] trfc
    );
	 
		 
	 always@(posedge clk) begin
		if(!rstn) begin
			trfc <= 28'd0;
		end
		else begin
      if(set_trfc) begin
		    trfc <= trfc_in;
		  end
      else begin
        trfc <= trfc;
      end
    end
	 end

 
	 always@(posedge clk) begin
		if(!rstn) begin
			aref_en <= 1'b0;
			aref_interval <= 28'd0;
		end
		else begin
			if(set_interval) begin
				aref_en <= |interval_in;
				aref_interval <= interval_in;
			end //set_interval
		  else begin
        aref_en <= aref_en;
        aref_interval <= aref_interval;
      end
    end
	 end

endmodule
