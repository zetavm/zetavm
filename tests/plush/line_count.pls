var io = import "core/io";

var str = readFile("tests/plush/line_count.pls");

print(str.length);

var numLines = 0;

if (str.length != 0)
    numLines = 1;

for (var i = 0; i < str.length; i += 1)
{
    var ch = str[i];

    if (ch == '\n')
        numLines = numLines + 1;
}

print(numLines);
assert (numLines == 22);
