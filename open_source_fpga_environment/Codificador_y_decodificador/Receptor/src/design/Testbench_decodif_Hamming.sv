`timescale 1ns/1ps
module tb_hamming74_dec();

    reg i_h0, i_h1, i_h2, i_h3, i_h4, i_h5, i_h6;
    reg i_parity;

    wire o_data0, o_data1, o_data2, o_data3;
    wire o_s1, o_s2, o_s4;
    wire o_1bit_error, o_2bit_error;

    hamming74_dec DEC0(
        .i_h0         (i_h0),
        .i_h1         (i_h1),
        .i_h2         (i_h2),
        .i_h3         (i_h3),
        .i_h4         (i_h4),
        .i_h5         (i_h5),
        .i_h6         (i_h6),
        .i_parity     (i_parity),
        .o_data0      (o_data0),
        .o_data1      (o_data1),
        .o_data2      (o_data2),
        .o_data3      (o_data3),
        .o_s1         (o_s1),
        .o_s2         (o_s2),
        .o_s4         (o_s4),
        .o_1bit_error (o_1bit_error),
        .o_2bit_error (o_2bit_error)
    );

    initial begin
        $display($time, " TEST START");
        $monitor($time, " i_h=%b%b%b%b%b%b%b parity=%b o_data=%b%b%b%b 1bit=%b 2bit=%b",
                 i_h6,i_h5,i_h4,i_h3,i_h2,i_h1,i_h0,
                 i_parity,
                 o_data3,o_data2,o_data1,o_data0,
                 o_1bit_error,o_2bit_error);

        #1; i_h6=0;i_h5=0;i_h4=0;i_h3=0;i_h2=0;i_h1=0;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=0;i_h4=0;i_h3=0;i_h2=1;i_h1=1;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=0;i_h4=1;i_h3=1;i_h2=0;i_h1=0;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=0;i_h4=1;i_h3=1;i_h2=1;i_h1=1;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=1;i_h4=0;i_h3=1;i_h2=0;i_h1=1;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=1;i_h4=0;i_h3=1;i_h2=1;i_h1=0;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=1;i_h4=1;i_h3=0;i_h2=0;i_h1=1;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=0;i_h5=1;i_h4=1;i_h3=0;i_h2=1;i_h1=0;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=0;i_h4=0;i_h3=1;i_h2=0;i_h1=1;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=0;i_h4=0;i_h3=1;i_h2=1;i_h1=0;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=0;i_h4=1;i_h3=0;i_h2=0;i_h1=1;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=0;i_h4=1;i_h3=0;i_h2=1;i_h1=0;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=1;i_h4=0;i_h3=0;i_h2=0;i_h1=0;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=1;i_h4=0;i_h3=0;i_h2=1;i_h1=1;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=1;i_h4=1;i_h3=1;i_h2=0;i_h1=0;i_h0=0;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;
        #1; i_h6=1;i_h5=1;i_h4=1;i_h3=1;i_h2=1;i_h1=1;i_h0=1;
            i_parity=i_h0^i_h1^i_h2^i_h3^i_h4^i_h5^i_h6;

        #1; $display($time, " 1bit error - bit 0");
            i_h6=0;i_h5=0;i_h4=0;i_h3=0;i_h2=0;i_h1=0;i_h0=1;
            i_parity=0;

        #1; $display($time, " 1bit error - bit 3");
            i_h6=0;i_h5=0;i_h4=0;i_h3=1;i_h2=0;i_h1=0;i_h0=0;
            i_parity=0;

        #1; $display($time, " 2bit error - bits 3 y 6");
            i_h6=1;i_h5=0;i_h4=0;i_h3=1;i_h2=0;i_h1=0;i_h0=0;
            i_parity=0;

        #1; $display($time, " sin error - decimal 0");
            i_h6=0;i_h5=0;i_h4=0;i_h3=0;i_h2=0;i_h1=0;i_h0=0;
            i_parity=0;

        #5; $display($time, " TEST STOP");
        $stop;
    end

endmodule