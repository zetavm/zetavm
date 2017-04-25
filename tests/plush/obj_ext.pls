#language "lang/plush/0"

var a = { x:1, y:2 };
var b = a::{ x:3, z:4 };

assert (b.x == 3);
assert (b.z == 4);
assert (b.y == 2);
a.y += 1;
assert (b.y == 3);

a.foo = function (self) { return self.x; };
assert (b:foo() == 3);
