`default_nettype none

module tt_um_riyanlord2026_dev_ternary_158 (
    input  wire [7:0] ui_in,    // Dedicated inputs (Your 8-bit Activations)
    output wire [7:0] uo_out,   // Dedicated outputs (Top 8 bits of Accumulator)
    input  wire [7:0] uio_in,   // IO Pads: Input path (uio_in[1:0] is Weight)
    output wire [7:0] uio_out,  // IO Pads: Output path
    output wire [7:0] uio_oe,   // IO Pads: Enable path
    input  wire       ena,      // Always 1 when design is powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset from factory
);

    wire alu_reset;
    assign alu_reset = !rst_n;

    // 1. Perform 8-bit Sign Extension to 16 bits (instead of 32)
    wire [15:0] ext_act;
    assign ext_act = {{8{ui_in[7]}}, ui_in};

    // 2. Scale internal math register to an optimized 16-bit width
    reg [15:0] accum_out;

    // 3. Pipe out the top 8 bits (bits 15:8) to the output pins
    assign uo_out = accum_out[15:8];

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    always @(posedge clk or posedge alu_reset) begin
        if (alu_reset) begin
            accum_out <= 16'h0000;
        end else begin
            if (uio_in[1:0] == 2'b01) begin
                accum_out <= accum_out + ext_act; // Weight = +1
            end else if (uio_in[1:0] == 2'b10) begin
                accum_out <= accum_out - ext_act; // Weight = -1
            end else begin
                accum_out <= accum_out;           // Weight = 0
            end
        end
    end

endmodule
