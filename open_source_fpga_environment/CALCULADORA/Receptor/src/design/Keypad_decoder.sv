module keypad_decoder (
    input wire clk,
    input wire rst,
    input wire [3:0] row,
    input wire [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid
);

// 27MHz * 0.2 segundos = 5,400,000 ciclos de bloqueo
localparam LOCKOUT = 5_400_000;

reg [22:0] lockout_cnt;
reg        locked;
reg [3:0]  row_prev;

always_ff @(posedge clk) begin
    if (!rst) begin
        row_prev    <= 0;
        key_valid   <= 0;
        key_value   <= 0;
        locked      <= 0;
        lockout_cnt <= 0;
    end else begin
        key_valid <= 0;
        row_prev  <= row;

        if (locked) begin
            if (lockout_cnt == LOCKOUT - 1) begin
                lockout_cnt <= 0;
                locked      <= 0;
            end else begin
                lockout_cnt <= lockout_cnt + 1;
            end
        end else begin
            // Flanco de subida de fila, no bloqueado
            if (row != 0 && row_prev == 0) begin
                locked <= 1;

                case ({row, col})
                    8'b0001_0001: begin key_value <= 4'd1;  key_valid <= 1; end
                    8'b0001_0010: begin key_value <= 4'd4;  key_valid <= 1; end
                    8'b0001_0100: begin key_value <= 4'd7;  key_valid <= 1; end
                    8'b0001_1000: begin key_value <= 4'd14; key_valid <= 1; end

                    8'b0010_0001: begin key_value <= 4'd2;  key_valid <= 1; end
                    8'b0010_0010: begin key_value <= 4'd5;  key_valid <= 1; end
                    8'b0010_0100: begin key_value <= 4'd8;  key_valid <= 1; end
                    8'b0010_1000: begin key_value <= 4'd0;  key_valid <= 1; end

                    8'b0100_0001: begin key_value <= 4'd3;  key_valid <= 1; end
                    8'b0100_0010: begin key_value <= 4'd6;  key_valid <= 1; end
                    8'b0100_0100: begin key_value <= 4'd9;  key_valid <= 1; end
                    8'b0100_1000: begin key_value <= 4'd13; key_valid <= 1; end

                    8'b1000_0001: begin key_value <= 4'd10; key_valid <= 1; end
                    8'b1000_0010: begin key_value <= 4'd11; key_valid <= 1; end
                    8'b1000_0100: begin key_value <= 4'd12; key_valid <= 1; end
                    8'b1000_1000: begin key_value <= 4'd15; key_valid <= 1; end

                    default: locked <= 0;
                endcase
            end
        end
    end
end

endmodule