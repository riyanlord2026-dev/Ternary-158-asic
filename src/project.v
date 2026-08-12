`default_nettype none

module tt_um_riyanlord2026_dev_ternary_row_158 (
    input  wire [7:0] ui_in,    // 8-bit Broadcast Activation Input
    output wire [7:0] uo_out,   // Final 8-bit pipeline output
    input  wire [7:0] uio_in,   // Inputs for packed weights
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    wire alu_reset = !rst_n;
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Extract four 2-bit weights from the 8-bit input buses
    // This lets us control 4 distinct cells at the exact same time
    wire [1:0] w0 = ui_in[1:0];   // We borrow top bits or IO bits for weights
    wire [1:0] w1 = ui_in[3:2];
    wire [1:0] w2 = ui_in[5:4];
    wire [1:0] w3 = ui_in[7:6];
    
    wire [7:0] activation_data = uio_in; // Activations feed through IO pins

    // Internal 32-bit accumulation wires linking cell to cell
    wire [31:0] accum0_to_1;
    wire [31:0] accum1_to_2;
    wire [31:0] accum2_to_3;
    wire [31:0] final_accum;

    // --- INSTANTIATE 4 TERNARY CELLS IN A ROW ---
    
    // Cell 0: Takes baseline input of 0, passes output to Cell 1
    Ternary_PE_Cell cell0 (
        .clk(clk), .reset(alu_reset),
        .activation(activation_data), .weight(w0),
        .accum_in(32'h00000000), .accum_out(accum0_to_1)
    );

    // Cell 1: Grabs Cell 0's answer, passes output to Cell 2
    Ternary_PE_Cell cell1 (
        .clk(clk), .reset(alu_reset),
        .activation(activation_data), .weight(w1),
        .accum_in(accum0_to_1), .accum_out(accum1_to_2)
    );

    // Cell 2: Grabs Cell 1's answer, passes output to Cell 3
    Ternary_PE_Cell cell2 (
        .clk(clk), .reset(alu_reset),
        .activation(activation_data), .weight(w2),
        .accum_in(accum1_to_2), .accum_out(accum2_to_3)
    );

    // Cell 3: Grabs Cell 2's answer, delivers final pipeline total
    Ternary_PE_Cell cell3 (
        .clk(clk), .reset(alu_reset),
        .activation(activation_data), .weight(w3),
        .accum_in(accum2_to_3), .accum_out(final_accum)
    );

    // Pipe out the top 8 bits of the final calculation result
    assign uo_out = final_accum[31:24];

endmodule

// =====================================================================
// YOUR CORE VERIFIED TERNARY CELL CONSTRUCT
// =====================================================================
module Ternary_PE_Cell (
    input clk, input reset, input [7:0] activation, input [1:0] weight, input [31:0] accum_in, output reg [31:0] accum_out
);
    wire [31:0] ext_act = {{24{activation[7]}}, activation};
    always @(posedge clk or posedge reset) begin
        if (reset) accum_out <= 32'h0;
        else begin
            if (weight == 2'b01)      accum_out <= accum_in + ext_act;
            else if (weight == 2'b10) accum_out <= accum_in - ext_act;
            else                      accum_out <= accum_in;
        end
    end
endmodule
