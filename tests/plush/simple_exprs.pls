#language "lang/plush/0"

// Function expressions
function () { return 1; };

// Comparison operators
assert (true == true, "boolean equality");
assert (!true == false, "boolean negate 1");
assert (!false == true);
assert (1 < 2);
assert (1 <= 2);
assert (undef == undef);
assert ([] != []);
var a1 = [];
assert (a1 == a1);

// Integer and bitwise arithmetic
assert (1 + 2 == 3);
assert (2 * -1 == -2);
assert (4 % 2 == 0);
assert (5 % 2 == 1);
assert (1 + 2 * 3 == 7);
assert (1 * 2 + 3 == 5);
assert (13 * 3 + -5 * 7 == 4);
assert (256 - 64 - 16 == 176);
assert ((3 ^ -2) == -3);
assert ((7 & 3) == 3);
assert ((5 | 2) == 7);
assert (1 << 1 == 2);
assert (1 >> 31 == 0);
assert (1 >>> 31 == 0);
assert (63 >> 4 == 3);
assert (63 >>> 4 == 3);
assert (-1 << 1 == -2);
assert (-1 >> 31 == -1);
assert (-1 >>> 31 == 1);
assert (3 << 2 + 3 == 96);
assert ((9 >> 1 | 1) == 5);
assert (~0 == -1);
assert (~-256 == 255);
assert (-2147483647 + -2147483647 >= 0);
assert (65537 * 65535 == -1);

// Logical expressions
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
assert (obj.w == 3);
assert ('z' in obj);
assert (!('k' in obj));
obj.w = obj.x + obj.z;
assert (obj.w == 4);

// Type tests
assert (typeof 1 == "int32", "int type");
assert (typeof "str" == "string");
assert (typeof obj == "object");
assert (typeof obj.x == "int32", "int property type");
assert (typeof undef == "undef");
var t = typeof 2;
assert (t == "int32");

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
assert ('\x41' == 'A');
assert ($get_char_code('\xF0', 0) == 240);
assert ("f" <= "f");
assert ("f" <= "g");
assert ("c" >= "c");
assert ("c" >= "b");

// Arrays
var arr = [5,7,2];
assert (arr[1] == 7);
assert (arr.length == 3);
arr[0] = 50;
assert (arr[0] == 50);
arr[1] = 100;
assert (arr[1] == 100);
assert (arr[1] == arr[1]);
assert (arr[1] == arr[0] * 2);
assert((arr[0] *= 4) == 200);
assert (arr[0] == arr[1] * 2);
