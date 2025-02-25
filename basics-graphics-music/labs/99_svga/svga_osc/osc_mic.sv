
`default_nettype none 

module osc_mic
#(
    parameter               is_simulation=0
)
(
  
    input   wire            clk,
    input   wire            reset_p,

    input   wire [15:0]     data,
    input   wire            data_we,

    input   wire [15:0]     threshold,


    input   wire [10:0]     x,
    input   wire [9:0]      y,
    output  wire [3:0]      vga_r,
    output  wire [3:0]      vga_g,
    output  wire [3:0]      vga_b,

    input   wire            vsync,
    output  wire [3:0]      state
);

logic [3:0]     stp;
logic [10:0]    index_wr;
logic [3:0]     vsync_cnt;

logic [3:0]     n_stp;
logic [10:0]    n_index_wr;
logic [3:0]     n_vsync_cnt;

logic           rstp;

logic [15:0]    mem[1023:0];

logic           vsync_z;
logic           vsync_step;

initial begin
    for( int ii=0; ii<1024; ii++ )
        mem[ii] = 0;
end

always_comb begin

    n_stp = stp;
    n_index_wr = index_wr;
    n_vsync_cnt = vsync_cnt;

    if( 0==n_stp && data_we && data>=threshold ) begin
        n_stp[0] = 1; n_index_wr=0;
    end



    if( stp[0] ) begin
        if( data_we ) begin
            n_index_wr++;
        end

        if( index_wr[10] )
            n_stp[1:0]=2'b10;

    end

    if( 0==n_stp )
        n_vsync_cnt=0;

    if( stp[1] && vsync_step )
        n_vsync_cnt++;

    if( stp[1] && vsync_step && vsync_cnt==4'b1111 )
        n_stp=0;

    
end

always_ff @(posedge clk) begin
    
    if( data_we && stp[0] )
        mem[index_wr[9:0]] <= #1 data;

    rstp <= #1 reset_p;
    vsync_z <= #1 vsync;
    vsync_step <= #1 vsync_z & ~vsync;



    if( rstp ) begin
        stp <= #1 '0;
        index_wr <= #1 '0;
        vsync_cnt <= #1 '0;
    end else begin
        stp <= #1 n_stp;
        index_wr <= #1 n_index_wr;
        vsync_cnt <= #1 n_vsync_cnt;
    end

end

logic [15:0]    curr_val_x;
logic [8:0]     val_y;
logic [9:0]     val_neg_y;
logic [9:0]     val_pos_y;
logic           osc_light;
logic [9:0]     pos_y;
logic [9:0]     neg_y;
always_comb begin

    curr_val_x=mem[x[9:0]];
    val_y[8]   = curr_val_x[15];
    val_y[7:0] = curr_val_x[7:0];

    val_neg_y[7:0] = ~val_y[7:0];
    val_neg_y[9:8] = '0;

    val_pos_y[7:0] = val_y[7:0];
    val_pos_y[9:8] = '0;

    pos_y = 384-y;
    neg_y = y-384;
    // if( y==(384-val_y))
    //     osc_light = 1;
    // else
    //     osc_light = 0;
    if( val_y[8] ) begin
        if( y>384 && y<384+256 ) begin
            if( val_neg_y <= neg_y[9:0] )
                osc_light = 0;
            else
                osc_light = 1;
        end else begin
            osc_light = 0;
        end

    end else begin
        if( y>(384-256) && y<=384 ) begin
            if( val_pos_y[7:0]<=pos_y[9:0])
                osc_light = 0;
            else
                osc_light = 1;
        end else begin
            osc_light = 0;
        end
    end

end

// assign vga_r=0;
// assign vga_g = { 4{osc_light}};
// assign vga_b = 0;

assign vga_r = 4'b0100;
assign vga_g = (osc_light) ? 4'b1111 : 4'b0100;
assign vga_b = 4'b0100;

assign state = stp;

endmodule

`default_nettype wire