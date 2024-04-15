`timescale 1ps / 1ps

`include "softmc_define.vh"

module instr_decoder
#(
  parameter RA_WIDTH = 14,
	parameter CA_WIDTH = 4,
  parameter BA_WIDTH = 2,
	parameter BG_WIDTH = 2,
	parameter PC_WIDTH = 1,
//	parameter CH_WIDTH = 3,
	parameter SID_WIDTH = 1
)
(
	input en,
	input[31:0] instr_r,
	input[31:0] instr_c,

  output reg [11:0]   dfi_aw_row,
  output reg [15:0]   dfi_aw_col
);

  reg pre_all = 1'b0;
  reg ref_all = 1'b0;

  // Row Command
	always@(*)  begin
    // Activation
		if(en & (instr_r[31:28] == `ACT)) begin
			if(~instr_r[`SEC_OFFSET]) begin // 2nd phase
				dfi_aw_row = {instr_r[`BG_OFFSET], instr_r[`RA_OFFSET], instr_r[`PC_OFFSET], instr_r[`PAR_OFFSET], instr_r[`RA_OFFSET-1-:2],
											instr_r[`BG_OFFSET-1], instr_r[`BA_OFFSET-:2], instr_r[`SID_OFFSET], 2'b10};
			end
			else begin
				dfi_aw_row = {instr_r[`RA_OFFSET-9-:3], instr_r[`PAR_OFFSET], instr_r[`RA_OFFSET-12-:2], instr_r[`RA_OFFSET-3-:6]};
			end
		end
    // Precharge
		else if(en & (instr_r[31:28] == `PRE)) begin 
      pre_all    = instr_r[0]; 
      if(pre_all) begin
        dfi_aw_row = {1'b1, pre_all, instr_r[`PC_OFFSET], instr_r[`PAR_OFFSET], 5'b11111, 3'b011};
      end
      else begin
        dfi_aw_row = {instr_r[`BG_OFFSET], pre_all, instr_r[`PC_OFFSET], instr_r[`PAR_OFFSET], instr_r[`SID_OFFSET], 1'b0,
                      instr_r[`BG_OFFSET-1], instr_r[`BA_OFFSET-:2], 3'b011};
      end
    end
    // Refresh
    else if(en & (instr_r[31:28] == `REF)) begin
      ref_all    = instr_r[0];
      if(ref_all) begin
        dfi_aw_row = {1'b1, ref_all, instr_r[`PC_OFFSET], instr_r[`PAR_OFFSET], 5'b11111, 3'b100};
      end
      else begin
        dfi_aw_row = {instr_r[`BG_OFFSET], ref_all, instr_r[`PC_OFFSET], instr_r[`PAR_OFFSET], instr_r[`SID_OFFSET], 1'b0,
                      instr_r[`BG_OFFSET-1], instr_r[`BA_OFFSET-:2], 3'b100};
      end
    end  
    else begin
  	  dfi_aw_row = 12'hfff;
    end
	end

  // Column Command
	always@(*) begin
    // Read
		if(en & (instr_c[31:28] == `READ)) begin
			dfi_aw_col = {instr_c[`PC_OFFSET], instr_c[`CA_OFFSET-:4], instr_c[`PAR_OFFSET], instr_c[`CA_OFFSET-4], instr_c[`SID_OFFSET],
                    instr_c[`BG_OFFSET-:2], instr_c[`BA_OFFSET-:2], 4'b0101};
		end
    // Write
		else if(en & (instr_c[31:28] == `WRITE)) begin
		  dfi_aw_col = {instr_c[`PC_OFFSET], instr_c[`CA_OFFSET-:4], instr_c[`PAR_OFFSET], instr_c[`CA_OFFSET-4], instr_c[`SID_OFFSET],
                    instr_c[`BG_OFFSET-:2], instr_c[`BA_OFFSET-:2], 4'b0001};
		end
    // MRS
		else if(en & (instr_c[31:28] == `MRS)) begin
			dfi_aw_col = {instr_c[`MRS_OP_OFFSET-1-:5], instr_c[`PAR_OFFSET], instr_c[`MRS_OP_OFFSET-6-:2],
                    instr_c[`BG_OFFSET-:2], instr_c[`BA_OFFSET-:2], instr_c[`MRS_OP_OFFSET], 3'b000};
    end
    else begin
  	  dfi_aw_col = 16'hffff;
    end
  end

endmodule



