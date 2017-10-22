#language "lang/plush/0"

var vm = import "core/vm/0";

var theLenFunc = function (str)
{
    return str.length;
};

var test = function ()
{
    var liveObj = { v:3 };

    theLenFunc('foo');

    // Trigger a collection
    vm.gc_collect();

    theLenFunc('foobar');

    assert (typeof liveObj == 'object');

    // Test that our live object hasn't been corrupted
    assert (liveObj.v == 3);

    // Test that the string table still works properly
    assert ('foo' + 'bar' == 'foobar');

    var theNewObj = { x:1 };

    // Test that new objects can still be created and manipulated
    assert (theNewObj.x == 1);

    // Test that linked strings are preserved
    var len = theLenFunc('foobarbif');
    assert (len == 9);
};

test();
