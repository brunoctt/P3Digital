módulo I2C_READ (
       clk,
rst_n,
scl, sda, data
              );
 
 input clk; // Bus clock 50MHz
input rst_n; // Reset assíncrono, ativo baixo
  
output scl; // relógio SCL
inout sda; // barramento de dados SDA
output [15: 0] data; // dados de temperatura
  
reg [15: 0] data_r; // registro de dados de temperatura
reg scl; // registro de barramento SCL
reg sda_r; // registro de barramento SDA
reg sda_link; // Sinalizador de direção de dados do barramento SDA
reg [7: 0] scl_cnt; // contador de geração de relógio SCL
reg [2: 0] cnt; // Usado para marcar o contador de relógio SCL
reg [25: 0] timer_cnt; // Timer, lê os dados de temperatura a cada 2s
reg [3: 0] data_cnt; // Data serial para registro de conversão paralela
reg [7: 0] address_reg; // registro de endereço do dispositivo
reg [8: 0] estado; // Registro de estado
/////////////////////////////////////////////////////// / ///////////////////////////////////
// Processo 1, 2, 3: Gerar relógio de barramento SCL
always @ (posedge clk ou negedge rst_n)
    começar
        if (! rst_n)
            scl_cnt <= 8'd0;
        else if (scl_cnt == 8'd199)
            scl_cnt <= 8'd0;
        senão
            scl_cnt <= scl_cnt + 1'b1;
    fim
always @ (posedge clk ou negedge rst_n)
    começar
        if (! rst_n)
            cnt <= 3'd5;
        senão
            case (scl_cnt)
                8'd49: cnt <= 3'd1; // Nível médio alto
                8'd99: cnt <= 3'd2; // borda descendente
                8'd149: cnt <= 3'd3; // nível médio baixo
                8'd199: cnt <= 3'd0; // borda ascendente
               padrão: cnt <= 3'd5;
            endcase
    fim
`define SCL_HIG (cnt == 3'd1)
`define SCL_NEG (cnt == 3'd2)
`define SCL_LOW (cnt == 3'd3)
`define SCL_POS (cnt == 3'd0)
always @ (posedge clk ou negedge rst_n)
    começar
        if (! rst_n)
            scl <= 1'b0;
        else if (`SCL_POS)
            scl <= 1'b1;
        else if (`SCL_NEG)
            scl <= 1'b0;
    fim
/////////////////////////////////////////////////////// / ///////////////////////////////////
// Processo 4: Timer, ler dados de temperatura a cada 1s
always @ (posedge clk ou negedge rst_n)
    começar
        if (! rst_n)
            timer_cnt <= 26'd0;
        else if (timer_cnt == 26'd49999999)
            timer_cnt <= 26'd0;
        senão
            timer_cnt <= timer_cnt + 1'b1;
    fim
/////////////////////////////////////////////////////// / ///////////////////////////////////
// Definição da máquina de estado
parâmetro IDLE = 9'b0_0000_0000,
             START = 9'b0_0000_0010,
             ENDEREÇO ​​= 9'b0_0000_0100,
             ACK1 = 9'b0_0000_1000,
             READ1 = 9'b0_0001_0000,
             ACK2 = 9'b0_0010_0000,
             READ2 = 9'b0_0100_0000,
             NACK = 9'b0_1000_0000,
             STOP = 9'b1_0000_0000;
`definir DEVICE_ADDRESS 8'b1001_0001 // endereço do dispositivo, operação de leitura
/////////////////////////////////////////////////////// / ///////////////////////////////////
// Processo 5: descrição da máquina de estado
always @ (posedge clk ou negedge rst_n)
    começar
        if (! rst_n)
            começar
                data_r <= 16'd0;
                sda_r <= 1'b1;
                sda_link <= 1'b1;
                estado <= IDLE;
                address_reg <= 15'd0;
                data_cnt <= 4'd0;
            fim
        senão
            caso (estado)
                OCIOSO:
                    começar
                        sda_r <= 1'b1;
                        sda_link <= 1'b1;
                        if (timer_cnt == 26'd49999999)
                            estado <= INICIAR;
                        senão
                            estado <= IDLE;
                    fim
                START: // Gerar sinal de início
                    começar
                        if (`SCL_HIG)
                            começar
                                sda_r <= 1'b0;
                                sda_link <= 1'b1;
                                address_reg <= `DEVICE_ADDRESS;
                                estado <= ENDEREÇO;
                                data_cnt <= 4'd0;
                            fim
                        senão
                            estado <= INICIAR;
                    fim
                ENDEREÇO: // O host endereça o dispositivo
                    começar
                        if (`SCL_LOW)
                            começar
                                if (data_cnt == 4'd8) // O endereçamento é concluído, o SDA muda de direção e o dispositivo está pronto para emitir um sinal de resposta
                                    começar
                                        estado <= ACK1;
                                        data_cnt <= 4'd0;
                                        sda_r <= 1'b1;
                                        sda_link <= 1'b0;
                                    fim
                                else // Durante o processo de endereçamento, SDA é usado como entrada para o dispositivo
                                    começar
                                        estado <= ENDEREÇO;
                                        data_cnt <= data_cnt + 1'b1;
                                        case (data_cnt)
                                            4'd0: sda_r <= address_reg [7];
                                            4'd0: sda_r <= address_reg [7];
                                            4'd1: sda_r <= address_reg [6];
                                            4'd2: sda_r <= endereço_reg [5];
                                            4'd3: sda_r <= address_reg [4];
                                            4'd4: sda_r <= address_reg [3];
                                            4'd5: sda_r <= address_reg [2];
                                            4'd6: sda_r <= address_reg [1];
                                            4'd7: sda_r <= address_reg [0];
                                            padrão:;
                                        endcase
                                    fim
                            fim
                        senão
                            estado <= ENDEREÇO;
                    fim
                ACK1: // sinal de reconhecimento de saída do dispositivo
                    começar
                        if (! sda && (`SCL_HIG))
                            estado <= READ1;
                        else if (`SCL_NEG)
                            estado <= READ1;
                        senão
                            estado <= ACK1;
                    fim
                READ1: // Lê dados do dispositivo, byte alto
                    começar
                        if ((`SCL_LOW) && (data_cnt == 4'd8)) // A leitura dos dados de byte alto está concluída, o SDA muda de direção e o host está pronto para emitir um sinal de resposta
                            começar
                                estado <= ACK2;
                                data_cnt <= 4'd0;
                                sda_r <= 1'b1;
                                sda_link <= 1'b1;
                            fim
                        else if (`SCL_HIG) // No processo de leitura de dados, o dispositivo é usado como saída
                            começar
                                data_cnt <= data_cnt + 1'b1;
                                case (data_cnt)
                                    4'd0: data_r [15] <= sda;
                                    4'd1: data_r [14] <= sda;
                                    4'd2: data_r [13] <= sda;
                                    4'd3: data_r [12] <= sda;
                                    4'd4: data_r [11] <= sda;
                                    4'd5: data_r [10] <= sda;
                                    4'd6: data_r [9] <= sda;
                                    4'd7: data_r [8] <= sda;
                                    padrão:;
                                endcase
                            fim
                        senão
                            estado <= READ1;
                    fim
                ACK2: // Sinal de resposta de saída do host
                    começar
                        if (`SCL_LOW)
                            sda_r <= 1'b0;
                        else if (`SCL_NEG)
                            começar
                                sda_r <= 1'b1;
                                sda_link <= 1'b0;
                                estado <= READ2;
                            fim
                        senão
                            estado <= ACK2;
                    fim
                READ2: // lê dados de byte baixo
                    começar
                        if ((`SCL_LOW) && (data_cnt == 4'd8))
                            começar
                                estado <= NACK;
                                data_cnt <= 4'd0;
                                sda_r <= 1'b1;
                                sda_link <= 1'b1;
                            fim
                        else if (`SCL_HIG)
                            começar
                                data_cnt <= data_cnt + 1'b1;
                                case (data_cnt)
                                    4'd0: data_r [7] <= sda;
                                    4'd1: data_r [6] <= sda;
                                    4'd2: data_r [5] <= sda;
                                    4'd3: data_r [4] <= sda;
                                    4'd4: data_r [3] <= sda;
                                    4'd5: data_r [2] <= sda;
                                    4'd6: data_r [1] <= sda;
                                    4'd7: data_r [0] <= sda;
                                    padrão:;
                                endcase
                            fim
                        senão
                            estado <= READ2;
                    fim
                NACK: // host não-reconhecimento
                    começar
                        if (`SCL_LOW)
                            começar
                                estado <= PARAR;
                                sda_r <= 1'b0;
                            fim
                        senão
                            estado <= NACK;
                    fim
                PARE:
                    começar
                        if (`SCL_HIG)
                            começar
                                estado <= IDLE;
                                sda_r <= 1'b1;
                            fim
                        senão
                            estado <= PARAR;
									 fim
                 padrão: estado <= IDLE;
             endcase
     fim
atribuir sda = sda_link? sda_r: 1'bz;
atribuir dados = data_r;
módulo final