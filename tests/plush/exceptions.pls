#language "lang/plush/0"

var foo = function()
{


};

try
{
    foo();
}
catch (e)
{
    print('caught exception');
}

print('done');
