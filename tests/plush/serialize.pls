#language "lang/plush/0"

var vm = import "core/vm/0";

var roundTrip = function (val)
{
    var s1 = vm.serialize(val, false);
    var v1 = vm.parse(s1);
    var s2 = vm.serialize(v1, false);

    print(s1);
    print(s2);

    assert (
        s1 == s2,
        "serializing twice does not produce the same string"
    );
};

assert (vm.parse("3;") == 3);
assert (vm.serialize(3, false) == "3;");
assert (vm.serialize(true, false) == "$true;");
assert (vm.serialize([1,2,3], false) == "[1,2,3];");

roundTrip(true);
roundTrip(false);
roundTrip(undef);
roundTrip(1.5f);
roundTrip(3.706f);
roundTrip(777);
roundTrip([1,2,3]);
roundTrip([1,2,[3,4]]);
roundTrip({ a:1, b:2 });

// Referencing a value twice
a1 = [1,2];
a2 = [a1, a1];
roundTrip(a2);

// Cycle
a1 = [];
a2 = [];
a1:push(a2);
a2:push(a1);
roundTrip(a2);

// Cycle
a1 = [];
a2 = [];
a1:push(a2);
a2:push(a1);
roundTrip([a2]);
