#language "lang/plush/0"

var o = {};

// Extend the object
o.x = 1;
o.y = 2;
o.z = 3;
o.w = 4;

// Trigger a collection
var vm = import "core/vm/0";
vm.gc_collect();

assert (
    o.x == 1 &&
    o.y == 2 &&
    o.z == 3 &&
    o.w == 4
);
