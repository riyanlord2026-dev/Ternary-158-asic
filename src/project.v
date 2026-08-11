    // -----------------------------------------------------------------
    // WIRE ASSIGNMENTS: Mapping your ALU to the physical outer chip pins
    // -----------------------------------------------------------------
    
    // Invert the factory active-low reset (rst_n) to match your ALU active-high logic
    wire alu_reset = !rst_n;

    // Capture the 8 physical input pins for your 8-bit image pixels (activations)
    wire [7:0] alu_activation = ui_in;

    // Allocate the first two bidirectional pins to take your 2-bit weight input (-1, 0, +1)
    wire [1:0] alu_weight = uio_in[1:0];

    // Pipe out the top 8 bits of your 32-bit internal accumulation state to uo_out
    wire [31:0] alu_accum_out;
    assign uo_out = alu_accum_out[31:24];

    // Safe configuration for unused bidirectional lines
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // -----------------------------------------------------------------
    // INSTANTIATION: Injecting your Ternary Engine into the Silicon Wrapper
    // -----------------------------------------------------------------
    Ternary_PE_Cell my_ternary_core (
        .clk(clk),
        .reset(alu_reset),
        .activation(alu_activation),
        .weight(alu_weight),
        .accum_in(32'h00000000), // Hardwired baseline initialization
        .accum_out(alu_accum_out)
    );

endmodule

// =====================================================================
// YOUR VERIFIED TERNARY PROCESSING ELEMENT LOGIC
// =====================================================================
module Ternary_PE_Cell (
    clk, reset, activation, weight, accum_in, accum_out
);
    input         clk;
    input         reset;
    input  [7:0]  activation;
    input  [1:0]  weight;
    input  [31:0] accum_in;
    output [31:0] accum_out;

    wire         clk;
    wire         reset;
    wire [7:0]   activation;
    wire [1:0]   weight;
    wire [31:0]  accum_in;
    reg  [31:0]  accum_out;

    wire [31:0] ext_act;
    assign ext_act = {{24{activation}}, activation};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            accum_out <= 32'h00000000;
        end else begin
            case (weight)
                2'b01:   begin accum_out <= accum_in + ext_act; end
                2'b10:   begin accum_out <= accum_in - ext_act; end
                default: begin accum_out <= accum_in; end
            </case>
        end
    end
endmodule
