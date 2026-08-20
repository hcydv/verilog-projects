`timescale 1ns/1ns
module tb_z_scan();

reg clk;
reg rst_n;
reg start;

wire [1:0] row;
wire [1:0] col;
wire valid;
wire done;

initial begin
    rst_n <= 0;
    clk <= 1;
    start <= 0;
    #20
    rst_n <= 1;
    #200
    start <= 1;
    #20
    start <= 0;
    #100
    start <= 1;
    #20
    start <= 0;
    #2000
    start <= 1;
    #20
    start <= 0;
end

always #10 clk = ~ clk;

reg [3:0] expected [0:15];
integer idx;

initial begin
    expected[0]  = 4'b0000; // (0,0)
    expected[1]  = 4'b0001; // (0,1)
    expected[2]  = 4'b0100; // (1,0)
    expected[3]  = 4'b1000; // (2,0)
    expected[4]  = 4'b0101; // (1,1)
    expected[5]  = 4'b0010; // (0,2)
    expected[6]  = 4'b0011; // (0,3)
    expected[7]  = 4'b0110; // (1,2)
    expected[8]  = 4'b1001; // (2,1)
    expected[9]  = 4'b1100; // (3,0)
    expected[10] = 4'b1101; // (3,1)
    expected[11] = 4'b1010; // (2,2)
    expected[12] = 4'b0111; // (1,3)
    expected[13] = 4'b1011; // (2,3)
    expected[14] = 4'b1110; // (3,2)
    expected[15] = 4'b1111; // (3,3)

    idx = 0;
end

always @(posedge clk or negedge rst_n)
    if(valid == 1)
        begin
            if({row,col} == expected[idx])
                begin
                    $display("PASS idx=%0d row=%0d cow=%0d",idx,row,col);
                    idx = idx + 1;
                end
            else 
                    $display("ERROR idx=%0d row=%0d cow=%0d",idx,row,col);
        end


z_scan z_scan_inst
(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),

    .row(row),
    .col(col),
    .valid(valid),
    .done(done)
);

endmodule