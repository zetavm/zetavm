#language "lang/plush/0"

var test = function ()
{
    var obj = { ctr: 0 };

    for (var i = 0; i < 1000000; i += 1)
        obj.ctr += 1;

    return obj.ctr;
};

test();
