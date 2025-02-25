
`default_nettype none 

module sim_inn441
#(
    parameter int       sck_period=320,  //! период тактового сигнала sck, [ns]
    parameter int       s_freq_100[8],   //! значения частоты Гц*100
    parameter int       s_time_ms[8],    //! время в мс когда начинают действовать параметры формирования
    parameter int       s_ampl[8],       //! амплитутда, максимальное значение 2^22-1
    parameter int       s_cnt=0

)
(
    input wire      sck,    //! частота получения данных Fws * 64
    input wire      ws,     //! частота дискретизации АЦП
    input wire      lr,
    output wire     sdo
);


logic [23:0]    adc_sample;
logic           sd;
int             state=0;

int             sck_cnt=0;
int             sck_last=0;
real            phi;
real            adc_sample_f;
integer         ampl = 30000; //8388600;
real            delta_phi=0;

//real current_period = 1000000000.0/2771.8; // текущий период в [ns]

//real current_period = 360776.390792987;
real current_period =3822191.644689065;
real fc = 0;// 1.0*sck_period / current_period;

real s_next_time;
real s_current_time;
real s_current_freq_100;

int  s_index=0;

assign sdo = sd;

initial begin
    for( ; ; ) begin
        @(posedge sck);
        sck_cnt++;
    end;
end

initial begin
    s_index=0;
    s_next_time = s_time_ms[0] * 1000000; // время следующего отсчёта
    
    for( ; ; ) begin
        
        @(posedge sck);
        s_current_time = sck_cnt*sck_period;
        if(  s_current_time > s_next_time ) begin
            ampl = s_ampl[s_index];
            s_current_freq_100 = s_freq_100[s_index];
            current_period = 100000000000.0/s_current_freq_100;
            fc = 1.0*sck_period/current_period;
            s_index++;

            if( s_index>=s_cnt )
                break;

            s_next_time = s_time_ms[s_index] * 1000000; // время следующего отсчёта
        end


    end

end
initial begin

    adc_sample = 24'hFFFFFC;
    sd  <= 1'bz;
    for( ; ; ) begin

        @(negedge ws);

        // фиксация  текущего значения adc_sample
        delta_phi = 2*3.1415926*fc*(sck_cnt-sck_last);
        phi += delta_phi;
        
        adc_sample_f = ampl * $sin(phi);
        adc_sample = adc_sample_f;
        sck_last = sck_cnt;

        for( int ii=0; ii<24; ii++ ) begin
            @(posedge sck);
            sd <= #10 adc_sample[23-ii];
        end
        @(posedge sck);
        @(posedge sck);
        sd <= #10 1'bz;

        // case( state )
        //     0: begin
        //         adc_sample++;    
        //         if( 93==adc_sample )
        //             state = 1;
        //     end

        //     1: begin
        //         adc_sample--;
        //         if( 24'hFFFFFC==adc_sample )
        //             state=0;
        //     end
        // endcase
        
    end
    
end

endmodule

`default_nettype wire