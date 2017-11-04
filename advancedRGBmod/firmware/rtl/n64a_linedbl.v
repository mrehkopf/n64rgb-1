//////////////////////////////////////////////////////////////////////////////////
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_linedbl
// Project Name:   N64 Advanced RGB Mod
// Target Devices: Max10, Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:    simple line-multiplying
//
// Dependencies: vh/n64a_params.vh
//               ip/ram2port_0.qip
//
// Revision: 1.1
// Features: linebuffer for - NTSC 240p -> 480p rate conversion
//                          - PAL  288p -> 576p rate conversion
//           injection of scanlines on demand in three selectable intensities
//
///////////////////////////////////////////////////////////////////////////////////////////


module n64a_linedbl(
  nCLK_in,
  CLK_out,

  vinfo_dbl,

  vdata_i,
  vdata_o
);

`include "vh/n64a_params.vh"

//`define HSTART 11'd109  // first pixel of a line
//`define HSTOP  11'd1532 // last pixel of a line
//                        // (atm a compromise between NTSC and PAL)

//`define nHS_WIDTH 8'd127  // HSYNC width (effectively 64 pixel)
`define nVS_WIDTH 2'd3    // three lines for VSYNC

wire [10:0] HSTART;
wire [10:0] HSTOP;
source_hstart_0 set_hstart(
  .source(HSTART)
);
source_hend_0 set_hstop(
  .source(HSTOP)
);

wire [7:0] nHS_WIDTH;
source_hs_width_0 set_nhs_width(
  .source(nHS_WIDTH)
);

wire [3:0] nVS_FP;
source_vs_fp_0 set_nvs_fp(
  .source(nVS_FP)
);

wire [5:0] nVS_BP;
source_vs_bp_0 set_nvs_bp(
  .source(nVS_BP)
);

localparam ram_depth = 11; // plus 1 due to oversampling

input nCLK_in;
input CLK_out;

input [4:0] vinfo_dbl; // [nLinedbl,SL_str (2bits),PAL,interlaced]

input  [`VDATA_I_FU_SLICE] vdata_i;
output [`VDATA_O_FU_SLICE] vdata_o;


// pre-assignments

wire nVS_i = vdata_i[3*color_width_i+3];
wire nHS_i = vdata_i[3*color_width_i+1];

wire [color_width_i-1:0] R_i = vdata_i[`VDATA_I_RE_SLICE];
wire [color_width_i-1:0] G_i = vdata_i[`VDATA_I_GR_SLICE];
wire [color_width_i-1:0] B_i = vdata_i[`VDATA_I_BL_SLICE];

reg               [3:0] S_o;
reg [color_width_o-1:0] R_o;
reg [color_width_o-1:0] G_o;
reg [color_width_o-1:0] B_o;


// start of rtl

reg div_2x = 1'b0;

always @(negedge nCLK_in) begin
  div_2x <= ~div_2x;
end

reg                 wren   = 1'b0;
reg                 wrline = 1'b0;
reg [ram_depth-1:0] wrhcnt = {ram_depth{1'b0}};
reg [ram_depth-1:0] wraddr = {ram_depth{1'b0}};

wire line_overflow = &{wrhcnt[ram_depth-1],wrhcnt[ram_depth-2],wrhcnt[ram_depth-5]};  // close approach for NTSC and PAL
//wire valid_line    = wrhcnt > `HSTOP;                                                 // for evaluation
wire valid_line    = wrhcnt > HSTOP;                                                 // for evaluation


reg [ram_depth-1:0] line_width[0:1];
initial begin
   line_width[1] = {ram_depth{1'b0}};
   line_width[0] = {ram_depth{1'b0}};
end

reg  nVS_i_buf = 1'b0;
reg  nHS_i_buf = 1'b0;


reg [1:0] newFrame       = 2'b0;
reg [1:0] start_reading_proc = 2'b00;


always @(negedge nCLK_in) begin
  if (~div_2x) begin
    if (nVS_i_buf & ~nVS_i) begin
      newFrame[0] <= ~newFrame[1];
      if (&{nHS_i_buf,~nHS_i,~line_overflow,valid_line})
        start_reading_proc[0] <= ~start_reading_proc[1];  // trigger start reading
    end

    if (nHS_i_buf & ~nHS_i) begin // negedge nHSYNC -> reset wrhcnt and toggle wrline
      line_width[wrline] <= wrhcnt[ram_depth-1:0];

      wrhcnt <= {ram_depth{1'b0}};
      wrline <= ~wrline;
    end else if (~line_overflow) begin
      wrhcnt <= wrhcnt + 1'b1;
    end

//    if (wrhcnt == `HSTART) begin
    if (wrhcnt == HSTART) begin
      wren   <= 1'b1;
      wraddr <= {ram_depth{1'b0}};
//    end else if (wrhcnt > `HSTART && wrhcnt < `HSTOP) begin
    end else if (wrhcnt > HSTART && wrhcnt < HSTOP) begin
      wraddr <= wraddr + 1'b1;
    end else begin
      wren   <= 1'b0;
      wraddr <= {ram_depth{1'b0}};
    end

    nVS_i_buf <= nVS_i;
    nHS_i_buf <= nHS_i;
  end
end


reg           [2:0] rden     = 3'b0;
reg           [1:0] rdrun    = 2'b00;
reg                 rdcnt    = 1'b0;
reg                 rdline   = 1'b0;
reg [ram_depth-1:0] rdhcnt   = {ram_depth{1'b0}};
reg [ram_depth-1:0] rdaddr   = {ram_depth{1'b0}};

always @(posedge CLK_out) begin
  if (rdrun[1]) begin
    if (rdhcnt == line_width[rdline]) begin
      rdhcnt   <= {ram_depth{1'b0}};
      if (rdcnt)
        rdline <= wrline;
      rdcnt <= ~rdcnt;
    end else begin
      rdhcnt <= rdhcnt + 1'b1;
    end
    if (line_overflow || &{nHS_i_buf,~nHS_i,~valid_line}) begin
      rdrun <= 2'b00;
    end

//    if (rdhcnt == `HSTART) begin
    if (rdhcnt == HSTART) begin
      rden[0] <= 1'b1;
      rdaddr  <= {ram_depth{1'b0}};
//    end else if (rdhcnt > `HSTART && rdhcnt < `HSTOP) begin
    end else if (rdhcnt > HSTART && rdhcnt < HSTOP) begin
      rdaddr <= rdaddr + 1'b1;
    end else begin
      rden[0] <= 1'b0;
      rdaddr  <= {ram_depth{1'b0}};
    end
  end else if (rdrun[0] && wrhcnt[3]) begin
    rdrun[1] <= 1'b1;
    rdcnt    <= 1'b1;
    rdline   <= ~wrline;
    rdhcnt   <= {ram_depth{1'b0}};
  end else if (^start_reading_proc) begin
    rdrun[0] <= 1'b1;
  end

  rden[2:1] <= rden[1:0];
  start_reading_proc[1] <= start_reading_proc[0];
end

wire [color_width_i-1:0] R_buf, G_buf, B_buf;

ram2port_0 videobuffer_0(
  .data({R_i,G_i,B_i}),
  .rdaddress(rdaddr),
  .rdclock(CLK_out),
  .rden(rden[0]),
  .wraddress(wraddr),
  .wrclock(~nCLK_in),
  .wren(&{wren,~line_overflow,~div_2x}),
  .q({R_buf,G_buf,B_buf})
);


reg     rdcnt_buf = 1'b0;
reg [7:0] nHS_cnt = 8'd0;
reg [9:0] vcnt    = 10'd1;

//wire CSen_lineend = ((rdhcnt + 2'b11) > (line_width[rdline] - {3'b000,`nHS_WIDTH}));
wire CSen_lineend = ((rdhcnt + 2'b11) > (line_width[rdline] - nHS_WIDTH));

wire    [1:0] SL_str = vinfo_dbl[3:2];
wire nENABLE_linedbl = vinfo_dbl[4] | ~rdrun[1];

wire pal_mode = vinfo_dbl[1];
wire n64_480i = vinfo_dbl[0];

wire [9:0] num_of_lines = pal_mode ? (n64_480i ? `LINES_PAL_576I_DBL  : `LINES_PAL_288P_DBL) :
                                     (n64_480i ? `LINES_NTSC_480I_DBL : `LINES_NTSC_240P_DBL);

wire v_nblank = (vcnt < `nVS_WIDTH + nVS_BP) || (vcnt > num_of_lines - nVS_FP);


always @(posedge CLK_out) begin

  if (rdcnt_buf ^ rdcnt) begin
    S_o[0] <= 1'b0;
    S_o[1] <= 1'b0;

//    nHS_cnt <= `nHS_WIDTH;
    nHS_cnt <= nHS_WIDTH;

    if (^newFrame) begin
      vcnt <= 10'd1;
      S_o[3]   <= 1'b0;
      newFrame[1] <= newFrame[0];
    end else begin
      if (vcnt == `nVS_WIDTH)
        S_o[3] <= 1'b1;
      vcnt <= vcnt + 1'b1;
    end
  end else begin
    if (|nHS_cnt) begin
      nHS_cnt <= nHS_cnt - 1'b1;
    end else begin
      S_o[1] <= 1'b1;
      if (S_o[3])
        S_o[0] <= 1'b1;
    end
    
    if (CSen_lineend) begin
      S_o[0] <= 1'b1;
    end
  end

  if (v_nblank)
    S_o[2] <= 1'b0;
  else
    S_o[2] <= rden[2];

    rdcnt_buf <= rdcnt;

    if (rden[2]) begin
      if (rdcnt) begin
        case (SL_str)
          2'b11: begin
            R_o <= {R_buf,1'b0};
            G_o <= {G_buf,1'b0};
            B_o <= {B_buf,1'b0};
          end
          2'b10: begin
            R_o <= {1'b0 ,R_buf[color_width_i-1:0]} +
                   {2'b00,R_buf[color_width_i-1:1]};
            G_o <= {1'b0 ,G_buf[color_width_i-1:0]} +
                   {2'b00,G_buf[color_width_i-1:1]};
            B_o <= {1'b0 ,B_buf[color_width_i-1:0]} +
                   {2'b00,B_buf[color_width_i-1:1]};
          end
          2'b01: begin
            R_o <= {1'b0,R_buf[color_width_i-1:0]};
            G_o <= {1'b0,G_buf[color_width_i-1:0]};
            B_o <= {1'b0,B_buf[color_width_i-1:0]};
          end
          2'b00: begin
            R_o <= {color_width_o{1'b0}};
            G_o <= {color_width_o{1'b0}};
            B_o <= {color_width_o{1'b0}};
          end
        endcase
      end else begin
        R_o <= {R_buf,1'b0};
        G_o <= {G_buf,1'b0};
        B_o <= {B_buf,1'b0};
      end
    end else begin
      R_o <= {color_width_o{1'b0}};
      G_o <= {color_width_o{1'b0}};
      B_o <= {color_width_o{1'b0}};
    end

  if (nENABLE_linedbl) begin
    S_o <= vdata_i[`VDATA_I_SY_SLICE];
    R_o <= {R_i,1'b0};
    G_o <= {G_i,1'b0};
    B_o <= {B_i,1'b0};
  end
end


// post-assignment

assign vdata_o = {S_o,R_o,G_o,B_o};

endmodule 