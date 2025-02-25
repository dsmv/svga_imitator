
#include "svga_dpi.h"
#include "shm_buffer.h"


shm_buffer 	*g_shmbuffer;
int 		*g_pBuf;
int 		g_size;




/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_init(
	int n)
{

	char *name = "svga_shm";
	g_size = 4*1024*1024;
	g_shmbuffer = new shm_buffer( name, 1, g_size );
	g_pBuf = (int*)g_shmbuffer->get_block_addr(0);

	printf( "%s : %s %p %d\n", __FUNCTION__, name, g_pBuf, g_size );

    return 0;	
}


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_get_param_int(
	int n ,
	int param_index)
{
    int ret=0;
    int* ptr = g_pBuf;

    ret = ptr[param_index];   
	return ret;
}	


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_set_param_int(
	int n ,
	int param_index ,
	int param_value)
{
    int ret=0;
    int* ptr = g_pBuf;
	ptr[param_index] = param_value;
	return 0;
}


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_set_current_tick(
	int n ,
	svLogic cnt_high ,
	svLogic cnt_low)
{
    int* ptr = g_pBuf;
	ptr[8]=cnt_low;
	ptr[9]=cnt_high;
	return 0;
}


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_ready_for_start(
	int n)
{
    int* ptr = g_pBuf;

    ptr[4]=0x123;
    printf( "%s(%d) ptr=%p\n", __FUNCTION__, n, ptr );
    return 0;
}


/* Imported (by SV) function */
DPI_LINKER_DECL DPI_DLLESPEC 
 int svga_dpi_destroy(
	int n)
{
	delete g_shmbuffer; g_shmbuffer = NULL;
    return 0;
}



