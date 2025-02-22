
#include "ta_simulator.h"
#include "shm_buffer.h"




    
ta_simulator::ta_simulator()
{
	char *name = (char*)"svga_shm";
	_size_w = 1024*1024;
	_p_shm_buffer = new shm_buffer( name, 1, _size_w*4 );
	_p_buf = (uint32_t*)_p_shm_buffer->get_block_addr(0);

	_p_buf[4]=0;
	_p_buf[5]=0;
	_p_buf[6]=0;
	_p_buf[7]=0;
    
}

ta_simulator::~ta_simulator()
{
    delete _p_shm_buffer; _p_shm_buffer = NULL;
    _p_buf = NULL;
}

uint32_t ta_simulator::get_param( uint32_t index )
{
	if( index>=_size_w )
		return 0;
	
	uint32_t ret = _p_buf[index];
	return ret;

}

void ta_simulator::set_param( uint32_t index, uint32_t val )
{
	if( index>=_size_w )
		return;

	_p_buf[index] = val;
}
