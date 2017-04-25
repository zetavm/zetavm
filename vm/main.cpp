#include <cassert>
#include <cstring>
#include <iostream>
#include <exception>
#include "parser.h"
#include "interp.h"
#include "core.h"

int main(int argc, char** argv)
{
    try
    {
        /*
        initRuntime();
        initParser();
        initInterp();
        */

        // If we are in test mode
        if (argc == 2 && strcmp(argv[1], "--test") == 0)
        {
            testRuntime();
            testParser();
            testInterp();
            return 0;
        }

        if (argc == 2)
        {
            auto fileName = argv[1];
            auto pkg = load(fileName);

            // Initialize the package
            if (pkg.hasField("init"))
            {
                callExportFn(pkg, "init");
            }

            // Call the main function, if present
            if (pkg.hasField("main"))
            {
                auto retVal = callExportFn(pkg, "main");
                return (int64_t)retVal;
            }

            return 0;
        }

        std::cerr << "Invalid command-line arguments" << std::endl;
    }

    catch (RunError& e)
    {
        std::cerr << "ERROR: " << e.toString() << std::endl;
        return -1;
    }

    return 0;
}
