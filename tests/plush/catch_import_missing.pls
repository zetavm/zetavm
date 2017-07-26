#language "lang/plush/0"

var b = false;

try
{
    //var pkg = import "_missing_package_";
    import "_missing_package_";
}
catch (e)
{
    b = true;
}

assert (b == true);
