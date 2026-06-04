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
wire [6:0]  quotient;
wire [4:0]  remainder;
wire        done;
wire [3:0]  digit_mux;
wire [3:0]  d0, d1, d2, d3;

// ── Conversión BCD→binario del dividendo (máximo 127) ────────────────────────
wire [6:0] dividend_bin =
    ({1'b0, num1[11:8]} * 7'd100) +
    ({1'b0, num1[7:4]}  * 7'd10)  +
    {3'b000, num1[3:0]};

// ── Conversión BCD→binario del divisor (máximo 31) ───────────────────────────
wire [4:0] divisor_bin =
    ({1'b0, num2[7:4]} * 5'd10) +
    {1'b0, num2[3:0]};

// ── Conversión binario→BCD del cociente (máximo 127) ─────────────────────────
// Tabla case completa — sin multiplicaciones ni restas para evitar
// el bug de síntesis de Gowin que ya encontramos con el residuo
reg [3:0] quot_cen_r, quot_dec_r, quot_uni_r;

always_comb begin
    case (quotient)
        7'd0:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd0; end
        7'd1:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd1; end
        7'd2:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd2; end
        7'd3:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd3; end
        7'd4:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd4; end
        7'd5:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd5; end
        7'd6:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd6; end
        7'd7:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd7; end
        7'd8:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd8; end
        7'd9:   begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd9; end
        7'd10:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd0; end
        7'd11:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd1; end
        7'd12:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd2; end
        7'd13:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd3; end
        7'd14:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd4; end
        7'd15:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd5; end
        7'd16:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd6; end
        7'd17:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd7; end
        7'd18:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd8; end
        7'd19:  begin quot_cen_r=4'd0; quot_dec_r=4'd1; quot_uni_r=4'd9; end
        7'd20:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd0; end
        7'd21:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd1; end
        7'd22:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd2; end
        7'd23:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd3; end
        7'd24:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd4; end
        7'd25:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd5; end
        7'd26:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd6; end
        7'd27:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd7; end
        7'd28:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd8; end
        7'd29:  begin quot_cen_r=4'd0; quot_dec_r=4'd2; quot_uni_r=4'd9; end
        7'd30:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd0; end
        7'd31:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd1; end
        7'd32:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd2; end
        7'd33:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd3; end
        7'd34:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd4; end
        7'd35:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd5; end
        7'd36:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd6; end
        7'd37:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd7; end
        7'd38:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd8; end
        7'd39:  begin quot_cen_r=4'd0; quot_dec_r=4'd3; quot_uni_r=4'd9; end
        7'd40:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd0; end
        7'd41:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd1; end
        7'd42:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd2; end
        7'd43:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd3; end
        7'd44:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd4; end
        7'd45:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd5; end
        7'd46:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd6; end
        7'd47:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd7; end
        7'd48:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd8; end
        7'd49:  begin quot_cen_r=4'd0; quot_dec_r=4'd4; quot_uni_r=4'd9; end
        7'd50:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd0; end
        7'd51:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd1; end
        7'd52:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd2; end
        7'd53:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd3; end
        7'd54:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd4; end
        7'd55:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd5; end
        7'd56:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd6; end
        7'd57:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd7; end
        7'd58:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd8; end
        7'd59:  begin quot_cen_r=4'd0; quot_dec_r=4'd5; quot_uni_r=4'd9; end
        7'd60:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd0; end
        7'd61:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd1; end
        7'd62:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd2; end
        7'd63:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd3; end
        7'd64:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd4; end
        7'd65:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd5; end
        7'd66:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd6; end
        7'd67:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd7; end
        7'd68:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd8; end
        7'd69:  begin quot_cen_r=4'd0; quot_dec_r=4'd6; quot_uni_r=4'd9; end
        7'd70:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd0; end
        7'd71:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd1; end
        7'd72:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd2; end
        7'd73:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd3; end
        7'd74:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd4; end
        7'd75:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd5; end
        7'd76:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd6; end
        7'd77:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd7; end
        7'd78:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd8; end
        7'd79:  begin quot_cen_r=4'd0; quot_dec_r=4'd7; quot_uni_r=4'd9; end
        7'd80:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd0; end
        7'd81:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd1; end
        7'd82:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd2; end
        7'd83:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd3; end
        7'd84:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd4; end
        7'd85:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd5; end
        7'd86:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd6; end
        7'd87:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd7; end
        7'd88:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd8; end
        7'd89:  begin quot_cen_r=4'd0; quot_dec_r=4'd8; quot_uni_r=4'd9; end
        7'd90:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd0; end
        7'd91:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd1; end
        7'd92:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd2; end
        7'd93:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd3; end
        7'd94:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd4; end
        7'd95:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd5; end
        7'd96:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd6; end
        7'd97:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd7; end
        7'd98:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd8; end
        7'd99:  begin quot_cen_r=4'd0; quot_dec_r=4'd9; quot_uni_r=4'd9; end
        7'd100: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd0; end
        7'd101: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd1; end
        7'd102: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd2; end
        7'd103: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd3; end
        7'd104: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd4; end
        7'd105: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd5; end
        7'd106: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd6; end
        7'd107: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd7; end
        7'd108: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd8; end
        7'd109: begin quot_cen_r=4'd1; quot_dec_r=4'd0; quot_uni_r=4'd9; end
        7'd110: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd0; end
        7'd111: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd1; end
        7'd112: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd2; end
        7'd113: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd3; end
        7'd114: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd4; end
        7'd115: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd5; end
        7'd116: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd6; end
        7'd117: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd7; end
        7'd118: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd8; end
        7'd119: begin quot_cen_r=4'd1; quot_dec_r=4'd1; quot_uni_r=4'd9; end
        7'd120: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd0; end
        7'd121: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd1; end
        7'd122: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd2; end
        7'd123: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd3; end
        7'd124: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd4; end
        7'd125: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd5; end
        7'd126: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd6; end
        7'd127: begin quot_cen_r=4'd1; quot_dec_r=4'd2; quot_uni_r=4'd7; end
        default: begin quot_cen_r=4'd0; quot_dec_r=4'd0; quot_uni_r=4'd0; end
    endcase
end

wire [3:0] rem_dec_out;
wire [3:0] rem_uni_out;

// ── Debounce ──────────────────────────────────────────────────────────────────
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
    .divisor(divisor_bin),
    .valid(do_div),
    .quotient(quotient),
    .remainder(remainder),
    .rem_dec(rem_dec_out),
    .rem_uni(rem_uni_out),
    .done(done)
);

// ── Asignación de displays ────────────────────────────────────────────────────
assign d0 = (display_sel == 3'd2) ? result[3:0]  :
            (display_sel == 3'd1) ? num2[3:0]     :
            (display_sel == 3'd4) ? quot_uni_r     :
            (display_sel == 3'd5) ? rem_uni_out    :
            (display_sel == 3'd3) ? 4'd0           : num1[3:0];

assign d1 = (display_sel == 3'd2) ? result[7:4]  :
            (display_sel == 3'd1) ? num2[7:4]     :
            (display_sel == 3'd4) ? quot_dec_r     :
            (display_sel == 3'd5) ? rem_dec_out    :
            (display_sel == 3'd3) ? 4'd0           : num1[7:4];

assign d2 = (display_sel == 3'd4) ? quot_cen_r    :
            (display_sel == 3'd5) ? 4'd15          :
            (display_sel == 3'd2) ? result[11:8]   :
            (display_sel == 3'd1) ? num2[11:8]     :
            (display_sel == 3'd3) ? 4'd0           : num1[11:8];

assign d3 = (modo_div)            ? 4'd14          :  // "d" de division
            (display_sel == 3'd2) ? result[15:12]  : 4'd5;   // "S" de suma

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