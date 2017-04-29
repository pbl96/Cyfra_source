// File: vga_example.v
// This is the top level design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_example (
  input wire clk,
  output reg vs,
  output reg hs,
  output reg [3:0] r,
  output reg [3:0] g,
  output reg [3:0] b,
  output wire pclk_mirror
  );

  // Converts 100 MHz clk into 40 MHz pclk.
  // This uses a vendor specific primitive
  // called MMCME2, for frequency synthesis.

  wire clk_in;
  wire locked;
  wire clk_fb;
  wire clk_ss;
  wire clk_out;
  wire pclk;
  (* KEEP = "TRUE" *) 
  (* ASYNC_REG = "TRUE" *)
  reg [7:0] safe_start = 0;

  IBUF clk_ibuf (.I(clk),.O(clk_in));

  MMCME2_BASE #(
    .CLKIN1_PERIOD(10.000),
    .CLKFBOUT_MULT_F(10.000),
    .CLKOUT0_DIVIDE_F(25.000))
  clk_in_mmcme2 (
    .CLKIN1(clk_in),
    .CLKOUT0(clk_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(clkfb),
    .CLKFBOUTB(),
    .CLKFBIN(clkfb),
    .LOCKED(locked),
    .PWRDWN(1'b0),
    .RST(1'b0)
  );

  BUFH clk_out_bufh (.I(clk_out),.O(clk_ss));
  always @(posedge clk_ss) safe_start<= {safe_start[6:0],locked};

  BUFGCE clk_out_bufgce (.I(clk_out),.CE(safe_start[7]),.O(pclk));

  // Mirrors pclk on a pin for use by the testbench;
  // not functionally required for this design to work.

  ODDR pclk_oddr (
    .Q(pclk_mirror),
    .C(pclk),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
  );
  
 wire [10:0] vcount, hcount;
   wire vsync, hsync;
   wire vblnk, hblnk;
 
   Timer my_Timer (
     .clk(pclk),
     .rst(1'b0),
     .vcount(vcount),
     .vsync(vsync),
     .vblnk(vblnk),
     .hcount(hcount),
     .hsync(hsync),
     .hblnk(hblnk)
   );
   
   wire [10:0] vcount_out, hcount_out;
   wire vsync_out, hsync_out;
   wire vblnk_out, hblnk_out;
   wire [11:0] rgb_out;
   
   
   Strzal my_Strzal (
 
 
     .hcount_in(hcount),
     .vcount_in(vcount),    
     .hsync_in(hsync),
     .hblnk_in(hblnk),
     .vsync_in(vsync),
     .vblnk_in(vblnk),    
     .pclk(pclk),
     .hcount_out(hcount_out),
     .vcount_out(vcount_out),
     .hsync_out(hsync_out),
     .hblnk_out(hblnk_out),    
     .vsync_out(vsync_out),
     .vblnk_out(vblnk_out),
     .rgb_out(rgb_out)
             
   );
   
   wire [10:0] vcount_out2, hcount_out2;
   wire vsync_out2, hsync_out2;
   wire vblnk_out2, hblnk_out2;
   wire [11:0] rgb_out2;
   
     draw_rect my_draw_rect (
 
       .hcount_in(hcount_out),
       .vcount_in(vcount_out),    
       .hsync_in(hsync_out),
       .hblnk_in(hblnk_out),
       .vsync_in(vsync_out),
       .vblnk_in(vblnk_out),    
       .pclk(pclk),
       .rgb_in(rgb_out),
       .hcount_out(hcount_out2),
       .vcount_out(vcount_out2),
       .hsync_out(hsync_out2),
       .hblnk_out(hblnk_out2),    
       .vsync_out(vsync_out2),
       .vblnk_out(vblnk_out2),
       .rgb_out(rgb_out2)
   );
   
 
   
   always @(posedge pclk) begin
       hs <= hsync_out2;
       vs <= vsync_out2;
       {r,g,b}<=rgb_out2;
  end
     
   
   
 
 endmodule

