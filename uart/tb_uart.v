`timescale 1ns/1ns

module tb_uart();

reg clk;
reg rst_n;
reg [7:0] data_in;
reg tx_start;

wire [7:0] data_out;
wire rx_done;
wire rx_busy;

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


uart uart_inst(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .tx_start(tx_start),

    .data_out(data_out),
    .rx_done(rx_done),
    .rx_busy(rx_busy)
);

endmodule