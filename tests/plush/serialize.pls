#language "lang/plush/0"

var vm = import "core/vm/0";

var roundTrip = function (val)
{
    // Test with minification enabled
    var s1 = vm.serialize(val, true);
    //print(s1);
    var v1 = vm.parse(s1);
    var s2 = vm.serialize(v1, true);
    //print(s2);

    assert (
        s1 == s2,
        "serializing twice does not produce the same string"
    );

    // Test again with minification disabled
    var s1 = vm.serialize(val, false);
    //print(s1);
    var v1 = vm.parse(s1);
    var s2 = vm.serialize(v1, false);
    //print(s2);

    assert (
        s1 == s2,
        "serializing twice does not produce the same string with minification disabled"
    );
};

assert (vm.parse("3;") == 3);
assert (vm.serialize(3, true) == "3;");
assert (vm.serialize(true, true) == "$true;");
assert (vm.serialize([1,2,3], true) == "[1,2,3];");

roundTrip(true);
roundTrip(false);
roundTrip(undef);
roundTrip(1.5f);
roundTrip(3.706f);
roundTrip(777);
roundTrip([1,2,3]);
roundTrip([1,2,[3,4]]);
roundTrip({ a:1, b:2 });
roundTrip({ a:1, b:2, c:[3,4] });
roundTrip("foobar");
roundTrip("foo\nbar");
roundTrip("foo\"bar");
roundTrip("\"");
roundTrip("\'");
roundTrip("\n");
roundTrip("\\");
roundTrip("\xF0");

// Object with non-identifier field name
obj = {};
obj["a b"] = true;
roundTrip(obj);

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

// Reference to cycle
a1 = [];
a2 = [];
a1:push(a2);
a2:push(a1);
roundTrip([a2]);

// Serializing, parsing and then calling a function
var fibPkg = import "./tests/vm/ex_fibonacci.zim";
var fib = fibPkg.fib;
var str = vm.serialize(fib, false);
//print(str);
var fib2 = vm.parse(str);
assert (fib(10) == fib2(10));
roundTrip(fib);

// Object with a method (parsed by the Plush package)
var obj = {
    count: 0,
    incr: function (self) { self.count += 1; }
};
obj:incr();
var str = vm.serialize(obj, false);
//print(str);
//print(str.length);
var obj2 = vm.parse(str);
obj2:incr();
assert (obj2.count == 2);
