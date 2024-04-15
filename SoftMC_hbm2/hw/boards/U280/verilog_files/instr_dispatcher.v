`timescale 1ps / 1ps

`include "softmc_define.vh"

module instr_dispatcher #
(
  parameter RA_WIDTH = 13,
  parameter CA_WIDTH = 4,
  parameter BA_WIDTH = 2,
  parameter BG_WIDTH = 2,
  parameter PC_WIDTH = 1,
//  parameter CH_WIDTH = 3,
  parameter SID_WIDTH = 1,
  parameter CKE_WIDTH = 1,
  parameter DQ_WIDTH = 256,
	parameter WL       = 7
)
(
  input clk,
  input rstn,
	
  input rdback_fifo_full,

  //There are two instructions queues to fetch from. Since PHY issues DDR commands at both pos and neg edges, 
  //we dispatch two instructions in the same cycle, running at half of the frequency of the DDR bus
  input  en_in0,
  output reg ack_out0,
  input [31:0] instr_in0,

  input  en_in1,
  output reg ack_out1,
  input [31:0] instr_in1,

  input  en_in2,
  output reg ack_out2,
  input [31:0] instr_in2,

  input  en_in3,
  output reg ack_out3,
  input [31:0] instr_in3,

  // auto-refresh
  output reg          aref_set_interval,
  output reg [27:0]   aref_interval,
  output reg          aref_set_trfc,
  output reg [27:0]   aref_trfc,
 
  // DFI INTERFACE SIGNALS
  output [11:0]   dfi_0_aw_row_p0,
  output [15:0]   dfi_0_aw_col_p0,
  output [255:0]  dfi_0_dw_wrdata_p0,

  output [11:0]   dfi_0_aw_row_p1,
  output [15:0]   dfi_0_aw_col_p1,
  output [255:0]  dfi_0_dw_wrdata_p1
);

  localparam ONE = 1;
  localparam TWO = 2;

  reg[12:0] wait_cycles_r, wait_cycles_ns,  wait_cycles_buf;
    
  reg dec0_en;
  reg dec1_en;
  reg [31:0] dec0_instr_r;
  reg [31:0] dec1_instr_r;
  reg [31:0] dec0_instr_c;
  reg [31:0] dec1_instr_c;

  reg dec0_en_buf;
  reg dec1_en_buf;
  reg [31:0] dec0_instr_r_buf;
  reg [31:0] dec1_instr_c_buf;
  reg [31:0] dec0_instr_c_buf;
  reg [31:0] dec1_instr_r_buf;

  reg dec0_en_d1;
  reg dec1_en_d1;
//  reg [31:0] dec0_instr_r_d1;
  reg [31:0] dec1_instr_c_d1;
  reg [31:0] dec0_instr_c_d1;
  reg [31:0] dec1_instr_r_d1;

  reg block_other_slot;

  reg [256:0]	wrdata_buf_p0;
  reg [256:0]	wrdata_buf_p0_d1 [15:0];
  reg [256:0]	wrdata_buf_p1;
  reg [256:0]	wrdata_buf_p1_d1 [15:0];

  reg[1:0] ptr; 
  reg[2:0] interval;

  reg[31:0] instr0, instr1, instr2, instr3;
  reg en0, en1, en2, en3;
  reg ack0, ack1, ack2, ack3;
  reg ack_out0_buf, ack_out1_buf, ack_out2_buf, ack_out3_buf;

  reg[31:0] dec1_instr_in0;
  reg[31:0] dec1_instr_in1;

  reg act_sec0;
  reg act_sec1;

  reg en0_buf;
  reg en1_buf;
  reg en2_buf;
  reg en3_buf;
  reg start;
  reg [31:0] instr0_buf;
  reg [31:0] instr1_buf;
  reg [31:0] instr2_buf;
  reg [31:0] instr3_buf;

  wire working;
  reg end_all, end_all_buf;
  wire en_all;

  //Counter saturating at zero
  reg load_counter;

  // auto-refresh
  reg        aref_set_interval_ns, aref_set_trfc_ns;
  reg [27:0] aref_interval_ns, aref_trfc_ns;

  always@(posedge clk) begin
    if(!rstn) begin
      end_all     <= 1'b0;
      end_all_buf <= 1'b0;
    end
    else begin
      end_all_buf <= !(en0 | en1 | en2 | en3) & !wait_cycles_r & !wait_cycles_ns & !wait_cycles_buf;
      end_all     <= end_all_buf;
    end
  end

  always@(posedge clk) begin
    if(!rstn) begin
      wait_cycles_buf <= 13'b0;
    end
    else begin
      wait_cycles_buf <= wait_cycles_r;
    end
  end

  always@(*) begin
    if(en_in0 & !instr0) begin
      start = 1'b1;
    end
    else begin
      start = 1'b0;
    end
  end

  //assign working = (en0 | wait_cycles_r) ? 1'b1 : en_all | ~end_all;
  assign working = en_all | ~end_all;
  assign en_all = en_in0 | en_in1 | en_in2 | en_in3;


  always@(posedge clk) begin
    if(!rstn)
      wait_cycles_r <= 13'd0;
    else begin
      if(load_counter) begin
        wait_cycles_r <= wait_cycles_ns;
      end //load_counter
      else begin
        if(|wait_cycles_r[12:1])
          wait_cycles_r <= wait_cycles_r - TWO[0 +: 13];
        else
          wait_cycles_r <= 13'd0;
      end
    end
  end

  //assign act_sec0 = (dec0_en & (dec0_instr_r[31:28] == `ACT) & dec0_instr_r[`SEC_OFFSET] == 1'b0);

  always@* begin
    dec0_en_buf = 1'b0;
    dec1_en_buf = 1'b0;

    dec0_instr_r_buf = 32'd0;
    dec0_instr_c_buf = 32'd0;
    dec1_instr_r_buf = 32'd0;
    dec1_instr_c_buf = 32'd0;

    //wait_cycles_ns = 13'dx;
    wait_cycles_ns = 13'd0;
    load_counter = 1'b0;
    
    aref_set_interval_ns = 1'b0;
    aref_set_trfc_ns     = 1'b0;
    if(!rstn) begin
      aref_interval_ns   = {28{1'b0}};
      aref_trfc_ns       = {28{1'b0}};
    end
    else begin
      aref_interval_ns   = aref_interval;
      aref_trfc_ns       = aref_trfc;
    end
    block_other_slot = 1'b0;

    interval = {~en_all, 2'b0};
    
    act_sec0 = 1'b0;

    if(~rdback_fifo_full) begin
      ////// phase 0 //////
      if(wait_cycles_r <= 13'd1) begin
        //if(en0) begin
        if(working) begin
          if(act_sec1) begin // 2nd phase of ACT 
            dec0_en_buf = 1'b1;
            dec0_instr_r_buf = {dec1_instr_r[31:`SEC_OFFSET+1],1'b1,dec1_instr_r[`SEC_OFFSET-1:0]};
            if(instr0[31:30] == `COL_CMD) begin // instr0 = 2nd ACT, instr1 = col cmd
              dec0_instr_c_buf = instr0;
              interval = 3'd1;
            end
          end
          else begin
            casex(instr0[31:28])
              `DRAM_INSTR: begin
                dec0_en_buf = 1'b1; 
                if(~act_sec1) begin // instr0 = row cmd, but not ACT 2nd
                  if(instr0[31:30] == `ROW_CMD) begin
                    dec0_instr_r_buf = instr0;
                    if(instr1[31:30] == `COL_CMD) begin // instr0 = col cmd, instr1 = row cmd
                      dec0_instr_c_buf = instr1;
                      interval = 3'd2;
                    end
                    else begin
                      interval = 3'd1;
                    end
                  end
                  else if(instr0[31:30] == `COL_CMD) begin // instr0 = col cmd
                    dec0_instr_c_buf = instr0;
                    if(instr1[31:30] == `ROW_CMD) begin // instr0 = row cmd, instr1 = col cmd
                      dec0_instr_r_buf = instr1;
                      interval = 3'd2;
                    end
                    else begin
                      interval = 3'd1;
                    end
                  end
                end
              end // DRAM_INSTR

              `WAIT: begin
                load_counter = 1'b1;
                wait_cycles_ns = instr0[12:0] - 13'd1; //reducing by one for the second slot
                
                interval = 3'd1;
                if(instr0[12:0] > 13'd1) begin
                  block_other_slot = 1'b1;
                end
              end // WAIT
              /*
              `SET_TREFI: begin
                aref_set_interval_ns = 1'b1;
                aref_interval_ns     = instr0[27:0];
                interval = 3'd1;
              end

              `SET_TRFC: begin
                aref_set_trfc_ns = 1'b1;
                aref_trfc_ns     = instr0[27:0];
                interval = 3'd1;
              end
              */
            endcase
          end
        end
      end

      if(dec0_instr_r_buf[31:28] == `ACT && dec0_instr_r_buf[`SEC_OFFSET] == 1'b0) begin
        act_sec0 = 1'b1;
      end

      case(interval)
        3'd0: begin
          dec1_instr_in0 = instr0;
          dec1_instr_in1 = instr1;
        end
        3'd1: begin
          dec1_instr_in0 = instr1;
          dec1_instr_in1 = instr2;
        end
        3'd2: begin
          dec1_instr_in0 = instr2;
          dec1_instr_in1 = instr3;
        end
        default: begin
          dec1_instr_in0 = instr0;
          dec1_instr_in1 = instr1;
        end
      endcase
    
      ////// phase 1 //////
      if(~(en0 & block_other_slot) & (wait_cycles_r <= 13'd2)) begin
        if(en1) begin
          if(act_sec0) begin // 2nd phase of ACT 
            dec1_en_buf = 1'b1;
            dec1_instr_r_buf = {dec0_instr_r_buf[31:`SEC_OFFSET+1], 1'b1, dec0_instr_r_buf[`SEC_OFFSET-1:0]};
            if(dec1_instr_in0[31:30] == `COL_CMD) begin // instr0 = 2nd ACT, instr1 = col cmd
              dec1_instr_c_buf = dec1_instr_in0;
              interval = interval + 3'd1;
            end
          end
          else begin
            casex(dec1_instr_in0[31:28])
              `DRAM_INSTR: begin
                dec1_en_buf = 1'b1;
                if(dec1_instr_in0[31:30] == `ROW_CMD) begin // instr0 = row cmd
                  dec1_instr_r_buf = dec1_instr_in0;
                  if(dec1_instr_in1[31:30] == `COL_CMD) begin // instr0 = row cmd, instr1 = col cmd
                    dec1_instr_c_buf = dec1_instr_in1;
                    interval = interval + 3'd2;
                  end
                  else begin
                    interval = interval + 3'd1;
                  end
                end
                else if(dec1_instr_in0[31:30] == `COL_CMD) begin // instr0 = col cmd
                  dec1_instr_c_buf = dec1_instr_in0;
                  if(dec1_instr_in1[31:30] == `ROW_CMD) begin // instr0 = col cmd, instr1 = row cmd
                    dec1_instr_r_buf = dec1_instr_in1;
                    interval = interval + 3'd2;
                  end
                  else begin
                    interval = interval + 3'd1;
                  end
                end
              end // DRAM_INSTR

              `WAIT: begin
                wait_cycles_ns = dec1_instr_in0[12:0];
                load_counter = 1'b1;
                interval = interval + 3'd1;
              end
              /*
              `SET_TREFI: begin
                aref_set_interval_ns = 1'b1;
                aref_interval_ns     = dec1_instr_in0[27:0];
                interval =  interval + 3'd1;
              end

              `SET_TRFC: begin
                aref_set_trfc_ns = 1'b1;
                aref_trfc_ns     = dec1_instr_in0[27:0];
                interval = interval + 3'd1;
              end
              */
            endcase
          end
        end
      end

      if(interval == 3'd0 & !instr0 & !instr1 & !instr2 & !instr3) 
        interval = 3'd4;
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(~rstn) begin
      act_sec1 <= 1'b0;
    end
    else begin
      if(dec1_instr_r_buf[31:28] == `ACT && dec1_instr_r_buf[`SEC_OFFSET] == 1'b0) begin
        act_sec1 <= 1'b1;
      end
      else begin 
        act_sec1 <= 1'b0;
      end
    end
  end



  //////////////////////////////////////////
  ///////////     Write Data     ///////////
  //////////////////////////////////////////

  // the MSB of wrdata_buf decides this wrrdata is valid
  assign dfi_0_dw_wrdata_p0 = wrdata_buf_p0_d1[WL/2][256] ? wrdata_buf_p0_d1[WL/2] : {1'b0,{DQ_WIDTH{1'b1}}};
  assign dfi_0_dw_wrdata_p1 = wrdata_buf_p1_d1[WL/2][256] ? wrdata_buf_p1_d1[WL/2] : {1'b0,{DQ_WIDTH{1'b1}}};

  always@(*) begin
    wrdata_buf_p0_d1[0] = wrdata_buf_p0;
    wrdata_buf_p1_d1[0] = wrdata_buf_p1;
  end

  genvar i;
  generate for (i = 0; i < 15; i = i + 1) begin
    always@(posedge clk or negedge rstn) begin
      if(~rstn) begin
        wrdata_buf_p0_d1[i+1] <= {1'b0,{256{1'b0}}};
        wrdata_buf_p1_d1[i+1] <= {1'b0,{256{1'b0}}};
      end
      else begin
        wrdata_buf_p0_d1[i+1] <= wrdata_buf_p0_d1[i];
        wrdata_buf_p1_d1[i+1] <= wrdata_buf_p1_d1[i];
      end
    end
  end
  endgenerate


  // dfi_p0
  always@(*) begin
    // write latency is even
    if(WL[0] == 1'b0) begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE)) begin
        wrdata_buf_p0[256] = 1'b1;
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE)) begin
        wrdata_buf_p0[256] = 1'b1;
      end
      else begin
        wrdata_buf_p0[256] = 1'b0;
      end
    end
    // write latency is odd
    else begin
      // instr 0
      if(dec0_en_d1 & (dec0_instr_c_d1[31:28] == `WRITE)) begin
        wrdata_buf_p0[256] = 1'b1;
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE)) begin
        wrdata_buf_p0[256] = 1'b1;
      end
      else begin
        wrdata_buf_p0[256] = 1'b0;
      end
    end 
  end


  // dfi_p0 & pc0
  always@(*) begin
    // write latency is even
    if(WL[0] == 1'b0) begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE) & (dec0_instr_c[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p0[63:0]    = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[191:128] = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE) & (dec1_instr_c_d1[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p0[63:0]    = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[191:128] = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p0[63:0]    = {64{1'b1}};
        wrdata_buf_p0[191:128] = {64{1'b1}};
      end
    end
    // write latency is odd
    else begin
      // instr 0
      if(dec0_en_d1 & (dec0_instr_c_d1[31:28] == `WRITE) & (dec0_instr_c_d1[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p0[63:0]    = {8{dec0_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[191:128] = {8{dec0_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE) & (dec1_instr_c_d1[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p0[63:0]    = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[191:128] = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p0[63:0]    = {64{1'b1}};
        wrdata_buf_p0[191:128] = {64{1'b1}};
      end
    end 
  end

  // dfi_p0 & pc1
  always@(*) begin
    // write latency is even
    if(WL[0] == 1'b0) begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE) & (dec0_instr_c[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p0[127:64]  = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[255:192] = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE) & (dec1_instr_c_d1[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p0[127:64]  = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[255:192] = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p0[127:64]  = {64{1'b1}};
        wrdata_buf_p0[255:192] = {64{1'b1}};
      end
    end
    // write latency is odd
    else begin
      // instr 0
      if(dec0_en_d1 & (dec0_instr_c_d1[31:28] == `WRITE) & (dec0_instr_c_d1[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p0[127:64]  = {8{dec0_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[255:192] = {8{dec0_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE) & (dec1_instr_c_d1[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p0[127:64]  = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p0[255:192] = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p0[127:64]  = {64{1'b1}};
        wrdata_buf_p0[255:192] = {64{1'b1}};
      end
    end 
  end


  // dfi_p1
  always@(*) begin
    // write latency is even
    if(WL[0] == 1'b0) begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE)) begin
        wrdata_buf_p1[256] = 1'b1;
      end
      // instr 1
      else if(dec1_en & (dec1_instr_in0[31:28] == `WRITE)) begin
        wrdata_buf_p1[256] = 1'b1;
      end
      else begin
        wrdata_buf_p1[256] = 1'b0;
      end
    end
    // write latency is odd
    else begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE)) begin
        wrdata_buf_p1[256] = 1'b1;
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE)) begin
        wrdata_buf_p1[256] = 1'b1;
      end
      else begin
        wrdata_buf_p1[256] = 1'b0;
      end
    end 
  end


  // dfi_p1 & pc0
  always@(*) begin
    // write latency is even
    if(WL[0] == 1'b0) begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE) & (dec0_instr_c[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p1[63:0]    = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[191:128] = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en & (dec1_instr_in0[31:28] == `WRITE) & (dec1_instr_in0[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p1[63:0]    = {8{dec1_instr_in0[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[191:128] = {8{dec1_instr_in0[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p1[63:0]    = {64{1'b1}};
        wrdata_buf_p1[191:128] = {64{1'b1}};
      end
    end
    // write latency is odd
    else begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE) & (dec0_instr_c[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p1[63:0]    = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[191:128] = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE) & (dec1_instr_c_d1[`PC_OFFSET] == 1'b0)) begin
        wrdata_buf_p1[63:0]    = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[191:128] = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p1[63:0]    = {64{1'b1}};
        wrdata_buf_p1[191:128] = {64{1'b1}};
      end
    end 
  end

  // dfi_p1 & pc1
  always@(*) begin
    // write latency is even
    if(WL[0] == 1'b0) begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE) & (dec0_instr_c[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p1[127:64]  = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[255:192] = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en & (dec1_instr_in0[31:28] == `WRITE) & (dec1_instr_in0[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p1[127:64]  = {8{dec1_instr_in0[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[255:192] = {8{dec1_instr_in0[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p1[127:64]  = {64{1'b1}};
        wrdata_buf_p1[255:192] = {64{1'b1}};
      end
    end
    // write latency is odd
    else begin
      // instr 0
      if(dec0_en & (dec0_instr_c[31:28] == `WRITE) & (dec0_instr_c[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p1[127:64]  = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[255:192] = {8{dec0_instr_c[`WRDATA_OFFSET-:8]}};
      end
      // instr 1
      else if(dec1_en_d1 & (dec1_instr_c_d1[31:28] == `WRITE) & (dec1_instr_c_d1[`PC_OFFSET] == 1'b1)) begin
        wrdata_buf_p1[127:64]  = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
        wrdata_buf_p1[255:192] = {8{dec1_instr_c_d1[`WRDATA_OFFSET-:8]}};
      end
      else begin
        wrdata_buf_p1[127:64]  = {64{1'b1}};
        wrdata_buf_p1[255:192] = {64{1'b1}};
      end
    end
  end



  ////////////////////////////////////
  /////////     Pointer      /////////
  ////////////////////////////////////

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      ptr <= 'd0;
    end
    else begin
      if(working) begin
        ptr <= ptr + interval; // divided by 4
      end 
      else begin
        ptr <= 'd0;
      end
    end
  end

  always@* begin
    if (en0 || en1 || en2 || en3) begin
      case(interval)
        3'd0: begin
          ack0 = 1'b0;
          ack1 = 1'b0;
          ack2 = 1'b0;
          ack3 = 1'b0;
        end
        3'd1: begin
          ack0 = 1'b1;
          ack1 = 1'b0;
          ack2 = 1'b0;
          ack3 = 1'b0;
        end
        3'd2: begin
          ack0 = 1'b1;
          ack1 = 1'b1;
          ack2 = 1'b0;
          ack3 = 1'b0;
        end
        3'd3: begin
          ack0 = 1'b1;
          ack1 = 1'b1;
          ack2 = 1'b1;
          ack3 = 1'b0;
        end
        3'd4: begin
          ack0 = 1'b1;
          ack1 = 1'b1;
          ack2 = 1'b1;
          ack3 = 1'b1;
        end
        default:;
      endcase
    end
    else begin
      ack0 = 1'b1;
      ack1 = 1'b1;
      ack2 = 1'b1;
      ack3 = 1'b1;
    end
  end

  // instr_seq by ptr
  always@(*) begin
    case(ptr)
      3'd0: begin
        en0 = en0_buf;
        en1 = en1_buf;
        en2 = en2_buf;
        en3 = en3_buf;
        instr0 = instr0_buf;
        instr1 = instr1_buf;
        instr2 = instr2_buf;
        instr3 = instr3_buf;
        ack_out0_buf = ack0;
        ack_out1_buf = ack1;
        ack_out2_buf = ack2;
        ack_out3_buf = ack3;
      end
      3'd1: begin
        en0 = en1_buf;
        en1 = en2_buf;
        en2 = en3_buf;
        en3 = en0_buf;
        instr0 = instr1_buf;
        instr1 = instr2_buf;
        instr2 = instr3_buf;
        instr3 = instr0_buf;
        ack_out0_buf = ack3;
        ack_out1_buf = ack0;
        ack_out2_buf = ack1;
        ack_out3_buf = ack2;
      end
      3'd2: begin
        en0 = en2_buf;
        en1 = en3_buf;
        en2 = en0_buf;
        en3 = en1_buf;
        instr0 = instr2_buf;
        instr1 = instr3_buf;
        instr2 = instr0_buf;
        instr3 = instr1_buf;
        ack_out0_buf = ack2;
        ack_out1_buf = ack3;
        ack_out2_buf = ack0;
        ack_out3_buf = ack1;
      end
      3'd3: begin
        en0 = en3_buf;
        en1 = en0_buf;
        en2 = en1_buf;
        en3 = en2_buf;
        instr0 = instr3_buf;
        instr1 = instr0_buf;
        instr2 = instr1_buf;
        instr3 = instr2_buf;
        ack_out0_buf = ack1;
        ack_out1_buf = ack2;
        ack_out2_buf = ack3;
        ack_out3_buf = ack0;
      end
      default: begin
        en0 = en0_buf;
        en1 = en1_buf;
        en2 = en2_buf;
        en3 = en3_buf;
        instr0 = instr0_buf;
        instr1 = instr1_buf;
        instr2 = instr2_buf;
        instr3 = instr3_buf;
        ack_out0_buf = ack0;
        ack_out1_buf = ack1;
        ack_out2_buf = ack2;
        ack_out3_buf = ack3;
      end
    endcase
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      en0_buf    <= 1'b0;
      instr0_buf <= 32'd0;
    end
    else begin
      if(ack_out0_buf) begin
        en0_buf    <= en_in0;
        instr0_buf <= working ? instr_in0 : 32'd0;
      end
      else begin
        en0_buf    <= en0_buf;
        instr0_buf <= working ? instr0_buf : 32'd0;
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      en1_buf    <= 1'b0;
      instr1_buf <= 32'd0;
    end
    else begin
      if(ack_out1_buf) begin
        en1_buf    <= en_in1;
        instr1_buf <= working ? instr_in1 : 32'd0;
      end
      else begin
        en1_buf    <= en1_buf;
        instr1_buf <= working ? instr1_buf : 32'd0;
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      en2_buf    <= 1'b0;
      instr2_buf <= 32'd0;
    end
    else begin
      if(ack_out2_buf) begin
        en2_buf    <= en_in2;
        instr2_buf <= working ? instr_in2 : 32'd0;
      end
      else begin
        en2_buf    <= en2_buf;
        instr2_buf <= working ? instr2_buf : 32'd0;
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      en3_buf    <= 1'b0;
      instr3_buf <= 32'd0;
    end
    else begin
      if(ack_out3_buf) begin
        en3_buf    <= en_in3;
        instr3_buf <= working ? instr_in3 : 32'd0;
      end
      else begin
        en3_buf    <= en3_buf;
        instr3_buf <= working ? instr3_buf : 32'd0;
      end
    end
  end

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      ack_out0 <= 1'b0;
      ack_out1 <= 1'b0;
      ack_out2 <= 1'b0;
      ack_out3 <= 1'b0;
    end
    else begin
      if(start) begin
        ack_out0 <= 1'b0;
        ack_out1 <= 1'b0;
        ack_out2 <= 1'b0;
        ack_out3 <= 1'b0;
      end 
      else begin
        ack_out0 <= ack_out0_buf;
        ack_out1 <= ack_out1_buf;
        ack_out2 <= ack_out2_buf;
        ack_out3 <= ack_out3_buf;
      end
    end
  end

  //////////////////////////////////////////////
  /////////     Delay (Buffering)      /////////
  //////////////////////////////////////////////

  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      dec0_en         <= 1'b0;
      dec1_en         <= 1'b0;
      dec0_instr_r    <= 32'd0;
      dec1_instr_r    <= 32'd0;
      dec0_instr_c    <= 32'd0;
      dec1_instr_c    <= 32'd0;
      dec0_en_d1      <= 1'b0;
      dec1_en_d1      <= 1'b0;
//      dec0_instr_r_d1 <= 32'd0;
      dec1_instr_r_d1 <= 32'd0;
      dec0_instr_c_d1 <= 32'd0;
      dec1_instr_c_d1 <= 32'd0;
    end
    else begin
      dec0_en         <= dec0_en_buf;
      dec1_en         <= dec1_en_buf;
      dec0_instr_r    <= dec0_instr_r_buf;
      dec1_instr_r    <= dec1_instr_r_buf;
      dec0_instr_c    <= dec0_instr_c_buf;
      dec1_instr_c    <= dec1_instr_c_buf;
      dec0_en_d1      <= dec0_en;
      dec1_en_d1      <= dec1_en;
//      dec0_instr_r_d1 <= dec0_instr_r;
      dec1_instr_r_d1 <= dec1_instr_r;
      dec0_instr_c_d1 <= dec0_instr_c;
      dec1_instr_c_d1 <= dec1_instr_c;
    end
  end
 /*
  always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      aref_set_interval <= 1'b0;
      aref_set_trfc     <= 1'b0;
      aref_interval     <= 28'd0;
      aref_trfc         <= 28'd0;
    end
    else begin
      if(aref_set_interval_ns) begin
        aref_interval     <=  aref_interval_ns;
      end
      if(aref_set_trfc_ns) begin
        aref_trfc         <=  aref_trfc_ns;
      end
      
      aref_set_interval <=  aref_set_interval_ns;
      aref_set_trfc     <=  aref_set_trfc_ns;
    end
  end
*/
  // Instruction decoder for phase 0
  instr_decoder
  #(
    .RA_WIDTH	  (RA_WIDTH),
    .CA_WIDTH		(CA_WIDTH),
    .BA_WIDTH		(BA_WIDTH),
    .BG_WIDTH		(BG_WIDTH),
    .PC_WIDTH 	(PC_WIDTH),
//		.CH_WIDTH		(CH_WIDTH),
    .SID_WIDTH	(SID_WIDTH)
  )
  instr_dec0
  (
    .en					(dec0_en),
    .instr_r		(dec0_instr_r),
    .instr_c    (dec0_instr_c),
    .dfi_aw_row (dfi_0_aw_row_p0),
    .dfi_aw_col (dfi_0_aw_col_p0)
  );

  // Instruction decoder for phase 1
  instr_decoder 
  #(
    .RA_WIDTH	(RA_WIDTH),
    .CA_WIDTH		(CA_WIDTH),
    .BA_WIDTH		(BA_WIDTH),
    .BG_WIDTH		(BG_WIDTH),
    .PC_WIDTH 	(PC_WIDTH),
//		.CH_WIDTH		(CH_WIDTH),
    .SID_WIDTH	(SID_WIDTH)
  )
  instr_dec1
  (
    .en					(dec1_en),
    .instr_r		(dec1_instr_r),
    .instr_c    (dec1_instr_c),
    .dfi_aw_row (dfi_0_aw_row_p1),
    .dfi_aw_col (dfi_0_aw_col_p1)
  );

endmodule
