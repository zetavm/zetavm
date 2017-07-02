#language "lang/plush/0"

var test = function ()
{
    var obj = { v: 1 };

    for (var i = 0; i < 1000000; i += 1)
        obj.v = i;

    return obj.v;
};

test();
