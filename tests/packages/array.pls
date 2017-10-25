#language "lang/plush/0"

/// Tests for package std/array

var array = import("std/array/0");

// to test forEach
var sum = 0;

var computeSum = function(arr)
{
    var total = 0;
    for (var i = 0; i < arr.length; i += 1)
    {
        total += arr[i];
    }
    return total;
};

var getArray = function()
{
    var arr = [];
    for (var i = 0; i < 10; i += 1)
    {
        arr:push(14 + i);
    }
    return arr;
};

var testNew = function ()
{
    var arr = array.new(10, 777);

    assert (arr.length == 10);
    for (var i = 0; i < arr.length; i += 1)
        assert (arr[i] == 777);
};

var testPushPop = function ()
{
    var arr = [];
    arr:push(3);
    arr:push(7);
    assert (arr.length == 2);

    var v1 = arr:pop();
    var v0 = arr:pop();
    assert (v1 == 7);
    assert (v0 == 3);
    assert (arr.length == 0);

    var arr = [0, 1, 2];
    var v = arr:popFront();
    assert (v == 0);
    assert (arr[0] == 1);
};

var testIndexOf = function(arr)
{
    assert(array.indexOf(arr, 17) == 3);
    assert(array.indexOf(arr, 22) == 8);
    assert(array.indexOf(arr, 43) == -1);
};

var testMap = function(arr)
{
    var incr = function(elem)
    {
        return elem + 1;
    };

    arr = array.map(arr, incr);

    for (var i = 0; i < 10; i += 1)
    {
        assert(arr[i] == 15 + i);
    }
};

var testFlatMap = function()
{
    var sentence = "Life, Universe and Everything";
    var out = "Life,UniverseandEverything";
    var wordToCharArray = function(word)
    {
        var arr = [];
        for (var i = 0; i < word.length; i += 1)
        {
            arr:push(word[i]);
        }
        return arr;
    };
    var words = sentence:split(" ");
    var arr = words:flatMap(wordToCharArray);
    assert(arr.length == 26);
    for (var i = 0; i < arr.length; i += 1)
    {
        assert(arr[i] == out[i]);
    }

    // Test corner cases
    // Function which wraps input value in monadic context.
    var ret = function (elem)
    {
        var arr = [elem];
        return arr;
    };

    var eat = function(elem)
    {
        return [];
    };

    var inp = [];
    var out = inp:flatMap(ret);
    assert(out.length == 0);
    inp:push(4);
    out = inp:flatMap(ret);
    assert(out.length == 1);
    assert(out[0] == 4);
    out = inp:flatMap(eat);
    assert(out.length == 0);
    assert(inp.length == 1);
    assert(inp[0] == 4);
};

var testForEach = function(arr)
{
    var add = function(elem)
    {
        sum += elem;
    };

    array.forEach(arr, add);
    assert(sum == 185);
};

var testSlice = function(arr)
{
    var sliced = array.slice(arr, 2, 6);
    assert(sliced.length == 4);
    for (var i = 0; i < sliced.length; i += 1)
    {
        assert(sliced[i] == 16 + i);
    }
};

var testConcat = function(arr)
{
    var concatenated = array.concat(arr, arr);
    assert(arr.length == 10);
    assert(concatenated.length == 20);
    assert(computeSum(arr) == 185);
    assert(computeSum(concatenated) == 185 * 2);
};

var testAppend = function(a, b)
{
    array.append(a, b);
    assert(b.length == 10);
    assert(a.length == 20);
    assert(computeSum(b) == 185);
    assert(computeSum(a) == 185 * 2);
};

var testReplace = function(arr)
{
    // replace 43 with 22 should not have any effect
    // since 43 is not present in array
    array.replace(arr, 43, 22);
    assert(computeSum(arr) == 185);
    // replace 16 with 20 should increase sum by 4
    array.replace(arr, 16, 20);
    assert(computeSum(arr) == 189);
    // now since there are 2 20's
    // increasing 20 by 30 should increase sum by 20
    array.replace(arr, 20, 30);
    assert(computeSum(arr) == 209);
};

var testFilter = function(arr)
{
    var greaterThan20 = function(elem)
    {
        return elem > 20;
    };
    var newArr = array.filter(arr, greaterThan20);
    assert(computeSum(newArr) == 66);
};

var testArrayEq = function(a, b)
{
    assert(array.arrayEq(a, b));
    array.append(a, a);
    assert(!array.arrayEq(a, b));
    array.append(b, b);
    assert(array.arrayEq(a, b));
    a[0] = -11;
    assert(!array.arrayEq(a, b));
};

var testContains = function(arr)
{
    assert(array.contains(arr, 14));
    assert(array.contains(arr, 23));
    assert(!array.contains(arr, -10));
};

var testBinarySearch = function()
{
    // Array has to be in order for binary search to work.
    var arr = [14, 15, 16, 18, 23];

    assert(array.binarySearch(arr, 4) == -1); // Should not be found
    assert(array.binarySearch(arr, 14) == 0); // Should be found
    assert(array.binarySearch(arr, 23) == 4); // Should be found
    assert(array.binarySearch(arr, 18) == 3); // Should be found
};

var testSort = function()
{
    var sortMe = [2, 8, 6, 4, 2, 1, 0];
    array.sort(sortMe,
        function(a, b)
        {
            return a - b;
        }
    );
    assert(sortMe[0] == 0);
    assert(sortMe[1] == 1);
    assert(sortMe[2] == 2);
    assert(sortMe[3] == 2);
    assert(sortMe[4] == 4);
    assert(sortMe[5] == 6);
    assert(sortMe[6] == 8);

    var smallArray = [-5];
    array.sort(smallArray,
        function(a, b)
        {
            return a - b;
        }
    );
    assert(smallArray[0] == -5);

    var emptyArray = [];
    array.sort(emptyArray,
        function(a, b)
        {
            return a - b;
        }
    );
	// Check the array didn't change in size from the sort.
    assert(emptyArray.length == 0);
};

testNew();
testPushPop();
testIndexOf(getArray());
testMap(getArray());
testFlatMap();
testForEach(getArray());
testSlice(getArray());
testConcat(getArray());
testAppend(getArray(), getArray());
testReplace(getArray());
testFilter(getArray());
testArrayEq(getArray(), getArray());
testContains(getArray());
testBinarySearch();
testSort();

// Array methods (Plush runtime)
assert (['a', 'b', 'c']:contains('b'));

print("std/array -> All tests passed");
