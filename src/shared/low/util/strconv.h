#ifndef STRCONV_H
#define STRCONV_H

//------------------------------------------------------------------------------

#include <cstring>
#include <sstream>
#include <vector>

//------------------------------------------------------------------------------
bool checkString(const std::string &s);
void lowercase(std::string &s);
unsigned digit_number(unsigned data_size);
bool is_option(int argc, char **argv, const char* name);
//------------------------------------------------------------------------------

template <typename T>
std::string toString(T val)
{
    std::ostringstream oss;
    oss<< val;
    return oss.str();
}

//------------------------------------------------------------------------------

template<typename T>
T fromString(const std::string& s)
{
    std::istringstream iss(s);
    T res;
    if(strstr(s.c_str(),"0x")) {
        iss >> std::hex >> res;
    } else {
        iss >> res;
    }
    return res;
}

//------------------------------------------------------------------------------

template<typename T>
bool parse_line(std::string &str, std::vector<T> &data)
{
    data.clear();

    // заменяем символы табуляции в строке на пробелы
    for(unsigned i=0; i<str.length(); i++) {
        if(str.at(i) == '\t' || str.at(i) == '\n')
            str[i] = ' ';
    }

    int start = 0;
    int stop = 0;

    do {

        start = str.find_first_not_of(" ", stop);
        stop = str.find_first_of(" ", start);

        if(start == -1)
            break;

        std::string s = str.substr(start,stop - start);

        if(!checkString(s))
            continue;

        T value = fromString<T>(s.c_str());
        data.push_back(value);

    } while (1);

    if(data.empty())
        return false;
    return true;
}

//------------------------------------------------------------------------------

template<typename T> T get_from_cmdline(int argc, char **argv, const char* name, T defValue)
{
    T res(defValue);
    for( int ii=1; ii<argc-1; ii++ ) {
        if(strcmp(argv[ii], name) == 0) {
            std::string val = argv[ii+1];
            res = fromString<T>(val);
        }
    }
    return res;
}

//------------------------------------------------------------------------------

template<typename T> bool get_from_cmdline(int argc, char **argv, const char* name, T defValue, T& value)
{
    value = defValue;
    for( int ii=1; ii<argc-1; ii++ ) {
        if(strcmp(argv[ii], name) == 0) {
            std::string val = argv[ii+1];
            value = fromString<T>(val);
            return true;
        }
    }
    return false;
}

//------------------------------------------------------------------------------

template<typename T> bool is_option(int argc, char **argv, const char* name)
{
    for( int ii=1; ii<argc-1; ii++ ) {
        if(strcmp(argv[ii], name) == 0) {
            return true;
        }
    }
    return false;
}

//------------------------------------------------------------------------------

#endif // STRCONV_H
