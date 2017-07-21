#language "lang/plush/0"

print("init circular3");

var circular1 = import "./tests/plush/circular1.pls";
assert (typeof circular1 == "object");
var circular2 = import "./tests/plush/circular2.pls";
assert (typeof circular2 == "object");

assert (circular2.call_f1() == 1);
assert (circular1.call_f2() == 2);

print('done init circular3');
