`timescale 1ns/1ns
module tb_uart_rx();

reg clk;
reg rst_n;
reg rx;

wire [7:0] data_out;
wire rx_done;
wire rx_busy;

initial 
    begin
        clk <= 1;
        rst_n <= 0;
        rx <= 1;
        #20
        rst_n <= 1;
    end

always #10 clk = ~clk;

task rx_bit
(
    input [7:0] data
);
    integer i;

for(i=0;i<=9;i=i+1)
    begin
    case(i)
        0:rx <= 0;
        1:rx <= data[0];
        2:rx <= data[1];
        3:rx <= data[2];
        4:rx <= data[3];
        5:rx <= data[4];
        6:rx <= data[5];
        7:rx <= data[6];
        8:rx <= data[7];
        9:rx <= 1;
    default:rx <= 1;
    endcase
    #(434 * 20);
    end

endtask

initial
    begin
        #200
        rx_bit(0);
        #200
        rx_bit(1);
        rx_bit(2);
        rx_bit(3);
        #200
        rx_bit(4);
        rx_bit(5);
    end 


uart_rx uart_rx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),

    .data_out(data_out),
    .rx_done(rx_done),
    .rx_busy(rx_busy)
);

endmodule