`timescale 1ns / 1ps

module read_capturer
#(
  parameter DQ_WIDTH = 256
)
(
  input                     clk,
  input                     rstn,

  //DFI Interface
  input  [DQ_WIDTH-1:0]     dfi_0_dw_rddata_p0,
  input  [DQ_WIDTH-1:0]     dfi_0_dw_rddata_p1,
  input  [3:0]              dfi_0_dw_rddata_valid,
  output reg				        dfi_0_aw_ck_dis,

  //FIFO interface
  input                     rdback_fifo_full_pc0,
  input                     rdback_fifo_full_pc1,
  output reg                rdback_fifo_wr_en_pc0,
  output reg                rdback_fifo_wr_en_pc1,
  output reg [DQ_WIDTH-1:0] rdback_fifo_din_pc0,
  output reg [DQ_WIDTH-1:0] rdback_fifo_din_pc1
);

  // Pseudo Channel 0
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      rdback_fifo_wr_en_pc0  <= 1'b0;
      rdback_fifo_din_pc0 <= {256{1'b1}};
    end 
    else begin
      if (dfi_0_dw_rddata_valid[1:0] == 2'b11) begin
        rdback_fifo_wr_en_pc0  <= 1'b1;
        rdback_fifo_din_pc0 <= {dfi_0_dw_rddata_p1[191:128], dfi_0_dw_rddata_p1[63:0], dfi_0_dw_rddata_p0[191:128], dfi_0_dw_rddata_p0[63:0]};
      end 
      else begin
        rdback_fifo_wr_en_pc0  <= 1'b0;
        rdback_fifo_din_pc0 <= {256{1'b1}};
      end 
    end 
  end

  // Pseudo Channel 1
  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      rdback_fifo_wr_en_pc1  <= 1'b0;
      rdback_fifo_din_pc1 <= {256{1'b1}};
    end 
    else begin
      if (dfi_0_dw_rddata_valid[3:2] == 2'b11) begin
        rdback_fifo_wr_en_pc1  <= 1'b1;
        rdback_fifo_din_pc1 <= {dfi_0_dw_rddata_p1[255:192], dfi_0_dw_rddata_p1[127:64], dfi_0_dw_rddata_p0[255:192], dfi_0_dw_rddata_p0[127:64]};
      end 
      else begin
        rdback_fifo_wr_en_pc1  <= 1'b0;
        rdback_fifo_din_pc1 <= {256{1'b1}};
      end 
    end 
  end

  always@(posedge clk) begin
    if(~rstn) begin
      dfi_0_aw_ck_dis <= 1'b0;
    end
    else begin
      dfi_0_aw_ck_dis <= rdback_fifo_full_pc0 | rdback_fifo_full_pc1;
    end
  end

endmodule
