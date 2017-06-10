#language "lang/plush/0"

var peval = import 'std/peval/0';

var id = function (x)
{
    return x;
};

var add = function (x, y)
{
    return x + y;
};

var ret7 = peval.curry(id, 7);
assert (ret7() == 7);

var add1 = peval.curry(add, 1);
assert (add1(5) == 6);
