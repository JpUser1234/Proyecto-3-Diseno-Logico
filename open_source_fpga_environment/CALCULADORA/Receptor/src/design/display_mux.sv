module display_mux (
    input wire clk,
    input wire rst,
    input wire [3:0] digit0,
    input wire [3:0] digit1,
    input wire [3:0] digit2,
    input wire [3:0] digit3,
    output reg [3:0] anode,
    output reg [3:0] digit_out
);

localparam MAX_COUNT = 27_000;

reg [14:0] counter;
reg [1:0]  sel;

// Lógica combinacional pura para anode y digit
wire [3:0] next_anode;
wire [3:0] next_digit;

assign next_anode = (sel == 2'd0) ? 4'b0001 :
                    (sel == 2'd1) ? 4'b0010 :
                    (sel == 2'd2) ? 4'b0100 : 4'b1000;

assign next_digit = (sel == 2'd0) ? digit0 :
                    (sel == 2'd1) ? digit1 :
                    (sel == 2'd2) ? digit2 : digit3;

always_ff @(posedge clk) begin
    if (!rst) begin
        counter   <= 0;
        sel       <= 0;
        anode     <= 4'b0001;
        digit_out <= 4'd0;
    end else begin
        anode     <= next_anode;
        digit_out <= next_digit;

        if (counter == MAX_COUNT - 1) begin
            counter <= 0;
            sel <= (sel == 2'd3) ? 0 : sel + 1;
        end else begin
            counter <= counter + 1;
        end
    end
end

endmodule