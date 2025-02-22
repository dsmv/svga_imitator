
#pragma once

#include <QWidget> 
#include <QTableView>
#include <QPlainTextEdit>


class tf_global_data;


class tc_log : public QWidget
{

    CS_OBJECT(tc_log)

    public:

        static tc_log* _p_instance;
        static int _is_present;

        explicit tc_log( uint id, tf_global_data  *p_global_data, QWidget *parent = nullptr);
        ~tc_log();

        void append_log( QString &str );

    private:

        uint _id;
        tf_global_data  *_p_global_data;

        QPlainTextEdit              *_p_text;

        void onClickTest1();

        void onClickTest2();

};

