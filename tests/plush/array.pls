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

var testBinarySearch = function() {
    
    // Array has to be in order for binary search to work.
    var arr = [14, 15, 16, 18, 23];

    assert(array.binarySearch(arr, 4) == -1); // Should not be found
    assert(array.binarySearch(arr, 14) == 0); // Should be found
    assert(array.binarySearch(arr, 23) == 4); // Should be found
    assert(array.binarySearch(arr, 18) == 3); // Should be found
};

var testSort = function() {
    var sortMe = [2, 8, 6, 4, 2, 1, 0];
    array.sort(sortMe, function(a, b) {
        return a - b;
    });
    assert(sortMe[0] == 0);
    assert(sortMe[1] == 1);
    assert(sortMe[2] == 2);
    assert(sortMe[3] == 2);
    assert(sortMe[4] == 4);
    assert(sortMe[5] == 6);
    assert(sortMe[6] == 8);
};

testIndexOf(getArray());
testMap(getArray());
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

print("std/array -> All tests passed");
