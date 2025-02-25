
#pragma once

#include <QWidget> 
#include <QTableView>
#include <QPlainTextEdit>


class tf_global_data;


class tc_svga_wg : public QWidget
{

    CS_OBJECT(tc_svga_wg)

    public:

        static tc_svga_wg* _p_instance;

        explicit tc_svga_wg( uint id, tf_global_data  *p_global_data, QWidget *parent = nullptr);
        ~tc_svga_wg();

        void paintEvent(QPaintEvent *event);


    private:

        uint _id;
        tf_global_data  *_p_global_data;

        QImage      *_p_image;



};