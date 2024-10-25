`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2024 01:23:46 AM
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx (
    input wire clk,                 // System clock
    input wire rst_n,               // Reset signal
    input wire baud_tick,           // Baud rate tick
    input wire rx,                  // UART receive line
    output reg [7:0] rx_data,  // Data received
    output reg rx_ready        // Data received flag
);


    reg [3:0] bit_idx;         // Bit index to track the bits in the frame
    reg [9:0] shift_reg;       // Shift register to assemble received data
    reg rx_active;             // Flag indicating if a frame is being received

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data <= 8'b0;
            rx_ready <= 0;
            rx_active <= 0;
            bit_idx <= 0;
            shift_reg <= 10'b1111111111;
        end else if (!rx_active && !rx) begin
            // Detect start bit (rx goes low)
            rx_active <= 1;
            bit_idx <= 0;
            rx_ready <= 0;
        end else if (rx_active && baud_tick) begin
            // Shift in the received bits
            shift_reg <= {rx, shift_reg[9:1]};
            bit_idx <= bit_idx + 1;
            if (bit_idx == 9) begin
                // End of frame
                rx_data <= shift_reg[8:1];  // Extract data bits
                rx_ready <= 1;
                rx_active <= 0;
            end
        end
    end
endmodule
