`timescale 1ps / 1ps

module pipe_reg
#(
  parameter WIDTH = 32
)
(
  input clk,
  input rstn,

  input ready_in,
  input valid_in,
  input[WIDTH - 1:0] data_in,
  output valid_out,
  output[WIDTH - 1:0] data_out,
  output ready_out
);
  
  reg r_ready, r_valid1, r_valid2;
  reg[WIDTH - 1:0] r_data1, r_data2;
  
  wire first_buf_ready = ready_in | ~r_valid1;
  
  assign data_out =  r_data1; // wire
  assign valid_out = r_valid1;
  assign ready_out = r_ready;

  // valid signal
  reg  valid_in1, valid_in2, valid_in3; 
  wire valid = valid_in ? valid_in : valid_in3; 

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      valid_in1 <= 0;
      valid_in2 <= 0;
      valid_in3 <= 0;
    end
    else begin
      valid_in1 <= valid_in;
      valid_in2 <= valid_in1;
      valid_in3 <= valid_in2;
    end
  end
  ///////////////////////////////////////
  always@(posedge clk) begin
    if(!rstn) begin
      r_data1 <= 0;
      r_data2 <= 0;
      r_ready <= 0;
      r_valid1 <= 0;
      r_valid2 <= 0;
    end
    else begin
      //data acquisition
      if(r_ready) begin
        if(first_buf_ready) begin
          r_data1 <= data_in;
          r_valid1 <= data_in ? valid : 1'b0;;
        end
        else begin
          r_data2 <= data_in;
          r_valid2 <= data_in ? valid : 1'b0;;
        end
      end //r_ready
      
      //data shift
      else if(~r_ready & ready_in) begin
        r_data1 <= r_data2;
        r_valid1 <= r_valid2;
      end
    end
    
    //control
    r_ready <= first_buf_ready;
  end
endmodule
