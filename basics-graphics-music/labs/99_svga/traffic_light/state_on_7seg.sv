module state_on_7seg 
(
    input   clk,
    input   rst,
    input   [3:0] state,
    output  logic [7:0] abcdefgh // l will be set to 1 if y = K*x+D
);
always_ff @ (posedge clk or posedge rst) begin
    if(rst)
        abcdefgh <= '0;
    else begin
        
        case (state) 
            0: abcdefgh <= 8'b11111100;
            1: abcdefgh <= 8'b01100000;
            2: abcdefgh <= 8'b11011010;
            3: abcdefgh <= 8'b11110010;
            4: abcdefgh <= 8'b01100110;
            5: abcdefgh <= 8'b10110110;
    endcase
end
end

endmodule