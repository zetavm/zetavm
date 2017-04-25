#pragma once

#include <cstdio>

bool fileExists(std::string filePath)
{
    auto fptr = fopen(filePath.c_str(), "r");

    if (fptr)
    {
        fclose(fptr);
        return true;
    }

    return false;
}
