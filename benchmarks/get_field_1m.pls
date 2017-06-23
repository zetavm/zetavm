#language "lang/plush/0"

var test = function ()
{
    var obj = { v: 1 };

    var sum = 0;

    for (var i = 0; i < 1000000; i += 1)
        sum += obj.v;

    return sum;
};

test();
