#include <cassert>
#include <cstring>
#include <iostream>
#include <exception>
#include "parser.h"
#include "interp.h"
#include "packages.h"
#include "opt_parser.h"

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
    BoolOpt test('t', "test", false, "run unit tests");
    OptParser parser;
    parser = parser.add(test);
    try
    {
        //initRuntime();
        //initParser();
        parser.parse(argc, argv);
        initInterp();

        // If we are in test mode
        if (test())
        {
            testRuntime();
            testParser();
            testInterp();
            testOptParser();
            return 0;
        }

        auto pkgName = parser.getProgramName();

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

    catch (ParseException& e)
    {
        std::cout << e.what() << std::endl;
        return -1;
    }

    catch (RunError& e)
    {
        std::cout << "ERROR: " << e.toString() << std::endl;
        return -1;
    }

    return 0;
}
