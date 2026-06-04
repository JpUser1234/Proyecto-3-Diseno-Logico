module divider (
    input  wire        clk,
    input  wire        rst,
    input  wire [6:0]  dividend,  // 7 bits: máximo 127
    input  wire [4:0]  divisor,   // 5 bits: máximo 31
    input  wire        valid,
    output reg  [6:0]  quotient,  // 7 bits: máximo 127
    output reg  [4:0]  remainder, // 5 bits: máximo 30
    output reg  [3:0]  rem_dec,
    output reg  [3:0]  rem_uni,
    output reg         done
);

// Pipeline de 7 etapas para dividendo de 7 bits.
// Cada etapa registra su residuo parcial (5 bits porque divisor es 5 bits)
// y propaga el divisor y los bits restantes del dividendo.

// Etapa 0 (combinacional)
wire [5:0] rsh0 = {5'b00000, dividend[6]};
wire [5:0] sub0 = rsh0 - {1'b0, divisor};
wire       q6   = ~sub0[5];
wire [5:0] r1w  = sub0[5] ? rsh0 : sub0;

// Registros etapa 1
reg [5:0] r1_r;
reg [4:0] div1;
reg [5:0] div1_bits; // dividend[5:0]
reg       q6_r;
reg       valid1;

always_ff @(posedge clk) begin
    if (!rst) begin
        r1_r <= 0; div1 <= 0; div1_bits <= 0; q6_r <= 0; valid1 <= 0;
    end else begin
        r1_r      <= r1w;
        div1      <= divisor;
        div1_bits <= dividend[5:0];
        q6_r      <= q6;
        valid1    <= valid;
    end
end

// Etapa 1
wire [5:0] rsh1 = {r1_r[4:0], div1_bits[5]};
wire [5:0] sub1 = rsh1 - {1'b0, div1};
wire       q5   = ~sub1[5];
wire [5:0] r2w  = sub1[5] ? rsh1 : sub1;

reg [5:0] r2_r;
reg [4:0] div2;
reg [4:0] div2_bits; // dividend[4:0]
reg       q6_r2, q5_r;
reg       valid2;

always_ff @(posedge clk) begin
    if (!rst) begin
        r2_r <= 0; div2 <= 0; div2_bits <= 0;
        q6_r2 <= 0; q5_r <= 0; valid2 <= 0;
    end else begin
        r2_r      <= r2w;
        div2      <= div1;
        div2_bits <= div1_bits[4:0];
        q6_r2     <= q6_r;
        q5_r      <= q5;
        valid2    <= valid1;
    end
end

// Etapa 2
wire [5:0] rsh2 = {r2_r[4:0], div2_bits[4]};
wire [5:0] sub2 = rsh2 - {1'b0, div2};
wire       q4   = ~sub2[5];
wire [5:0] r3w  = sub2[5] ? rsh2 : sub2;

reg [5:0] r3_r;
reg [4:0] div3;
reg [3:0] div3_bits; // dividend[3:0]
reg       q6_r3, q5_r3, q4_r;
reg       valid3;

always_ff @(posedge clk) begin
    if (!rst) begin
        r3_r <= 0; div3 <= 0; div3_bits <= 0;
        q6_r3 <= 0; q5_r3 <= 0; q4_r <= 0; valid3 <= 0;
    end else begin
        r3_r      <= r3w;
        div3      <= div2;
        div3_bits <= div2_bits[3:0];
        q6_r3     <= q6_r2;
        q5_r3     <= q5_r;
        q4_r      <= q4;
        valid3    <= valid2;
    end
end

// Etapa 3
wire [5:0] rsh3 = {r3_r[4:0], div3_bits[3]};
wire [5:0] sub3 = rsh3 - {1'b0, div3};
wire       q3   = ~sub3[5];
wire [5:0] r4w  = sub3[5] ? rsh3 : sub3;

reg [5:0] r4_r;
reg [4:0] div4;
reg [2:0] div4_bits; // dividend[2:0]
reg       q6_r4, q5_r4, q4_r4, q3_r;
reg       valid4;

always_ff @(posedge clk) begin
    if (!rst) begin
        r4_r <= 0; div4 <= 0; div4_bits <= 0;
        q6_r4 <= 0; q5_r4 <= 0; q4_r4 <= 0; q3_r <= 0; valid4 <= 0;
    end else begin
        r4_r      <= r4w;
        div4      <= div3;
        div4_bits <= div3_bits[2:0];
        q6_r4     <= q6_r3;
        q5_r4     <= q5_r3;
        q4_r4     <= q4_r;
        q3_r      <= q3;
        valid4    <= valid3;
    end
end

// Etapa 4
wire [5:0] rsh4 = {r4_r[4:0], div4_bits[2]};
wire [5:0] sub4 = rsh4 - {1'b0, div4};
wire       q2   = ~sub4[5];
wire [5:0] r5w  = sub4[5] ? rsh4 : sub4;

reg [5:0] r5_r;
reg [4:0] div5;
reg [1:0] div5_bits; // dividend[1:0]
reg       q6_r5, q5_r5, q4_r5, q3_r5, q2_r;
reg       valid5;

always_ff @(posedge clk) begin
    if (!rst) begin
        r5_r <= 0; div5 <= 0; div5_bits <= 0;
        q6_r5 <= 0; q5_r5 <= 0; q4_r5 <= 0; q3_r5 <= 0; q2_r <= 0; valid5 <= 0;
    end else begin
        r5_r      <= r5w;
        div5      <= div4;
        div5_bits <= div4_bits[1:0];
        q6_r5     <= q6_r4;
        q5_r5     <= q5_r4;
        q4_r5     <= q4_r4;
        q3_r5     <= q3_r;
        q2_r      <= q2;
        valid5    <= valid4;
    end
end

// Etapa 5
wire [5:0] rsh5 = {r5_r[4:0], div5_bits[1]};
wire [5:0] sub5 = rsh5 - {1'b0, div5};
wire       q1   = ~sub5[5];
wire [5:0] r6w  = sub5[5] ? rsh5 : sub5;

reg [5:0] r6_r;
reg [4:0] div6;
reg       div6_bit; // dividend[0]
reg       q6_r6, q5_r6, q4_r6, q3_r6, q2_r6, q1_r;
reg       valid6;

always_ff @(posedge clk) begin
    if (!rst) begin
        r6_r <= 0; div6 <= 0; div6_bit <= 0;
        q6_r6 <= 0; q5_r6 <= 0; q4_r6 <= 0;
        q3_r6 <= 0; q2_r6 <= 0; q1_r <= 0; valid6 <= 0;
    end else begin
        r6_r     <= r6w;
        div6     <= div5;
        div6_bit <= div5_bits[0];
        q6_r6    <= q6_r5;
        q5_r6    <= q5_r5;
        q4_r6    <= q4_r5;
        q3_r6    <= q3_r5;
        q2_r6    <= q2_r;
        q1_r     <= q1;
        valid6   <= valid5;
    end
end

// Etapa 6 — última, produce resultado final
wire [5:0] rsh6   = {r6_r[4:0], div6_bit};
wire [5:0] sub6   = rsh6 - {1'b0, div6};
wire       q0     = ~sub6[5];
wire [5:0] r7w    = sub6[5] ? rsh6 : sub6;

wire [4:0] r_final  = r7w[4:0];
wire [6:0] q_final  = {q6_r6, q5_r6, q4_r6, q3_r6, q2_r6, q1_r, q0};

// Tabla case completa para BCD del residuo (máximo 30)
reg [3:0] rem_dec_comb;
reg [3:0] rem_uni_comb;

always_comb begin
    case (r_final)
        5'd0:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd0; end
        5'd1:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd1; end
        5'd2:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd2; end
        5'd3:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd3; end
        5'd4:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd4; end
        5'd5:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd5; end
        5'd6:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd6; end
        5'd7:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd7; end
        5'd8:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd8; end
        5'd9:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd9; end
        5'd10: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd0; end
        5'd11: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd1; end
        5'd12: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd2; end
        5'd13: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd3; end
        5'd14: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd4; end
        5'd15: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd5; end
        5'd16: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd6; end
        5'd17: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd7; end
        5'd18: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd8; end
        5'd19: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd9; end
        5'd20: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd0; end
        5'd21: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd1; end
        5'd22: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd2; end
        5'd23: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd3; end
        5'd24: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd4; end
        5'd25: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd5; end
        5'd26: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd6; end
        5'd27: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd7; end
        5'd28: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd8; end
        5'd29: begin rem_dec_comb = 4'd2; rem_uni_comb = 4'd9; end
        5'd30: begin rem_dec_comb = 4'd3; rem_uni_comb = 4'd0; end
        default: begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd0; end
    endcase
end

always_ff @(posedge clk) begin
    if (!rst) begin
        quotient  <= 0;
        remainder <= 0;
        rem_dec   <= 0;
        rem_uni   <= 0;
        done      <= 0;
    end else if (valid6) begin
        quotient  <= q_final;
        remainder <= r_final;
        rem_dec   <= rem_dec_comb;
        rem_uni   <= rem_uni_comb;
        done      <= 1;
    end else begin
        done <= 0;
    end
end

endmodule