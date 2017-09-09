#language "lang/plush/0"

var fib = function (n)
{
    if (n < 2)
        return n;

    return fib(n-1) + fib(n-2);
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var n = string.parseInt(args[1], 10);

    var r = fib(n);
    print(r);

    return 0;
};
