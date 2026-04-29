module bin_to_7seg(
    input  wire i_d0,
    input  wire i_d1,
    input  wire i_d2,
    input  wire i_d3,
    input  wire i_no_error,
    input  wire i_no_err_dash,
    output wire o_seg_a,
    output wire o_seg_b,
    output wire o_seg_c,
    output wire o_seg_d,
    output wire o_seg_e,
    output wire o_seg_f,
    output wire o_seg_g
);

wire d0n, d1n, d2n, d3n;
assign d0n = ~i_d0;
assign d1n = ~i_d1;
assign d2n = ~i_d2;
assign d3n = ~i_d3;

wire no_err_n;
assign no_err_n = ~i_no_error & ~i_no_err_dash;

assign o_seg_a = (i_no_error) | (no_err_n & ((d2n & d0n) | (d3n & i_d1) | (i_d2 & i_d1) |
                 (i_d3 & d0n) | (i_d3 & i_d2 & i_d1 & i_d0) |
                 (i_d3 & d2n & d1n) | (i_d2 & i_d0 & d3n)));

assign o_seg_b = no_err_n & ((d2n & d0n) | (d3n & d2n) | (d3n & d1n & d0n) |
                 (d3n & i_d1 & i_d0) | (i_d3 & d1n & i_d0));

assign o_seg_c = no_err_n & ((d3n & d1n) | (d3n & i_d0) | (d3n & i_d2) |
                 (d1n & i_d0) | (i_d3 & d2n));

assign o_seg_d = (i_no_error) | (no_err_n & ((i_d3 & d1n) | (i_d2 & d1n & i_d0) |
                 (i_d2 & i_d1 & d0n) | (d3n & d2n & d0n) |
                 (d2n & i_d1 & i_d0)));

assign o_seg_e = (i_no_error) | (no_err_n & ((d2n & d0n) | (i_d1 & d0n) |
                 (i_d3 & i_d2) | (i_d3 & i_d1)));

assign o_seg_f = (i_no_error) | (no_err_n & ((d1n & d0n) | (i_d3 & d2n) |
                 (i_d3 & i_d1) | (i_d2 & d0n) |
                 (d3n & i_d2 & d1n)));

assign o_seg_g = (i_no_error) | (i_no_err_dash) |
                 (no_err_n & (i_d1 | (d3n & i_d2) | (i_d3 & d2n) | (i_d3 & i_d0)));

endmodule