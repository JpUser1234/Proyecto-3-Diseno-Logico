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
    if (key_valid) begin
        case (state)
            ESPERA:
                case (key_value)
                    4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
                        next_state = INGRESO_NUM1;
                endcase
            INGRESO_NUM1:
                case (key_value)
                    KEY_HASH: next_state = INGRESO_NUM2;
                    KEY_STAR: next_state = ESPERA;
                endcase
            INGRESO_NUM2:
                case (key_value)
                    KEY_A:    next_state = SUMA;
                    KEY_STAR: next_state = ESPERA;
                endcase
            SUMA:
                if (key_value == KEY_STAR)
                    next_state = ESPERA;
        endcase
    end
end

always_ff @(posedge clk) begin
    if (!rst) begin
        num1        <= 0;
        num2        <= 0;
        do_sum      <= 0;
        display_sel <= 0;
    end else begin

        // do_sum se mantiene activo mientras state == SUMA
        do_sum <= (state == SUMA);

        // display_sel sigue al estado actual
        case (state)
            ESPERA:       display_sel <= 0;
            INGRESO_NUM1: display_sel <= 0;
            INGRESO_NUM2: display_sel <= 1;
            SUMA:         display_sel <= 2;
        endcase

        if (key_valid) begin
            case (next_state)
                INGRESO_NUM1: begin
                    case (key_value)
                        4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
                            num1 <= {num1[7:0], key_value};
                    endcase
                end
                INGRESO_NUM2: begin
                    case (key_value)
                        4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9:
                            num2 <= {num2[7:0], key_value};
                    endcase
                end
                ESPERA: begin
                    num1 <= 0;
                    num2 <= 0;
                end
                default: ;
            endcase
        end
    end
end

endmodule