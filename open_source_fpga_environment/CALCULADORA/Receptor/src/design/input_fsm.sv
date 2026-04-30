module input_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire        key_valid,     // hay tecla válida
    input  wire [3:0]  key_value,     // valor de la tecla
    output reg  [11:0] num1,          // número 1 acumulado (3 dígitos BCD)
    output reg  [11:0] num2,          // número 2 acumulado (3 dígitos BCD)
    output reg         do_sum,        // pulso para ejecutar la suma
    output reg  [1:0]  display_sel    // qué mostrar: 0=num1, 1=num2, 2=resultado
);

// Definicion de teclas especiales
localparam KEY_HASH  = 4'd13;  // # confirma num1
localparam KEY_A     = 4'd10;  // A confirma num2 y suma
localparam KEY_STAR  = 4'd14;  // * limpia todo

// Estados
typedef enum logic [1:0] {
    ESPERA,
    INGRESO_NUM1,
    INGRESO_NUM2,
    SUMA
} state_t;

state_t state, next_state;

// Registro de estado
always_ff @(posedge clk) begin
    if (rst)
        state <= ESPERA;
    else
        state <= next_state;
end

// Lógica de próximo estado y salidas
always_ff @(posedge clk) begin
    if (rst) begin
        num1        <= 12'd0;
        num2        <= 12'd0;
        do_sum      <= 0;
        display_sel <= 0;
    end else begin
        do_sum <= 0;  // por defecto no suma

        case (state)
            ESPERA: begin
                if (key_valid && key_value <= 4'd9) begin
                    // primer dígito de num1
                    num1        <= {8'd0, key_value};
                    display_sel <= 0;
                    next_state  <= INGRESO_NUM1;
                end
            end

            INGRESO_NUM1: begin
                if (key_valid) begin
                    if (key_value == KEY_STAR) begin
                        // limpiar todo
                        num1       <= 0;
                        next_state <= ESPERA;
                    end else if (key_value == KEY_HASH) begin
                        // confirmar num1 y pasar a num2
                        display_sel <= 1;
                        next_state  <= INGRESO_NUM2;
                    end else if (key_value <= 4'd9) begin
                        // acumular dígito: desplazar BCD y agregar nuevo dígito
                        num1 <= {num1[7:0], key_value};
                    end
                end
            end

            INGRESO_NUM2: begin
                if (key_valid) begin
                    if (key_value == KEY_STAR) begin
                        num1       <= 0;
                        num2       <= 0;
                        next_state <= ESPERA;
                    end else if (key_value == KEY_A) begin
                        // confirmar num2 y ejecutar suma
                        do_sum      <= 1;
                        display_sel <= 2;
                        next_state  <= SUMA;
                    end else if (key_value <= 4'd9) begin
                        num2 <= {num2[7:0], key_value};
                    end
                end
            end

            SUMA: begin
                if (key_valid && key_value == KEY_STAR) begin
                    num1        <= 0;
                    num2        <= 0;
                    display_sel <= 0;
                    next_state  <= ESPERA;
                end
            end
        endcase
    end
end

endmodule