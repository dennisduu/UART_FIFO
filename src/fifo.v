`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2024 01:28:37 AM
// Design Name: 
// Module Name: fifo
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


module fifo #(
    parameter DEPTH = 8,       // FIFO depth
    parameter WIDTH = 8        // Data width
)(
    input clk,
    input rst_n,
    input wr_en,               // Write enable
    input rd_en,               // Read enable
    input [WIDTH-1:0] din,     // Data input
    output reg [WIDTH-1:0] dout, // Data output
    output reg full,           // FIFO full flag
    output reg empty           // FIFO empty flag
);

    reg [WIDTH-1:0] fifo_mem [0:DEPTH-1];  // FIFO memory array
    reg [2:0] rd_ptr;                      // Read pointer (3 bits for 8-depth FIFO)
    reg [2:0] wr_ptr;                      // Write pointer
    reg [2:0] fifo_cnt;                    // Counter to track the number of elements in the FIFO

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            full <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= din;       // Write data into FIFO
            wr_ptr <= (wr_ptr + 1) % DEPTH; // Update write pointer (circular buffer)
            fifo_cnt <= fifo_cnt + 1;      // Increase element count
        end

        // Update full flag
        full <= (fifo_cnt == DEPTH);
    end

    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            dout <= 0;
            empty <= 1;
        end else if (rd_en && !empty) begin
            dout <= fifo_mem[rd_ptr];      // Read data from FIFO
            rd_ptr <= (rd_ptr + 1) % DEPTH; // Update read pointer (circular buffer)
            fifo_cnt <= fifo_cnt - 1;      // Decrease element count
        end

        // Update empty flag
        empty <= (fifo_cnt == 0);
    end

endmodule
