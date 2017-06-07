#language "lang/plush/0"

// Test one level of stack unwinding along with a unit-level exception
// handler. The catch variable is implemented differently for
// unit-level functions.

var foo = function()
{
    throw "foo";
};

try
{
    foo();
}
catch (e)
{
    print('caught exception');
    assert (e == "foo");
}

print('done');
