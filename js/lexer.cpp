#include "lexer.h"

StrStream::StrStream(std::string str, std::string file)
{
    this->str = str;
    this->file = file;
    this->index = 0;
    this->line = 1;
    this->col = 1;
}
