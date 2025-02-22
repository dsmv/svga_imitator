
#include <cstdint>

int IPC_getch(void);

int IPC_getche(void);

int IPC_kbhit(void);

void IPC_delay(int ms);

long IPC_getTickCount();

uint64_t IPC_getTickNs();

uint64_t IPC_getStartTickNs();

uint64_t IPC_setStartTickNs();

typedef struct timeval IPC_TIMEVAL;

//! Возвращает в переданном аргументе текущее время в величинах, зависимых от ОС
int	IPC_getTime(IPC_TIMEVAL* time_val);

//! Возвращает разницу между двумя переданными временными метками в миллисекундах
double IPC_getDiffTime(IPC_TIMEVAL* start, IPC_TIMEVAL* stop);
