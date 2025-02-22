

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <error.h>
#include <time.h>
#include <sys/ioctl.h>

#include "ipc.h"
//-----------------------------------------------------------------------------

void IPC_delay(int ms)
{
    // struct timeval tv = {0, 0};
    // tv.tv_usec = 1000*ms;

    // select(0,NULL,NULL,NULL,&tv);

        timespec tm_req, tm_rem;

        long sec = ms / 1000;
        long ns  = (ms %1000) * 1000000L;

        tm_req.tv_sec= sec;
        tm_req.tv_nsec=ns;
        nanosleep( &tm_req, &tm_rem );    
}

//-----------------------------------------------------------------------------

int IPC_getch(void)
{
    int ch;

    while(1)
    {
        size_t size = 0;
    if (ioctl(STDIN_FILENO, FIONREAD, &size) == -1)
            size = 0;
        if(size)
    {
        ch = getchar();
        //read(0, &ch, 1);
        //DEBUG_PRINT("%s(): ch = %d\n", __FUNCTION__, ch );
        break;
    }
    }
    return ch;
}

//-----------------------------------------------------------------------------

 int IPC_getche(void)
{
    return IPC_getch();
}

//-----------------------------------------------------------------------------

int IPC_kbhit(void)
{
    size_t size = 0;
    if (ioctl(STDIN_FILENO, FIONREAD, &size) == -1)
        return 0;

    //DEBUG_PRINT("%s(): size = %d\n", __FUNCTION__, size );

    return size;
}

// Возвращает время в милисекундах
long IPC_getTickCount()
{

    timespec t_current;
    clock_gettime(CLOCK_REALTIME, &t_current);
    long ret = t_current.tv_sec*1000 + t_current.tv_nsec/1000000;


   return ret;
}

static uint64_t start_tick_ns=0;

uint64_t IPC_getStartTickNs()
{

   return start_tick_ns;

}


uint64_t IPC_setStartTickNs()
{
    timespec t_current;
    clock_gettime(CLOCK_REALTIME, &t_current);
    uint64_t ret = t_current.tv_sec*1000000000UL + t_current.tv_nsec;

    start_tick_ns = ret;

    return ret;

}

uint64_t IPC_getTickNs()
{
    timespec t_current;
    clock_gettime(CLOCK_REALTIME, &t_current);
    uint64_t ret = t_current.tv_sec*1000000000UL + t_current.tv_nsec;

    ret -= start_tick_ns;

   return ret;

}

//-----------------------------------------------------------------------------

int IPC_getTime(IPC_TIMEVAL* time_val)
{
    timespec t_current;
    clock_gettime(CLOCK_REALTIME, &t_current);

    IPC_TIMEVAL ret;
    ret.tv_sec = t_current.tv_sec;
    ret.tv_usec = t_current.tv_nsec /1000;
    *time_val = ret;
    return 0;
}

//-----------------------------------------------------------------------------

double IPC_getDiffTime(IPC_TIMEVAL* start, IPC_TIMEVAL* stop)
{
    struct timeval dt;
    dt.tv_sec = stop->tv_sec - start->tv_sec;
    dt.tv_usec = stop->tv_usec - start->tv_usec;
    if(dt.tv_usec<0) {
        dt.tv_sec--;
        dt.tv_usec += 1000000;
    }
    double msTime = dt.tv_sec*1000 + (double)dt.tv_usec/1000;
    return msTime;
}

//-----------------------------------------------------------------------------
