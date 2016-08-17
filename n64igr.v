//////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64igr
// Project Name:   n64rgb
// Target Devices: MaxII
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies:
//
// Revision: 1
// Additional Comments: activate / deactivate de-blur in 240p (default:  on)
//                      activate / deactivate 15bit mode      (default: off)
//                      defaults set on each power cycle
///////////////////////////////////////////////////////////////////////////////////////////


module n64igr (
  input nCLK,

  input CTRL,

  output reg nDeBlur,
  output reg n15bit_mode
);

initial begin
  nDeBlur     = 1'b0;
  n15bit_mode = 1'b1;
end

// nCLK frequency (NTSC and PAL related to console type; not to video type)
//   - NTSC: ~48.68MHz
//   -  PAL: ~49.66MHz
// nCLK2 is nCLK divided by 2*9
//   - NTSC: ~2.70MHz (~0.369us period)
//   -  PAL: ~2.76MHz (~0.362us period)

reg nCLK2 = 1'b0;             // clock with period as described
reg [3:0] div_clk_cnt = 4'h0; // counter to generate a clock devider 2*9

always @(negedge nCLK) begin
  if (div_clk_cnt[3]) begin
    nCLK2 <= ~nCLK2;
    div_clk_cnt <= 4'h0;
  end else
    div_clk_cnt <= div_clk_cnt + 1'b1;
end



reg [1:0] read_state  = 2'b0; // state machine

parameter ST_WAIT4N64 = 2'b00; // wait for N64 sending request to controller
parameter ST_N64_RD   = 2'b01; // N64 request sniffing
parameter ST_CTRL_RD  = 2'b10; // controller response

reg        prev_ctrl    =  1'b1;
reg [11:0] wait_cnt     = 12'b0; // counter for wait state (needs appr. 1.5ms at nCLK2 clock to fill up from 0 to 4095)

reg [15:0] data_stream      = 16'b0;
reg [ 3:0] remember_data    =  4'h0;
reg [15:0] prev_data_stream = 16'h0;
reg  [3:0] data_cnt         =  4'h0;


always @(negedge nCLK2) begin
  case (read_state)
    ST_WAIT4N64:
      if (&wait_cnt) begin // waiting duration ends (exit wait state only if CTRL was high for a certain duration)
        read_state  <= ST_N64_RD;
        data_stream <= 16'h0000;
        data_cnt    <=  4'h0;
      end
    ST_N64_RD:
      if (wait_cnt[3:0] == 4'h4) begin // low bit_cnt increased 4 times since neg. edge (delay somewhere between 1.8us and 2.2us) -> sample data
        if (data_cnt[3]) // eight bits read
          if (data_stream[13:6] == 8'b00000001 & CTRL) begin // check command and stop bit
          // trick: the 2 LSB command bits lies where controller produces unused constant values
          //         -> (hopefully) no exchange with controller response
            read_state  <= ST_CTRL_RD;
            data_stream <= 16'h0000;
            data_cnt    <=  4'h0;
          end else
            read_state  <= ST_WAIT4N64;
        else begin
          data_stream[13:7] <= data_stream[12:6];
          data_stream[6]    <= CTRL;
          data_cnt          <= data_cnt + 1'b1;
        end
      end
    ST_CTRL_RD:
      if (wait_cnt[7:0] == 8'h04) begin // low bit_cnt increased 4 times since neg. edge (delay somewhere between 1.8us and 2.2us) -> sample data
        if (&data_cnt) begin // sixteen bits read (analog values of stick not point of interest)
          if ({data_stream[14:0], CTRL} == 16'b0000000100110001) begin // Dr + L + R + Cr pressed
            if (prev_data_stream != {data_stream[14:0], CTRL}) // prevents multiple executions (together with remember data)
              nDeBlur <= ~nDeBlur;
            remember_data <= 4'hf;
          end
          if ({data_stream[14:0], CTRL} == 16'b0000001000110010) begin // Dl + L + R + Cl pressed
            if (prev_data_stream != {data_stream[14:0], CTRL}) // prevents multiple executions (together with remember data)
              n15bit_mode <= ~n15bit_mode;
            remember_data <= 4'hf;
          end
          read_state  <= ST_WAIT4N64;
          if (~|remember_data)
            prev_data_stream <= {data_stream[14:0], CTRL};
          else
            remember_data <= remember_data - 1'b1;
        end else begin
          data_stream[15:1] <= data_stream[14:0];
          data_stream[0]    <= CTRL;
          data_cnt          <= data_cnt + 1'b1;
        end
      end
  endcase


  if (prev_ctrl & ~CTRL) // counter resets on neg. edge
    wait_cnt <= 12'h000;
  else if (~&wait_cnt) // saturate counter if needed
    wait_cnt <= wait_cnt + 1'b1;

  prev_ctrl <= CTRL;
end

endmodule
