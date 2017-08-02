#language "lang/plush/0"

var str = import "std/string/0";

//Utility functions
var arrayeq = function(a, b)
{
    if (a.length != b.length)
    {
        return false;
    }
    for (var i = 0; i < a.length; i += 1)
    {
        if (a[i] != b[i])
        {
            return false;
        }
    }
    return true;
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


assert(str.toString(obj)== "17");

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
assert(arrayeq(split("a,b,c,d", ","), ["a", "b", "c", "d"]));
assert(arrayeq(split("a,,c,d", ","), ["a", "c", "d"]));
assert(arrayeq(split("a,b,c,", ","), ["a", "b", "c"]));
assert(arrayeq(split(",b,c,d", ","), ["b", "c", "d"]));
assert(arrayeq(split("a,,b,,c,,d", ",,"), ["a", "b", "c", "d"]));
assert(arrayeq(split("a,,,,c,,d", ",,"), ["a", "c", "d"]));
assert(arrayeq(split("a,,b,,c,,", ",,"), ["a", "b", "c"]));
assert(arrayeq(split(",,b,,c,,d", ",,"), ["b", "c", "d"]));
assert(arrayeq(split("", ""), []));
assert(arrayeq(split("", "abc"), []));
assert(arrayeq(split("abc", "abc"), []));
assert(arrayeq(split("abc", "defg"), ["abc"]));

//join
var join = str.join;
var a = "a,b,c,d";
assert(join(split(a, ","), ",") == a);

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

var startsWith = str.startsWith;
assert(startsWith("Banana", "Ban"));
assert(!startsWith("Banana", "Bun"));
assert(!startsWith("Ban", "Banana"));


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

try
{
    parseInt("", 10);
    assert(false);
}
catch(e)
{
    assert(true);
}
try
{
    parseInt("123abc", 10);
    assert(false);
}
catch(e)
{
    assert(true);
}
