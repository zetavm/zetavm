#language "lang/plush/0"

print("init circular1");

var circular2 = import "./tests/plush/circular2.pls";
assert (typeof circular2 == "object");

exports.f1 = function ()
{
    return 1;
};

exports.call_f2 = function ()
{
    return circular2.f2();
};
