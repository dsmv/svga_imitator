


import "DPI-C" function int svga_dpi_init( input int n );
import "DPI-C" function int svga_dpi_get_param_int( input int n, input int param_index );
import "DPI-C" function int svga_dpi_set_param_int( input int n, input int param_index, input int param_value );
import "DPI-C" function int svga_dpi_set_current_tick( input int n, input unsigned cnt_high, input unsigned  cnt_low );
import "DPI-C" function int svga_dpi_ready_for_start( input int n );
import "DPI-C" function int svga_dpi_destroy( input int n );


module tb
(
);


initial begin
    $display( "create svga_dpi.h" );
    svga_dpi_init(0);
end

endmodule

