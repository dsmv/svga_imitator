#ifndef CONFIG_FILE_H
#define CONFIG_FILE_H



struct config_file_task_data;

class config_file
{
	config_file_task_data  *td;


public:

	config_file();

	~config_file();

	void read_file( char* fname );

	void write_file_start( char* fname );

    void write_file_complete();

    void write_set_current_option( char *option );

    void write_value_uint( char* name, uint32_t val );

    void write_value_float( char* name, float val );

	void set_current_section( char *section );

	int get_value_int( char* name, int& val, int default_value=0 );

	int get_value_uint( char* name, uint32_t& val, uint32_t default_value = uint32_t(0) );

	int get_value_double( char* name, double& val, double default_value=0);

	int get_value_char( char* name, char *val, char *default_value="" );

};

#endif // CONFIG_FILE_H
