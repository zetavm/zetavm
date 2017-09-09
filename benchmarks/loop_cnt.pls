#language "lang/plush/0"

var test = function (itrCount)
{
    for (var i = 0; i < itrCount; i += 1)
    {
    }

    return i;
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var math = import "std/math/0";
    var n = string.parseInt(args[1], 10);
    var itrCount = math.pow(10, n);
    print('itrCount: {}':format([itrCount]));

    test(itrCount);

    return 0;
};
