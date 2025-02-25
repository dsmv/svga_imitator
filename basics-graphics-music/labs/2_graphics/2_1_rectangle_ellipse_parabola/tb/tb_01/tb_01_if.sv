// import ex_types_pkg::*;
// import connect_pkg::*;


interface tb_01_if(  input wire clk );


    logic [3:0]         key;

    logic               vsync;
    logic               hsync;

    task init;

        key = 0;

    endtask
    
endinterface //tb_01_if


