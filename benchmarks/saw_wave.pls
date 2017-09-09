#language "lang/plush/0"

var fill = function (len)
{
    var buf = [];

    print(len);

    var s = 0;

    for (var i = 0; i < len; i = i + 1)
    {
        s = s + 1;
        if (s > 10)
            s = 0;

        buf:push(s);
    }
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var numSecs = string.parseInt(args[1], 10);

    fill(44100 * numSecs);

    return 0;
};
