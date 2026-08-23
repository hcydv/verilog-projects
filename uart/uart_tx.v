module uart_tx(
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire tx_start,

    output reg tx,
    output reg tx_busy,
    output reg tx_done
);

parameter BAUD_CNT_MAX =9'd434 ;
parameter BIT_CNT_MAX= 4'd9;

reg [7:0] data_reg;
reg [3:0] bit_cnt;
reg [8:0] baud_cnt;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        data_reg <= 0;
    else if(tx_start == 1 && tx_busy == 0)
        data_reg <= data_in;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        tx_busy <= 0;
    else if(tx_start == 1 && tx_busy == 0)
        tx_busy <= 1;
    else if(bit_cnt == BIT_CNT_MAX && baud_cnt == BAUD_CNT_MAX-1)
        tx_busy <= 0;
    
always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        baud_cnt <= 0;
    else if(tx_busy == 1 && baud_cnt == BAUD_CNT_MAX-1)
        baud_cnt <= 0;
    else if(tx_busy == 1)
        baud_cnt <= baud_cnt + 1;
    else 
        baud_cnt <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        bit_cnt <= 0;
    else if(tx_busy == 1 && baud_cnt == BAUD_CNT_MAX-1 && bit_cnt == BIT_CNT_MAX)
        bit_cnt <= 0;
    else if(tx_busy == 1 && baud_cnt == BAUD_CNT_MAX-1)
        bit_cnt <= bit_cnt + 1;
    else if(tx_busy == 1)
        bit_cnt <= bit_cnt;
    else 
        bit_cnt <= 0;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        tx <= 1;
    else if(tx_busy == 1)
        case(bit_cnt)
            0:tx <= 0;
            1:tx <= data_reg[0];
            2:tx <= data_reg[1];
            3:tx <= data_reg[2];
            4:tx <= data_reg[3];
            5:tx <= data_reg[4];
            6:tx <= data_reg[5];
            7:tx <= data_reg[6];
            8:tx <= data_reg[7];
            9:tx <= 1;
        endcase
    else 
        tx <= 1;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0 )
        tx_done <= 0;
    else if(tx_busy == 1 && bit_cnt == BIT_CNT_MAX && baud_cnt == BAUD_CNT_MAX - 1)
        tx_done <= 1;
    else 
        tx_done <= 0;
    





endmodule