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
               w_y           = $clog2 ( screen_height ),

               IS_SIMULATION = 0 // value for synthesis
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
    input                    vsync,

    output logic [w_red   - 1:0] red,
    output logic [w_green - 1:0] green,
    output logic [w_blue  - 1:0] blue,

    // Microphone, sound output and UART

    input        [         23:0] mic,
    output       [         15:0] sound,

    input                        uart_rx,
    output                       uart_tx,

    // General-purpose Input/Output

    inout        [w_gpio  - 1:0] gpio
);

    //------------------------------------------------------------------------

       assign led        = '0;
    //    assign abcdefgh   = '0;
       assign digit      = 'b1;
    // assign red        = '0;
    // assign green      = '0;
    // assign blue       = '0;
       assign sound      = '0;
       assign uart_tx    = '1;

    //------------------------------------------------------------------------

    wire [w_x * 2 - 1:0] x_2 = x * x;

    // These additional wires are needed
    // because some graphics interfaces have up to 10 bits per color channel

    wire [10:0] x11 = 11' (x);
    wire [ 9:0] y10 = 10' (y);
    
    logic e_line1; 
    logic e_line2; 
    logic e_ellipse_1;

    logic [w_y-1 : 0] not_y;
    assign not_y = ~y; 


    logic tick;

    logic red_on;
    logic green_on;
    logic yellow_on;
    
    tick_05s_generator #( //generates 0.5s ticks when synthesized (IS_SIMULATION == 0) and around 0.5µs ticks if IS_SIMULATION==1
        .clk_mhz(clk_mhz),
        .IS_SIMULATION(IS_SIMULATION)
    ) ticker (
        .clk(clk),
        .rst(rst),
        .tick_05s(tick)
    );
    
    generate 
        if(IS_SIMULATION != 2) begin //if IS_SIMULATION==2 the fsm is completely disabled, as it is not needed to test the vga output
    fsm_1 better_fsm (
        .clk(clk),
        .rst(rst),
        .tick_05s(tick),

        .red_on(red_on),
        .yellow_on(yellow_on),
        .green_on(green_on)
    );
        end else begin
        logic [2 : 0] frame_cnt = 0;
        always_ff @ (posedge vsync) begin
            frame_cnt++;
        end
        assign red_on = frame_cnt[2];
        assign yellow_on = frame_cnt[1];
        assign green_on = frame_cnt[0];
        end
    endgenerate

    line_f_x #(.X_START (301), .X_END (346), .K (-6), .D (395)) line_1( //K = 100*k from geogebra
        .x (x),
        .y (~y),
        .belongs(e_line1)
    );

    

    line_f_x #(.X_START (286), .X_END (301), .K (200), .D (-225)) line_2(
        .x (x),
        .y (~y),
        .belongs(e_line2)
    );

    line_f_x #(.X_START (286), .X_END (299), .K (-67), .D (537), .THICKNESS (1)) line_3(
        .x (x),
        .y (~y),
        .belongs(e_line3)
    );

    line_f_x #(.X_START (346), .X_END (363), .K (-60), .D (582), .THICKNESS (1)) line_4(
        .x (x),
        .y (~y),
        .belongs(e_line4)
    );
    
    line_f_x #(.X_START (299), .X_END (362), .K (43), .D (210), .THICKNESS (1)) line_5(
        .x (x),
        .y (~y),
        .belongs(e_line5)
    );

    line_f_x #(.X_START (148), .X_END (338), .K (0), .D (299), .THICKNESS (0)) line_6(
        // .x(~y),        //This assignment works properly with [8:0] y on a real hardware 640*480 VGA output
        .x ('d512 - y),   //On SVGA, y is [9:0], so ~y would give 1024-y instead of 512-y. This shifts vertical lines into the BACK_PORCH and breaks the picture
        .y (x),
        .belongs(e_line6)
    );

    line_f_x #(.X_START (156), .X_END (346), .K (0), .D (286), .THICKNESS (0), .screen_width(screen_height), .screen_height(screen_width)) line_7(
        .x ('d512 - y),
        // .x(~y),
        .y (x),
        .belongs(e_line7)
    );

    line_f_x #(.X_START (175), .X_END (364), .K (0), .D (363), .THICKNESS (0)) line_8(
        .x ('d512 - y),
        // .x(~y),
        .y (x),
        .belongs(e_line8)
    );

    line_f_x #(.X_START (286), .X_END (299), .K (-60), .D (327), .THICKNESS (1)) line_9(
        .x (x),
        .y (~y), //here 1024-y (~y) and 512-y do not affect the output.
        .belongs(e_line9)
    );

    line_f_x #(.X_START (299), .X_END (362), .K (43), .D (20), .THICKNESS (1)) line_10(
        .x (x),
        .y (~y),
        .belongs(e_line10)
    );

    line_f_x #(.X_START (299), .X_END (362), .K (43), .D (83), .THICKNESS (1)) line_11(
        .x (x),
        .y (~y),
        .belongs(e_line11)
    );

    line_f_x #(.X_START (299), .X_END (362), .K (43), .D (146), .THICKNESS (1)) line_12(
        .x (x),
        .y (~y),
        .belongs(e_line12)
    );

    filled_ellipse yellow_light(
        .x(x),
        .y(~y),
        .belongs(e_yellow)
    );

    filled_ellipse #(.Y_OFFSET(-63)) green_light
    (
        .x(x),
        .y(~y),
        .belongs(e_green)
    );

    filled_ellipse #(.Y_OFFSET(63)) red_light
    (
        .x(x),
        .y(~y),
        .belongs(e_red)
    );

// logic [3:0] mealy_state;
// logic [3:0] next_mealy_state;


    always_comb
    begin
        red   = '1;
        green = '1;
        blue  = '1;

        if (e_line1 || e_line2 || e_line3 || e_line4 || e_line5 || e_line6 || e_line7 || e_line8 || e_line8 ||  e_line9 || e_line10 || e_line11 || e_line12)
        begin
            red   = '0;
            green = '0;
            blue  = '0;
        end
        else begin
            if (e_red) begin
                //red = 4'b1111 - 4'b1001*(red_on==0);
                red = {red_on} ? 4'b1111 : 4'b0010;
                green = '0;
                blue = '0;
            end else if (e_yellow) begin
                // red = 4'b1111 - 4'b1001*(~(yellow_on));
                // green = 4'b1111 - 4'b1001*(~(yellow_on));
                red = {yellow_on} ? 4'b1111 : 4'b0010;
                green = {yellow_on} ? 4'b1111 : 4'b0010;

                blue = '0;
            end else if (e_green) begin
                red = '0;
                //green = 4'b1111 - 4'b1001*(~(green_on));
                //green = 4'b1111;
                green = {green_on} ? 4'b1111 : 4'b0010;

                blue = '0;                
            end
        end
        end

    endmodule
