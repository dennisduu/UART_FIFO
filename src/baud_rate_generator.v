`timescale 1ns / 1ps

module baud_rate_generator (
    input clk,                 // System clock
    input rst_n,               // Reset signal, active low
    output reg baud_tick       // Baud rate tick signal
);
    parameter BAUD_DIV = 5208;  // Divisor for the baud rate
    reg [12:0] counter;         // 13-bit counter to generate baud rate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            baud_tick <= 0;
        end else if (counter == BAUD_DIV - 1) begin
            counter <= 0;
            baud_tick <= 1;     // Generate a baud tick
        end else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end
endmodule
