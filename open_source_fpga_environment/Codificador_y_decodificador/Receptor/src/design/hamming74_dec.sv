module hamming74_dec(
    input  wire i_h0,
    input  wire i_h1,
    input  wire i_h2,
    input  wire i_h3,
    input  wire i_h4,
    input  wire i_h5,
    input  wire i_h6,
    input  wire i_parity,
    output wire o_data0,
    output wire o_data1,
    output wire o_data2,
    output wire o_data3,
    output wire o_s1,
    output wire o_s2,
    output wire o_s4,
    output wire o_1bit_error,
    output wire o_2bit_error
);

wire s1, s2, s4;

assign s1 = i_h0 ^ i_h2 ^ i_h4 ^ i_h6;
assign s2 = i_h1 ^ i_h2 ^ i_h5 ^ i_h6;
assign s4 = i_h3 ^ i_h4 ^ i_h5 ^ i_h6;

assign o_s1 = s1;
assign o_s2 = s2;
assign o_s4 = s4;

wire s1n = ~s1;
wire s2n = ~s2;
wire s4n = ~s4;

wire parity_calc;
assign parity_calc = i_h0 ^ i_h1 ^ i_h2 ^ i_h3 ^ i_h4 ^ i_h5 ^ i_h6;

wire global_error;
assign global_error = i_parity ^ parity_calc;

wire syndrome_nonzero;
assign syndrome_nonzero = s1 | s2 | s4;

// SECDED 
assign o_1bit_error = global_error & syndrome_nonzero;
assign o_2bit_error = (~global_error) & syndrome_nonzero;

// bloquear síndrome en 2 errores
wire syn_valid;
assign syn_valid = syndrome_nonzero & global_error;

// Síndrome bloqueado cuando hay 2 errores
wire syn0, syn1, syn2, syn3, syn4, syn5, syn6;

assign syn0 = syn_valid & (s4n & s2n & s1);
assign syn1 = syn_valid & (s4n & s2  & s1n);
assign syn2 = syn_valid & (s4n & s2  & s1);
assign syn3 = syn_valid & (s4  & s2n & s1n);
assign syn4 = syn_valid & (s4  & s2n & s1);
assign syn5 = syn_valid & (s4  & s2  & s1n);
assign syn6 = syn_valid & (s4  & s2  & s1);

// Corrección SOLO si es error de 1 bit
wire corr_enable;
assign corr_enable = o_1bit_error;

wire c0, c1, c2, c3, c4, c5, c6;

assign c0 = (i_h0 & ~corr_enable) | ((i_h0 ^ syn0) & corr_enable);
assign c1 = (i_h1 & ~corr_enable) | ((i_h1 ^ syn1) & corr_enable);
assign c2 = (i_h2 & ~corr_enable) | ((i_h2 ^ syn2) & corr_enable);
assign c3 = (i_h3 & ~corr_enable) | ((i_h3 ^ syn3) & corr_enable);
assign c4 = (i_h4 & ~corr_enable) | ((i_h4 ^ syn4) & corr_enable);
assign c5 = (i_h5 & ~corr_enable) | ((i_h5 ^ syn5) & corr_enable);
assign c6 = (i_h6 & ~corr_enable) | ((i_h6 ^ syn6) & corr_enable);

// Datos corregidos
assign o_data0 = c2;
assign o_data1 = c4;
assign o_data2 = c5;
assign o_data3 = c6;

endmodule