`include "config.svh"

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

    //------------------------------------------------------------------------

    assign led        = '0;
    assign abcdefgh   = '0;
    assign digit      = '0;
    // assign red        = '0;
    // assign green      = '0;
    // assign blue       = '0;
    assign sound      = '0;
    assign uart_tx    = '1;
    
    logic [11:0]    color;
    logic [11:0]    color_q;
    
    logic [w_x - 1:0] pixel_x;
    logic [w_y - 1:0] pixel_y;
    
    logic [w_x - 1:0] pixel_x_q;
    logic [w_x - 1:0] pixel_x_q2;

    logic   [3:0]                   osc_vga_r;
    logic   [3:0]                   osc_vga_g;
    logic   [3:0]                   osc_vga_b;
    logic   [3:0]                   osc_state;

   
    logic               rstp;
    logic               vsync;

    logic [15:0]        mic12;

    assign mic12 = mic [23:8];
    
    assign pixel_x = x;
    assign pixel_y = y;

    always @(posedge clk) begin
 
        rstp <= #1 rst;
        pixel_x_q  <= #1 pixel_x;
        pixel_x_q2 <= #1 pixel_x_q;
    
        if( pixel_y>15 && pixel_x>15 && pixel_x<(1024-16) && pixel_y<(768-16))
            //color_q <= display_on & (bitmap_out[pixel_x_q2[3:1]]) ? 12'h0F0 : 0;
            color_q <= #1 { osc_vga_r, osc_vga_g, osc_vga_b };
        else
            color_q <= #1 '0;
    
        vsync <= #1 (pixel_y==0) ? 1'b0 : 1'b1;

    end

    //assign {red, green, blue } = color_q;
    assign red   = color_q[11:8];
    assign green = color_q[7:4];
    assign blue  = color_q[3:0];

    osc_mic 
    #(
        .is_simulation   ( 0 )
    )
    osc_mic
    (
      
        .clk            (   clk         ),
        .reset_p        (   rstp        ),
    
        .data           (   mic12       ),
        .data_we        (   mic_we      ),
    
        .threshold      (   16'h0010    ),
    
    
        .x              (   pixel_x     ),
        .y              (   pixel_y     ),
        .vga_r          (   osc_vga_r   ),
        .vga_g          (   osc_vga_g   ),
        .vga_b          (   osc_vga_b   ),
        .vsync          (   vsync      ),
        .state          (   osc_state   )
    );    

endmodule
