#language "lang/plush/0"

var vm = import "core/vm/0";

assert (vm.parse("3;") == 3);
