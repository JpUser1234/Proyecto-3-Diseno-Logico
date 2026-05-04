module col_scanner (
    input  wire clk,
    input  wire rst,
    output reg  [3:0] col_scan
);

localparam MAX_COUNT = 10_000;
reg [14:0] counter;

always_ff @(posedge clk) begin
    if (!rst) begin
        counter  <= 0;
        col_scan <= 4'b0001;
    end else begin
        counter <= counter + 1;
        if (counter == MAX_COUNT-1) begin
            counter  <= 0;
            col_scan <= {col_scan[2:0], col_scan[3]};
        end
    end
end

endmodule