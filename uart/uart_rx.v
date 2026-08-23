module uart_rx
(
    input wire clk,
    input wire rst_n,
    input wire rx,

    output reg [7:0] data_out,
    output reg rx_done,
    output reg rx_busy
);


parameter BIT_CNT_MAX = 4'd9;
parameter BAUD_CNT_MAX = 9'd434;

reg rx0;
reg rx1;
reg [3:0] bit_cnt;
reg [8:0] baud_cnt;
reg [7:0] data_reg;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
            rx0<=1;
            rx1<=1;
        end
    else 
        begin
            rx0<=rx;
            rx1<=rx0;
        end

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        rx_busy <= 0;
    else if(rx1 == 0 && rx_busy == 0)
        rx_busy <= 1;
    else if(bit_cnt == BIT_CNT_MAX && baud_cnt == BAUD_CNT_MAX-1)
        rx_busy <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        bit_cnt <= 0;
    else if(rx_busy == 1 && baud_cnt == BAUD_CNT_MAX-1 && bit_cnt == BIT_CNT_MAX)
        bit_cnt <= 0;
    else if(rx_busy == 1 && baud_cnt == BAUD_CNT_MAX-1 )
        bit_cnt <= bit_cnt + 1;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        baud_cnt <= 0;
    else if(rx_busy == 1 && baud_cnt == BAUD_CNT_MAX - 1)
        baud_cnt <= 0 ;
    else if(rx_busy == 1)
        baud_cnt <= baud_cnt + 1;
    else 
        baud_cnt <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        data_reg <= 0;
    else if(rx_busy == 1 && baud_cnt == BAUD_CNT_MAX/2 -1 )
        case(bit_cnt)
            1:data_reg[0] <= rx1;
            2:data_reg[1] <= rx1;
            3:data_reg[2] <= rx1;
            4:data_reg[3] <= rx1;
            5:data_reg[4] <= rx1;
            6:data_reg[5] <= rx1;
            7:data_reg[6] <= rx1;
            8:data_reg[7] <= rx1;
        endcase

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        rx_done <= 0;
    else if(rx_busy == 1 && bit_cnt == BIT_CNT_MAX && baud_cnt == BAUD_CNT_MAX - 1)
        rx_done <= 1;
    else 
        rx_done <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        data_out <= 0;
    else if(rx_busy == 1 && bit_cnt == BIT_CNT_MAX && baud_cnt == BAUD_CNT_MAX - 1)
        data_out <= data_reg;

endmodule