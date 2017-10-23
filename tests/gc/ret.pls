#language "lang/plush/0"

var vm = import "core/vm/0";

var bif = function ()
{
    return { x: 777 };
};

var test = function ()
{
    var o = bif();

    vm.gc_collect();

    assert (typeof o == 'object');
    assert (o.x == 777);
};

test();
