
#include "tf_global_data.h"

#include "ta_simulator.h"

#include <QImage>

tf_global_data::tf_global_data()
{

    _svga.cadr=0;
    _svga.h_size=1024;
    _svga.v_size=768;
    _svga.h_pos_r=0;
    _svga.v_pos_r=0;
    _svga.h_pos_w=0;
    _svga.v_pos_w=0;

    _state=0;

    _p_svga_image = new QImage( 1024, 768, QImage::Format_RGB32 );
 
    _p_simulator = new ta_simulator();

    _p_log_timer = new QTimer( this );

    bool ret = connect( _p_log_timer, &QTimer::timeout, this, &tf_global_data::log_step );

    _p_log_timer->start( 200 );

    

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
            if( 0x123==val ) // проверка на запуск симулятора
            {

                _svga.h_pos_w = 0;
                _svga.v_pos_w = 0;

                uint w_x, w_y;

                w_x = _p_simulator->get_param( 10 );
                w_y = _p_simulator->get_param( 11 );

                if( w_x>1024 || w_y>768 )
                {
                    _p_simulator->set_param( 4, 0 ); 
                    break;
                }

                _svga.h_size = w_x;
                _svga.v_size = w_y;
                // _svga.h_pos_w = _p_simulator->get_param( 12 );
                // _svga.v_pos_w = _p_simulator->get_param( 13 );
                _svga.h_pos_r = 0;
                _svga.v_pos_r = 0;
                _svga.cadr = 0;

                emit updateScreenSize( _svga.h_size, _svga.v_size );
                _state = 1;
                _p_simulator->set_param( 4, 1 ); // 
                _state = 1;

                _p_svga_image->fill(0);
                QString str = "Start";
                emit showStatusMessage( str, 2000 );
            }
            break;
        }

        case 1:
        {
            val = _p_simulator->get_param( 4 );
            if( 0x123==val )
            {   // симулятор перезапущен


                uint w_x, w_y;

                w_x = _p_simulator->get_param( 10 );
                w_y = _p_simulator->get_param( 11 );

                if( w_x>1024 || w_y>768 )
                {
                    _state = 0;
                    _p_simulator->set_param( 4, 0 ); 
                    break;
                }

                _svga.h_size = w_x;
                _svga.v_size = w_y;

                // _svga.h_size = _p_simulator->get_param( 10 );
                // _svga.v_size = _p_simulator->get_param( 11 );
                _svga.h_pos_r = 0;
                _svga.v_pos_r = 0;
                _svga.cadr=0;

                _p_simulator->set_param( 4, 0 ); 

                _p_svga_image->fill(0);

                emit updateScreenSize( _svga.h_size, _svga.v_size );
                QString str = "Restart";
                emit showStatusMessage( str, 2000 );
            }

            _svga.h_pos_w = _p_simulator->get_param( 12 );
            _svga.v_pos_w = _p_simulator->get_param( 13 );

            if( _svga.h_pos_w>1024 || _svga.v_pos_w>768 )
                break;

            // _svga.h_pos_w++;
            // if( _svga.h_pos_w==1000 )
            // {
            //     _svga.h_pos_w=0;
            //     _svga.v_pos_w++;
            //     if( _svga.v_pos_w==1500 )
            //     {
            //         _svga.v_pos_w=0;
            //     }
            // }


            // if( _svga.v_pos_w < _svga.v_pos_r )
            //     _svga.cadr++;

            if(     _svga.h_pos_w != _svga.h_pos_r  
                ||  _svga.v_pos_w != _svga.v_pos_r 
            )
            {
                uint curr_x = _svga.h_pos_r;
                uint curr_y = _svga.v_pos_r;
                uint index;
                uint color;

                for( ; ; )
                {
                    index = 1024+curr_y*_svga.h_size+curr_x; 
                    color = _p_simulator->get_param( index );
                    _p_svga_image->setPixel( curr_x, curr_y, color );
                    curr_x++;
                    if( curr_x==_svga.h_size ) 
                    {
                        curr_x=0;
                        curr_y++;
                        if( curr_y==_svga.v_size )
                        {
                            QString fname = QString( "svga_%1.png").formatArg(_svga.cadr);
                            _p_svga_image->save( fname );
                            curr_y=0;
                            _svga.cadr++;
                            QString str = QString( "Write file %1").formatArg( fname );
                            emit showStatusMessage( str, 0 );
                        }
                    }
                    if( curr_y==_svga.v_pos_w  && curr_x==_svga.h_pos_w )
                        break;
                }

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
