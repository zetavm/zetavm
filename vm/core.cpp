#include <cassert>
#include <iostream>
#include <regex>
#include <unordered_map>
#include "util.h"
#include "core.h"
#include "parser.h"
#include "interp.h"

HostFn::HostFn(std::string name, size_t numParams, void* fptr)
: name(name),
  numParams(numParams),
  fptr(fptr)
{
}

Value HostFn::call1(Value arg0)
{
    assert (fptr);
    assert (numParams == 1);
    auto f1 = (Value(*)(Value)) fptr;
    return f1(arg0);
}

Value HostFn::call2(Value arg0, Value arg1)
{
    assert (fptr);
    assert (numParams == 2);
    auto f2 = (Value(*)(Value,Value)) fptr;
    return f2(arg0, arg1);
}

void setHostFn(
    Object pkgObj,
    std::string name,
    size_t numParams,
    void* fptr
)
{
    auto fnObj = new HostFn(name, numParams, fptr);

    auto fnVal = Value((refptr)fnObj, TAG_HOSTFN);

    assert (!pkgObj.hasField(name));

    pkgObj.setField(name, fnVal);
}

//============================================================================

Value print_int64(Value val)
{
    assert (val.isInt64());
    std::cout << (int64_t)val;
    return Value::UNDEF;
}

Value print_str(Value val)
{
    assert (val.isString());
    std::cout << (std::string)val;
    return Value::UNDEF;
}

Value read_file(Value fileName)
{
    assert (fileName.isString());
    auto nameStr = (std::string)fileName;

    std::cout << "reading file: " << nameStr << std::endl;

    FILE* file = fopen(nameStr.c_str(), "r");

    if (!file)
    {
        printf("failed to open file\n");
        return Value::FALSE;
    }

    // Get the file size in bytes
    fseek(file, 0, SEEK_END);
    size_t len = ftell(file);
    fseek(file, 0, SEEK_SET);

    char* buf = (char*)malloc(len+1);

    // Read into the allocated buffer
    int read = fread(buf, 1, len, file);

    if (read != len)
    {
        printf("failed to read file");
        return Value::FALSE;
    }

    // Add a null terminator to the string
    buf[len] = '\0';

    // Close the input file
    fclose(file);

    return String(buf);
}

Value get_core_io_pkg()
{
    auto exports = Object::newObject(32);

    setHostFn(exports, "print_int64", 1, (void*)print_int64);
    setHostFn(exports, "print_str"  , 1, (void*)print_str);
    setHostFn(exports, "read_file"  , 1, (void*)read_file);

    return exports;
}

//============================================================================

// Cache of loaded packages
std::unordered_map<std::string, Value> pkgCache;

/// Load a package based on its path
Object load(std::string pkgPath)
{
    Input input(pkgPath);

    Value exportVal;

    // Parse the language directive
    auto langPkgName = parseLang(input);

    // If a language package is specified
    if (langPkgName != "")
    {
        std::cout << "Loading language package" << std::endl;

        auto langPkgVal = import(langPkgName);

        if (!langPkgVal.isObject())
        {
            throw RunError("failed to load parser package");
        }

        auto langPkg = Object(langPkgVal);

        if (!langPkg.hasField("parse_input"))
        {
            throw RunError(
                "parser packages must export a parse_input function"
            );
        }

        // Create an object to pass the input data
        auto inputObj = Object::newObject();
        inputObj.setField("src_name", String(input.getSrcName()));
        inputObj.setField("src_string", String(input.getInputStr()));
        inputObj.setField("str_idx", Value(input.getInputIdx()));
        inputObj.setField("line_no", Value(input.getLineNo()));
        inputObj.setField("col_no", Value(input.getColNo()));

        std::cout << "Calling parse_input" << std::endl;

        // Call the parse_input method exported by the parser package
        ValueVec args;
        args.push_back(inputObj);
        exportVal = callExportFn(langPkg, "parse_input", args);

        std::cout << "Returned from parse_input" << std::endl;
    }
    else
    {
        // Parse the package file contents
        exportVal = parseInput(input);
    }

    if (!exportVal.isObject())
    {
        throw RunError("exports value is not an object");
    }

    auto pkg = Object(exportVal);

    return pkg;
}

/// Import a package based on its name, and perform caching
Value import(std::string pkgName)
{
    // Package names may only contain lowercase identifiers
    // separated by single forward slashes
    std::regex ex("([a-z0-9]+/)*[a-z0-9]+.?[a-z0-9]+");
    if(!regex_match(pkgName, ex))
    {
        std::cout << "invalid package name: \"" << pkgName << "\"" << std::endl;
        return Value::FALSE;
    }

    // If the package is already loaded
    auto itr = pkgCache.find(pkgName);
    if (itr != pkgCache.end())
    {
        return itr->second;
    }

    // Internal/core packages
    if (pkgName == "core/io")
        return get_core_io_pkg();

    std::string pkgPath;

    // If the package name directly maps to a relative path
    if (fileExists(pkgName))
    {
        pkgPath = pkgName;
    }
    else
    {
        pkgPath = PKGS_DIR + pkgName + "/package";

        if (!fileExists(pkgPath))
        {
            // Package not found
            return Value::UNDEF;
        }
    }

    // Load and initialize the package
    auto pkg = load(pkgPath);

    // Cache the package
    pkgCache[pkgName] = pkg;

    // Initialize the package
    if (pkg.hasField("init"))
    {
        callExportFn(pkg, "init");
    }

    return pkg;
}
