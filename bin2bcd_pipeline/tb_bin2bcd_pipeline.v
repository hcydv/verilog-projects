`timescale 1ns/1ns
module tb_bin2bcd_pipeline();

reg clk;
reg rst_n;

reg [15:0] bin_in;
reg in_valid;

wire [19:0] bcd_out;
wire out_valid;

initial begin
    clk <= 1;
    rst_n <= 0;
    bin_in <= 0;
    in_valid <= 0;
    #20
    rst_n <= 1;
    #100
    bin_in <= 16'd12345;
    in_valid <= 1;
    #20
    bin_in <= 16'd11111;
    #20
    bin_in <= 16'd22222;
    #20
    bin_in <= 16'd33333;
    #20
    bin_in <= 16'd44444;
    #20
    in_valid <= 0;
    bin_in <= 16'd54321;
    #20
    in_valid <= 1;
    bin_in <= 0;
    #20
    in_valid <= 0;
end

always #10 clk = ~ clk;

bin2bcd_pipeline bin2bcd_pipeline_inst(
    .clk(clk),
    .rst_n(rst_n),
    .bin_in(bin_in),
    .in_valid(in_valid),

    .bcd_out(bcd_out),
    .out_valid(out_valid)
);

endmodule