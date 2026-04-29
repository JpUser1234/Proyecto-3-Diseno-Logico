module error_generator(
    input  wire i_h0,
    input  wire i_h1,
    input  wire i_h2,
    input  wire i_h3,
    input  wire i_h4,
    input  wire i_h5,
    input  wire i_h6,
    input  wire i_pos0,
    input  wire i_pos1,
    input  wire i_pos2,
    output wire o_h0,
    output wire o_h1,
    output wire o_h2,
    output wire o_h3,
    output wire o_h4,
    output wire o_h5,
    output wire o_h6
);

wire pos0n, pos1n, pos2n;
assign pos0n = ~i_pos0;
assign pos1n = ~i_pos1;
assign pos2n = ~i_pos2;

wire inv0, inv1, inv2, inv3, inv4, inv5, inv6;
assign inv0 = pos2n & pos1n & i_pos0;
assign inv1 = pos2n & i_pos1 & pos0n;
assign inv2 = pos2n & i_pos1 & i_pos0;
assign inv3 = i_pos2 & pos1n & pos0n;
assign inv4 = i_pos2 & pos1n & i_pos0;
assign inv5 = i_pos2 & i_pos1 & pos0n;
assign inv6 = i_pos2 & i_pos1 & i_pos0;

assign o_h0 = i_h0 ^ inv0;
assign o_h1 = i_h1 ^ inv1;
assign o_h2 = i_h2 ^ inv2;
assign o_h3 = i_h3 ^ inv3;
assign o_h4 = i_h4 ^ inv4;
assign o_h5 = i_h5 ^ inv5;
assign o_h6 = i_h6 ^ inv6;

endmodule