module display_mux (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  digit0,
    input  wire [3:0]  digit1,
    input  wire [3:0]  digit2,
    input  wire [3:0]  digit3,
    output reg  [3:0]  anode,
    output reg  [3:0]  digit_out
);

localparam MAX_COUNT = 27_000;
reg [14:0] counter;
reg [1:0]  sel;

always_ff @(posedge clk) begin
    if (rst) begin
        counter   <= 0;
        sel       <= 0;
        anode     <= 4'b0001;
        digit_out <= 4'd0;
    end else begin
        if (counter == MAX_COUNT - 1) begin
            counter <= 0;
            if (sel == 2'd3)
                sel <= 0;
            else
                sel <= sel + 1;
        end else begin
            counter <= counter + 1;
        end

        case (sel)
            2'd0: begin anode <= 4'b0001; digit_out <= digit0; end
            2'd1: begin anode <= 4'b0010; digit_out <= digit1; end
            2'd2: begin anode <= 4'b0100; digit_out <= digit2; end
            2'd3: begin anode <= 4'b1000; digit_out <= digit3; end
        endcase
    end
end

endmodule