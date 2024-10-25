`timescale 1ns / 1ps


module uart_tx (
    input wire clk,                 // System clock
    input wire rst_n,               // Reset signal (active low)
    input wire baud_tick,           // Baud rate tick
    input wire [7:0] tx_data,       // Data to be transmitted
    input wire tx_start,            // Start transmission signal
    output reg tx,             // UART transmission line
    output reg tx_busy         // Indicates if transmission is ongoing
);

    reg [3:0] bit_idx;         // Bit index to track the bits in the frame (0-9: start bit, 8 data bits, stop bit)
    reg [9:0] shift_reg;       // Shift register to hold the full UART frame

    // UART transmitter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all signals to their default state
            tx <= 1'b1;          // Idle state of UART is high (line stays high when idle)
            tx_busy <= 0;        // Not busy when reset
            bit_idx <= 0;        // Reset bit index
            shift_reg <= 10'b1111111111;  // Clear shift register
        end else if (tx_start && !tx_busy) begin
            // Start transmission: Load data into shift register and set busy flag
            shift_reg <= {1'b1, tx_data, 1'b0};  // Create UART frame: stop bit, 8 data bits, start bit
            tx_busy <= 1;        // Set busy flag to indicate ongoing transmission
            bit_idx <= 0;        // Reset bit index to start from the beginning
        end else if (tx_busy && baud_tick) begin
            // Transmission in progress: Shift out bits on each baud tick
            tx <= shift_reg[0];  // Transmit the LSB of the shift register
            shift_reg <= shift_reg >> 1;  // Shift the register right to prepare the next bit
            bit_idx <= bit_idx + 1;       // Increment bit index

            // When all bits (start, 8 data bits, stop) are transmitted, complete the transmission
            if (bit_idx == 9) begin
                tx_busy <= 0;    // Clear busy flag after transmission is complete
                tx <= 1'b1;      // Set TX back to idle (high) after stop bit
            end
        end
    end

endmodule
