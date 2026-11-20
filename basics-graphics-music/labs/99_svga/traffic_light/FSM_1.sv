module fsm_1(
input clk,
input rst,
input tick_05s,

output reg red_on,
output reg yellow_on,
output reg green_on
// output reg [3:0] stp,
// output reg [3:0] n_stp
);

logic [3: 0] stp;
logic [3: 0] n_stp;

logic n_red_on;
logic n_yellow_on;
logic n_green_on;

logic [5:0] timer;
logic [5:0] n_timer;

logic [2:0] blink_cnt;
logic [2:0] n_blink_cnt;

logic previous_tick_05s;


always_comb begin: p_comb
    n_stp = stp;
    n_red_on = red_on;
    n_yellow_on = yellow_on;
    n_green_on = green_on;
    n_timer = timer;
    n_blink_cnt = blink_cnt; 
    
    // if (~timer[5])
    //     n_timer = n_timer - 1;

    if (~timer[5] && tick_05s == 1 && previous_tick_05s == 0)
        n_timer = n_timer - 1;

    case (stp)
    0: begin
        n_red_on = 1;
        n_yellow_on = 0;
        n_green_on = 0;
        if(timer [5]) begin
            n_stp = 1;
            n_timer = 6'd5;
        end 
    end

    1: begin
        n_yellow_on = 1;
        n_blink_cnt = 0;
        if(timer[5]) begin
            n_stp = 2;
            n_timer = 6'd19;
        end
    end

    2: begin
        n_red_on = 0;
        n_yellow_on = 0;
        n_green_on = 1;

        if(timer[5]) begin
            n_stp = 3;
            n_timer = 0;
        end
    end

    3: begin
        n_red_on = 0;
        n_yellow_on = 0;
        n_green_on = 0;
        
        if(timer[5]) begin
            n_blink_cnt = n_blink_cnt + 1;
            if(blink_cnt == 4) begin
                n_stp = 4;
                n_timer = 6'd5;
            end else begin
            n_stp = 2;
            n_timer = 0;
            end
        end
    end

    4: begin
        n_red_on = 0;
        n_yellow_on = 1;
        n_green_on = 0;

        if(timer[5]) begin
            n_stp = 0;
            n_timer = 6'd19;
        end
    end

endcase
end

always_ff @ (posedge clk) begin: p_ff
    red_on <= n_red_on;
    yellow_on <= n_yellow_on;
    green_on <= n_green_on;

    if (rst) begin
       stp <= 0;
       timer <= 6'b010011;
    end
    else begin
        stp <= n_stp;
        timer <= n_timer;
        blink_cnt <= n_blink_cnt;
        previous_tick_05s <= tick_05s;
    end
end


endmodule