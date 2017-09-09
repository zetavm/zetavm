#language "lang/plush/0"

var math = import "std/math/0";

var sampleRate = 44100;
var freq = 200;
var ratio = freq * 2 * math.PI / sampleRate;

var fill = function (len)
{
    var buf = [];

    print(len);

    var s = 0;

    for (var i = 0; i < len; i = i + 1)
    {
        var s = math.sin(i * ratio);
        buf:push(s);
    }
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var numSecs = string.parseInt(args[1], 10);

    fill(sampleRate * numSecs);

    return 0;
};
