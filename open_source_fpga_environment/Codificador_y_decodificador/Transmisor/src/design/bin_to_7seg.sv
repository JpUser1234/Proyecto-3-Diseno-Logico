module bin_to_7seg(
    input  wire i_d0,
    input  wire i_d1,
    input  wire i_d2,
    input  wire i_d3,
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

assign o_seg_a = ((d2n & d0n) | (d3n & i_d1) | (i_d2 & i_d1) |
                 (i_d3 & d0n) |
                 (i_d3 & d2n & d1n) |
                 (d3n & i_d2 & d1n & i_d0));

assign o_seg_b = ((d2n & d0n) | (d3n & d2n) | (d3n & d1n & d0n) |
                 (d3n & i_d1 & i_d0) | (i_d3 & d1n & i_d0));

assign o_seg_c = ((d3n & d1n) | (d3n & i_d0) | (d3n & i_d2) |
                 (d1n & i_d0) | (i_d3 & d2n));

assign o_seg_d = ((i_d3 & d1n) | (i_d2 & d1n & i_d0) | (i_d2 & i_d1 & d0n) |
                 (d3n & d2n & d0n) | (d2n & i_d1 & i_d0));

assign o_seg_e = ((d2n & d0n) | (i_d1 & d0n) | (i_d3 & i_d2) |
                 (i_d3 & i_d1));

assign o_seg_f = ((d1n & d0n) | (i_d3 & d2n) | (i_d3 & i_d1) |
                 (i_d2 & d0n) | (d3n & i_d2 & d1n));

assign o_seg_g = ((i_d1) | (d3n & i_d2) | (i_d3 & d2n) | (i_d3 & i_d0));

endmodule

