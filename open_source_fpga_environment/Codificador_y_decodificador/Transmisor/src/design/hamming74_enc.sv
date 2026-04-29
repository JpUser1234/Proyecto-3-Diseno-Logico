module hamming74_enc(
    input  wire i_data0,
    input  wire i_data1,
    input  wire i_data2,
    input  wire i_data3,
    output wire o_h0,
    output wire o_h1,
    output wire o_h2,
    output wire o_h3,
    output wire o_h4,
    output wire o_h5,
    output wire o_h6,
    output wire o_parity
);

wire p1, p2, p4;

assign p1 = i_data0 ^ i_data1 ^ i_data3;
assign p2 = i_data0 ^ i_data2 ^ i_data3;
assign p4 = i_data1 ^ i_data2 ^ i_data3;

assign o_h0 = p1;
assign o_h1 = p2;
assign o_h2 = i_data0;
assign o_h3 = p4;
assign o_h4 = i_data1;
assign o_h5 = i_data2;
assign o_h6 = i_data3;

assign o_parity = o_h0 ^ o_h1 ^ o_h2 ^ o_h3 ^ o_h4 ^ o_h5 ^ o_h6;

endmodule