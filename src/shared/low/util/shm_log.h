
#pragma once

#include <stdio.h>

class shm_buffer;

class shm_log
{

    private:

        uint32_t        _current_size=0;
        uint32_t        _max_size=0;
        shm_buffer      *_p_shm_buffer=0;

        char            *_buf=0;

        int             _is_write_to_file=0;

        char            _fname[128];

    public:

        shm_log( char* name, int size_mb, int is_write_to_file );
        ~shm_log();

        int printf( char* fmt, ... );


};