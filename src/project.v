`timescale 1ns / 1ps
`default_nettype none

module tt_um_uart_fifo (
    input  wire [7:0] ui_in,    // Dedicated inputs (data to transmit)
    output wire [7:0] uo_out,   // Dedicated outputs (TX and RX output)
    input  wire [7:0] uio_in,   // IOs: Input path (RX input)
    output wire [7:0] uio_out,  // IOs: Unused in this case
    output wire [7:0] uio_oe,   // IOs: Enable path (unused, all 0)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire baud_tick;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_ready;
    wire full, empty;
    reg tx_start;

    // Data input from external source (for FIFO and TX)
    wire [7:0] data_in = ui_in;

    // Instantiate baud rate generator
    baud_rate_generator baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // Instantiate TX FIFO module
    uart_tx_fifo tx_fifo_module (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .wr_en(tx_start),       // Write enable triggered by tx_start
        .tx_data(data_in),      // Data input to FIFO
        .tx(uo_out[0]),         // TX output to uo_out[0]
        .tx_busy(tx_busy),
        .full(full),
        .empty(empty)
    );

    // Instantiate UART receiver with FIFO
    uart_rx_fifo rx_fifo_module (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .rx(uio_in[0]),         // RX input from uio_in[0]
        .data_out(rx_data),     // Output from FIFO after reception
        .empty(empty)           // FIFO empty signal
    );

    // Control UART transmission
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_start <= 0;
        end else begin
            // Trigger FIFO write (TX)
            tx_start <= 1;
        end
    end

    // Output the received data
    reg [7:0] rx_output;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_output <= 8'b0;
        end else if (!empty) begin
            rx_output <= rx_data;  // Output the received data from RX FIFO
        end
    end

    // Assign the received data to uo_out[7:1]
    assign uo_out[7:1] = rx_output[6:0];

    // Disable uio_out and uio_oe (unused in this design)
    assign uio_out = 8'b00000000;
    assign uio_oe = 8'b00000000;

endmodule
