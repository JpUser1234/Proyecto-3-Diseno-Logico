module input_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire        key_valid,
    input  wire [3:0]  key_value,
    output reg  [11:0] num1,
    output reg  [11:0] num2,
    output reg         do_sum,
    output reg  [1:0]  display_sel
);

localparam ESPERA        = 2'd0;
localparam INGRESO_NUM1  = 2'd1;
localparam INGRESO_NUM2  = 2'd2;
localparam SUMA          = 2'd3;

localparam KEY_HASH = 4'd13;
localparam KEY_A    = 4'd10;
localparam KEY_STAR = 4'd14;

reg [1:0] state, next_state;

// ===== Estado =====
always @(posedge clk or negedge rst) begin
    if (!rst)
        state <= ESPERA;
    else
        state <= next_state;
end

// ===== Transiciones =====
always @(*) begin
    next_state = state;

    case (state)
        ESPERA:
            if (key_valid && key_value <= 9)
                next_state = INGRESO_NUM1;

        INGRESO_NUM1:
            if (key_valid && key_value == KEY_HASH)
                next_state = INGRESO_NUM2;

        INGRESO_NUM2:
            if (key_valid && key_value == KEY_A)
                next_state = SUMA;

        SUMA:
            if (key_valid && key_value == KEY_STAR)
                next_state = ESPERA;
    endcase
end

// ===== Lógica BCD =====
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        num1 <= 12'h000;
        num2 <= 12'h000;
        do_sum <= 0;
        display_sel <= 0;
    end else begin
        do_sum <= 0;

        case (state)

            ESPERA: begin
                display_sel <= 0;
                num1 <= 12'h000;
                num2 <= 12'h000;

                if (key_valid && key_value <= 9)
                    num1 <= {8'h00, key_value};
            end

            INGRESO_NUM1: begin
                display_sel <= 0;
                if (key_valid && key_value <= 9)
                    num1 <= {num1[7:0], key_value};
            end

            INGRESO_NUM2: begin
                display_sel <= 1;
                if (key_valid && key_value <= 9)
                    num2 <= {num2[7:0], key_value};

                if (next_state == SUMA)
                    do_sum <= 1;
            end

            SUMA: begin
                display_sel <= 2;
            end

        endcase
    end
end

endmodule