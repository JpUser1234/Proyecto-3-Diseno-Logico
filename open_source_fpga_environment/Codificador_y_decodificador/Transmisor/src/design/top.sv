module transmitter_top(
    input  wire i_data0,
    input  wire i_data1,
    input  wire i_data2,
    input  wire i_data3,
    input  wire i_pos0,
    input  wire i_pos1,
    input  wire i_pos2,
    output wire o_tx0,
    output wire o_tx1,
    output wire o_tx2,
    output wire o_tx3,
    output wire o_tx4,
    output wire o_tx5,
    output wire o_tx6,
    output wire o_parity,
    output wire o_seg_a,
    output wire o_seg_b,
    output wire o_seg_c,
    output wire o_seg_d,
    output wire o_seg_e,
    output wire o_seg_f,
    output wire o_seg_g
);

wire h0, h1, h2, h3, h4, h5, h6, parity;

hamming74_enc ENC(
    .i_data0 (i_data0),
    .i_data1 (i_data1),
    .i_data2 (i_data2),
    .i_data3 (i_data3),
    .o_h0    (h0),
    .o_h1    (h1),
    .o_h2    (h2),
    .o_h3    (h3),
    .o_h4    (h4),
    .o_h5    (h5),
    .o_h6    (h6),
    .o_parity(parity)
);

error_generator ERR(
    .i_h0    (h0),
    .i_h1    (h1),
    .i_h2    (h2),
    .i_h3    (h3),
    .i_h4    (h4),
    .i_h5    (h5),
    .i_h6    (h6),
    .i_pos0  (i_pos0),
    .i_pos1  (i_pos1),
    .i_pos2  (i_pos2),
    .o_h0    (o_tx0),
    .o_h1    (o_tx1),
    .o_h2    (o_tx2),
    .o_h3    (o_tx3),
    .o_h4    (o_tx4),
    .o_h5    (o_tx5),
    .o_h6    (o_tx6)
);
assign o_parity = parity;
bin_to_7seg SEG(
    .i_d0    (i_data0),
    .i_d1    (i_data1),
    .i_d2    (i_data2),
    .i_d3    (i_data3),
    .o_seg_a (o_seg_a),
    .o_seg_b (o_seg_b),
    .o_seg_c (o_seg_c),
    .o_seg_d (o_seg_d),
    .o_seg_e (o_seg_e),
    .o_seg_f (o_seg_f),
    .o_seg_g (o_seg_g)
);

endmodule