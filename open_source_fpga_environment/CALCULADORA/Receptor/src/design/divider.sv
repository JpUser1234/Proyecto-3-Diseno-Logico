module divider (
    input  wire        clk,
    input  wire        rst,
    input  wire [5:0]  dividend,
    input  wire [3:0]  divisor,
    input  wire        valid,
    output reg  [5:0]  quotient,
    output reg  [3:0]  remainder,
    output reg  [3:0]  rem_dec,
    output reg  [3:0]  rem_uni,
    output reg         done
);

// ---------------------------------------------------------------------------
// Pipeline de 6 etapas. Cada etapa registra su residuo parcial y su bit de
// cociente, cortando el camino crítico a una sola resta por ciclo de reloj.
// La latencia total es de 6 ciclos desde que valid=1 hasta que done=1.
//
// En cada etapa se necesita saber el divisor y el bit correspondiente del
// dividendo, por lo que ambos se propagan como registros a lo largo del pipe.
// ---------------------------------------------------------------------------

// --- Etapa 0 → 1 (combinacional, entrada) ----------------------------------
wire [4:0] rsh0 = {4'b0000, dividend[5]};
wire [4:0] sub0 = rsh0 - {1'b0, divisor};
wire       q5   = ~sub0[4];
wire [4:0] r1w  = sub0[4] ? rsh0 : sub0;

// --- Registros de pipeline etapa 1 ----------------------------------------
reg [4:0] r1_r;
reg [3:0] div1, div1_bits; // divisor y bits restantes del dividendo
reg       q5_r;
reg       valid1;

always_ff @(posedge clk) begin
    if (!rst) begin
        r1_r <= 0; div1 <= 0; div1_bits <= 0; q5_r <= 0; valid1 <= 0;
    end else begin
        r1_r      <= r1w;
        div1      <= divisor;
        div1_bits <= dividend[4:1];   // bits 4..1 para las etapas 1..4
        q5_r      <= q5;
        valid1    <= valid;
    end
end

// --- Etapa 1 → 2 ----------------------------------------------------------
wire [4:0] rsh1 = {r1_r[3:0], div1_bits[3]};  // dividend[4]
wire [4:0] sub1 = rsh1 - {1'b0, div1};
wire       q4   = ~sub1[4];
wire [4:0] r2w  = sub1[4] ? rsh1 : sub1;

reg [4:0] r2_r;
reg [3:0] div2;
reg [2:0] div2_bits;  // bits 3..1
reg       q5_r2, q4_r;
reg       valid2;

always_ff @(posedge clk) begin
    if (!rst) begin
        r2_r <= 0; div2 <= 0; div2_bits <= 0;
        q5_r2 <= 0; q4_r <= 0; valid2 <= 0;
    end else begin
        r2_r      <= r2w;
        div2      <= div1;
        div2_bits <= div1_bits[2:0];  // bits 3..1
        q5_r2     <= q5_r;
        q4_r      <= q4;
        valid2    <= valid1;
    end
end

// --- Etapa 2 → 3 ----------------------------------------------------------
wire [4:0] rsh2 = {r2_r[3:0], div2_bits[2]};  // dividend[3]
wire [4:0] sub2 = rsh2 - {1'b0, div2};
wire       q3   = ~sub2[4];
wire [4:0] r3w  = sub2[4] ? rsh2 : sub2;

reg [4:0] r3_r;
reg [3:0] div3;
reg [1:0] div3_bits;  // bits 2..1
reg       q5_r3, q4_r3, q3_r;
reg       valid3;

always_ff @(posedge clk) begin
    if (!rst) begin
        r3_r <= 0; div3 <= 0; div3_bits <= 0;
        q5_r3 <= 0; q4_r3 <= 0; q3_r <= 0; valid3 <= 0;
    end else begin
        r3_r      <= r3w;
        div3      <= div2;
        div3_bits <= div2_bits[1:0];  // bits 2..1
        q5_r3     <= q5_r2;
        q4_r3     <= q4_r;
        q3_r      <= q3;
        valid3    <= valid2;
    end
end

// --- Etapa 3 → 4 ----------------------------------------------------------
wire [4:0] rsh3 = {r3_r[3:0], div3_bits[1]};  // dividend[2]
wire [4:0] sub3 = rsh3 - {1'b0, div3};
wire       q2   = ~sub3[4];
wire [4:0] r4w  = sub3[4] ? rsh3 : sub3;

reg [4:0] r4_r;
reg [3:0] div4;
reg       div4_bit;   // bit 1
reg       q5_r4, q4_r4, q3_r4, q2_r;
reg       valid4;

always_ff @(posedge clk) begin
    if (!rst) begin
        r4_r <= 0; div4 <= 0; div4_bit <= 0;
        q5_r4 <= 0; q4_r4 <= 0; q3_r4 <= 0; q2_r <= 0; valid4 <= 0;
    end else begin
        r4_r     <= r4w;
        div4     <= div3;
        div4_bit <= div3_bits[0];  // bit 1
        q5_r4    <= q5_r3;
        q4_r4    <= q4_r3;
        q3_r4    <= q3_r;
        q2_r     <= q2;
        valid4   <= valid3;
    end
end

// --- Etapa 4 → 5 ----------------------------------------------------------
wire [4:0] rsh4 = {r4_r[3:0], div4_bit};      // dividend[1]
wire [4:0] sub4 = rsh4 - {1'b0, div4};
wire       q1   = ~sub4[4];
wire [4:0] r5w  = sub4[4] ? rsh4 : sub4;

reg [4:0] r5_r;
reg [3:0] div5;
reg       q5_r5, q4_r5, q3_r5, q2_r5, q1_r;
reg       valid5;
reg       div5_bit;   // bit 0 del dividendo original — hay que propagarlo

// bit 0 del dividendo se propaga desde el inicio
reg div_bit0_r1, div_bit0_r2, div_bit0_r3, div_bit0_r4;

always_ff @(posedge clk) begin
    if (!rst) begin
        div_bit0_r1 <= 0; div_bit0_r2 <= 0;
        div_bit0_r3 <= 0; div_bit0_r4 <= 0;
    end else begin
        div_bit0_r1 <= dividend[0];
        div_bit0_r2 <= div_bit0_r1;
        div_bit0_r3 <= div_bit0_r2;
        div_bit0_r4 <= div_bit0_r3;
    end
end

always_ff @(posedge clk) begin
    if (!rst) begin
        r5_r <= 0; div5 <= 0; div5_bit <= 0;
        q5_r5 <= 0; q4_r5 <= 0; q3_r5 <= 0; q2_r5 <= 0; q1_r <= 0;
        valid5 <= 0;
    end else begin
        r5_r     <= r5w;
        div5     <= div4;
        div5_bit <= div_bit0_r4;   // dividend[0] propagado 4 ciclos
        q5_r5    <= q5_r4;
        q4_r5    <= q4_r4;
        q3_r5    <= q3_r4;
        q2_r5    <= q2_r;
        q1_r     <= q1;
        valid5   <= valid4;
    end
end

// --- Etapa 5 → salida (último ciclo) --------------------------------------
wire [4:0] rsh5 = {r5_r[3:0], div5_bit};      // dividend[0]
wire [4:0] sub5 = rsh5 - {1'b0, div5};
wire       q0   = ~sub5[4];
wire [4:0] r6w  = sub5[4] ? rsh5 : sub5;

wire [3:0] r_final   = r6w[3:0];
wire [5:0] q_final   = {q5_r5, q4_r5, q3_r5, q2_r5, q1_r, q0};

// Tabla case para la conversión BCD — sin aritmética ni comparaciones
// para evitar el bug de síntesis en Gowin con >= y restas
reg [3:0] rem_dec_comb;
reg [3:0] rem_uni_comb;

always_comb begin
    case (r_final)
        4'd0:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd0; end
        4'd1:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd1; end
        4'd2:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd2; end
        4'd3:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd3; end
        4'd4:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd4; end
        4'd5:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd5; end
        4'd6:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd6; end
        4'd7:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd7; end
        4'd8:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd8; end
        4'd9:  begin rem_dec_comb = 4'd0; rem_uni_comb = 4'd9; end
        4'd10: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd0; end
        4'd11: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd1; end
        4'd12: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd2; end
        4'd13: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd3; end
        4'd14: begin rem_dec_comb = 4'd1; rem_uni_comb = 4'd4; end
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
    end else if (valid5) begin
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