#language "lang/plush/0"

var random = import "std/random/0";

var test = function (numFloats)
{
    var rng = random.newRNG(1337);

    for (var i = 0; i < numFloats; i += 1)
    {
        var num = rng:float(-1.0f, 1.0f);
    }
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var exp = string.parseInt(args[1], 10);
    var numFloats = 1 << exp;

    test(numFloats);

    return 0;
};
