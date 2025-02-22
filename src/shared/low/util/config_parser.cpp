
#include <stdio.h>
#include <signal.h>
#include <assert.h>
#include <fstream>

#include "exceptinfo.h"
#include "config_parser.h"

//-----------------------------------------------------------------------------

using namespace std;

//-----------------------------------------------------------------------------

struct space_info {
	std::vector<std::string>  segment_name;     //!< Имена всех сегментов в файле конфигурации
};

//-----------------------------------------------------------------------------

bool get_sections(const std::string& fname, std::vector<std::string>& sections)
{
	std::fstream  ifs;
	std::string   str;

	ifs.open(fname.c_str());
	if (!ifs.is_open()) {
		return false;
	}

	while (!ifs.eof()) {

		getline(ifs, str);

		if (strstr(str.c_str(), "[")) {

			int begin = 0;
			int end = 0;

			begin = str.find_first_not_of("[", end);
			end = str.find_first_of("]", begin);

			if (begin != -1) {

				string name = str.substr(begin, end - begin);
				sections.push_back(name);
			}
		}
	}

	return !sections.empty();
}

//-----------------------------------------------------------------------------

bool get_options(const std::string& fname, std::vector<std::string>& optionsList)
{
	std::fstream ifs;
    ifs.open(fname.c_str(), std::ios::in);
    if (!ifs.is_open()) {
        throw except_info("%hs, %d: %hs():\n Can't open configuration file: %hs\n", __FILE__, __LINE__, __FUNCTION__, fname.c_str());
    }

    optionsList.clear();

    while(!ifs.eof()) {

        std::string str;
        getline(ifs, str);

        if(!str.length())
            continue;

        // заменяем символы табуляции в строке на нули
        for(unsigned i=0; i<str.length(); i++) {
            if(str.at(i) == '\t' || str.at(i) == '\n' || str.at(i) == '\r' || str.at(i) == '#' || str.at(i) == ';')
                str[i] = '\0';
        }

        if(strstr(str.c_str(),"#")) {
            continue;
        }

        if(strstr(str.c_str(),";")) {
            continue;
        }

		if(strstr( str.c_str(), "/" )) {
			continue;
		}

        if(strstr(str.c_str(),"=")) {
            optionsList.push_back(str);
        }
    }

    return !optionsList.empty();
}

//------------------------------------------------------------------------------

bool get_options(const std::string& fname, const std::string& section, std::vector<std::string>& optionsList)
{
	std::fstream ifs(fname.c_str(), std::ios::in);
	if (!ifs.is_open()) {
		throw except_info("%hs, %d: %hs():\n Can't open configuration file: %hs\n", __FILE__, __LINE__, __FUNCTION__, fname.c_str());
	}

	optionsList.clear();

	// найдем секцию
	bool found = false;
	while (!ifs.eof()) {

		std::string str;
		getline(ifs, str);

		if (!str.length())
			continue;

		// заменяем символы табуляции в строке на нули
		for (unsigned i = 0; i < str.length(); i++) {
			if (str.at(i) == '\t' || str.at(i) == '\n' || str.at(i) == '\r' || str.at(i) == '#' || str.at(i) == ';')
				str[i] = '\0';
		}

		if (strstr(str.c_str(), "[")) {

			int begin = 0;
			int end = 0;

			begin = str.find_first_not_of("[", end);
			end = str.find_first_of("]", begin);

			if (begin != -1) {

				string name = str.substr(begin, end - begin);
				if (name != section) {
					continue;
				}

				found = true;
				break;
			}
		}
	}

	// не нашли указанной секции
	if (!found) return false;

	while (!ifs.eof()) {

		std::string str;
		getline(ifs, str);

		if (!str.length())
			continue;

		// заменяем символы табуляции в строке на нули
		for (unsigned i = 0; i < str.length(); i++) {
			if (str.at(i) == '\t' || str.at(i) == '\n' || str.at(i) == '\r' || str.at(i) == '#' || str.at(i) == ';')
				str[i] = '\0';
		}

		// встретили конец секции
		if (strstr(str.c_str(), "[")) {
			break;
		}

		if (strstr(str.c_str(), "#")) {
			continue;
		}

		if (strstr(str.c_str(), ";")) {
			continue;
		}

		if (strstr(str.c_str(), "=")) {
			optionsList.push_back(str);
		}
	}

	return !optionsList.empty();
}

//------------------------------------------------------------------------------

/**
 * 	\brief 	get configuration filename from command line
 *
 * 	format command line:
 * 	<arg1> <filename1> <arg2> <filename2>
 *
 * 	\param	argc		number of argument
 * 	\param	argv		pointers to arguments
 * 	\param	name		key of argument
 *
 * 	\return   pointer to filename or 0
 */
char* GetConfigFileName(int argc, char **argv, const char* argname)
{
    for( int ii=1; ii<argc-1; ii++ ) {
        if(strcmp(argv[ii], argname) == 0) {
            return argv[ii+1];
        }
    }
    return 0;
}

//-----------------------------------------------------------------------------
