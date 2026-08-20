module z_scan(
    input wire clk,
    input wire rst_n,
    input wire start,

    output reg [1:0] row,
    output reg [1:0] col,
    output reg valid,
    output reg done
);

parameter IDLE =2'b00;
parameter UP_RIGHT = 2'b01;
parameter DOWN_LEFT= 2'b10;
parameter DONE     = 2'b11;

reg [1:0] state;
reg [1:0] next_state;

always @(posedge clk or negedge rst_n)
    if(rst_n == 0)
        state <= IDLE;
    else 
        state <= next_state;

always @(*)
    begin
    next_state = state;
    valid = 0;
    done = 0;
    case(state)
        IDLE:
            begin
                if(start == 1)
                    next_state = UP_RIGHT;
            end
        UP_RIGHT:
            begin
                valid = 1;
                if(row == 2'd3 && col == 2'd3)
                    next_state = DONE;
                else if(row == 2'd0 || col == 2'd3)
                    next_state = DOWN_LEFT;
            end
        DOWN_LEFT:
            begin
                valid = 1;
                if(row == 2'd3 || col == 2'd0)
                    next_state = UP_RIGHT;
            end
        DONE:
            begin
                done = 1;
                next_state = IDLE;
            end
        default:
            next_state = IDLE;
    endcase
    end

always @(posedge clk or negedge rst_n)
    begin
    if(rst_n == 0)
        begin
            row <= 0;
            col <= 0;
        end
    else 
        begin
            case(state)
                IDLE:
                    begin
                        row <= 0;
                        col <= 0;
                    end
                UP_RIGHT:
                    begin
                        if(row != 2'd0 && col != 2'd3 )
                            begin
                                row <= row - 1;
                                col <= col + 1;
                            end
                        else if(row == 2'd0 && col != 2'd3)
                            begin
                                col <= col + 1;
                            end
                        else if(row != 2'd0 && col == 2'd3)
                            begin
                                row <= row + 1;
                            end
                    end
                DOWN_LEFT:
                    begin
                        if(row != 2'd3 && col != 2'd0)
                            begin
                                row <= row + 1;
                                col <= col - 1;
                            end
                        else if(row == 2'd3 && col != 2'd0)
                            begin
                                row <= row;
                                col <= col + 1;
                            end
                        else if(row != 2'd3 && col == 2'd0)
                            begin
                                row <= row+ 1;
                                col <= col;
                            end
                        else if(row == 2'd3 && col == 2'd0)
                            begin
                                col <= col+1;
                            end
                    end
                DONE:
                    begin
                        row <= 0;
                        col <= 0;
                    end
            endcase
        end
    end

endmodule   