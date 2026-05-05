module top (
    input wire clk,
    input wire rst,
    input wire [3:0] row,
    output wire [3:0] col,
    output wire [6:0] seg,
    output wire [3:0] anode
);

wire rst_n;
assign rst_n = rst;

wire [3:0] row_clean;
wire [3:0] col_scan;
wire [3:0] key_value;
wire key_valid;

wire [11:0] num1, num2;
wire do_sum;
wire [1:0] display_sel;
wire [13:0] result;

wire [3:0] digit_mux;
wire [3:0] d0, d1, d2, d3;

genvar i;
generate
    for (i = 0; i < 4; i++) begin : deb_rows
        debounce DEB (
            .clk(clk),
            .rst(rst_n),
            .button_in(row[i]),
            .DB_out(row_clean[i])
        );
    end
endgenerate

col_scanner SCANNER (
    .clk(clk),
    .rst(rst_n),
    .col_scan(col_scan)
);

assign col = col_scan;

keypad_decoder DECODER (
    .clk(clk),
    .rst(rst_n),
    .row(row_clean),
    .col(col_scan),
    .key_value(key_value),
    .key_valid(key_valid)
);

input_fsm FSM (
    .clk(clk),
    .rst(rst_n),
    .key_valid(key_valid),
    .key_value(key_value),
    .num1(num1),
    .num2(num2),
    .do_sum(do_sum),
    .display_sel(display_sel)
);

adder ADDER (
    .clk(clk),
    .rst(rst_n),
    .do_sum(do_sum),
    .num1(num1),
    .num2(num2),
    .result(result)
);

wire [13:0] display_data;

assign display_data =
    (display_sel == 2'd0) ? {2'd0, num1} :
    (display_sel == 2'd1) ? {2'd0, num2} :
    result;

assign d0 = display_data[3:0];
assign d1 = display_data[7:4];
assign d2 = display_data[11:8];
assign d3 = display_data[13:12];

display_mux MUX (
    .clk(clk),
    .rst(rst_n),
    .digit0(d0),
    .digit1(d1),
    .digit2(d2),
    .digit3(d3),
    .anode(anode),
    .digit_out(digit_mux)
);

bcd_to_7seg SEG (
    .digit(digit_mux),
    .seg(seg)
);

endmodule