`default_nettype none

module tt_um_riyanlord2026-dev_ternary_158 (
    input  wire [7:0] ui_in,    // Dedicated inputs (Your 8-bit Activations)
    output wire [7:0] uo_out,   // Dedicated outputs (Top 8 bits of Accumulator)
    input  wire [7:0] uio_in,   // IO Pads: Input path (uio_in[1:0] is Weight)
    output wire [7:0] uio_out,  // IO Pads: Output path
    output wire [7:0] uio_oe,   // IO Pads: Enable path
    input  wire       ena,      // Always 1 when design is powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset from factory
);

    // 1. Convert active-low reset to active-high internal reset
    wire alu_reset;
    assign alu_reset = !rst_n;

    // 2. Correct Sign Extension targeting the 7th bit of ui_in explicitly
    wire [31:0] ext_act;
    assign ext_act = {{24{ui_in[7]}}, ui_in};

    // 3. Main 32-bit internal math register
    reg [31:0] accum_out;

    // 4. Pipe out the top 8 bits to the physical output pin bus
    assign uo_out = accum_out[31:24];

    // Safe default values for unused bidirectional pins
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // 5. Multiplexer-driven math logic block
    always @(posedge clk or posedge alu_reset) begin
        if (alu_reset) begin
            accum_out <= 32'h00000000;
        end else begin
            if (uio_in[1:0] == 2'b01) begin
                accum_out <= accum_out + ext_act; // Weight = +1
            end else if (uio_in[1:0] == 2'b10) begin
                accum_out <= accum_out - ext_act; // Weight = -1
            end else begin
                accum_out <= accum_out;           // Weight = 0 (Do nothing)
            end
        end
    end

endmodule
