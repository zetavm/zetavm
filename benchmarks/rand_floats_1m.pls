#language "lang/plush/0"

var random = import "std/random/0";

var test = function ()
{
    var rng = random.newRNG(1337);

    for (var i = 0; i < 1000000; i += 1)
    {
        var num = rng:float(0, 1);
    }
};

test();

print('done');
