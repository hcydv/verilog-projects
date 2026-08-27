`timescale 1ns/1ns
module tb_sad_cal_pipeline();

reg clk;
reg rst_n;

reg [63:0] a_data;
reg [63:0] b_data;
reg in_valid;

wire [10:0] sad_out;
wire out_valid;

reg [10:0] expected_pipe[0:4];
reg [4:0] expected_valid;

integer i;
integer pass_count;
integer error_count;

function [10:0] cal_sad;
    input [63:0] a_in;
    input [63:0] b_in;

    integer k;
    reg [7:0] av;
    reg [7:0] bv;
    reg [10:0] sum;

    sum = 0;
    for(k=0;k<=7;k=k+1)begin
        av = a_in[k*8 +:8];
        bv = b_in[k*8 +:8];
        if(av >= bv)
            sum = sum +(av-bv);
        else 
            sum = sum +(bv-av);

    end 
    cal_sad = sum;
endfunction

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        begin
        expected_valid <= 0;
        for(i=0;i<=4;i=i+1)
            expected_pipe[i] <= 0;
        end
    else 
        begin
        expected_valid <= in_valid;
        expected_valid[4:1] = expected_valid[3:0];
        if(in_valid == 1)
            expected_pipe[0] <= cal_sad(a_data,b_data);
        else
            expected_pipe[0] <= 0;
        expected_pipe[1] <= expected_pipe[0];
        expected_pipe[2] <= expected_pipe[1];
        expected_pipe[3] <= expected_pipe[2];
        expected_pipe[4] <= expected_pipe[3];
        end

always @(posedge clk)
    if(rst_n == 1 && out_valid == 1)
        if(expected_pipe[4] == sad_out)
            begin
                pass_count <= pass_count + 1;
                $display("PASS,actual=%0d,expected=%0d",sad_out,expected_pipe[4]);
            end
        else 
            begin
                error_count <= error_count + 1;
                $display("ERROR,actual=%0d,expected=%0d",sad_out,expected_pipe[4]);
            end

initial begin
    pass_count = 0;
    error_count = 0;
    clk <= 1;
    rst_n <= 0;
    a_data <= 0;
    b_data <= 0;
    in_valid <= 0;
    #20
    rst_n <= 1;
    #190
    in_valid <= 1;
    #20
    a_data <=64'hffffffffffffffff;
    #20
    a_data <= 64'h0A141E28323C4650;
    b_data <= 64'h0A141E28323C465A;
    #20
    a_data = 64'h50_46_3C_32_28_1E_14_0A;
    b_data = 64'h5A_3C_41_37_1E_23_12_0F;
    #20
    a_data = 64'h08_07_06_05_04_03_02_01;
    b_data = 64'h01_02_03_04_05_06_07_08;
    #20
    a_data = 64'h10_20_30_40_50_60_70_80;
    b_data = 64'h08_18_28_38_48_58_68_78;
    #20
    in_valid <= 0;
    #20
    in_valid <= 1;
    a_data = 64'hFF_E0_C0_A0_80_60_40_20;
    b_data = 64'hF0_D0_B0_90_70_50_30_10;
    #20
    in_valid <= 0;
    #40
    a_data = 64'h11_22_33_44_55_66_77_88;
    b_data = 64'h10_20_30_40_50_60_70_80;
    in_valid <= 1;
    #20
    in_valid <= 0;
    #200
    $display("pass_count=%0d",pass_count);
    $display("error_count=%0d",error_count);
end

always #10 clk = ~ clk;


sad_cal_pipeline sad_cal_pipeline_inst(
    .clk(clk),
    .rst_n(rst_n),
    .a_data(a_data),
    .b_data(b_data),
    .in_valid(in_valid),

    .sad_out(sad_out),
    .out_valid(out_valid)
);


endmodule