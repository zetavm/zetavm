#language "lang/plush/0"

// This test used to fail because the var statement leaves things
// on the temporary stack after the exception is thrown

var io = import "core/io/0";

var b = false;

try
{
    var x = io.read_file("_missing_file_");
}
catch (e)
{
    b = true;
}

assert (b == true);
