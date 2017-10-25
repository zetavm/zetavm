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

var sub = function (x, y)
{
    return x - y;
};

var madd = function (x, y, z)
{
    return x + y * z;
};

var ret7 = peval.curry(id, 7);
assert (ret7() == 7);

var add1 = peval.curry(add, 1);
assert (add1(5) == 6);

var addNone = peval.curry2(add, 1, 2);
assert (addNone() == 3);

// peval function
var add2 = peval.peval(add, { x:2 });
assert (add2(3) == 5);
var subNone = peval.peval(sub, { x:5, y:2 });
assert (subNone() == 3);
var m1a = peval.peval(madd, { y: 1 });
assert (m1a(2, 5) == 7);
