#language "lang/plush/0"

// Import the Plush language package source.
// This will cause the compiled Plush language
// package to parse its own source code.
var plushPkg = import "./plush/plush_pkg.pls";

// Serialize the compiled Plush package
var vm = import "core/vm/0";
var str = vm.serialize(plushPkg, true);
//print(str.length);
var plushPkg2 = vm.parse(str);

// FIXME: for this to work, need runtime package
//var unit = plushPkg.parseString("return 2 * 3;", "test", {});
//assert (typeof unit == "object");
// TODO: try running compiled unit, test output

// FIXME
//plushPkg2.parseString("return 2 * 3;", "test", {});
