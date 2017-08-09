//////////////////////////////////////////////////////////////////////////////////
// Company: Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64igr
// Project Name:   n64rgb
// Target Devices: several MaxII & MaxV devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: igr_params.vh
//
// Revision: 2.5
// Features: console reset
//           override heuristic for deblur (resets on each reset and power cycle)
//           activate / deactivate de-blur in 240p (a change overrides heuristic for de-blur)
//           activate / deactivate 15bit mode
//           selectable defaults
//           defaults set on each power cycle and on each reset
//
///////////////////////////////////////////////////////////////////////////////////////////


module n64igr (
  input nCLK,
  inout nRST,

  input CTRL,

  input Default_nForceDeBlur,
  input Default_DeBlur,
  input Default_n15bit_mode,

  output reg nDeBlur,
  output reg nForceDeBlur,
  output reg n15bit_mode

`ifdef OPTION_INVLPF
  ,
  output reg InvLPF
`endif
);

`include "igr_params.vh"

`ifdef OPTION_INVLPF
  initial InvLPF = 1'b0;
`endif

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


reg [1:0] read_state  = 2'b0; // state machine

parameter ST_WAIT4N64 = 2'b00; // wait for N64 sending request to controller
parameter ST_N64_RD   = 2'b01; // N64 request sniffing
parameter ST_CTRL_RD  = 2'b10; // controller response

reg [3:0] sampling_point_n64  = 4'h9; // wait_cnt increased a few times since neg. edge -> sample data
reg [3:0] sampling_point_ctrl = 4'h9; // (10 by default -> delay somewhere around 2.4us)

reg        prev_ctrl    =  1'b1;
reg [11:0] wait_cnt     = 12'b0; // counter for wait state (needs appr. 1.0ms at nCLK2 clock to fill up from 0 to 4095)

reg [15:0] data_stream      = 16'b0;
reg  [3:0] data_cnt         =  4'h0;

`ifdef OPTION_INVLPF
  reg [ 3:0] remember_data    =  4'h0;
  reg [15:0] prev_data_stream = 16'h0;
`endif

reg initiate_nrst = 1'b0;

reg nfirstboot = 1'b0;


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
    ST_N64_RD: begin
      if (wait_cnt[7:0] == {4'h0,sampling_point_n64}) begin // sample data
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
      if (&{prev_ctrl,~CTRL,|data_cnt})
        sampling_point_n64 <= wait_cnt[4:1];
    end
    ST_CTRL_RD: begin
      if (wait_cnt[7:0] == {4'h0,sampling_point_ctrl}) begin // sample data
        if (&data_cnt) begin // sixteen bits read (analog values of stick not point of interest)
          if ({data_stream[14:0], CTRL} == igr_deblur_off) begin // defined button combination pressed
            nForceDeBlur <= 1'b0;
            nDeBlur      <= 1'b1;
          end
          if ({data_stream[14:0], CTRL} == igr_deblur_on) begin // defined button combination pressed
            nForceDeBlur <= 1'b0;
            nDeBlur      <= 1'b0;
          end
          if ({data_stream[14:0], CTRL} == igr_15bitmode_off) begin // defined button combination pressed
`ifdef DEBUG // reset nForceDeBlur by changing 15bit mode
            nForceDeBlur <= 1'b1;
`endif
            n15bit_mode  <= 1'b1;
          end
          if ({data_stream[14:0], CTRL} == igr_15bitmode_on) begin // defined button combination pressed
`ifdef DEBUG // reset nForceDeBlur by changing 15bit mode
            nForceDeBlur <= 1'b1;
`endif
            n15bit_mode  <= 1'b0;
          end
`ifdef OPTION_INVLPF
          if ({data_stream[14:0], CTRL} == igr_toggle_LPF) begin // defined button combination pressed
            if (prev_data_stream != {data_stream[14:0], CTRL})   // prevents multiple executions (together with remember data)
              InvLPF <= ~InvLPF;
            remember_data <= 4'hf;
          end
`endif
          if ({data_stream[14:0], CTRL} == igr_reset) begin// defined button combination pressed
            initiate_nrst <= 1'b1;
          end
          read_state  <= ST_WAIT4N64;
`ifdef OPTION_INVLPF
          if (~|remember_data)
            prev_data_stream <= {data_stream[14:0], CTRL};
          else
            remember_data <= remember_data - 1'b1;
`endif
        end else begin
          data_stream[15:1] <= data_stream[14:0];
          data_stream[0]    <= CTRL;
          data_cnt          <= data_cnt + 1'b1;
        end
      end
      if (&{prev_ctrl,~CTRL,|data_cnt})
        sampling_point_ctrl <= wait_cnt[4:1];
    end
    default: read_state <= ST_WAIT4N64;
  endcase


  if (prev_ctrl & ~CTRL) // counter resets on neg. edge
    wait_cnt <= 12'h000;
  else if (~&wait_cnt) // saturate counter if needed
    wait_cnt <= wait_cnt + 1'b1;

  prev_ctrl <= CTRL;

  if (nRST == 1'b0) begin
`ifdef OPTION_INVLPF
    InvLPF      <= 1'b0;
`endif

    nForceDeBlur <= Default_nForceDeBlur;

    read_state    <= ST_WAIT4N64;
    wait_cnt      <= 12'h000;
    prev_ctrl     <=  1'b1;
    initiate_nrst <=  1'b0;
  end

  if (~nfirstboot) begin
    nfirstboot   <=  1'b1;
    nForceDeBlur <=  Default_nForceDeBlur;
    nDeBlur      <= ~Default_DeBlur;
    n15bit_mode  <=  Default_n15bit_mode;
  end
end

reg        drv_rst =  1'b0;
reg [17:0] rst_cnt = 18'b0; // ~65ms are needed to count from max downto 0 with nCLK2.

always @(negedge nCLK2) begin
  if (initiate_nrst == 1'b1) begin
    drv_rst <= 1'b1;      // reset system
    rst_cnt <= 18'h3ffff;
  end else if (|rst_cnt) // decrement as long as rst_cnt is not zero
    rst_cnt <= rst_cnt - 1'b1;
  else
    drv_rst <= 1'b0; // end of reset
end

assign nRST = drv_rst ? 1'b0 : 1'bz;

endmodule
