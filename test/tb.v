`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file for waveform viewing
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #10;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in; // This will be the UART RX input
  wire [7:0] uo_out;
  wire [7:0] uio_out; // UART TX output
  wire [7:0] uio_oe; // Enable for the UART TX line
  
   supply1 VPWR;
   supply0 VGND;

  // Instantiate the UART + FIFO module
  tt_uart_fifo user_project (
      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path (UART RX)
      .uio_out(uio_out),  // IOs: Output path (UART TX)
      .uio_oe (uio_oe),   // IOs: Enable path
      .ena    (ena),      // Enable signal
      .clk    (clk),      // Clock
      .rst_n  (rst_n)     // Reset signal
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock
  end

  // Test process
  initial begin
    ena = 1'b1;
    rst_n = 1'b0;
    ui_in = 8'h00;
    uio_in = 8'h00;
    #10 rst_n = 1'b1; // Release reset after some time
  end

endmodule
