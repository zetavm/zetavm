#language "lang/plush/0"

var obj = {};

obj.a = 333;
assert (obj['a'] == 333);

obj['foobar?'] = 777;
assert (obj['foobar?'] == 777);

var obj2 = { 'C#': 3 };
assert (obj2['C#'] == 3);
