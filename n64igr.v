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
// Revision: 4
// Additional Comments: console reset
//                      activate / deactivate de-blur in 240p
//                      activate / deactivate 15bit mode
//                      selectable defaults
//                      defaults set on each power cycle and on each reset
///////////////////////////////////////////////////////////////////////////////////////////


module n64igr (
  input nCLK,
  input nRST_IGR,

  input CTRL,

  input Default_DeBlur,
  input Default_n15bit_mode,

  output reg nDeBlur,
  output reg n15bit_mode,

  output reg DRV_RST
);

initial begin
  DRV_RST    = 1'b0;
end

// Part 1: Clock Divider
// =====================

// nCLK frequency (NTSC and PAL related to console type; not to video type)
//   - NTSC: ~48.68MHz
//   -  PAL: ~49.66MHz
// nCLK2 is nCLK divided by 2*6
//   - NTSC: ~4.06MHz (~0.247us period)
//   -  PAL: ~4.14MHz (~0.242us period)

reg nCLK2 = 1'b0;               // clock with period as described
reg [2:0] div_clk_cnt = 3'b000; // counter to generate a clock devider 2*6

always @(negedge nCLK) begin
  if (div_clk_cnt == 3'b101) begin
    nCLK2 <= ~nCLK2;
    div_clk_cnt <= 3'b000;
  end else
    div_clk_cnt <= div_clk_cnt + 1'b1;
end


// Part 2: IGR
// ===========

reg [1:0] read_state  = 2'b0; // state machine

parameter ST_WAIT4N64 = 2'b00; // wait for N64 sending request to controller
parameter ST_N64_RD   = 2'b01; // N64 request sniffing
parameter ST_CTRL_RD  = 2'b10; // controller response

reg        prev_ctrl    =  1'b1;
reg [11:0] wait_cnt     = 12'b0; // counter for wait state (needs appr. 1.0ms at nCLK2 clock to fill up from 0 to 4095)

reg [15:0] data_stream      = 16'b0;
reg  [3:0] data_cnt         =  4'h0;

reg initiate_nrst = 1'b0;
reg nfirstboot    = 1'b0;

// controller data bits:
//  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
//  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
// 16:23 - X axis
// 24:31 - Y axis
// 32    - Stop bit
// (bits[0:15] used here)

always @(negedge nCLK2) begin
  case (read_state)
    ST_WAIT4N64:
      if (&wait_cnt) begin // waiting duration ends (exit wait state only if CTRL was high for a certain duration)
        read_state    <= ST_N64_RD;
        data_stream   <= 16'h0000;
        data_cnt      <=  4'h0;
        initiate_nrst <=  1'b0;
      end
    ST_N64_RD:
      if (wait_cnt[7:0] == 8'h09) begin // low bit_cnt increased 10 times since neg. edge (delay somewhere between 2.4us) -> sample data
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
      if (wait_cnt[7:0] == 8'h09) begin // low bit_cnt increased 10 times since neg. edge (delay somewhere around 2.4us) -> sample data
        if (&data_cnt) begin // sixteen bits read (analog values of stick not point of interest)
          if ({data_stream[14:0], CTRL} == 16'b0000001000110010) // Dl + L + R + Cl pressed
            nDeBlur <= 1'b1;
          if ({data_stream[14:0], CTRL} == 16'b0000000100110001) // Dr + L + R + Cr pressed
            nDeBlur <= 1'b0;
          if ({data_stream[14:0], CTRL} == 16'b0000100000111000) // Du + L + R + Cu pressed
              n15bit_mode <= 1'b1;
          if ({data_stream[14:0], CTRL} == 16'b0000010000110100) // Dd + L + R + Cd pressed
              n15bit_mode <= 1'b0;
          if ({data_stream[14:0], CTRL} == 16'b1100010100110000) // A + B + Dd + Dr + L + R pressed
            initiate_nrst <= 1'b1;
          read_state  <= ST_WAIT4N64;
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

  if (~nRST_IGR) begin
    read_state    <= ST_WAIT4N64;
    wait_cnt      <= 12'h000;
    prev_ctrl     <=  1'b1;
    initiate_nrst <=  1'b0;
  end

  if (~nfirstboot) begin
    nfirstboot  <= 1'b1;
    nDeBlur     <= ~Default_DeBlur;
    n15bit_mode <=  Default_n15bit_mode;
  end
end

// Part 3: Driving Reset
// =====================

reg [17:0] rst_cnt = 18'b0; // ~65ms are needed to count from max downto 0 with nCLK2.

always @(negedge nCLK2) begin
  if (initiate_nrst == 1'b1) begin
    DRV_RST <= 1'b1;      // reset system
    rst_cnt <= 18'h3ffff;
  end else if (|rst_cnt) // decrement as long as rst_cnt is not zero
    rst_cnt <= rst_cnt - 1'b1;
  else
    DRV_RST <= 1'b0; // end of reset
end

endmodule
