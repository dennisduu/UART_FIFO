`timescale 1ns / 1ps

module uart_tx_fifo (
    input wire clk,
    input wire rst_n,
    input wire baud_tick,
    input wire wr_en,               // Write enable signal for FIFO
    input wire [7:0] tx_data,       // Data input for transmission
    output reg tx,                  // UART transmit line
    output reg tx_busy,             // Indicates if transmission is ongoing
    output wire full,               // FIFO full flag - changed to wire
    output wire empty               // FIFO empty flag - changed to wire
);
    wire [7:0] fifo_data_out;       // Data output from FIFO
    reg rd_en;                      // Read enable signal for FIFO

    // Instantiate FIFO for TX
    fifo #(.DEPTH(8), .WIDTH(8)) tx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en && !full),     // Write data into FIFO when not full
        .rd_en(rd_en),              // Read data from FIFO when ready
        .din(tx_data),
        .dout(fifo_data_out),
        .full(full),                // Full signal is now a wire
        .empty(empty)               // Empty signal is now a wire
    );

    reg [3:0] bit_idx;              // Bit index for tracking transmission bits
    reg [9:0] shift_reg;            // Shift register for UART frame
    reg fifo_read_pending;          // Flag to indicate if a FIFO read is pending

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1;             // Idle state for UART line is high
            tx_busy <= 0;
            bit_idx <= 0;
            rd_en <= 0;
            fifo_read_pending <= 0;
        end else if (!tx_busy && !empty && !fifo_read_pending) begin
            // Start reading from FIFO
            rd_en <= 1;         
            fifo_read_pending <= 1;  // Mark that a read from FIFO is pending
        end else if (fifo_read_pending) begin
            // Load data from FIFO into shift register and start transmission
            shift_reg <= {1'b1, fifo_data_out, 1'b0}; // Stop bit, data, start bit
            tx_busy <= 1;
            rd_en <= 0;             // Clear read enable after reading FIFO
            fifo_read_pending <= 0;
            bit_idx <= 0;           // Reset bit index for transmission
        end else if (tx_busy && baud_tick) begin
            // Transmit bits on each baud tick
            tx <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_idx <= bit_idx + 1;
            if (bit_idx == 9) begin
                tx_busy <= 0;       // Transmission complete
                tx <= 1'b1;         // Set TX back to idle state (high)
            end
        end
    end
endmodule
