#language "lang/plush/0"

var vm = import "core/vm/0";
var array = import "std/array/0";

var ARR_LEN = 5000;

//$rt_shrinkHeap(500000);

var gcCount = vm.get_gc_count();

for (; vm.get_gc_count() < gcCount + 2; )
{
    var arr = array.new(ARR_LEN, 0);
}
