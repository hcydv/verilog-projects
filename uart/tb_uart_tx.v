`timescale 1ns/1ns
module tb_uart_tx();

reg clk;
reg rst_n;
reg [7:0] data_in;
reg tx_start;

wire tx;
wire tx_busy;
wire tx_done;

initial begin
    clk <= 1;
    rst_n <= 0 ;
    #20
    rst_n <= 1;
end

always #10 clk = ~clk;

initial
    begin
        data_in <= 8'd1;
        tx_start <= 0;
        #200
        tx_start <= 1;
        #20
        tx_start <= 0;
        #200
        tx_start <= 1;
        #20
        tx_start <= 0;
        #(20*12*434)
        data_in <= 8'd2;
        tx_start <= 1;
        #20
        tx_start <= 0;
        #200
        data_in <= 8'd7;
    end

uart_tx uart_tx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .tx_start(tx_start),

    .tx(tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);


endmodule