`timescale 1ps / 1ps

`include "softmc_define.vh"

module maint_handler #(parameter CS_WIDTH = 1)(
  input clk,
  input rstn,

  input autoref_req,

  output maint_instr_en,
  input maint_ack,
  output reg[31:0] maint_instr,

  output reg autoref_ack,

  input[27:0] trfc
);

localparam HIGH = 1'b1;
localparam LOW  = 1'b0;

//maintenance logic
reg  autoref_process_ns, autoref_process_r = 1'b0;
wire maint_process;

localparam AREF_PRE       = 4'b0000;
localparam AREF_WAIT_PRE  = 4'b0001;
localparam AREF_REF       = 4'b0010;
localparam AREF_WAIT_REF  = 4'b0011;
localparam MAINT_DUMMY    = 4'b0100;
localparam MAINT_FIN      = 4'b0101;

reg [3:0] maint_state, maint_state_ns;

reg       pc;
reg       dummy_start;
reg [4:0] dummy_count, dummy_count_ns;

always@* begin
  autoref_process_ns = autoref_process_r;

  autoref_ack = 1'b0;

  maint_state_ns = maint_state;
  dummy_count_ns = dummy_count;
  maint_instr = {`END_ISEQ, 28'd0};
  pc = 1'b0;

  //enter maintenance
  if(~maint_process) begin
    if(autoref_req) begin
      autoref_process_ns = 1'b1;
      maint_state_ns = AREF_PRE;
      //pc = 1'b0;
    end
  end //~dispatcher_busy_r

  //process maintenance
  else if(maint_process) begin
    if(autoref_process_r) begin
      case(maint_state)
        AREF_PRE: begin
          //Precharge all banks
          maint_instr[31:28] = `PRE;
          maint_instr[`PC_OFFSET] = pc;
          maint_instr[23] = 1'b1; ///////////////// CKE
          maint_instr[0]     = 1'b1;          

          if(maint_ack)
            maint_state_ns = AREF_WAIT_PRE;
        end //AREF_PRE

        AREF_WAIT_PRE: begin
          maint_instr[31:28] = `WAIT;
          maint_instr[27:0] = `DEF_TRP + 1;

          if(maint_ack)
            maint_state_ns = AREF_REF;
        end //AREF_WAIT_PRE

        AREF_REF: begin
          //Refresh Instruction //TODO: assign CS appropriately when implementing multi-rank support
          maint_instr[31:28] = `REF;
          maint_instr[`PC_OFFSET] = pc;
          maint_instr[23] = 1'b1; ///////////////// CKE
          maint_instr[0]  = 1'b1;

          if(maint_ack)
            maint_state_ns = AREF_WAIT_REF;
        end //AREF_REF

        AREF_WAIT_REF: begin
          maint_instr[31:28] = `WAIT;
          maint_instr[27:0]  = trfc;

          if(maint_ack) begin
            maint_state_ns = MAINT_DUMMY;
            dummy_count_ns = 5'd16;
            /*
            if(pc == 1'b0) begin
              maint_state_ns = AREF_PRE;
              pc = 1'b1;
            end
            else begin
              pc = 1'b0;
              //maint_state_ns = MAINT_FIN;
              maint_state_ns = MAINT_DUMMY;
              dummy_count_ns = 4'h8;
            end
            */
          end
        end //AREF_WAIT_REF

        MAINT_DUMMY: begin
          maint_instr[31:28] = `WAIT;
          maint_instr[27:0] = 28'd1;
          dummy_count_ns = dummy_count_ns - 1;
          
          if(maint_ack) begin
            if(dummy_count > 5'd0) begin
              maint_state_ns = MAINT_DUMMY;
            end
            else begin
              maint_state_ns = MAINT_FIN;
            end
          end
        end //MAINT_DUMMY


        MAINT_FIN: begin
          maint_instr[31:28] = `END_ISEQ;
          autoref_process_ns = 1'b0;
          autoref_ack = 1'b1;
        end //MAINT_FIN
      endcase //maint_state
    end //autoref_process_r
  end //maint_process
end //always maintenance

always@(posedge clk) begin
  if(!rstn) begin
    maint_state <= 4'd0;
    dummy_count <= 5'd0;
  end
  else begin
    maint_state <= maint_state_ns;
    dummy_count <= dummy_count_ns;
  end
end

assign maint_process = autoref_process_r;

assign maint_instr_en = maint_process;

always@(posedge clk) begin
  autoref_process_r <= autoref_process_ns;
end


endmodule
