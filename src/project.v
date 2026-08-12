`default_nettype none

module tt_um_riyanlord2026_dev_ternary_158 (
    input  wire [7:0] ui_in,    // Dedicated inputs (Your 8-bit Activations)
    output wire [7:0] uo_out,   // Dedicated outputs (Top 8 bits of Cell 1 Accumulator)
    input  wire [7:0] uio_in,   // IO Pads: Input path (uio_in[1:0] = W0, uio_in[3:2] = W1)
    output wire [7:0] uio_out,  // IO Pads: Output path
    output wire [7:0] uio_oe,   // IO Pads: Enable path
    input  wire       ena,      // Always 1 when design is powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset from factory
);

    // 1. Invert the factory active-low reset
    wire alu_reset;
    assign alu_reset = !rst_n;

    // 2. Perform Sign Extension on the shared 8-bit input bus
    wire [31:0] ext_act;
    assign ext_act = {{24{ui_in[7]}}, ui_in};

    // 3. Extract two separate 2-bit weights from your bidirectional bus pins
    wire [1:0] weight_cell0 = uio_in[1:0];
    wire [1:0] weight_cell1 = uio_in[3:2];

    // 4. Internal 32-bit accumulation wire linking Cell 0 straight to Cell 1
    wire [31:0] cell0_to_cell1;
    wire [31:0] final_accum_out;

    // Safe default values for unused bidirectional channels
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // 5. Pipe out the top 8 bits of the second cell's final calculation result
    assign uo_out = final_accum_out[31:24];

    // -----------------------------------------------------------------
    // CELL 0: Processes the baseline math and passes tally forward
    // -----------------------------------------------------------------
    Ternary_PE_Cell core_cell0 (
        .clk(clk),
        .reset(alu_reset),
        .activation(ext_act),
        .weight(weight_cell0),
        .accum_in(32'h00000000), // Ground the input baseline to zero
        .accum_out(cell0_to_cell1)
    );

    // -----------------------------------------------------------------
    // CELL 1: Grabs Cell 0's answer, computes layer 2 math, outputs total
    // -----------------------------------------------------------------
    Ternary_PE_Cell core_cell1 (
        .clk(clk),
        .reset(alu_reset),
        .activation(ext_act),
        .weight(weight_cell1),
        .accum_in(cell0_to_cell1), // Connects straight to cell 0's output pipeline
        .accum_out(final_accum_out)
    );

endmodule

// =====================================================================
// HOUSING SUB-MODULE: YOUR CORE VERIFIED TERNARY CELL UNIT
// =====================================================================
module Ternary_PE_Cell (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] activation,
    input  wire [1:0]  weight,
    input  wire [31:0] accum_in,
    output reg  [31:0] accum_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            accum_out <= 32'h00000000;
        end else begin
            if (weight == 2'b01) begin
                accum_out <= accum_in + activation; // Weight = +1
            end else if (weight == 2'b10) begin
                accum_out <= accum_in - activation; // Weight = -1
            end else begin
                accum_out <= accum_in;              // Weight = 0 (Pass through)
            end
        end
    end
endmodule
