
#pragma once

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <memory>

#include <boost/interprocess/shared_memory_object.hpp>
#include <boost/interprocess/managed_shared_memory.hpp>
#include <boost/interprocess/managed_mapped_file.hpp>

//-----------------------------------------------------------------------------

class shm_buf_impl;

//-----------------------------------------------------------------------------

class shm_buffer {
public:
	shm_buffer() {
	    _data = nullptr;
	    _buffer_size = 0ULL;
	}
    shm_buffer(const std::string& name, size_t block_count, size_t block_size);
    virtual ~shm_buffer();
    uint32_t* get_block_addr(size_t idx);
    size_t get_block_size(size_t idx);
    uint32_t* get_buffer() { return _data; }
    size_t get_buffer_size() { return _buffer_size; }
    uint32_t& operator[] (const size_t idx) {
    	return _data[idx];
    }

private:
    uint32_t* _data;
    size_t _buffer_size;
    std::shared_ptr<shm_buf_impl> _buf;
};

//-----------------------------------------------------------------------------
