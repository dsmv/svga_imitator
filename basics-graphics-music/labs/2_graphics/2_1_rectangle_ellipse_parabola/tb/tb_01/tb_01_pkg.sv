
package tb_01_pkg;


    virtual     tb_01_if    _s;

    // virtual     axi_stream_if   #( .bytes ( n ) )  _st0;
    // virtual     axi_stream_if   #( .bytes ( n ) )  _st1;


    int                 _cnt_wr=0;
    int                 _cnt_rd=0;
    int                 _cnt_ok=0;  
    int                 _cnt_error=0;


    task tb_01_init;

        _s.init();
    
    endtask

    task tb_01_prepare;


    endtask


    task tb_01_seq_key;

        $display( "tb_01_seq_key() - start" );
        for( int ii=0; ii<16; ii++ ) begin
            
            @(posedge _s.clk iff ~_s.vsync );

            _s.key <= _s.key + 1;

            @(posedge _s.clk iff _s.vsync );

        end
        $display( "tb_01_seq_key() - complete" );
    endtask

endpackage    