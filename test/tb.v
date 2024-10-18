`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [3:0] a,b;
  wire [3:0] sum;
  wire carry_out;
  wire [2:0] uo_dum;  // 3 bits of unused outputs
  reg [7:0] uio_in;   // Unused in this case
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Replace tt_um_example with your module name:
  tt_um_koggestone_adder4 user_project (
      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  ({b,a}),    // Dedicated inputs
      .uo_out ({uo_dum,carry_out,sum}),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path (unused here)
      .uio_out(uio_out),  // IOs: Output path (unused here)
      .uio_oe (uio_oe),   // IOs: Enable path (unused here)
      .ena    (ena),      // Enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // Active-low reset
  );

endmodule
