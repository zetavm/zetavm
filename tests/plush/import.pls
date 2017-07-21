#language "lang/plush/0"

var module = import "./tests/plush/module.pls";

assert (
    module != undef,
    "failed to import module"
);

assert (typeof module == "object");
assert (module.testVar == 333);
assert (module.incFn() == 1);

var module2 = import "./tests/plush/module.pls";
assert (module2.incFn() == 2);
