#language "lang/plush/0"

print("init circular2");

var circular1 = import "./tests/plush/circular1.pls";
assert (typeof circular1 == "object");

exports.f2 = function ()
{
    return 2;
};

exports.call_f1 = function ()
{
    return circular1.f1();
};
