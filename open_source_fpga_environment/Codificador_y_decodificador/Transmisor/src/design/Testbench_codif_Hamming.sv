`timescale 1ns/1ps
module tb_hamming74_enc();

    reg i_data0;
    reg i_data1;
    reg i_data2;
    reg i_data3;

    wire o_h0;
    wire o_h1;
    wire o_h2;
    wire o_h3;
    wire o_h4;
    wire o_h5;
    wire o_h6;
    wire o_parity;

    integer success_count = 0;
    integer error_count   = 0;
    integer test_count    = 0;
    integer i             = 0;

    hamming74_enc ENC0(
        .i_data0 (i_data0),
        .i_data1 (i_data1),
        .i_data2 (i_data2),
        .i_data3 (i_data3),
        .o_h0    (o_h0),
        .o_h1    (o_h1),
        .o_h2    (o_h2),
        .o_h3    (o_h3),
        .o_h4    (o_h4),
        .o_h5    (o_h5),
        .o_h6    (o_h6),
        .o_parity(o_parity)
    );

    initial begin
        $display($time, " TEST START");
        i_data3=0; i_data2=0; i_data1=0; i_data0=0;
        #1;

        for (i=0; i<16; i=i+1) begin
            i_data0 = i[0];
            i_data1 = i[1];
            i_data2 = i[2];
            i_data3 = i[3];
            #1;
            compare_data(i[3:0], {o_h6, o_h5, o_h4, o_h3, o_h2, o_h1, o_h0});
        end

        #5;
        $display($time, " TEST RESULTS success_count = %0d, error_count = %0d, test_count = %0d",
                 success_count, error_count, test_count);
        $stop;
    end

    task compare_data(input [3:0] i_data, input [6:0] i_hamming74);
        begin : cmp_data
            reg [6:0] exp_hamming74;
            case(i_data)
                4'd0:  exp_hamming74 = 7'b000_0_0_00;
                4'd1:  exp_hamming74 = 7'b000_0_1_11;
                4'd2:  exp_hamming74 = 7'b001_1_0_01;
                4'd3:  exp_hamming74 = 7'b001_1_1_10;
                4'd4:  exp_hamming74 = 7'b010_1_0_10;
                4'd5:  exp_hamming74 = 7'b010_1_1_01;
                4'd6:  exp_hamming74 = 7'b011_0_0_11;
                4'd7:  exp_hamming74 = 7'b011_0_1_00;
                4'd8:  exp_hamming74 = 7'b100_1_0_11;
                4'd9:  exp_hamming74 = 7'b100_1_1_00;
                4'd10: exp_hamming74 = 7'b101_0_0_10;
                4'd11: exp_hamming74 = 7'b101_0_1_01;
                4'd12: exp_hamming74 = 7'b110_0_0_01;
                4'd13: exp_hamming74 = 7'b110_0_1_10;
                4'd14: exp_hamming74 = 7'b111_1_0_00;
                4'd15: exp_hamming74 = 7'b111_1_1_11;
            endcase

            if (i_hamming74 === exp_hamming74) begin
                $display($time, " SUCCESS \t i_data = %b, got = %b, expected = %b",
                         i_data, i_hamming74, exp_hamming74);
                success_count = success_count + 1;
            end else begin
                $display($time, " ERROR \t i_data = %b, got = %b, expected = %b",
                         i_data, i_hamming74, exp_hamming74);
                error_count = error_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

endmodule