#language "lang/plush/0"

// This test used to fail because values are left on the temporary
// stack after the exception is thrown

var idx = function ()
{
    throw "excepshun!";
};

try
{
    [0, 1, 2][idx()];
}
catch (e)
{
    b = true;
}

assert (b == true);
