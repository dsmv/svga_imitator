
#include <stdio.h>
#include <signal.h>
#include <assert.h>
#include <fstream>

#include "exceptinfo.h"
#include "config_file.h"

#include "config_parser.h"
//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------

struct config_file_task_data
{
	std::string fname;
	std::vector<std::string> optList;

    FILE    *fw;
};


config_file::config_file()
{
	td = new config_file_task_data();
}

config_file::~config_file()
{

	delete td; td = NULL;
}

void config_file::read_file( char* fname )
{
	td->fname = fname;
}

void config_file::write_file_start( char* fname )
{
    td->fw = fopen( fname, "wt" );
}

void config_file::write_file_complete()
{
    if( td->fw )
        fclose( td->fw );
}

void config_file::write_set_current_option( char *option )
{
    if( td->fw )
        fprintf( td->fw, "[%s]\n", option );
}


void config_file::write_value_uint( char* name, uint32_t val )
{
    if( td->fw )
        fprintf( td->fw, "%s= %u\n", name, val );
}

void config_file::write_value_float( char* name, float val )
{
    if( td->fw )
        fprintf( td->fw, "%s= %f\n", name, val );

}


void config_file::set_current_section( char *section )
{
	get_options( td->fname, section, td->optList );
}

int config_file::get_value_int( char* name, int& val, int default_value )
{

    int ret;
	int val_i;

	ret = get_value( td->optList, name, val_i, default_value );
	val = val_i;
	return ret;
}

int config_file::get_value_uint( char* name, uint32_t& val, uint32_t default_value )
{

	int ret;
	uint32_t val_i;

	ret = get_value( td->optList, name, val_i, default_value );
	val = val_i;
	return ret;
}

int config_file::get_value_double( char* name, double& val, double default_value )
{

	int ret;
	double val_i;

	ret = get_value( td->optList, name, val_i, default_value );
	val = val_i;
	return ret;
}

int config_file::get_value_char( char* name, char *val, char *default_value )
{

// char name_i[256];
// char default_i[256];

	int ret;
	std::string val_i;
	std::string default_s = default_value;

	ret = get_value( td->optList, name, val_i, default_s );

	//// надо отрезать кавычки
	//char str[256];
	//sprintf( str, "%s", val_i.c_str() );
	//int len = strlen( str );
	//if( len>0 )
	// str[len-1] = 0;

//	BRDC_sprintf( val, _BRDC( "%hs" ), val_i.c_str() );
	sprintf( val, "%s", val_i.c_str() );
	return ret;
}

