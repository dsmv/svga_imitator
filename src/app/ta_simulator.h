
#pragma once

//#include <stdio.h>
#include <cstdint>

class shm_buffer;

class ta_simulator
{


    shm_buffer  *_p_shm_buffer;
    uint32_t    _size_w;
    uint32_t    *_p_buf;

    public:

    ta_simulator();

    ~ta_simulator();

    uint32_t get_param( uint32_t index );

    void set_param( uint32_t index, uint32_t val );
    
};