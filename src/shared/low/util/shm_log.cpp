

#include "shm_buffer.h"
#include "shm_log.h"
#include <vector>
#include <stdarg.h>

shm_log::shm_log( char* name, int size_mb, int is_write_to_file )
{
    if( size_mb>4095 )
        size_mb=4095;

    _max_size = size_mb * 1024 * 1024;
    _current_size = 0;
    _is_write_to_file = is_write_to_file;

    strncpy( _fname, name, 128 );

    _p_shm_buffer = new shm_buffer( name, 1, size_mb * 1024 * 1024 );
    _buf = (char*) (_p_shm_buffer->get_block_addr(0));
    memset( _buf, 0, _max_size );
}

shm_log::~shm_log()
{
    if( _is_write_to_file )
    {
        FILE *f = fopen( _fname, "wb" );
        fwrite( _buf, _current_size, 1, f );
        fclose( f );
    }

    delete _p_shm_buffer;
    _p_shm_buffer = NULL;
    _buf = NULL;

}

int shm_log::printf( char* fmt, ... )
{
    int ret;
    char str[4096];
    va_list aptr;
    va_start(aptr, fmt);
    ret = vsprintf( str, fmt, aptr );
    va_end(aptr);

    if( ret )
    {
        if( (_current_size+ret)>=_max_size )
            return 0;
            
        char *src = str;
        char *dst = _buf + _current_size;
        for( int ii=0; ii<ret; ii++ )
        {
            *dst++ = *src++;
        }
        *dst++ = 0;
        _current_size += ret;
    }
    return ret;
}
