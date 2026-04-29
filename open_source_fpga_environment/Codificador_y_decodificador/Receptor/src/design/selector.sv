module selector(
    input  wire i_data0,
    input  wire i_data1,
    input  wire i_data2,
    input  wire i_data3,
    input  wire i_pos0,
    input  wire i_pos1,
    input  wire i_pos2,
    input  wire i_ctrl,
    output wire o_out0,
    output wire o_out1,
    output wire o_out2,
    output wire o_out3
);

wire ctrln;
assign ctrln = ~i_ctrl;

assign o_out0 = (i_ctrl & i_pos0) | (ctrln & i_data0);
assign o_out1 = (i_ctrl & i_pos1) | (ctrln & i_data1);
assign o_out2 = (i_ctrl & i_pos2) | (ctrln & i_data2);
assign o_out3 = (i_ctrl & 1'b0)   | (ctrln & i_data3);

endmodule