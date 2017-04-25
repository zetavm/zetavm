#pragma once

#include "runtime.h"

/**
Host function wrapper
*/
class HostFn
{
private:

    std::string name;

    size_t numParams;

    void* fptr;

public:

    HostFn(
        std::string name,
        size_t numParams,
        void* fptr
    );

    Value call1(Value arg0);
    Value call2(Value arg0, Value arg1);

    size_t getNumParams() const { return numParams; }
};

/// Load a package based on its path
Object load(std::string pkgPath);

/// Import a package based on its name, and perform caching
Value import(std::string pkgName);
