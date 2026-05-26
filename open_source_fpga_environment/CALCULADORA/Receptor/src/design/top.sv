module top (
    input wire clk,
    input wire rst,
    input wire [3:0] row,
    output wire [3:0] col,
    output wire [6:0] seg,
    output wire [3:0] anode
);

wire rst_n = rst;

wire [3:0] row_clean;
wire [3:0] col_scan;
wire [3:0] key_value;
wire key_valid;

wire [11:0] num1, num2;
wire do_sum, do_div;
wire [2:0]  display_sel;
wire modo_div;
wire [15:0] result;
wire [5:0]  quotient;
wire [3:0]  remainder;
wire        done;
wire [3:0]  digit_mux;
wire [3:0]  d0, d1, d2, d3;

// Conversión BCD a binario para el dividendo (máximo 63)
wire [5:0] dividend_bin = ({2'b00, num1[7:4]} * 6'd10) + {2'b00, num1[3:0]};

// Conversión BCD a binario para el divisor (máximo 15)
wire [4:0] divisor_bin = ({1'b0, num2[7:4]} * 5'd10) + {1'b0, num2[3:0]};

// Conversión binario a BCD del cociente (máximo 63)
wire [3:0] quot_dec = (quotient >= 6'd50) ? 4'd5 :
                      (quotient >= 6'd40) ? 4'd4 :
                      (quotient >= 6'd30) ? 4'd3 :
                      (quotient >= 6'd20) ? 4'd2 :
                      (quotient >= 6'd10) ? 4'd1 : 4'd0;
wire [5:0] quot_uni_full = quotient - (quot_dec * 6'd10);
wire [3:0] quot_uni = quot_uni_full[3:0];

// BUG FIX: se usan las salidas rem_dec y rem_uni del divider directamente.
// Antes se recalculaban en el top con registros propios (rem_dec_reg,
// rem_uni_reg) usando la señal done como habilitador. El problema es que
// done y remainder se registran en el mismo flanco dentro del divider, por
// lo que el always_ff del top que leía remainder cuando done=1 capturaba
// el valor ANTERIOR de remainder (el FF aún no había propagado su salida
// en ese flanco). Al mover la conversión BCD al interior del divider y
// registrarla junto con remainder en el mismo always_ff, ambas señales
// quedan perfectamente sincronizadas y el top solo necesita rutear los
// wires directamente al display.
wire [3:0] rem_dec_out;
wire [3:0] rem_uni_out;

// Debounce para las 4 filas
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
    .do_div(do_div),
    .display_sel(display_sel),
    .modo_div(modo_div)
);

adder ADDER (
    .clk(clk),
    .rst(rst_n),
    .do_sum(do_sum),
    .num1(num1),
    .num2(num2),
    .result(result)
);

divider DIVIDER (
    .clk(clk),
    .rst(rst_n),
    .dividend(dividend_bin),
    .divisor(divisor_bin[3:0]),
    .valid(do_div),
    .quotient(quotient),
    .remainder(remainder),
    .rem_dec(rem_dec_out),   // BUG FIX: salidas BCD del residuo ya registradas
    .rem_uni(rem_uni_out),   // BUG FIX: salidas BCD del residuo ya registradas
    .done(done)
);

assign d0 = (display_sel == 3'd2) ? result[3:0]  :
            (display_sel == 3'd1) ? num2[3:0]     :
            (display_sel == 3'd4) ? quot_uni       :
            (display_sel == 3'd5) ? rem_uni_out    :  // BUG FIX: antes rem_uni_reg
            (display_sel == 3'd3) ? 4'd0           : num1[3:0];

assign d1 = (display_sel == 3'd2) ? result[7:4]  :
            (display_sel == 3'd1) ? num2[7:4]     :
            (display_sel == 3'd4) ? quot_dec       :
            (display_sel == 3'd5) ? rem_dec_out    :  // BUG FIX: antes rem_dec_reg
            (display_sel == 3'd3) ? 4'd0           : num1[7:4];

assign d2 = (modo_div)            ? 4'd15          :
            (display_sel == 3'd2) ? result[11:8]   :
            (display_sel == 3'd1) ? num2[11:8]     : num1[11:8];

assign d3 = (modo_div)            ? 4'd15          :
            (display_sel == 3'd2) ? result[15:12]  : 4'd15;

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