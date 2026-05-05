module adder (
    input  wire        clk,
    input  wire        rst,
    input  wire        do_sum,
    input  wire [11:0] num1,
    input  wire [11:0] num2,
    output reg  [13:0] result
);

wire [9:0] num1_bin;
wire [9:0] num2_bin;

assign num1_bin = (num1[11:8] * 10'd100) +
                  (num1[7:4]  * 10'd10)  +
                   num1[3:0];

assign num2_bin = (num2[11:8] * 10'd100) +
                  (num2[7:4]  * 10'd10)  +
                   num2[3:0];

always_ff @(posedge clk) begin
    if (!rst)        // reset activo en bajo
        result <= 0;
    else if (do_sum)
        result <= num1_bin + num2_bin;
end

endmodule