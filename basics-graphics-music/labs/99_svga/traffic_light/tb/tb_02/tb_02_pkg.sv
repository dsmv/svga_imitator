
package tb_02_pkg;



    // virtual     axi_stream_if   #( .bytes ( n ) )  _st0;
    // virtual     axi_stream_if   #( .bytes ( n ) )  _st1;


    int                 _cnt_wr=0;
    int                 _cnt_rd=0;
    int                 _cnt_ok=0;  
    int                 _cnt_error=0;
    // int                 _checksum=0;
    int                 _next_cycle=0;
    
    virtual tb_02_if _cn;


    task tb_02_init;
    
    endtask

    task tb_02_prepare;
        

    endtask

    task tb_02_check(input int cycles_cnt);
    for (int ii=0; ii<cycles_cnt; ii++) begin
        check_state('b100, 20);
        check_state('b110, 6);
        check_state('b001, 20);
        check_state('b000, 1);
        check_state('b001, 1);
        check_state('b000, 1);
        check_state('b001, 1);
        check_state('b000, 1);
        check_state('b001, 1);
        check_state('b000, 1);
        check_state('b001, 1);
        check_state('b000, 1);
        check_state('b010, 6);


    end
    endtask
    
    task check_state(input logic [2:0] mask, input int cycle);
    
    automatic int flag_ok;
    automatic int flag_error;
    automatic int cnt_05s;
    automatic logic pred_tick;

    $display("chack_state %h %d", mask, cycle);

    flag_ok = 0;
    flag_error = 0;
    cnt_05s = 0;

    pred_tick = _cn.tick_05s;
    


    for (int ii=0; ii<5; ii++) begin
        @ (posedge _cn.clk);
        if ((_cn.red_on == mask[2]) && (_cn.yellow_on == mask[1] ) && (_cn.green_on==mask[0]))
            break;
    end
    $display("state found");
    for (;;) begin
        @ (posedge _cn.clk);

            if ((_cn.red_on == mask[2]) && (_cn.yellow_on == mask[1] ) && (_cn.green_on==mask[0]))
                flag_ok++;
            else 
                flag_error++;
            if (_cn.tick_05s && ~pred_tick) begin
                cnt_05s++;
                $display("check %d: %h %h %h", cnt_05s, _cn.red_on, _cn.yellow_on, _cn.green_on);
            end
            if(cycle == cnt_05s)
                break;
            pred_tick = _cn.tick_05s;

    end

    if (flag_ok > 0 && flag_error == 0)
        _cnt_ok++;
    else
        _cnt_error++;
$display("%d %d %d %d", _cnt_ok, _cnt_error, flag_ok, flag_error);
endtask

endpackage    