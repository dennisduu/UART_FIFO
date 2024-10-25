`timescale 1ns / 1ps

module uart_rx_fifo (
    input wire clk,
    input wire rst_n,
    input wire baud_tick,
    input wire rx,                  // UART receive line
    output wire [7:0] data_out,     // Data output from FIFO (changed to wire)
    output wire empty               // FIFO empty flag (changed to wire)
);
    wire [7:0] rx_data;        // Data received from UART
    wire rx_ready;             // Data received flag
    wire fifo_full;            // FIFO full flag

    // Instantiate UART receiver
    uart_rx rx_module (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Instantiate FIFO for RX
    fifo #(.DEPTH(8), .WIDTH(8)) rx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(rx_ready && !fifo_full), // Write to FIFO when data received and FIFO not full
        .rd_en(/* External read enable signal */),
        .din(rx_data),
        .dout(data_out),                // Ensure data_out is wire type
        .full(fifo_full),
        .empty(empty)                   // Ensure empty is wire type
    );
endmodule
