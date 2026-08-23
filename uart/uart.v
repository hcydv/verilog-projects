module uart
(
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire tx_start,

    output wire [7:0] data_out,
    output wire rx_done,
    output wire rx_busy
);

wire tx;
wire tx_busy;
wire tx_done;

uart_tx uart_tx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .tx_start(tx_start),

    .tx(tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

uart_rx uart_rx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .rx(tx),

    .data_out(data_out),
    .rx_done(rx_done),
    .rx_busy(rx_busy)
);

endmodule