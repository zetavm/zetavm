#pragma once

#include <string>

struct StrStream
{
public:
    StrStream(std::string str, std::string file);

    std::string str;

    std::string file;

    size_t index;

    size_t line;

    size_t col;
};

class TokenStream
{
public:
    TokenStream(
        StrStream* strStream
    )
    : preStream(new StrStream(*strStream))
    {
    }

    ~TokenStream() {
        delete preStream;
        if (postStream != nullptr)
            delete postStream;
    }

private:
    StrStream* preStream;

    StrStream* postStream;
};
