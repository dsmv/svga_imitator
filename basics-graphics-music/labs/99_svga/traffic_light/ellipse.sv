module ellipse //module for ellipses of the form 1 = (x-a)^2/b + (y-c)^2/d
# (
    parameter    X_START = 0, //inclusive []
                 X_END = 2, //inclusive []
                 Y_START = 0,
                 Y_END = 1,
                 A = 1,
                 B = 1,
                 C = 1,
                 D = 1,
                 THICKNESS = 10000,
                 screen_width  = 640,
                 screen_height = 480,
                 w_x           = $clog2 ( screen_width  ),
                 w_y           = $clog2 ( screen_height )

)(
    input   clk,
    input   rst,
    input   [w_x     - 1:0] x,
    input   [w_y     - 1:0] y,
    output  logic belongs // l will be set to 1 if y = K*x+D
);
logic [32:0] ellipse_func;

    always_comb
    begin
    //if ((0 <= ((((x-A)*(x-A))/B)+((y-C)*(y-C))/D)) && (1 >= ((((x-A)*(x-A))/B)+((y-C)*(y-C))/D)) && (x >= X_START) && (x <= X_END) && (y >= Y_START) && (y <= Y_END))
    // if ((1 == ((((x-A)*(x-A))/B)+((y-C)*(y-C))/D)) && (x >= X_START) && (x <= X_END) && (y >= Y_START) && (y <= Y_END))

    ellipse_func = (((((x-A)*(x-A)))*D)+((y-C)*(y-C))*B);
    if ((ellipse_func >= B*D-THICKNESS) && (ellipse_func <= B*D+THICKNESS) && (x >= X_START) && (x <= X_END) && (y >= Y_START) && (y <= Y_END))
        belongs = '1;
    else 
        belongs = '0;
    end


endmodule