// test 1 - checks the sequence of lights
// test 2 - checks the sequence of lights using covergroups
import tb_02_pkg::*;

module tb
();

int       test_id=0;

string	test_name[1:0]=
{
 "covergroups", 
 "lights" 
};


logic next_loop = 0;

bit test_result=0;

logic [3:0] stp;
logic [3:0] n_stp;


logic rst;

initial begin  : create_time_diagram
$dumpfile("dump.vcd");
$dumpvars(2);
end


task test_finish;
        input int 	test_id;
        input string	test_name;
        input int		result;
begin

  automatic int fd = $fopen( "global.txt", "a" );

  $display("");
  $display("");

  if( 1==result ) begin
      $fdisplay( fd, "test_id=%-5d test_name: %15s         TEST_PASSED", 
      test_id, test_name );
      $display(      "test_id=%-5d test_name: %15s         TEST_PASSED", 
      test_id, test_name );
  end else begin
      $fdisplay( fd, "test_id=%-5d test_name: %15s         TEST_FAILED *******", 
      test_id, test_name );
      $display(      "test_id=%-5d test_name: %15s         TEST_FAILED *******", 
      test_id, test_name );
  end
  //$display("coverage of covergroup cg = %0f", uut.dut.cg.get_coverage());
  $fclose( fd );
  
  $display("");
  $display("");

  $finish();
end endtask  
// logic previous_tick_05s;
// always_ff @ (posedge clk)
//     previous_tick_05s <= ~tick_05s;
    


/////////////////////////////////////////////////////////////////


logic               clk=0;
logic               reset_n;

logic               test_start=0;
logic               test_timeout=0;
logic               test_done=0;

real               cv_all;


initial begin : check_timeout
//  #100000;
  #300ms;
  $display( "Timeout");
  test_timeout = '1;
end


// Main process  
initial begin  : main_process

  automatic int args=-1;
  
  if( $value$plusargs( "test_id=%0d", args )) begin
      if( args>=0 && args<2 )
      test_id = args;

      $display( "args=%d  test_id=%d", args, test_id );

  end

  $display("tb_01  test_id=%d  name:", test_id, test_name[test_id] );
  rst = 1;
  test_init();
  
  //reset_n = '0;

  #100;

  //reset_n = '1;
  rst = 0;
  repeat (2) @(posedge clk );

  test_start <= #1 '1;


  @(posedge clk iff test_done=='1 || test_timeout=='1);

  if( test_timeout ) 
      _cnt_error++;

//   $display( "cnt_wr: %d", _cnt_wr );
//   $display( "cnt_rd: %d", _cnt_rd );
  $display( "cnt_ok: %d", _cnt_ok );
  $display( "cnt_error: %d", _cnt_error );
  $display("coverage of covergroup cg = %0f", uut.dut.cg.get_coverage());
    $display("coverage of covergroup cg_transitions_05 = %0f", uut.dut.cg_transitions_05.get_coverage());

  
  // $display("coverage of covergroup cg.transitions  = %0f", uut.dut.cg.transitions.get_coverage());
  //$display("overall coverage = %0f", $get_coverage());

  if( 0==_cnt_error && _cnt_ok>0 )
      test_finish( test_id, test_name[test_id], 1 );
  else
      test_finish( test_id, test_name[test_id], 0 );

end

//always @(posedge clk ) cv_all = $get_coverage();





always #7.7 clk = ~clk; // 65 MHz

task tb_init;


    reset_n = '0;

    tb_02_init();

endtask

// Generate test sequence 
initial begin : generate_test_sequence


  tb_init();

  @(posedge clk iff test_start=='1); #1;

  reset_n = '1;
      
  case( test_id )
    0: begin

        
        tb_02_prepare();
        tb_02_check(5);
        
        // fork
        //     tb_02_seq_direct();
        //     tb_02_monitor( _st1 );
        // join
        #200ns;


        test_done=1;        

     end

    1: begin
       
       
       #33000ns
       if(uut.dut.cg.get_coverage()==100.0)
           _cnt_ok++; 
        else
            _cnt_error++;
        
       if(uut.dut.cg_transitions_05.get_coverage()==100.0)
           _cnt_ok++; 
        else
            _cnt_error++;

       //test_finish(1, test_name[1], (uut.dut.cg.get_coverage()==100.0));
       #200ns
       test_done=1;        
    end


  endcase
end


logic               slow_clk;
logic [3:0]         key;
logic [3:0]         sw;
logic [3:0]         led;

// A dynamic seven-segment displa

logic [7:0]         abcdefgh;
logic [9:0]         digit;

localparam          clk_mhz = 65;
localparam          w_x = 11;
localparam          w_y = 10;

logic               display_on;
logic               hsync;
logic               vsync;


logic [w_x-1:0]     x;
logic [w_y-1:0]     y;

logic [3:0]         red;
logic [3:0]         green;
logic [3:0]         blue;
logic [15:0]        sound;
logic               uart_rx;
logic               uart_tx;


// General-purpose Input/Output

wire [99:0]         gpio;
//logic tick_05s;

tb_02_if cn(clk);


tick_05s_generator #(
    .IS_SIMULATION(1),
    .clk_mhz(clk_mhz)
) ticker(
    .clk(clk),
    .rst(rst),
    .tick_05s(cn.tick_05s)
//    .tick_05s(tick_05s)
); 

fsm_1 uut (
    .clk(clk),
    .rst(rst),
    .tick_05s(cn.tick_05s),

    .red_on(cn.red_on),
    .yellow_on(cn.yellow_on),
    .green_on(cn.green_on)
    // .stp(stp),
    // .n_stp(n_stp)
);  // Unit under test
// insert the component bind_user_axis into the component user_axis for simulation purpose
bind fsm_1 bind_fsm_1 dut(.*);

task test_init ();
_cn = cn;

endtask

logic [3:0] previous_stp;

always @ (posedge clk or posedge rst) begin // Used to determine if the 1st loops is over
    if(rst)
        next_loop <= '0;
    else  if (stp [3:0]== '0 && n_stp [3:0] == 4'b0001)
                next_loop <= #1000ns 1;
end
endmodule