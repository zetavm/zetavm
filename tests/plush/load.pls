#language "lang/plush/0"

var vm = import "core/vm/0";

var pkg = vm.load("./tests/vm/ex_image.zim");
var pkg2 = vm.load("./tests/vm/ex_image.zim");

pkg.foo = 1;
pkg2.foo = 2;
assert (pkg.foo == 1);
assert (pkg2.foo == 2);
