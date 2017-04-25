#language "lang/plush/0"

var counter = 0;

exports.testVar = 333;

exports.incFn = function ()
{
    counter += 1;
    return counter;
};
