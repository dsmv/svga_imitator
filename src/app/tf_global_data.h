
#pragma once

#include <QObject>
#include <QTimer>

class ta_simulator;

class tf_global_data : public QObject
{

    CS_OBJECT(tf_global_data)

    public:

        QString             _log_str;

        ta_simulator        *_p_simulator;


        uint                _state=0;

        struct svga_state_t
        {
            uint    h_size;
            uint    v_size;
            uint    h_pos_r;
            uint    v_pos_r;
            uint    h_pos_w;
            uint    v_pos_w;
            uint    cadr;
        };

        svga_state_t        _svga;

        QImage              *_p_svga_image;

        tf_global_data();
        ~tf_global_data();


        CS_SIGNAL_1(Public, void updateScreenSize(uint h_size, uint v_size));
        CS_SIGNAL_2(updateScreenSize, h_size, v_size);

        CS_SIGNAL_1(Public, void updateScreenPos( uint cadr, uint h_pos, uint v_pos));
        CS_SIGNAL_2(updateScreenPos, cadr, h_pos, v_pos);

        CS_SIGNAL_1(Public, void showStatusMessage(QString &str, uint time_ms));
        CS_SIGNAL_2(showStatusMessage, str, time_ms);

        void append_log( uint id, QString &str );

        void  log_step();

    private:

        QTimer  *_p_log_timer;

};