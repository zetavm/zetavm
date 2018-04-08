#language "lang/plush/0"

var str = import "std/string/0";
var array = import "std/array/0";
var arrayEq = array.arrayEq;

var assertThrows = function (fun)
{
    var threw = false;
    try
    {
        fun();
    }
    catch (e)
    {
        threw = true;
    }
    assert (threw);
};

var indexOf = str.indexOf;
var substring = str.substring;
var indexofcheck = function(string, needle)
{
    var pos = indexOf(string, needle);
    if (pos != -1)
    {
        var sub = substring(string, pos, pos + needle.length);
        return sub == needle;
    }
    else
    {
        return true;
    }
};

var printa = function(obj)
{
    return str.toString(obj.a);
};

var obj = {
    a : 17,
    toString : printa,
};

assert (str.toString(obj)== "17");
assert (typeof str.toString({}) == "string");
assert (str.toString( [[1], "A string", 3, 4, 5] ) == "[[1], A string, 3, 4, 5]");
assert (str.toString([]) == "[]");

//ord/char
var fromCharCode = str.fromCharCode;
var toCharCode = str.toCharCode;
assert(fromCharCode(toCharCode("a")) == "a");
assert(fromCharCode(toCharCode("\n")) == "\n");
assert(toCharCode(fromCharCode(78)) == 78);

//trim
var trim = str.trim;
var ltrim = str.trim;
var rtrim = str.trim;
assert(rtrim("abc   ") == "abc");
assert(rtrim("abc\n") == "abc");
assert(rtrim("   ") == "");
assert(ltrim("   abc") == "abc");
assert(ltrim("   \nabc") == "abc");
assert(ltrim("   ") == "");
assert(trim("   abc   ") == "abc");
assert(trim("\nabc\n") == "abc");
assert(trim("   ") == "");

//replace
var replace = str.replace;
assert(replace("abcde", "bc", "qe") == "aqede");
assert(replace("abcde", "a", "qe") == "qebcde");
assert(replace("aaaa", "a", "qe") == "qeqeqeqe");
assert(replace("aaaa", "aa", "qe") == "qeqe");
assert(replace("test test", " ", "") == "testtest");
assert(replace("test    test", " ", "") == "testtest");

//split
var split = str.split;
assert(arrayEq(split("a,b,c,d", ","), ["a", "b", "c", "d"]));
assert(arrayEq(split("a,,c,d", ","), ["a", "c", "d"]));
assert(arrayEq(split("a,b,c,", ","), ["a", "b", "c"]));
assert(arrayEq(split(",b,c,d", ","), ["b", "c", "d"]));
assert(arrayEq(split("a,,b,,c,,d", ",,"), ["a", "b", "c", "d"]));
assert(arrayEq(split("a,,,,c,,d", ",,"), ["a", "c", "d"]));
assert(arrayEq(split("a,,b,,c,,", ",,"), ["a", "b", "c"]));
assert(arrayEq(split(",,b,,c,,d", ",,"), ["b", "c", "d"]));
assert(arrayEq(split("", ""), []));
assert(arrayEq(split("", "abc"), []));
assert(arrayEq(split("abc", "abc"), []));
assert(arrayEq(split("abc", "defg"), ["abc"]));

//join
var join = str.join;
var a = "a,b,c,d";
assert(join(split(a, ","), ",") == a);
assert(join([], ", ") == "");
assert(join(["foo"], ", ") == "foo");
assert(join(["foo", "bar"], ", ") == "foo, bar");
assert(join(["foo", "bar", "baz"], ", ") == "foo, bar, baz");

//indexOf
assert(indexOf("", "") == 0);
assert(indexOf("", "a") == -1);
assert(indexOf("", "ab") == -1);
assert(indexOf("BBBB", "B") == 0);
assert(indexofcheck("Blah", "B"));
assert(indexofcheck("BBBB", "B"));
assert(indexofcheck("Blah", "h"));
assert(indexofcheck("Blah", "ah"));
assert(indexofcheck("Banana", "an"));

//contains
var contains = str.contains;
assert(contains("foobar", "foo"));

//format
var format = str.format;
assert(format("{}, {} and {}", ["numbers", 1, 2]) == "numbers, 1 and 2");
assert(format("{0}, {1} and {2}", ["numbers", 1, 2]) == "numbers, 1 and 2");
assert(format("{x}, {y} and {z}", {x: "numbers", y:1, z:2}) == "numbers, 1 and 2");

//substring
assert(substring("abcdefg", 0, 2) == "ab");
assert(substring("abcdefg", 0, 0) == "");

//toLower
var toLower = str.toLower;
assert(toLower("ab cde") == "ab cde");
assert(toLower("AB cde") == "ab cde");
assert(toLower("AB CDE") == "ab cde");

//toUpper
var toUpper = str.toUpper;
assert(toUpper("ab cde") == "AB CDE");
assert(toUpper("AB cde") == "AB CDE");
assert(toUpper("AB CDE") == "AB CDE");

//lpad
var lpad = str.lpad;
assert(lpad("Hello", " ", 7) == "  Hello");
assert(lpad("Hello", ".", 7) == "..Hello");
assert(lpad("Hello", " ", 3) == "Hello");
assert(lpad("Hello", " ", -1) == "Hello");
assertThrows(function () { lpad("Hello", "", 7); });
assertThrows(function () { lpad("Hello", "abcd", 7); });

//lpad
var rpad = str.rpad;
assert(rpad("Hello", " ", 7) == "Hello  ");
assert(rpad("Hello", ".", 7) == "Hello..");
assert(rpad("Hello", " ", 3) == "Hello");
assert(rpad("Hello", " ", -1) == "Hello");
assertThrows(function () { rpad("Hello", "", 7); });
assertThrows(function () { rpad("Hello", "abcd", 7); });

var startsWith = str.startsWith;
assert(startsWith("Banana", "Ban"));
assert(startsWith("Banana", ""));
assert(!startsWith("Banana", "Bun"));
assert(!startsWith("Ban", "Banana"));

var endsWith = str.endsWith;
assert (endsWith("Banana", "na"));
assert (endsWith("Banana", ""));
assert (!endsWith("Banana", "Bun"));
assert ("foobar":endsWith("bar"));

var intToString = str.intToString;
assert(intToString(0, 10) == "0");
assert(intToString(-0, 10) == "0");
assert(intToString(1234, 10) == "1234");
assert(intToString(-1234, 10) == "-1234");
assert(intToString(1234, 16) == "4d2");
assert(intToString(-1234, 16) == "-4d2"); // ??
assert(intToString(1234, 2) == "10011010010");
assert(intToString(1234, 8) == "2322");

var parseInt = str.parseInt;
assert(parseInt("0", 10) == 0);
assert(parseInt("123", 10) == 123);
assert(parseInt("-123", 10) == -123);
assert(parseInt("a", 16) == 10);
assert(parseInt("1010", 2) == 10);
assertThrows(function () { parseInt("", 10); });
assertThrows(function () { parseInt("123abc", 10); });

var parseFloat = str.parseFloat;
assert (parseFloat("0") == 0.0f);
assert (parseFloat("0.5") == 0.5f);

var escapeStr = str.escape;
assert (escapeStr("hello") == "\"hello\"");
assert (escapeStr("hello\r\n\t") == "\"hello\\r\\n\\t\"");
assert (escapeStr("\x4") == "\"\\x04\"");
assert (escapeStr("\xFF") == "\"\\xff\"");
assert (escapeStr("\\") == "\"\\\\\"");
assert (escapeStr("\"\'") == "\"\\\"\\\'\"");

// String methods through prototype object (Plush runtime)
assert ("foo":contains("oo"));
assert ("foo":replace("oo", "oobar") == "foobar");
