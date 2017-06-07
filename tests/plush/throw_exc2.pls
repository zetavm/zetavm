#language "lang/plush/0"

var leThrow = function (x)
{
    throw x + 1;
};

var foo = function(x, y)
{
    leThrow(x);
};

var catchFun = function()
{
    try
    {
        foo(7, 9);
    }
    catch (e)
    {
        print('caught exception');
        assert (e == 8);
    }
};

catchFun();
print('done');
