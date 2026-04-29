module led_display(
    input  wire i_data0,
    input  wire i_data1,
    input  wire i_data2,
    input  wire i_data3,
    output wire o_led0,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3
);

assign o_led0 = i_data0;
assign o_led1 = i_data1;
assign o_led2 = i_data2;
assign o_led3 = i_data3;

endmodule