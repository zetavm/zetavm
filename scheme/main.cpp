#include <cassert>
#include <cstring>
#include <iostream>
#include <exception>
#include "parser.h"
#include "codegen.h"

int main(int argc, char** argv)
{
    try
    {
        // If we are in test mode
        if (argc == 2 && strcmp(argv[1], "--test") == 0)
        {
            testParser();
            return 0;
        }

        if (argc == 2)
        {
            auto srcFile = argv[1];

            // Parse the source file
            auto srcUnit = parseFile(srcFile);

            // Generate a code string
            auto codeStr = genProgram(std::move(srcUnit));

            // Output the string to standard output
            std::cout << codeStr;

            return 0;
        }

        std::cout << "unrecognized options" << std::endl;
        std::cout << "usage: " << argv[0] << " <in_file> <out_file>" << std::endl;
        return -1;
    }

    catch (ParseError& e)
    {
        std::cerr << e.toString() << std::endl;
        return -1;
    }

    return 0;
}
