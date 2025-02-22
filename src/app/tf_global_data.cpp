
#include "tf_global_data.h"

#include "ta_simulator.h"

tf_global_data::tf_global_data()
{
 
    _p_simulator = new ta_simulator();

    _p_log_timer = new QTimer( this );

    bool ret = connect( _p_log_timer, &QTimer::timeout, this, &tf_global_data::log_step );

    _p_log_timer->start( 20 );

    //_log_str = "Hello, world!";

}

tf_global_data::~tf_global_data()
{
    _p_log_timer->stop();

    delete _p_simulator; _p_simulator = NULL;
}

void  tf_global_data::log_step()
{
    uint val;
    switch( _state )
    {
        case 0: // wait for start 
        {
            val = _p_simulator->get_param( 4 );
            //if( 0x123==val ) // проверка на запуск симулятора
            {

                _svga.h_pos_w = 0;
                _svga.v_pos_w = 0;

                _svga.h_size = _p_simulator->get_param( 10 );
                _svga.v_size = _p_simulator->get_param( 11 );
                // _svga.h_pos_w = _p_simulator->get_param( 12 );
                // _svga.v_pos_w = _p_simulator->get_param( 13 );
                _svga.h_pos_r = 0;
                _svga.v_pos_r = 0;
                _svga.cadr = 0;

                emit updateScreenSize( _svga.h_size, _svga.v_size );
                _state = 1;
                _p_simulator->set_param( 4, 1 ); // 
            }
            _state = 1;
            break;
        }

        case 1:
        {
            val = _p_simulator->get_param( 4 );
            //if( 0x123==val )
            {   // симулятор перезапущен

                _svga.h_size = _p_simulator->get_param( 10 );
                _svga.v_size = _p_simulator->get_param( 11 );
                _svga.h_pos_r = 0;
                _svga.v_pos_r = 0;

                emit updateScreenSize( _svga.h_size, _svga.v_size );
            }

            // _svga.h_pos_w = _p_simulator->get_param( 12 );
            // _svga.v_pos_w = _p_simulator->get_param( 13 );

            _svga.h_pos_w++;
            if( _svga.h_pos_w==1000 )
            {
                _svga.h_pos_w=0;
                _svga.v_pos_w++;
                if( _svga.v_pos_w==1500 )
                {
                    _svga.v_pos_w=0;
                }
            }


            if( _svga.v_pos_w < _svga.v_pos_r )
                _svga.cadr++;

            if(     _svga.h_pos_w != _svga.h_pos_r  
                ||  _svga.v_pos_w != _svga.v_pos_r 
            )
            {

                emit updateScreenPos( _svga.cadr, _svga.h_pos_w, _svga.v_pos_w );

                _svga.h_pos_r = _svga.h_pos_w;
                _svga.v_pos_r = _svga.v_pos_w;
            }

        }

    }


   // append_log( title->src_id, str );

}


void tf_global_data::append_log( uint id, QString &str )
{
}
