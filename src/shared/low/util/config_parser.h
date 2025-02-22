#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include <vector>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <iomanip>

//------------------------------------------------------------------------------

template <typename T> std::string toString(T val)
{
    std::ostringstream oss;
    oss << val;
    return oss.str();
}

//------------------------------------------------------------------------------

template <typename T> std::string toStringHex(T val)
{
	std::ostringstream oss;
	oss << std::hex << val;
	return oss.str();
}

//------------------------------------------------------------------------------

template<typename T> T fromString(const std::string& s)
{
    std::istringstream iss(s);
    T res;
	
	if (strstr(s.c_str(), "0x")) {
        iss >> std::hex >> res;
    } else {
        iss >> res;
    }
    return res;
}

//------------------------------------------------------------------------------

template<typename T> bool get_value(const std::vector<std::string>& optionsList, unsigned& start_index, const std::string& key, T& val)
{
    if(optionsList.empty() || (start_index >= optionsList.size()))
        return false;

    bool found = false;

    for(unsigned i=start_index; i<optionsList.size(); i++) {

        const std::string& opt = optionsList.at(i);
        int begin = opt.find_first_of("=", 0);
        int end = opt.length();

        if(!begin && (begin >= end))
            continue;

        std::string value = opt.substr(++begin, end);
        if(value.empty())
            continue;

        if(strstr(opt.c_str(),key.c_str())) {
            val = fromString<T>(value);
            found = true;
			start_index = i+1;
            break;
        }
    }

    return found;
}

//-----------------------------------------------------------------------------

template<typename T> bool get_value(const std::vector<std::string>& optionsList, unsigned& start_index, const std::string& key, T& val, T default_value)
{
    val = default_value;

    if(optionsList.empty() || (start_index >= optionsList.size()))
        return false;

    bool found = false;

    for(unsigned i=start_index; i<optionsList.size(); i++) {

        const std::string& opt = optionsList.at(i);
        int begin = opt.find_first_of("=", 0);
        int end = opt.length();

        if(!begin && (begin >= end))
            continue;

        std::string value = opt.substr(++begin, end);
        if(value.empty())
            continue;

        if(strstr(opt.c_str(),key.c_str())) {
            val = fromString<T>(value);
            found = true;
            start_index = i+1;
            break;
        }
    }

    return found;
}

//-----------------------------------------------------------------------------

template<typename T> bool get_raw_value(const std::vector<std::string>& optionsList, unsigned& start_index, const std::string& key, T& val, T default_value)
{
    val = default_value;

	if (optionsList.empty() || (start_index >= optionsList.size()))
		return false;

	bool found = false;

	for (unsigned i = start_index; i<optionsList.size(); i++) {

		const std::string& opt = optionsList.at(i);
		int begin = opt.find_first_of("=", 0);
		int end = opt.length();

		if (!begin && (begin >= end))
			continue;

		std::string value = opt.substr(++begin, end);
		if (value.empty())
			continue;

		if (strstr(opt.c_str(), key.c_str())) {
			val = value;
			found = true;
			start_index = i + 1;
			break;
		}
	}

	return found;
}

//-----------------------------------------------------------------------------

template<typename T> bool get_raw_value(const std::vector<std::string>& optionsList, unsigned& start_index, const std::string& key, T& val)
{
    if (optionsList.empty() || (start_index >= optionsList.size()))
        return false;

    bool found = false;

    for (unsigned i = start_index; i<optionsList.size(); i++) {

        const std::string& opt = optionsList.at(i);
        int begin = opt.find_first_of("=", 0);
        int end = opt.length();

        if (!begin && (begin >= end))
            continue;

        std::string value = opt.substr(++begin, end);
        if (value.empty())
            continue;

        if (strstr(opt.c_str(), key.c_str())) {
            val = value;
            found = true;
            start_index = i + 1;
            break;
        }
    }

    return found;
}

//-----------------------------------------------------------------------------

template<typename T> bool get_value(const std::vector<std::string>& optionsList, const std::string& key, T& val)
{
	if (optionsList.empty())
		return false;

	bool found = false;

	for (unsigned i = 0; i<optionsList.size(); i++) {

		const std::string& opt = optionsList.at(i);
		int begin = opt.find_first_of("=", 0);
		int end = opt.length();

		if (!begin && (begin >= end))
			continue;

		std::string value = opt.substr(++begin, end);
		if (value.empty())
			continue;

		if (strstr(opt.c_str(), key.c_str())) {
			val = fromString<T>(value);
			found = true;
			break;
		}
	}

	return found;
}

//-----------------------------------------------------------------------------

template<typename T> bool get_value(const std::vector<std::string>& optionsList, const std::string& key, T& val, T default_value)
{
    val = default_value;

    if (optionsList.empty())
        return false;

    bool found = false;

    for (unsigned i = 0; i<optionsList.size(); i++) {

        const std::string& opt = optionsList.at(i);
        int begin = opt.find_first_of("=", 0);
        int end = opt.length();

        if (!begin && (begin >= end))
            continue;

        std::string value = opt.substr(++begin, end);
        if (value.empty())
            continue;

        if (strstr(opt.c_str(), key.c_str())) {
            val = fromString<T>(value);
            found = true;
            break;
        }
    }

    return found;
}

//-----------------------------------------------------------------------------

/**
* 	\brief 	get value from command line
*
* 	format command line:
* 	<name1> <value1> <name2> <value2>
*
* 	\param	argc		number of argument
* 	\param	argv		pointers to arguments
* 	\param	name		key of argument
* 	\parma	defValue	default value for arguments
*
* 	\return   value of argument or default value of argument
*/
template<typename T> T GetFromCommnadLine(int argc, char **argv, const char* name, T defValue)
{
	T ret = defValue;
	for (int ii = 1; ii<argc - 1; ii++) {
		if (strcmp(argv[ii], name) == 0) {
			std::string val = argv[ii + 1];
			ret = fromString<T>(val);
		}
	}
	return ret;
}

//-----------------------------------------------------------------------------

bool get_sections(const std::string& fname, std::vector<std::string>& sections);
bool get_options(const std::string& fname, std::vector<std::string>& optionsList);
bool get_options(const std::string& fname, const std::string& section, std::vector<std::string>& optionsList);
char* GetConfigFileName(int argc, char **argv, const char* argname);

//-----------------------------------------------------------------------------

#endif // CONFIG_PARSER_H
