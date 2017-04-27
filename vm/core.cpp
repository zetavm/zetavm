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

Value HostFn::call0()
{
    assert (fptr);
    assert (numParams == 0);
    auto f0 = (Value(*)()) fptr;
    return f0();
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

Value HostFn::call3(Value arg0, Value arg1, Value arg2)
{
    assert (fptr);
    assert (numParams == 3);
    auto f3 = (Value(*)(Value,Value,Value)) fptr;
    return f3(arg0, arg1, arg2);
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
// core/io package
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
// core/window package
//============================================================================

#ifdef HAVE_SDL2

#include <SDL.h>

size_t width = 0;
size_t height = 0;

std::vector<uint8_t> pixelBuffer;

SDL_Window* window = nullptr;
SDL_Renderer* renderer = nullptr;
SDL_Texture* texture = nullptr;

Value create_window(
    Value titleVal,
    Value widthVal,
    Value heightVal
)
{
    SDL_Init(SDL_INIT_VIDEO);

    auto title = (std::string)titleVal;
    width = (size_t)(int64_t)widthVal;
    height = (size_t)(int64_t)heightVal;

    window = SDL_CreateWindow(
        title.c_str(),
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        width,
        height,
        0
    );

    renderer = SDL_CreateRenderer(window, -1, 0);

    texture = SDL_CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STATIC,
        width,
        height
    );

    pixelBuffer.resize(width * height * 4, 0);

    SDL_ShowWindow(window);

    return Value::UNDEF;
}

Value destroy_window()
{
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    pixelBuffer.clear();

    return Value::UNDEF;
}

Value process_events()
{
    // FIXME
    // How do we know when quit happened? Return false then?
    // Maybe change go let users do the polling, write our own loop?

    SDL_Event event;

    while (SDL_PollEvent(&event))
    {
        switch (event.type)
        {
            case SDL_QUIT:
            //quit = true;
            return Value::FALSE;
            break;

            default:
            break;
        }
    }

    return Value::TRUE;
}

Value draw_pixels(Value pixelsArray)
{
    auto pixels = (Array)pixelsArray;

    assert (pixels.length() == width * height * 3);

    for (size_t pixIdx = 0; pixIdx < width * height; ++pixIdx)
    {
        // SDL's RGBA888 is actually ABGR, because of course.
        pixelBuffer[4*pixIdx+0] = 255;
        pixelBuffer[4*pixIdx+1] = (uint8_t)(int64_t)pixels.getElem(3*pixIdx+2);
        pixelBuffer[4*pixIdx+2] = (uint8_t)(int64_t)pixels.getElem(3*pixIdx+1);
        pixelBuffer[4*pixIdx+3] = (uint8_t)(int64_t)pixels.getElem(3*pixIdx+0);
    }

    SDL_UpdateTexture(texture, NULL, &pixelBuffer[0], width * 4);
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
    return Value::UNDEF;
}

#endif // HAVE_SDL2

Value get_core_window_pkg()
{
#ifdef HAVE_SDL2
    auto exports = Object::newObject(32);
    setHostFn(exports, "create_window"  , 3, (void*)create_window);
    setHostFn(exports, "destroy_window" , 0, (void*)destroy_window);
    setHostFn(exports, "process_events" , 0, (void*)process_events);
    setHostFn(exports, "draw_pixels"    , 1, (void*)draw_pixels);
    return exports;
#else
    return Value::UNDEF;
#endif
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

std::string findPkgPath(std::string pkgName)
{
    // If the package name directly maps to a relative path
    if (fileExists(pkgName))
        return pkgName;

    // Look in the package directory
    auto pkgPath = PKGS_DIR + pkgName + "/package";
    if (fileExists(pkgPath))
        return pkgPath;

    // Not found
    return "";
}

Value getCorePkg(std::string pkgName)
{
    // Internal/core packages
    if (pkgName == "core/io")
        return get_core_io_pkg();
    if (pkgName == "core/window")
        return get_core_window_pkg();

    return Value::UNDEF;
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

    // If we can find a package file for this name
    auto pkgPath = findPkgPath(pkgName);
    if (pkgPath != "")
    {
        // Load the package file
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

    // If we can find a core package for this name
    auto corePkg = getCorePkg(pkgName);
    if (corePkg != Value::UNDEF)
    {
        pkgCache[pkgName] = corePkg;
        return corePkg;
    }

    // Package not found
    return Value::UNDEF;
}
