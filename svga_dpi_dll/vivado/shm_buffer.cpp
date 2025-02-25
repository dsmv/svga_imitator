
#include "shm_buffer.h"

#include <cstdint>

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

using namespace boost::interprocess;
using namespace std;

//-----------------------------------------------------------------------------

using simple_shm_t  = std::shared_ptr<boost::interprocess::shared_memory_object>;
using map_region_t  = std::shared_ptr<boost::interprocess::mapped_region>;

//-----------------------------------------------------------------------------

class shm_buf_impl
{
public:
    shm_buf_impl() {
    	_data = nullptr;
    }
    virtual ~shm_buf_impl() {
    	std::cout << __func__ << ": remove buffer - " << _name.c_str() << std::endl;
    	//shared_memory_object::remove(_name.c_str());
    }
    bool create_buffer(const std::string& name, size_t block_count, size_t block_size);
    void* get_block_addr(size_t idx);
    size_t get_block_size(size_t idx);
    void* get_buffer() { return _data; }
    size_t get_buffer_size() { return _block_count*_block_size; }

private:
    std::string		_name;
    simple_shm_t    _simple_shm;
    map_region_t    _region;
    size_t          _size;
    size_t          _block_count;
    size_t          _block_size;
    void*       	_data;
};

//-----------------------------------------------------------------------------

void* shm_buf_impl::get_block_addr(size_t idx)
{
    if(!_data) return nullptr;
    if(idx >= _block_count) return nullptr;

    return (uint8_t*)_data + idx * _block_size;
}

//-----------------------------------------------------------------------------

size_t shm_buf_impl::get_block_size(size_t idx)
{
    if(!_data) return 0;
    if(idx >= _block_count) return 0;
    return _block_size;
}

//-----------------------------------------------------------------------------

bool shm_buf_impl::create_buffer(const std::string& name, size_t block_count, size_t block_size)
{
    _block_count = block_count;
    _block_size = block_size;
    _size = _block_count*_block_size;
    _simple_shm = std::make_shared<boost::interprocess::shared_memory_object>(open_or_create, name.c_str(), read_write);
    if(!_simple_shm.get())
        return false;

    _simple_shm->truncate(_size);
    _region = std::make_shared<boost::interprocess::mapped_region>(*_simple_shm.get(), read_write);
    _data = _region->get_address();
    _name = name;

    std::cout << "REGION: " << name.c_str() << " - " << std::hex << _region->get_address() << " [0x" << _region->get_size() << "]" << std::endl;

    return true;
}

//-----------------------------------------------------------------------------

shm_buffer::shm_buffer(const std::string& name, size_t block_count, size_t block_size)
{
    _buf = std::make_shared<shm_buf_impl>();
    _buf->create_buffer(name, block_count, block_size);
    _buffer_size = block_count * block_size;
}

//-----------------------------------------------------------------------------

shm_buffer::~shm_buffer()
{
}

//-----------------------------------------------------------------------------

size_t shm_buffer::get_block_size(size_t idx)
{
    return _buf->get_block_size(idx);
}

//-----------------------------------------------------------------------------

uint32_t* shm_buffer::get_block_addr(size_t idx)
{
    return (uint32_t*)_buf->get_block_addr(idx);
}

//-----------------------------------------------------------------------------
