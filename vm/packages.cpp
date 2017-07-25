#include <cassert>
#include <iostream>
#include <regex>
#include <unordered_map>
#include "util.h"
#include "packages.h"
#include "parser.h"
#include "interp.h"

#ifdef HAVE_SDL2
#include <SDL.h>
#endif

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
// core/io/0 package
//============================================================================

namespace core_io_0
{
    Value print_int32(Value val)
    {
        assert (val.isInt32());
        std::cout << (int32_t)val;
        return Value::UNDEF;
    }

    Value print_float32(Value val)
    {
        assert (val.isFloat32());
        std::cout << (float)val;
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
            throw RunError("failed to open file \"" + nameStr + "\"");
        }

        // Get the file size in bytes
        fseek(file, 0, SEEK_END);
        size_t len = ftell(file);
        fseek(file, 0, SEEK_SET);

        char* buf = (char*)malloc(len+1);

        // Read into the allocated buffer
        size_t read = fread(buf, 1, len, file);

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

    Value write_file(Value fileName, Value data)
    {
        assert (fileName.isString());
        assert (data.isString());

        auto nameStr = (std::string)fileName;

        std::cout << "writing file: " << nameStr << std::endl;

        FILE* file = fopen(nameStr.c_str(), "w");

        if (!file)
        {
            throw RunError("failed to open file \"" + nameStr + "\"");
        }

        auto dataStr = String(data);

        fwrite(
            dataStr.getDataPtr(),
            dataStr.length(),
            1,
            file
        );

        fclose(file);

        return Value::TRUE;
    }

    Value read_line()
    {
        char* lineBuf = nullptr;
        size_t bufSize = 0;

        auto numRead = getdelim(&lineBuf, &bufSize, '\n', stdin);

        if (numRead <= 0)
        {
            free(lineBuf);
            return Value::UNDEF;
        }

        // Clear trailing end of line characters
        for (ssize_t i = 0; i < numRead; ++i)
        {
            size_t idx = numRead - 1 - i;

            if (lineBuf[idx] == '\n' || lineBuf[idx] == '\r')
            {
                lineBuf[idx] = '\0';
            }
            else
            {
                break;
            }
        }

        auto str = String(lineBuf);
        free(lineBuf);

        return str;
    }

    Value get_pkg()
    {
        auto exports = Object::newObject(32);
        setHostFn(exports, "print_int32"  , 1, (void*)print_int32);
        setHostFn(exports, "print_float32", 1, (void*)print_float32);
        setHostFn(exports, "print_str"    , 1, (void*)print_str);
        setHostFn(exports, "read_file"    , 1, (void*)read_file);
        setHostFn(exports, "write_file"   , 2, (void*)write_file);
        setHostFn(exports, "read_line"    , 0, (void*)read_line);
        return exports;
    }
}

//============================================================================
// core/window/0 package
//============================================================================

namespace core_window_0
{
#ifdef HAVE_SDL2
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
        width = (size_t)(int32_t)widthVal;
        height = (size_t)(int32_t)heightVal;

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
            pixelBuffer[4*pixIdx+1] = (uint8_t)(int32_t)pixels.getElem(3*pixIdx+2);
            pixelBuffer[4*pixIdx+2] = (uint8_t)(int32_t)pixels.getElem(3*pixIdx+1);
            pixelBuffer[4*pixIdx+3] = (uint8_t)(int32_t)pixels.getElem(3*pixIdx+0);
        }

        SDL_UpdateTexture(texture, NULL, &pixelBuffer[0], width * 4);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
        return Value::UNDEF;
    }
#endif // HAVE_SDL2

    Value get_pkg()
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
}

//============================================================================
// core/audio/0 package
//============================================================================

namespace core_audio_0
{
#ifdef HAVE_SDL2
    bool paused = true;

    Value open_output_device(
        Value num_channels
    )
    {
        assert(num_channels.isInt32());

        SDL_Init(SDL_INIT_AUDIO);
        SDL_AudioSpec want, have;

        SDL_zero(want);
        want.freq = 44100;
        want.format = AUDIO_F32;
        want.channels = (uint8_t)(int32_t)num_channels;
        want.samples = 4096;
        want.callback = NULL;

        auto devId = (int32_t)SDL_OpenAudioDevice(NULL, 0, &want, &have, SDL_AUDIO_ALLOW_ANY_CHANGE);

        assert (want.format == have.format);
        assert (want.freq == have.freq);
        assert (want.channels = have.channels);

        return Value::int32(devId);
    }

    Value queue_samples(
        Value dev,
        Value samplesArray
    )
    {
        assert(dev.isInt32());
        assert(samplesArray.isArray());
        auto devID = (int32_t)dev;

        if (paused)
        {
            paused = false;
            SDL_PauseAudioDevice(devID, 0);
        }

        auto samples = (Array)samplesArray;

        if (samples.length() == 0)
            return Value::UNDEF;

        float samples_buf[samples.length()];

        for (size_t i = 0; i < samples.length(); i++)
        {
            auto elem = samples.getElem(i);

            if (!elem.isFloat32())
            {
                throw RunError("audio samples must be float32");
            }

            float sample = (float)elem > 1.0f ? 1.0f : elem;
            sample = sample < -1.0f ? -1.0f : sample;
            samples_buf[i] = sample;
        }

        if (SDL_QueueAudio(devID, samples_buf, sizeof(samples_buf)) != 0)
        {
            return Value::FALSE;
        }

        return Value::TRUE;
    }

    Value get_queue_size(
        Value dev
    )
    {
        assert(dev.isInt32());

        auto devID = (int32_t)dev;

        auto numBytes = SDL_GetQueuedAudioSize(devID);
        auto numSamples = numBytes / 4;

        return Value::int32((int32_t)numSamples);
    }

    Value close_output_device(
        Value dev
    )
    {
        assert(dev.isInt32());

        auto devID = (int32_t)dev;
        SDL_CloseAudioDevice(devID);

        return Value::UNDEF;
    }
#endif // HAVE_SDL2

    Value get_pkg()
    {
#ifdef HAVE_SDL2
        auto exports = Object::newObject(32);
        setHostFn(exports, "open_output_device" , 1, (void*)open_output_device);
        setHostFn(exports, "close_output_device", 1, (void*)close_output_device);
        setHostFn(exports, "queue_samples"      , 2, (void*)queue_samples);
        setHostFn(exports, "get_queue_size"     , 1, (void*)get_queue_size);
        return exports;
#else
        return Value::UNDEF;
#endif
    }
}

//============================================================================
// core/vm/0 package
//============================================================================

namespace core_vm_0
{
    Value import(Value pkgName)
    {
        assert (pkgName.isString());
        return ::import(std::string(pkgName));
    }
};

HostFn importFn("import", 1, (void*)core_vm_0::import);

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
        //std::cout << "Loading language package" << std::endl;

        auto langPkg = import(langPkgName);

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
        inputObj.setField("str_idx", Value::int32(input.getInputIdx()));
        inputObj.setField("line_no", Value::int32(input.getLineNo()));
        inputObj.setField("col_no", Value::int32(input.getColNo()));

        //std::cout << "Calling parse_input" << std::endl;

        // Call the parse_input method exported by the parser package
        ValueVec args;
        args.push_back(inputObj);
        exportVal = callExportFn(langPkg, "parse_input", args);

        //std::cout << "Returned from parse_input" << std::endl;
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

Value getCorePkg(std::string pkgName)
{
    // Internal/core packages
    if (pkgName == "core/io/0")
        return core_io_0::get_pkg();
    if (pkgName == "core/window/0")
        return core_window_0::get_pkg();
    if (pkgName == "core/audio/0")
        return core_audio_0::get_pkg();

    return Value::UNDEF;
}

/// Import a package based on its name, and perform caching
Object import(std::string pkgName)
{
    // If the package is already loaded
    auto itr = pkgCache.find(pkgName);
    if (itr != pkgCache.end())
    {
        return Object(itr->second);
    }

    std::string pkgPath = "";

    // If this is a local import
    if (pkgName.substr(0, 2) == "./")
    {
        if (!fileExists(pkgName))
        {
            throw ImportError("local package not found \"" + pkgName + "\"");
        }

        pkgPath = pkgName;
    }

    // Otherwise, this is a global import
    else
    {
        if (!regex_match(pkgName, std::regex("([a-z0-9]+/)*[0-9]+")))
        {
            throw ImportError("invalid global package name \"" + pkgName + "\"");
        }

        // Look in the package directory
        auto pkgDirPath = PKGS_DIR + pkgName + "/package";

        if (fileExists(pkgDirPath))
        {
            pkgPath = pkgDirPath;
        }
    }

    // If a package file was found for the given package name
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
        return Object(corePkg);
    }

    // Package not found
    throw ImportError("global package not found \"" + pkgName + "\"");
}
