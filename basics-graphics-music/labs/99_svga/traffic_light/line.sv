module line_f_x //module for non vertical lines in the form (y=(k/100)x+d).
# (             //k being 100*dy/dx is helpful to improve precision and avoid using non-integer numbers
    parameter    X_START = 0, //inclusive []
                 X_END = 2, //inclusive []
                 K = 1,
                 D = 0,
                 THICKNESS = 1,
                 screen_width  = 640,
                 screen_height = 480,
                 w_x           = $clog2 ( screen_width  ),
                 w_y           = $clog2 ( screen_height )

)(
    input   [w_x     - 1:0] x,
    input   [w_y     - 1:0] y,
    output  logic belongs // l will be set to 1 if y = K*x+D
);
    always_comb
    begin
    // if(rst)
    //     belongs <= '0;
    if ((((100*y >= (K*x+D*100)-100*THICKNESS) && 100*y <= (K*x+D*100)+100*THICKNESS) && (x >= X_START)) && (x <= X_END))
        belongs = '1;
    else
        belongs = '0;
    end



endmodule