`timescale 1ns/1ps

module divider_tb;

    reg        clk;
    reg        rst;
    reg  [6:0] dividend;
    reg  [4:0] divisor;
    reg        valid;
    wire [6:0] quotient;
    wire [4:0] remainder;
    wire [3:0] rem_dec;
    wire [3:0] rem_uni;
    wire       done;

    divider DUT (
        .clk      (clk),
        .rst      (rst),
        .dividend (dividend),
        .divisor  (divisor),
        .valid    (valid),
        .quotient (quotient),
        .remainder(remainder),
        .rem_dec  (rem_dec),
        .rem_uni  (rem_uni),
        .done     (done)
    );

    initial clk = 0;
    always #18 clk = ~clk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, divider_tb);
    end

    initial begin
        rst = 0; valid = 0; dividend = 0; divisor = 0;
        repeat(6) @(posedge clk);
        rst = 1;
        repeat(4) @(posedge clk);

        // Caso 1: 100 / 7 = cociente 14, residuo 2
        dividend = 7'd100; divisor = 5'd7; valid = 1;
        @(posedge clk);
        valid = 0;
        repeat(40) @(posedge clk);

        // Caso 2: 127 / 31 = cociente 4, residuo 3
        dividend = 7'd127; divisor = 5'd31; valid = 1;
        @(posedge clk);
        valid = 0;
        repeat(40) @(posedge clk);

        // Caso 3: 60 / 6 = cociente 10, residuo 0
        dividend = 7'd60; divisor = 5'd6; valid = 1;
        @(posedge clk);
        valid = 0;
        repeat(40) @(posedge clk);

        $finish;
    end

endmodule