#language "lang/plush/0"

var test = function ()
{
    for (var i = 0; i < 100000000; i += 1)
    {
    }

    return i;
};

test();
