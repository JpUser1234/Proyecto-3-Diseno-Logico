module receiver_top(
    input  wire i_h0,
    input  wire i_h1,
    input  wire i_h2,
    input  wire i_h3,
    input  wire i_h4,
    input  wire i_h5,
    input  wire i_h6,
    input  wire i_parity,
    input  wire i_ctrl,
    output wire o_led0,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_seg_a,
    output wire o_seg_b,
    output wire o_seg_c,
    output wire o_seg_d,
    output wire o_seg_e,
    output wire o_seg_f,
    output wire o_seg_g
);

wire data0, data1, data2, data3;
wire pos0, pos1, pos2;
wire out0, out1, out2, out3;
wire one_bit_error, two_bit_error;

wire no_error_flag;
wire no_error_dash;
assign no_error_flag = two_bit_error;
assign no_error_dash = ~one_bit_error & ~two_bit_error & i_ctrl;

hamming74_dec DEC(
    .i_h0         (i_h0),
    .i_h1         (i_h1),
    .i_h2         (i_h2),
    .i_h3         (i_h3),
    .i_h4         (i_h4),
    .i_h5         (i_h5),
    .i_h6         (i_h6),
    .i_parity     (i_parity),
    .o_data0      (data0),
    .o_data1      (data1),
    .o_data2      (data2),
    .o_data3      (data3),
    .o_s1         (pos0),
    .o_s2         (pos1),
    .o_s4         (pos2),
    .o_1bit_error (one_bit_error),
    .o_2bit_error (two_bit_error)
);
wire safe0, safe1, safe2, safe3;

assign safe0 = data0 & ~two_bit_error;
assign safe1 = data1 & ~two_bit_error;
assign safe2 = data2 & ~two_bit_error;
assign safe3 = data3 & ~two_bit_error;
led_display LEDS(
    .i_data0 (safe0),
    .i_data1 (safe1),
    .i_data2 (safe2),
    .i_data3 (safe3),
    .o_led0  (o_led0),
    .o_led1  (o_led1),
    .o_led2  (o_led2),
    .o_led3  (o_led3)
);

selector SEL(
    .i_data0 (safe0),
    .i_data1 (safe1),
    .i_data2 (safe2),
    .i_data3 (safe3),
    .i_pos0  (pos0),
    .i_pos1  (pos1),
    .i_pos2  (pos2),
    .i_ctrl  (i_ctrl),
    .o_out0  (out0),
    .o_out1  (out1),
    .o_out2  (out2),
    .o_out3  (out3)
);

bin_to_7seg SEG(
    .i_d0    (out0),
    .i_d1    (out1),
    .i_d2    (out2),
    .i_d3    (out3),
    .i_no_error   (no_error_flag),
    .i_no_err_dash(no_error_dash),
    .o_seg_a (o_seg_a),
    .o_seg_b (o_seg_b),
    .o_seg_c (o_seg_c),
    .o_seg_d (o_seg_d),
    .o_seg_e (o_seg_e),
    .o_seg_f (o_seg_f),
    .o_seg_g (o_seg_g)
);

endmodule