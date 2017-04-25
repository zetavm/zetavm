#language "lang/plush/0"

// Function expressions
function () { return 1; };

// Unary expressions
assert (!true == false);
assert (!false == true);

// Binary expressions
assert (1 < 2);
assert (1 <= 2);
assert (1 + 2 == 3);
assert (2 * -1 == -2);
assert (undef == undef);

// Logical conjunction and disjunction
assert (true && true);
assert (!(true && false));
assert (!(false && true));
assert (true || true);
assert (true || false);
assert (false || true);
assert (!(false || false));

// Objects and properties
var obj = { x:1, y:2, z:3, w:1+2 };
assert (obj.x == 1);
assert (obj.y == 2);
assert (obj.z == 3);
assert ('z' in obj);
assert (!('k' in obj));

// Type tests
assert (typeof 1 == "int64");
assert (typeof "str" == "string");
assert (typeof obj == "object");
assert (typeof obj.x == "int64");
assert (typeof undef == "undef");

// Global assignments
var x = 1;
assert (x == 1);
x = 2;
assert (x == 2);
x += 2;
assert (x == 4);

// Exports object
exports.x = 7;
assert (exports.x == 7);

// String operations
"'foo'";
assert ("foo" == "foo");
assert ("foo".length == 3);
assert (''.length == 0);
assert ('\0'.length == 1);
assert ("foo"[0] == "f");
assert ("foo"[1] == "o");
assert ("foo" + "bar" == "foobar");
assert ("f" <= "f");
assert ("f" <= "g");
assert ("c" >= "c");
assert ("c" >= "b");

// Arrays
var arr = [5,7,2];
assert (arr[1] == 7);
assert (arr.length == 3);
