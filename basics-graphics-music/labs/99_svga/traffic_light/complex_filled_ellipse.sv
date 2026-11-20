module filled_ellipse //module for a single ellipse type
# (
    parameter    X_OFFSET = 0,
                 Y_OFFSET = 0,   
                 screen_width  = 640,
                 screen_height = 480,
                 w_x           = $clog2 ( screen_width  ),
                 w_y           = $clog2 ( screen_height )

)(
    input   [w_x     - 1:0] x,
    input   [w_y     - 1:0] y,
    output  logic belongs // l will be set to 1 if y = K*x+D
);
logic [32:0] ellipse_func;

    always_comb
    begin
    //if ((0 <= ((((x-A)*(x-A))/B)+((y-C)*(y-C))/D)) && (1 >= ((((x-A)*(x-A))/B)+((y-C)*(y-C))/D)) && (x >= X_START) && (x <= X_END) && (y >= Y_START) && (y <= Y_END))
    // if ((1 == ((((x-A)*(x-A))/B)+((y-C)*(y-C))/D)) && (x >= X_START) && (x <= X_END) && (y >= Y_START) && (y <= Y_END))

    ellipse_func = 10769*(x-X_OFFSET)*(x-X_OFFSET)-3188*(x-X_OFFSET)*(y-Y_OFFSET)+6633*(y-Y_OFFSET)*(y-Y_OFFSET)-6290153*(x-X_OFFSET)-2333700*(y-Y_OFFSET);
    if (ellipse_func <= -1330819538 && x<400 && x>200)
        belongs = '1;
    else 
        belongs = '0;
    end


endmodule