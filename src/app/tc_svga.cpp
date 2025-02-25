


#include "tc_svga.h"

#include <QVBoxLayout>
#include <QPushButton>
#include <QLabel>
#include <QHeaderView>
#include <QPainter>
#include <QImage>


#include "tf_global_data.h"
#include "tc_svga_wg.h"

tc_svga* tc_svga::_p_instance=NULL;

tc_svga::tc_svga( uint id, tf_global_data  *p_global_data, QWidget *parent )
{
    _id = id;
    _p_global_data = p_global_data;

    char str[128];
    sprintf( str, "svga" );


    QString title = QString::fromLatin1( str );

    this->setWindowTitle( title );



    QHBoxLayout *hlayout = new QHBoxLayout;

    hlayout->addStretch();

    _p_svga_wg = new tc_svga_wg( 0, _p_global_data );
    hlayout->addWidget( _p_svga_wg );
    hlayout->addStretch();
    

    // QPushButton *button1 = new QPushButton("Clear");
    // //QPushButton *button2 = new QPushButton("test2");
    // hlayout->addWidget(button1);
    // hlayout->addStretch();
    // //hlayout->addWidget(button2);

    QWidget *hwg = new QWidget();
    hwg->setLayout( hlayout );

    QVBoxLayout *layout = new QVBoxLayout;

    layout->addStretch();
    layout->addWidget( hwg );
    layout->addStretch();


    // QHBoxLayout *hlayout2 = new QHBoxLayout;

    

    // QPushButton *button1 = new QPushButton("test1");
    // QPushButton *button2 = new QPushButton("test2");
    // hlayout2->addWidget(button1);
    // hlayout2->addWidget(button2);
    // hlayout2->addStretch();

    // QWidget *hwg2 = new QWidget();
    // hwg2->setLayout( hlayout2 );

    //layout->addWidget( hwg2 );

    this->setLayout( layout );

    _p_instance=this;

    this->setMinimumHeight( 800 );
    this->setMinimumWidth( 1044 );

}
   
tc_svga::~tc_svga()
{
    _p_instance = NULL;
}

void tc_svga::updateSvgaScreen()
{
    _p_svga_wg->update();
}