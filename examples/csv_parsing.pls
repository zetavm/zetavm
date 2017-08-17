#language "lang/plush/0"

// Example command to run this program:
// ./zeta examples/csv_parsing.pls -- examples/GOOG.csv

var csv = import "std/csv/0";
var vm = import "core/vm/0";

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

    var rows = csv.parseFile(fileName);

    // Serialize the rows into a readable format
    print(vm.serialize(rows, false));

    output('number of rows: ');
    output(rows.length);
    output('\n');

    // Success
    return 0;
};
