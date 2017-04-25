#language "lang/plush/0"

var foo = function (x)
{
    var y = x;
    y = y + 1;
    bar();
    return y;
};

var bar = function ()
{
    var y = 0;
};

assert (foo(1) == 2);
