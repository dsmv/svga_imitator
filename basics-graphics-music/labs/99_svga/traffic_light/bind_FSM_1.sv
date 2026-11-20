module bind_fsm_1(
input clk,
input rst,
input tick_05s,

output reg red_on,
output reg yellow_on,
output reg green_on
);

logic [2:0] ryg_on;
assign ryg_on = {red_on, yellow_on, green_on};

covergroup cvr @ (posedge clk iff ~rst);

red_toggled : coverpoint red_on
{
    bins lit_up = { 1 };
    bins lit_down = { 0 };
}
yellow_toggled : coverpoint yellow_on {
    bins lit_up = { 1 };
    bins lit_down = { 0 };
}
green_toggled : coverpoint green_on {
    option.at_least = 4;
    bins lit_up = { 1 };
    
}

cross_r_y : cross red_toggled, yellow_toggled {
    bins r_y = binsof(red_toggled.lit_up) && binsof(yellow_toggled.lit_up);
    bins nr_y = binsof(red_toggled.lit_down) && binsof(yellow_toggled.lit_up);
    bins r_ny = binsof(red_toggled.lit_up) && binsof(yellow_toggled.lit_down);
    bins nr_ny = binsof(red_toggled.lit_down) && binsof(yellow_toggled.lit_down);
}

cross_g_r : cross green_toggled, red_toggled {
    illegal_bins g_r = binsof(red_toggled.lit_up) && binsof(green_toggled.lit_up);
}
cross_g_y : cross green_toggled, yellow_toggled {
    illegal_bins g_y = binsof(yellow_toggled.lit_up) && binsof(green_toggled.lit_up);
}


 transitions : coverpoint ryg_on {
    bins t1 = (3'b100 => 3'b110);
    bins t2 = (3'b110 => 3'b001);
    bins t3 = (3'b001 => 3'b000);
    bins t4 = (3'b000 => 3'b001);
    bins t5 = (3'b000 => 3'b010);
    bins t6 = (3'b010 => 3'b100);    
} 

/* cross_r_y : cross green_toggled, yellow_toggled {
    bins r_y = binsof(red_toggled.lit_up) && binsof(yellow_toggled.lit_up);
    bins nr_y = binsof(red_toggled.lit_down) && binsof(yellow_toggled.lit_up);
    bins r_ny = binsof(red_toggled.lit_up) && binsof(yellow_toggled.lit_down);
    bins nr_ny = binsof(red_toggled.lit_down) && binsof(yellow_toggled.lit_down);
}
 */

endgroup

covergroup cvr_tr @ (posedge tick_05s iff ~rst);
main : coverpoint ryg_on {
    bins r_ry_g = (3'b100 [*20] => 3'b110 [*6] => 3'b001 [*20]);
    bins g_0_y_r = (3'b001 [*20] => 3'b000 => 3'b001 => 3'b000 => 3'b001 => 3'b000 => 3'b001 => 3'b000 => 3'b001 => 3'b000 => 3'b010 [*6] => 3'b100);    
}

endgroup

cvr cg = new ();
cvr_tr cg_transitions_05 = new ();
endmodule