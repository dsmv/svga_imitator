


#include "tc_log.h"

#include <QVBoxLayout>
#include <QPushButton>
#include <QLabel>
#include <QHeaderView>


#include "tf_global_data.h"

int tc_log::_is_present=0;

tc_log* tc_log::_p_instance=NULL;

tc_log::tc_log( uint id, tf_global_data  *p_global_data, QWidget *parent )
{
    _id = id;
    _p_global_data = p_global_data;

    char str[128];
    sprintf( str, "rtl" );


    QString title = QString::fromLatin1( str );

    this->setWindowTitle( title );



    QHBoxLayout *hlayout = new QHBoxLayout;

    QPushButton *button1 = new QPushButton("Clear");
    //QPushButton *button2 = new QPushButton("test2");
    hlayout->addWidget(button1);
    hlayout->addStretch();
    //hlayout->addWidget(button2);

    QWidget *hwg = new QWidget();
    hwg->setLayout( hlayout );

    QVBoxLayout *layout = new QVBoxLayout;

    _p_text = new QPlainTextEdit();

    layout->addWidget( _p_text );
    layout->addWidget( hwg );



    this->setLayout( layout );

    _p_text->appendPlainText( _p_global_data->_log_str );
    


   bool ret = connect( button1, &QPushButton::clicked, this, &tc_log::onClickTest1 );
        //ret = connect( button2, &QPushButton::clicked, this, &tc_log::onClickTest2 );

    _p_instance=this;
    _is_present = 1;
}
   
tc_log::~tc_log()
{
    _is_present = 0;
    _p_instance=NULL;

}

void tc_log::onClickTest1()
{
    _p_global_data->_log_str="";
    _p_text->clear();


}

void tc_log::onClickTest2()
{
}


void tc_log::append_log( QString &str )
{
    _p_text->appendPlainText( str );
}
