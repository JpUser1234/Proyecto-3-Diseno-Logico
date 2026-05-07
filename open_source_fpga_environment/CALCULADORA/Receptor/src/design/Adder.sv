module adder (
    input  wire        clk,
    input  wire        rst,
    input  wire        do_sum,
    input  wire [11:0] num1,
    input  wire [11:0] num2,
    output reg  [15:0] result
);

function automatic [4:0] bcd_add;
    input [3:0] a;
    input [3:0] b;
    input       cin;
    reg [4:0] s;
    begin
        s = {1'b0, a} + {1'b0, b} + {4'b0, cin};
        case (s)
            5'd0:  bcd_add = 5'b0_0000;
            5'd1:  bcd_add = 5'b0_0001;
            5'd2:  bcd_add = 5'b0_0010;
            5'd3:  bcd_add = 5'b0_0011;
            5'd4:  bcd_add = 5'b0_0100;
            5'd5:  bcd_add = 5'b0_0101;
            5'd6:  bcd_add = 5'b0_0110;
            5'd7:  bcd_add = 5'b0_0111;
            5'd8:  bcd_add = 5'b0_1000;
            5'd9:  bcd_add = 5'b0_1001;
            5'd10: bcd_add = 5'b1_0000;
            5'd11: bcd_add = 5'b1_0001;
            5'd12: bcd_add = 5'b1_0010;
            5'd13: bcd_add = 5'b1_0011;
            5'd14: bcd_add = 5'b1_0100;
            5'd15: bcd_add = 5'b1_0101;
            5'd16: bcd_add = 5'b1_0110;
            5'd17: bcd_add = 5'b1_0111;
            5'd18: bcd_add = 5'b1_1000;
            5'd19: bcd_add = 5'b1_1001;
            default: bcd_add = 5'b0_0000;
        endcase
    end
endfunction

wire [4:0] res_u = bcd_add(num1[3:0],  num2[3:0],  1'b0);
wire [4:0] res_d = bcd_add(num1[7:4],  num2[7:4],  res_u[4]);
wire [4:0] res_c = bcd_add(num1[11:8], num2[11:8], res_d[4]);

always_ff @(posedge clk) begin
    if (!rst)
        result <= 0;
    else if (do_sum)
        result <= {{3'b0, res_c[4]}, res_c[3:0], res_d[3:0], res_u[3:0]};
end

endmodule