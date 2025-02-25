module inmp441_mic_spi_receiver_65m
(
    input             clk,
    input             reset,
    output            cs,
    output            sck,
    input             sdo,
    output logic [23:0] value,
    output logic        value_we
);

    logic [ 10:0] cnt;
    logic [31:0] shift;

    logic           sck_q;
    logic           cs_t;
    logic           cs_o;


    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
            cnt <= 8'b100;
        else
            cnt <= cnt + 8'b1;
    end

    assign sck = ~ cnt [4];
    assign cs_t  =   cnt [10];

    always_ff @(posedge clk) begin
        sck_q <= #1 sck;

        if( ~sck & sck_q )
            cs_o <= #1 cs_t;
    end

    assign cs = cs_o;

    wire sample_bit = ( cs == 1'b0 && cnt [4:0] == 4'b1111 );
    wire value_done = ( cnt [10:0] == 11'b0 );

    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            shift <= 32'h0000;
            value <= 16'h0000;
        end
        else if (sample_bit)
        begin
            shift <= (shift << 1) | sdo;
        end
        else if (value_done)
        begin
            //value[15:0] <= shift[30:7];
            value[23:0] <= shift[30:7];
        end
    end

    always_ff @ (posedge clk)
        value_we <= value_done;


endmodule
