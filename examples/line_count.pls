#language "lang/plush/0"

// Import the IO library so we can read files
var io = import "core/io/0";

/// Main function, gets an array of command-line arguments as input
exports.main = function (args)
{
    if (args.length != 2)
    {
        print('usage: ./zeta ' + args[0] + ' -- <file_name>');

        // Failed
        return -1;
    }

    var fileName = args[1];

    // Read the whole input file as a string
    try
    {
        var str = io.read_file(fileName);
    }
    catch (e)
    {
        print('Failed to open file "' + fileName + '"');

        // Failed
        return -1;
    }

    var numLines = 0;

    if (str.length != 0)
        numLines = 1;

    // For each character
    for (var i = 0; i < str.length; i += 1)
    {
        var ch = str[i];

        if (ch == '\n')
            numLines = numLines + 1;
    }

    print('number of bytes: ');
    print(str.length);
    print('number of lines: ');
    print(numLines);

    // Success
    return 0;
};
