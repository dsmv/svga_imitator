
import "DPI-C" function int svga_dpi_init( input int n );
import "DPI-C" function int svga_dpi_get_param_int( input int n, input int param_index );
import "DPI-C" function int svga_dpi_set_param_int( input int n, input int param_index, input int param_value );
import "DPI-C" function int svga_dpi_set_current_tick( input int n, input unsigned cnt_high, input unsigned  cnt_low );
import "DPI-C" function int svga_dpi_ready_for_start( input int n );
import "DPI-C" function int svga_dpi_destroy( input int n );


module sim_svga
# (
    parameter  clk_mhz       = 50,

               screen_width  = 640,
               screen_height = 480,

               w_red         = 4,
               w_green       = 4,
               w_blue        = 4,

               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)
(
    input wire                     clk,
    input wire                     rst, // 1 - reset

    // Graphics
    input wire                    display_on,
    input wire [w_x     - 1:0]    x,
    input wire [w_y     - 1:0]    y,

    input wire                    hsync,
    input wire                    vsync,

    input wire [w_red   - 1:0]    red,
    input wire [w_green - 1:0]    green,
    input wire [w_blue  - 1:0]    blue
);

logic [31:0]    color;
int             index;

initial begin

    svga_dpi_init( 0 );

    svga_dpi_set_param_int( 0, 10, screen_width  );
    svga_dpi_set_param_int( 0, 11, screen_height );

    svga_dpi_set_param_int( 0, 12, 0 );
    svga_dpi_set_param_int( 0, 13, 0 );

    svga_dpi_ready_for_start( 0 );

    @(posedge clk iff ~rst);

    for( ; ; ) begin
        
        @(posedge clk iff display_on);

        if( x>screen_width || y>screen_height )
            continue;
            
        color[8*3+:8] = '0;
        color[8*2+:8] = { red  [3:0], 4'b0 };
        color[8*1+:8] = { green[3:0], 4'b0 };
        color[8*0+:8] = { blue [3:0], 4'b0 };

        index = y*screen_width + x;

        svga_dpi_set_param_int( 0, 1024+index, color );

        svga_dpi_set_param_int( 0, 12, x );
        svga_dpi_set_param_int( 0, 13, y );
    
    end
    
end

endmodule