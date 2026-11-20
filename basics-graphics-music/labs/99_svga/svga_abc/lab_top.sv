
`default_nettype none 

module lab_top
# (
    parameter  clk_mhz       = 50,
               w_key         = 4,
               w_sw          = 8,
               w_led         = 8,
               w_digit       = 8,
               w_gpio        = 100,

               screen_width  = 640,
               screen_height = 480,

               w_red         = 4,
               w_green       = 4,
               w_blue        = 4,

               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)
(
    input                        clk,
    input                        slow_clk,
    input                        rst,

    // Keys, switches, LEDs

    input        [w_key   - 1:0] key,
    input        [w_sw    - 1:0] sw,
    output logic [w_led   - 1:0] led,

    // A dynamic seven-segment display

    output logic [          7:0] abcdefgh,
    output logic [w_digit - 1:0] digit,

    // Graphics

    input        [w_x     - 1:0] x,
    input        [w_y     - 1:0] y,

    output logic [w_red   - 1:0] red,
    output logic [w_green - 1:0] green,
    output logic [w_blue  - 1:0] blue,

    // Microphone, sound output and UART

    input        [         23:0] mic,
    output       [         15:0] sound,
    input                        mic_we,

    input                        uart_rx,
    output                       uart_tx,

    // General-purpose Input/Output

    inout        [w_gpio  - 1:0] gpio
);


logic                           rstp;
logic   [3:0]                   key_sw_p_z1;
logic   [3:0]                   key_sw_p_z2;





always @(posedge clk) begin
    rstp <= #1 rst;// || key[0];
    //p0_reset_n <= #1 ~rstp;

    key_sw_p_z1 <= #1 key;
    key_sw_p_z2 <= #1 key_sw_p_z1;
end 



localparam  X_WIDTH = 11,
            Y_WIDTH = 10,
            CLK_MHZ = 50;

wire display_on;

// wire [X_WIDTH - 1:0] x;
// wire [Y_WIDTH - 1:0] y;

logic [11:0]    color;
logic [11:0]    color_q;

logic [X_WIDTH - 1:0] pixel_x;
logic [Y_WIDTH - 1:0] pixel_y;

logic [X_WIDTH - 1:0] pixel_x_q;
logic [X_WIDTH - 1:0] pixel_x_q2;

logic [11:0]                    video_r_addr;
logic [7:0]                     video_r_data;
logic [11:0]                    video_w_addr;
logic [7:0]                     video_w_data;
logic                           video_w_valid;
logic                           video_reset_done;

assign red   = color_q[11:8];
assign green = color_q[7:4];
assign blue  = color_q[3:0];

assign pixel_x = x;
assign pixel_y = y;

logic [7:0]         index; // Character Index
logic [2:0]         sub_index; // Y position in character
logic [7:0]         bitmap_out;        // 8 bit horizontal slice of character

text_rom    text_rom
  (
   .clock           (       clk         ), // Clock
   .index           (       index       ), // Character Index
   .sub_index       (       sub_index   ), // Y position in character

   .bitmap_out      (       bitmap_out  )         // 8 bit horizontal slice of character
   );

// assign index = (pixel_y[9:4]=='d16 && pixel_x[9:4]=='d32) ? 8'h32 : 0;
assign sub_index = pixel_y[3:1];

always @(posedge clk) begin
 
    pixel_x_q  <= #1 pixel_x;
    pixel_x_q2 <= #1 pixel_x_q;

    if( pixel_y>15 && pixel_x>15 && pixel_x<(1024-16) && pixel_y<(768-16))
        color_q <= (bitmap_out[pixel_x_q2[3:1]]) ? 12'h0F0 : 0;
    else
        color_q <= '0;

end

assign video_r_addr = { pixel_y[9:4], pixel_x[9:4] };
assign index = video_r_data;

video_memory
#(
    //.INIT_VALUE                  ( 8'h41 )
    .INIT_VALUE                  ( 8'h20 )
) video_memory
(
    .clk                (       clk     ),
    .reset_p            (       rstp    ),
    .reset_done         (       video_reset_done ),
    .r_addr             (       video_r_addr     ),
    .r_data             (       video_r_data    ),
    .w_addr             (       video_w_addr    ),
    .w_data             (       video_w_data    ),
    .w_valid            (       video_w_valid   )
);

logic [3:0]     stp;

logic [15:0][7:0]  str_data = " Hello, world!  ";


always @(posedge clk) begin
    case( stp )
    0: begin
        video_w_addr <= #1 'h40;
        video_w_data <= #1 8'h30;
        video_w_valid=1;
        stp <= #1 1;
    end

    1: begin

        if( video_w_data == 8'h39 )
            video_w_data <= #1 8'h30;
        else
            video_w_data <= #1 video_w_data + 1;
        
        if( video_w_addr==('h40+63) ) begin

            video_w_addr <= #1 'h40*46;
            video_w_data <= #1 8'h41;
            stp <= #1 2;
        end else begin
            video_w_addr <= #1 video_w_addr + 1;    
        end

    end

    2: begin
        
        if( video_w_addr==('h40*46+63) ) begin
            video_w_addr <= #1 'h40*16;
            video_w_data <= #1 str_data[15];
            stp <= #1 3;
        end else begin
            video_w_addr <= #1 video_w_addr + 1;    
        end


        // if( video_w_data == 8'h39 )
        //     video_w_data <= #1 8'h30;
        // else
        //     video_w_data <= #1 video_w_data + 1;
        video_w_data <= #1 video_w_data + 1;
    end

    3: begin
        
        if( video_w_addr[4] ) begin
            video_w_valid=0;
            stp <= #1 4;
        end else begin
            video_w_addr <= #1 video_w_addr + 1;    
        end

        video_w_data <= #1 str_data[15-video_w_addr[3:0]];
    end


    4: begin
        video_w_valid=0;
    end

    endcase

    if( rstp || ~video_reset_done )
        stp <= #1 '0;

end



endmodule

`default_nettype wire