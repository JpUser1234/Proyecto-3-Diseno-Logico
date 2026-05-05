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

localparam KEY_HASH = 4'd13;
localparam KEY_A    = 4'd10;
localparam KEY_STAR = 4'd14;

typedef enum logic [1:0] {
    ESPERA,
    INGRESO_NUM1,
    INGRESO_NUM2,
    SUMA
} state_t;

state_t state, next_state;

always_ff @(posedge clk) begin
    if (!rst)
        state <= ESPERA;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        ESPERA:
            if (key_valid && key_value <= 9)
                next_state = INGRESO_NUM1;
        INGRESO_NUM1:
            if (key_valid) begin
                if (key_value == KEY_HASH)
                    next_state = INGRESO_NUM2;
                else if (key_value == KEY_STAR)
                    next_state = ESPERA;
            end
        INGRESO_NUM2:
            if (key_valid) begin
                if (key_value == KEY_A)
                    next_state = SUMA;
                else if (key_value == KEY_STAR)
                    next_state = ESPERA;
            end
        SUMA:
            if (key_valid && key_value == KEY_STAR)
                next_state = ESPERA;
    endcase
end

always_ff @(posedge clk) begin
    if (!rst) begin
        num1        <= 0;
        num2        <= 0;
        do_sum      <= 0;
        display_sel <= 0;
    end else begin
        do_sum <= 0;
        case (state)
            ESPERA: begin
                display_sel <= 0;
                if (key_valid && key_value <= 9)
                    num1 <= key_value;
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
                if (key_valid && key_value == KEY_STAR) begin
                    num1 <= 0;
                    num2 <= 0;
                end
            end
        endcase
    end
end

endmodule