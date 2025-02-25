
#pragma once

#include <QWidget> 
#include <QTableView>
#include <QPlainTextEdit>


class tf_global_data;

class tc_svga_wg;


class tc_svga : public QWidget
{

    CS_OBJECT(tc_svga)

    public:

        static tc_svga* _p_instance;

        explicit tc_svga( uint id, tf_global_data  *p_global_data, QWidget *parent = nullptr);
        ~tc_svga();

        void updateSvgaScreen();
        
    private:

        uint _id;
        tf_global_data  *_p_global_data;


        tc_svga_wg      *_p_svga_wg;


};