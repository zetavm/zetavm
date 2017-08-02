#include <cassert>
#include <cstring>
#include <iostream>
#include <exception>
#include "parser.h"
#include "interp.h"
#include "packages.h"
#include "opt_parser.h"

int runPkgMain(
    Object pkg,
    std::string pkgName,
    std::vector<std::string> progArgs
)
{
    // If the package has no main function, do nothing
    if (!pkg.hasField("main"))
        return 0;

    auto mainFn = pkg.getFieldObj("main");
    auto params = mainFn.getFieldArr("params");

    Value retVal;

    // If the main function expects an arguments array
    if (params.length() == 1)
    {
        // Create an array to store the program arguments
        auto argVals = Array(1 + progArgs.size());
        argVals.push(String(pkgName));
        for (size_t i = 0; i < progArgs.size(); ++i)
            argVals.push(String(progArgs[i]));

        // Call main with an array of string arguments
        retVal = callExportFn(pkg, "main", { argVals });
    }
    else if (params.length() == 0)
    {
        if (progArgs.size() > 0)
        {
            throw RunError(
                "main function expects zero arguments, "
                "but some were provided"
            );
        }

        // Call main with no arguments
        retVal = callExportFn(pkg, "main");
    }
    else
    {
        throw RunError("main function should either accept 0 or 1 parameter");
    }

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
            return runPkgMain(pkg, pkgName, parser.getProgramArgs());
        }

        // If the package failed to import
        catch (ImportError e)
        {
            // Try loading the package as a local file
            auto pkg = load(pkgName);

            // Initialize the package
            if (pkg.hasField("init"))
                callExportFn(pkg, "init");

            return runPkgMain(pkg, pkgName, parser.getProgramArgs());
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
