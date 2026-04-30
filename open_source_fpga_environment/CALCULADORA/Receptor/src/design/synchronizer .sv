module synchronizer (
    input  wire clk,
    input  wire rst,
    input  wire async_in,   // señal externa asincrónica
    output reg  sync_out    // señal sincronizada
);

reg stage1;  // primer flip-flop D

always_ff @(posedge clk) begin
    if (rst) begin
        stage1   <= 0;
        sync_out <= 0;
    end else begin
        stage1   <= async_in;   // primer FF captura la señal
        sync_out <= stage1;     // segundo FF estabiliza
    end
end

endmodule