


#include "tc_svga_wg.h"

#include <QVBoxLayout>
#include <QPushButton>
#include <QLabel>
#include <QHeaderView>
#include <QPainter>
#include <QImage>


#include "tf_global_data.h"

tc_svga_wg* tc_svga_wg::_p_instance=NULL;

tc_svga_wg::tc_svga_wg( uint id, tf_global_data  *p_global_data, QWidget *parent )
{
    _id = id;
    _p_global_data = p_global_data;

    char str[128];
    sprintf( str, "svga" );


    QString title = QString::fromLatin1( str );

    this->setWindowTitle( title );

    _p_instance=this;

    // this->setMinimumHeight( 770 );
    // this->setMinimumWidth( 1026 );

    _h_size = _p_global_data->_svga.h_size;
    _v_size = _p_global_data->_svga.v_size;

    this->setFixedHeight( _v_size );
    this->setFixedWidth( _h_size );

 }
   
tc_svga_wg::~tc_svga_wg()
{
    _p_instance = NULL;
}


void tc_svga_wg::paintEvent(QPaintEvent *event)
{
    QPainter painter(this);
    //painter.drawImage( 0, 0, _p_image );
    // painter.setPen( Qt::blue);
    // painter.drawLine( 0,0, 1023, 767);
    // painter.drawRect( 0,0,1025, 769);

    painter.drawImage( 0, 0, *(_p_global_data->_p_svga_image) );

}

void tc_svga_wg::updateScreenSize( uint h_size, uint v_size )
{
    _h_size = h_size;
    _v_size = v_size;

    this->setFixedHeight( _v_size );
    this->setFixedWidth( _h_size );

    this->update();
}