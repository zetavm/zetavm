#include <cassert>
#include <cstring>
#include <iostream>
#include <exception>
#include "parser.h"
#include "interp.h"
#include "packages.h"

int runPkgMain(Object pkg)
{
    // If the package has no main function, do nothing
    if (!pkg.hasField("main"))
        return 0;

    auto retVal = callExportFn(pkg, "main");

    if (!retVal.isInt32())
    {
        throw RunError(
            "main function should return an int64 value"
        );
    }

    return (int32_t)retVal;
}

int main(int argc, char** argv)
{
    try
    {
        //initRuntime();
        //initParser();
        initInterp();

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
            auto pkgName = argv[1];

            // Try importing and running the package
            try
            {
                auto pkg = import(pkgName);

                return runPkgMain(pkg);
            }

            // If the package failed to import
            catch (ImportError e)
            {
                // Try loading the package as a local file
                auto pkg = load(pkgName);

                // Initialize the package
                if (pkg.hasField("init"))
                {
                    callExportFn(pkg, "init");
                }

                return runPkgMain(pkg);
            }
        }

        std::cout << "Invalid command-line arguments" << std::endl;
    }

    catch (RunError& e)
    {
        std::cout << "ERROR: " << e.toString() << std::endl;
        return -1;
    }

    return 0;
}
