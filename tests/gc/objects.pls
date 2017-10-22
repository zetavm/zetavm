#language "lang/plush/0"

var test = function ()
{
    var vm = import "core/vm/0";

    //$rt_shrinkHeap(40000);

    var gcCount = vm.get_gc_count();

    var p = { k: 1 };

    for (; vm.get_gc_count() < gcCount + 2; )
    {
        var o = { v: 2 };
    }

    assert (p.k == 1);
    assert (o.v == 2);
};

test();
