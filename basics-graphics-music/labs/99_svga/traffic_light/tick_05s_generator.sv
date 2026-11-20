module tick_05s_generator #( // should be around 5µs in simulation. For the exact timing, a clock frequency divisible by 5 is necessary
    parameter          IS_SIMULATION=0, 
    parameter          clk_mhz
)(
    input clk,
    input rst,

    output logic tick_05s
);

logic [$clog2(clk_mhz*1000000/2):0] cnt;

always_ff @ (posedge clk) begin
    if (rst) begin
        cnt <= 0;
        tick_05s <= 0;
    end
    else begin
        if (cnt >= (clk_mhz*1000000/4)/(1+IS_SIMULATION*999999)) begin
            tick_05s <= ~tick_05s;
            cnt <= '0;
        end
        else
            cnt <= cnt + 'b1;
    end

end

endmodule