module debounce #(
    parameter N = 10  // 2^10 / 27MHz ≈ 0.04ms (más rápido para teclados)
)(
    input  wire clk,
    input  wire rst,        // activo en bajo (rst_n)
    input  wire button_in,
    output reg  DB_out
);

reg [N-1:0] q_reg;
reg [N-1:0] q_next;
reg DFF1, DFF2;

wire q_reset;
wire q_add;

assign q_reset = DFF1 ^ DFF2;
assign q_add   = ~q_reg[N-1];

always_comb begin
    case ({q_reset, q_add})
        2'b00:   q_next = q_reg;
        2'b01:   q_next = q_reg + 1;
        default: q_next = {N{1'b0}};
    endcase
end

always_ff @(posedge clk) begin
    if (!rst) begin
        DFF1  <= 0;
        DFF2  <= 0;
        q_reg <= 0;
    end else begin
        DFF1  <= button_in;
        DFF2  <= DFF1;
        q_reg <= q_next;
    end
end

always_ff @(posedge clk) begin
    if (!rst)
        DB_out <= 0;
    else if (q_reg[N-1])
        DB_out <= DFF2;
end

endmodule