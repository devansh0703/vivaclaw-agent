module top (
    input wire clk1,
    input wire clk2,
    input wire [7:0] data_in,
    output wire [7:0] data_out
);
    reg [7:0] sync_reg;
    reg [7:0] out_reg;

    // Deliberate unsafe CDC
    always @(posedge clk1) begin
        sync_reg <= data_in;
    end

    always @(posedge clk2) begin
        out_reg <= sync_reg;
    end

    assign data_out = out_reg;
endmodule
