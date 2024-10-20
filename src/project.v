/*
 * Copyright (c) 2024 Dennis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none


module tt_um_uart_fifo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Signals for UART
  wire uart_rx;   // UART receive line
  wire uart_tx;   // UART transmit line
  wire [7:0] rx_data; // Data received from UART
  wire rx_ready;  // Signal indicating data is ready to be read
  wire tx_ready;  // Signal indicating UART is ready to transmit
  wire fifo_empty, fifo_full;
  
  // FIFO buffer
  reg [7:0] fifo_data_in;
  wire [7:0] fifo_data_out;
  reg fifo_write, fifo_read;
  
  // UART receiver instance
  uart_rx_module uart_rx_inst (
      .clk(clk),
      .rst_n(rst_n),
      .rx(uart_rx),
      .data_out(rx_data),
      .data_ready(rx_ready)
  );
  
  // UART transmitter instance
  uart_tx_module uart_tx_inst (
      .clk(clk),
      .rst_n(rst_n),
      .tx(uart_tx),
      .data_in(fifo_data_out),
      .tx_start(fifo_read),
      .tx_ready(tx_ready)
  );
  
  // FIFO buffer instance
  fifo_buffer fifo_inst (
      .clk(clk),
      .rst_n(rst_n),
      .data_in(fifo_data_in),
      .write_en(fifo_write),
      .read_en(fifo_read),
      .data_out(fifo_data_out),
      .empty(fifo_empty),
      .full(fifo_full)
  );

  // Control logic for FIFO and UART
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fifo_write <= 0;
        fifo_read <= 0;
        fifo_data_in <= 0;
    end else begin
        if (rx_ready && !fifo_full) begin
            fifo_data_in <= rx_data;
            fifo_write <= 1;
        end else begin
            fifo_write <= 0;
        end

        if (tx_ready && !fifo_empty) begin
            fifo_read <= 1;
        end else begin
            fifo_read <= 0;
        end
    end
  end

  // Assign outputs
  assign uart_rx = uio_in[0];   // UART RX on uio_in[0]
  assign uio_out[0] = uart_tx;  // UART TX on uio_out[0]
  assign uo_out = 8'h00;        // Not used, assigned to 0
  assign uio_oe = 8'h01;        // Enable only uio_out[0] for UART TX
  wire _unused = &{ena, 1'b0};  // Prevent unused signal warnings

endmodule
