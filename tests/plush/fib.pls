#language "lang/plush/0"

var fib = function (n)
{
    if (n < 2)
        return n;

    return fib(n-1) + fib(n-2);
};

var r = fib(7);

print(r);

assert (r == 13);
