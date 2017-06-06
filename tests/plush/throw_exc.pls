#language "lang/plush/0"

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
