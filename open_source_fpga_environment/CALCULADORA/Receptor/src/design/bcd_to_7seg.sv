module bcd_to_7seg (
    input  [3:0] digit,
    output reg [6:0] seg
);

// Segmentos: seg[6]=a, seg[5]=b, seg[4]=c, seg[3]=d, seg[2]=e, seg[1]=f, seg[0]=g
always @(*) begin
    case (digit)
        4'd0:  seg = 7'b1111110;  // 0
        4'd1:  seg = 7'b0110000;  // 1
        4'd2:  seg = 7'b1101101;  // 2
        4'd3:  seg = 7'b1111001;  // 3
        4'd4:  seg = 7'b0110011;  // 4
        4'd5:  seg = 7'b1011011;  // 5 — también sirve como "S"
        4'd6:  seg = 7'b1011111;  // 6
        4'd7:  seg = 7'b1110000;  // 7
        4'd8:  seg = 7'b1111111;  // 8
        4'd9:  seg = 7'b1111011;  // 9
        4'd14: seg = 7'b0111101;  // "d" minúscula: b,c,d,e,g encendidos
        4'd15: seg = 7'b0000000;  // apagado
        default: seg = 7'b0000000;
    endcase
end

endmodule