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

// Instanceof operator
assert (b instanceof a);
assert (!({} instanceof a));

assert ('x' in a);
assert ('y' in b);

// Test the get_field_list instruction
var c = { x:1, y:2, z:3 };
var field_list = $get_field_list(c);
assert(field_list.length == 3);
for (var i = 0; i < field_list.length; i += 1)
{
    assert(field_list[i] in c);
    print(field_list[i]);
}
