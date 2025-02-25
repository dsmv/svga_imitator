`include "config.svh"
`include "lab_specific_board_config.svh"

// `define USE_DIGILENT_PMOD_MIC3

`define USE_SDRAM_PINS_AS_GPIO

// `ifdef USE_DIGILENT_PMOD_MIC3
//     `define USE_SDRAM_PINS_AS_GPIO
// `else
//     `define USE_LCD_AS_GPIO
// `endif

`define USE_INTERNALLY_WIDE_COLOR_CHANNELS
`define INSTANTIATE_GRAPHICS_INTERFACE_MODULE

//----------------------------------------------------------------------------

module board_specific_top
# (
    parameter clk_mhz       = 50,
              pixel_mhz     = 25,

              w_key         = 4,
              w_sw          = 4,
              w_led         = 4,
              w_digit       = 4,

              `ifdef USE_SDRAM_PINS_AS_GPIO
              w_gpio        = 14,
              `elsif USE_LCD_AS_GPIO
              w_gpio        = 11,
              `else
              w_gpio        = 1,
              `endif

            //   screen_width  = 640,
            //   screen_height = 480,
              screen_width  = 1024,
              screen_height = 768,

              `ifdef USE_INTERNALLY_WIDE_COLOR_CHANNELS

              w_red         = 4,
              w_green       = 4,
              w_blue        = 4,

              `else

              w_red         = 1,
              w_green       = 1,
              w_blue        = 1,

              `endif

              w_x = 11,
              w_y = 10
            //   w_x           = $clog2 ( screen_width  ),
            //   w_y           = $clog2 ( screen_height )
)
(
    input                  CLK,
    input                  RESET,

    input  [w_key   - 1:0] KEY_SW,
    output [w_led   - 1:0] LED,

    output [          7:0] SEG,
    output [w_digit - 1:0] DIG,

    output                 VGA_HSYNC,
    output                 VGA_VSYNC,
    output                 VGA_R,
    output                 VGA_G,
    output                 VGA_B,

    input                  UART_RXD,
    output                 UART_TXD,

    inout  [w_gpio  - 1:0] PSEUDO_GPIO_USING_SDRAM_PINS,

    inout                  LCD_RS,
    inout                  LCD_RW,
    inout                  LCD_E,
    inout  [          7:0] LCD_D,


    output  wire [3:0]      vgaext_r,
    output  wire [3:0]      vgaext_g,
    output  wire [3:0]      vgaext_b,
    output  wire            vgaext_hsync,
    output  wire            vgaext_vsync    
);

    //------------------------------------------------------------------------

    wire clk =   CLK;
    //wire rst = ~ RESET;
    wire rst;

    //------------------------------------------------------------------------

    wire [w_led   - 1:0] lab_led;

    // Seven-segment display

    wire [          7:0] abcdefgh;
    wire [w_digit - 1:0] digit;

    // Graphics

    wire                 display_on;

    wire [w_x     - 1:0] x;
    wire [w_y     - 1:0] y;

    wire [w_red   - 1:0] red;
    wire [w_green - 1:0] green;
    wire [w_blue  - 1:0] blue;

    assign VGA_R = display_on & ( | red   );
    assign VGA_G = display_on & ( | green );
    assign VGA_B = display_on & ( | blue  );

    assign vgaext_r = {4{display_on}} & red;
    assign vgaext_g = {4{display_on}} & green;
    assign vgaext_b = {4{display_on}} & blue;


    // assign VGA_R = display_on;
    // assign VGA_G = display_on;
    // assign VGA_B = display_on;

    // assign vgaext_r = {4{display_on}};
    // assign vgaext_g = {4{display_on}};
    // assign vgaext_b = {4{display_on}};

    assign vgaext_hsync = VGA_HSYNC;
    assign vgaext_vsync = VGA_VSYNC;


    wire    clk65;
    localparam clk65_mhz       = 50;
    wire    locked;
    logic   interface_rstp;
      

    always @(posedge clk) interface_rstp <= #1 ~RESET;

    //assign  rst = ~RESET || ~locked;
    always @(posedge clk65) rst <= ~RESET || ~locked;

pll50_65 pll
(
	.areset     (   interface_rstp  ),
	.inclk0     (   clk             ),
	.c0         (   clk65           ),
    .locked     (   locked          )
);

    // Sound

    wire [         23:0] mic;
    wire [         15:0] sound;
    wire                 mic_we;

    //------------------------------------------------------------------------

    wire slow_clk;

    slow_clk_gen # (.fast_clk_mhz (clk65_mhz), .slow_clk_hz (1))
    i_slow_clk_gen (.slow_clk (slow_clk), .clk( clk65 ),  .*);

    //------------------------------------------------------------------------

    lab_top
    # (
        .clk_mhz       (   clk65_mhz     ),

        .w_key         (   w_key         ),
        .w_sw          (   w_sw          ),
        .w_led         (   w_led         ),
        .w_digit       (   w_digit       ),
        .w_gpio        (   w_gpio        ),

        .screen_width  (   screen_width  ),
        .screen_height (   screen_height ),

        .w_red         (   w_red         ),
        .w_green       (   w_green       ),
        .w_blue        (   w_blue        )
    )
    i_lab_top
    (
        .clk           (   clk65         ),
        .slow_clk      (   slow_clk      ),
        .rst           (   rst           ),

        .key           ( ~ KEY_SW        ),
        .sw            ( ~ KEY_SW        ),

        .led           (   lab_led       ),

        .abcdefgh      (   abcdefgh      ),
        .digit         (   digit         ),

        .x             (   x             ),
        .y             (   y             ),

        .red           (   red           ),
        .green         (   green         ),
        .blue          (   blue          ),

        .uart_rx       (   UART_RXD      ),
        .uart_tx       (   UART_TXD      ),

        // .mic           (   mic           ),
        // .sound         (   sound         ),
        // .mic_we        (   mic_we        ),

        `ifdef USE_SDRAM_PINS_AS_GPIO
            .gpio ( PSEUDO_GPIO_USING_SDRAM_PINS ),
        `elsif USE_LCD_AS_GPIO
            .gpio ({ LCD_RS, LCD_RW, LCD_E, LCD_D }),
        `endif

            .*   // mic, sound, mc_we
    );

    //------------------------------------------------------------------------

    assign LED       = ~ lab_led;

    assign SEG       = ~ abcdefgh;
    assign DIG       = ~ digit;

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_GRAPHICS_INTERFACE_MODULE

        wire [w_x-1:0] x10; assign x = x10;
        wire [w_y-1:0] y10; assign y = y10;

        vga
        # (
            .N_MIXER_PIPE_STAGES ( 2 ),
            .HPOS_WIDTH ( w_x      ),
            .VPOS_WIDTH ( w_y      ),
        
            // Horizontal constants
        
            .H_DISPLAY           ( 1024  ),  // Horizontal display width
            .H_FRONT             (   24  ),  // Horizontal right border (front porch)
            .H_SYNC              (  136  ),  // Horizontal sync width
            .H_BACK              (  160  ),  // Horizontal left border (back porch)
        
            // Vertical constants
        
            .V_DISPLAY           (  768  ),  // Vertical display height
            .V_BOTTOM            (  29   ),  // Vertical bottom border
            .V_SYNC              (  6    ),  // Vertical sync # lines
            .V_TOP               (  3    ),  // Vertical top border
            
            .CLK_MHZ                (  clk_mhz  ),   // Clock frequency (50 or 100 MHz)
            .PIXEL_MHZ              (  clk_mhz  )  // Pixel clock of VGA in MHz                
        )
        i_vga
        (
            .clk         ( clk65      ),
            .rst         ( rst        ),
            .hsync       ( VGA_HSYNC  ),
            .vsync       ( VGA_VSYNC  ),
            .display_on  ( display_on ),
            .hpos        ( x10        ),
            .vpos        ( y10        ),
            .pixel_clk   (            )
        );

    `endif

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_MICROPHONE_INTERFACE_MODULE

        `ifdef USE_DIGILENT_PMOD_MIC3

            wire [11:0] mic_12;

            digilent_pmod_mic3_spi_receiver i_microphone
            (
                .clk   ( clk                               ),
                .rst   ( rst                               ),
                .cs    ( PSEUDO_GPIO_USING_SDRAM_PINS  [0] ),
                .sck   ( PSEUDO_GPIO_USING_SDRAM_PINS  [6] ),
                .sdo   ( PSEUDO_GPIO_USING_SDRAM_PINS  [4] ),
                .value ( mic_12                            )
            );

            assign PSEUDO_GPIO_USING_SDRAM_PINS [ 8] = 1'b0;  // GND
            assign PSEUDO_GPIO_USING_SDRAM_PINS [10] = 1'b1;  // VCC

            wire [11:0] mic_12_minus_offset = mic_12 - 12'h800;

            assign mic = { { 12 { mic_12_minus_offset [11] } },
                           mic_12_minus_offset };

        //--------------------------------------------------------------------

        `else  // USE_INMP_441_MIC

                           
            // inmp441_mic_i2s_receiver
            // # (
            //     .clk_mhz ( clk_mhz   )
            // )
            // i_microphone
            // (
            //     .clk     ( clk       ),
            //     .rst     ( rst       ),
            //     // .lr      ( LCD_D [5] ),
            //     // .ws      ( LCD_D [3] ),
            //     // .sck     ( LCD_D [1] ),
            //     // .sd      ( LCD_D [2] ),

            //     .lr      ( PSEUDO_GPIO_USING_SDRAM_PINS [5] ),
            //     .ws      ( PSEUDO_GPIO_USING_SDRAM_PINS [3] ),
            //     .sck     ( PSEUDO_GPIO_USING_SDRAM_PINS [1] ),
            //     .sd      ( PSEUDO_GPIO_USING_SDRAM_PINS [0] ),
                                
            //     .value   ( mic       )
            // );

            inmp441_mic_spi_receiver_65m
            i_microphone
            (
                .clk     ( clk65     ),
                .reset   ( rst       ),
                // .lr      ( LCD_D [5] ),
                // .ws      ( LCD_D [3] ),
                // .sck     ( LCD_D [1] ),
                // .sd      ( LCD_D [2] ),

                //.lr      ( PSEUDO_GPIO_USING_SDRAM_PINS [5] ),
                .cs      ( PSEUDO_GPIO_USING_SDRAM_PINS [3] ),
                .sck     ( PSEUDO_GPIO_USING_SDRAM_PINS [1] ),
                .sdo     ( PSEUDO_GPIO_USING_SDRAM_PINS [0] ),
                                
                .value      ( mic       ),
                .value_we   ( mic_we    )
            );
               
            assign PSEUDO_GPIO_USING_SDRAM_PINS [5] = 1'b0; // LR
            assign PSEUDO_GPIO_USING_SDRAM_PINS [6] = 1'b0;  // GND
            assign PSEUDO_GPIO_USING_SDRAM_PINS [4] = 1'b1;  // VCC

        `endif  // USE_INMP_441_MIC

    `endif  // INSTANTIATE_MICROPHONE_INTERFACE_MODULE

    //------------------------------------------------------------------------

    `ifdef INSTANTIATE_SOUND_OUTPUT_INTERFACE_MODULE

        i2s_audio_out
        # (
            .clk_mhz ( clk_mhz   )
        )
        inst_audio_out
        (
            .clk     ( clk       ),
            .reset   ( rst       ),
            .data_in ( sound     ),
            .mclk    ( LCD_E     ),  // Pin 143
            .bclk    ( LCD_RS    ),  // Pin 141
            .lrclk   ( LCD_RW    ),  // Pin 138
            .sdata   ( LCD_D [0] )   // Pin 142
        );                           // GND and VCC 3.3V (30-45 mA)

    `endif

endmodule
