#language "lang/plush/0"

var identFn = function (x)
{
    return x;
};

var r = identFn(333);

assert (r == 333);
