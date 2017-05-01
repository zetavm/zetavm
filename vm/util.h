#pragma once

#include <cstdio>

static bool fileExists(std::string filePath)
{
    auto fptr = fopen(filePath.c_str(), "r");

    if (fptr)
    {
        fclose(fptr);
        return true;
    }

    return false;
}
