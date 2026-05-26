module input_fsm ( 
    input  wire        clk,
    input  wire        rst,
    input  wire        key_valid,
    input  wire [3:0]  key_value,
    output reg  [11:0] num1,
    output reg  [11:0] num2,
    output reg         do_sum,
    output reg         do_div,
    output reg  [2:0]  display_sel,
    output reg         modo_div
);

localparam KEY_HASH = 4'd13;
localparam KEY_A    = 4'd10;
localparam KEY_STAR = 4'd14;
localparam KEY_B    = 4'd11;
localparam KEY_C    = 4'd12;
localparam KEY_D    = 4'd15;

typedef enum logic [2:0] {
    ESPERA,
    INGRESO_NUM1,
    INGRESO_NUM2,
    SUMA,
    DIV_CALCULO,
    DIV_COCIENTE,
    DIV_RESIDUO
} state_t;

state_t state, next_state;

// Registro del modo: 0 = suma, 1 = división
reg modo;

// Toggle del modo con tecla B
always_ff @(posedge clk) begin
    if (!rst)
        modo <= 0;
    else if (key_valid && key_value == KEY_B)
        modo <= ~modo;
end

// Registro de estado
always_ff @(posedge clk) begin
    if (!rst)
        state <= ESPERA;
    else
        state <= next_state;
end

// Lógica de siguiente estado
always_comb begin
    next_state = state;
    if (key_valid) begin
        case (state)
            ESPERA:
                case (key_value)
                    4'd0,4'd1,4'd2,4'd3,4'd4,
                    4'd5,4'd6,4'd7,4'd8,4'd9:
                        next_state = INGRESO_NUM1;
                endcase

            INGRESO_NUM1:
                case (key_value)
                    KEY_HASH: next_state = INGRESO_NUM2;
                    KEY_STAR: next_state = ESPERA;
                endcase

            INGRESO_NUM2:
                if (modo == 0) begin
                    case (key_value)
                        KEY_A:    next_state = SUMA;
                        KEY_STAR: next_state = ESPERA;
                    endcase
                end else begin
                    case (key_value)
                        KEY_A:    next_state = DIV_CALCULO;
                        KEY_STAR: next_state = ESPERA;
                    endcase
                end

            SUMA:
                if (key_value == KEY_STAR)
                    next_state = ESPERA;

            DIV_CALCULO:
                case (key_value)
                    KEY_C:    next_state = DIV_COCIENTE;
                    KEY_D:    next_state = DIV_RESIDUO;
                    KEY_STAR: next_state = ESPERA;
                endcase

            DIV_COCIENTE:
                case (key_value)
                    KEY_D:    next_state = DIV_RESIDUO;
                    KEY_STAR: next_state = ESPERA;
                endcase

            DIV_RESIDUO:
                case (key_value)
                    KEY_C:    next_state = DIV_COCIENTE;
                    KEY_STAR: next_state = ESPERA;
                endcase

            default: next_state = ESPERA;
        endcase
    end
end

// Lógica de salidas
always_ff @(posedge clk) begin
    if (!rst) begin
        num1        <= 0;
        num2        <= 0;
        do_sum      <= 0;
        do_div      <= 0;
        display_sel <= 0;
        modo_div    <= 0;
    end else begin

        modo_div <= modo;
        do_sum   <= (state == SUMA);
        do_div   <= (state == DIV_CALCULO);

        case (state)
            ESPERA:       display_sel <= 0;
            INGRESO_NUM1: display_sel <= 0;
            INGRESO_NUM2: display_sel <= 1;
            SUMA:         display_sel <= 2;
            DIV_CALCULO:  display_sel <= 3;
            DIV_COCIENTE: display_sel <= 4;
            DIV_RESIDUO:  display_sel <= 5;
            default:      display_sel <= 0;
        endcase

        if (key_valid) begin
            case (next_state)
                INGRESO_NUM1: begin
                    case (key_value)
                        4'd0,4'd1,4'd2,4'd3,4'd4,
                        4'd5,4'd6,4'd7,4'd8,4'd9:
                            num1 <= {num1[7:0], key_value};
                    endcase
                end
                INGRESO_NUM2: begin
                    case (key_value)
                        4'd0,4'd1,4'd2,4'd3,4'd4,
                        4'd5,4'd6,4'd7,4'd8,4'd9:
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