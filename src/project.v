`default_nettype none

module tt_um_riyanlord2026_dev_ternary_158 (
    input  wire [7:0] ui_in,    // 8-bit Dedicated Inputs (Streaming Activation data)
    output wire [7:0] uo_out,   // 8-bit Dedicated Outputs (Row 0 & Row 1 Top Bits)
    input  wire [7:0] uio_in,   // Bidirectional Input Bus (Feeds packed weights)
    output wire [7:0] uio_out,  // Bidirectional Output Bus
    output wire [7:0] uio_oe,   // Bidirectional Pin Directions
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    wire alu_reset = !rst_n;
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // 1. Unified 8-bit to 32-bit Sign Extension
    wire [31:0] ext_act;
    assign ext_act = {{24{ui_in[7]}}, ui_in};

    // 2. Extract weights for Row 0 and Row 1 from the incoming pin streams
    // Each row reads 4 separate 1-bit binary weights to save pin space!
    // 1'b1 means Weight = +1, 1'b0 means Weight = -1
    wire w0 = uio_in[0]; wire w1 = uio_in[1]; wire w2 = uio_in[2]; wire w3 = uio_in[3];
    wire w4 = uio_in[4]; wire w5 = uio_in[5]; wire w6 = uio_in[6]; wire w7 = uio_in[7];

    // 3. Pipeline Wires connecting the array grid elements internally
    wire [31:0] r0_c0_to_c1, r0_c1_to_c2, r0_c2_to_c3, r0_final;
    wire [31:0] r1_c0_to_c1, r1_c1_to_c2, r1_c2_to_c3, r1_final;

    // 4. Connect the output pins to share the results:
    // Top 4 bits of uo_out display Row 0, bottom 4 bits display Row 1
    assign uo_out = {r0_final[31:28], r1_final[31:28]};

    // =====================================================================
    // MATRIX ROW 0 PIPELINE (4 Cells Chained)
    // =====================================================================
    Ternary_PE_Cell r0_p0 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w0), .accum_in(32'h0), .accum_out(r0_c0_to_c1));
    Ternary_PE_Cell r0_p1 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w1), .accum_in(r0_c0_to_c1), .accum_out(r0_c1_to_c2));
    Ternary_PE_Cell r0_p2 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w2), .accum_in(r0_c1_to_c2), .accum_out(r0_c2_to_c3));
    Ternary_PE_Cell r0_p3 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w3), .accum_in(r0_c2_to_c3), .accum_out(r0_final));

    // =====================================================================
    // MATRIX ROW 1 PIPELINE (4 Cells Chained)
    // =====================================================================
    Ternary_PE_Cell r1_p0 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w4), .accum_in(32'h0), .accum_out(r1_c0_to_c1));
    Ternary_PE_Cell r1_p1 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w5), .accum_in(r1_c0_to_c1), .accum_out(r1_c1_to_c2));
    Ternary_PE_Cell r1_p2 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w6), .accum_in(r1_c1_to_c2), .accum_out(r1_c2_to_c3));
    Ternary_PE_Cell r1_p3 (.clk(clk), .reset(alu_reset), .activation(ext_act), .weight_bit(w7), .accum_in(r1_c2_to_c3), .accum_out(r1_final));

endmodule

// =====================================================================
// CELL SUB-MODULE: OPTIMIZED FOR LARGE PARALLEL GRID STRIPS
// =====================================================================
module Ternary_PE_Cell (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] activation,
    input  wire        weight_bit,
    input  wire [31:0] accum_in,
    output reg  [31:0] accum_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            accum_out <= 32'h00000000;
        end else begin
            // 1'b1 acts as +1 Weight (Adds activation)
            // 1'b0 acts as -1 Weight (Subtracts activation)
            if (weight_bit == 1'b1) begin
                accum_out <= accum_in + activation;
            end else begin
                accum_out <= accum_in - activation;
            end
        end
    end
endmodule
