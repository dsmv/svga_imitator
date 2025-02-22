
#include <string>
#include <sstream>
#include <vector>
#include <cstring>

//------------------------------------------------------------------------------
using namespace std;
//------------------------------------------------------------------------------

bool checkString(const std::string &s)
{
    for(unsigned i=0; i<s.length(); i++) {
        if(!isdigit(s.at(i))) {
            if(s.at(i) == '+')
               continue;
            if(s.at(i) == '-')
               continue;
            if(s.at(i) == '.')
               continue;
            return false;
        }
    }
    return true;
}

//------------------------------------------------------------------------------

void lowercase(std::string &s)
{
    for(unsigned i=0; i<s.length(); i++) {
        s.at(i) = tolower(s.at(i));
    }
}

//------------------------------------------------------------------------------

unsigned digit_number(unsigned data_size)
{
    unsigned n = 1;
    unsigned den = 10;
    for(unsigned i=0; i<9; i++) {
        if(data_size / den) {
            den *= 10;
            ++n;
        }
    }
    return n;
}

//-----------------------------------------------------------------------------

bool is_option(int argc, char **argv, const char* name)
{
    for( int ii=1; ii<argc; ii++ ) {
        if(strcmp(argv[ii], name) == 0) {
            return true;
        }
    }
    return false;
}

//------------------------------------------------------------------------------

