#language "lang/plush/0"

fp_assert = function (xVal, xExpect, errMsg)
{
    var err = xVal - xExpect;
    if (err < 0)
        err = -err;

    assert (err < 0.001, errMsg);
};

// assigning floats;
x = 1.0;
y = 1e2;

// arithmetic
x = 1.0 + 3.5;
fp_assert(x, 4.5, "float addition doesn't work");
y = 5.5 - 2.8;
fp_assert(y, 2.7, "float substraction doesn't work");
w = 9.0 / 3.0;
fp_assert(w, 3.0, "float division doesn't work");
z = 4.4 * 3.3;
fp_assert(z, 14.52, "float multiplication doesn't work");

// automatic type casting
x = 4.5 * 5.4 / 3 + 3 - 2.5;
fp_assert(x, 8.6, "float auto casting and arithmetic doesn't work");

// Import the math package
var math = import "std/math/0";

x = math.sin(50.8);
fp_assert(x, 0.50942, "sin for float doesn't work");
y = math.sqrt(30.8);
fp_assert(y, 5.54977, "sqrt for float doesn't work");
z = math.cos(40);
fp_assert(z, -0.66693, "cos for float doesn't work");

fp_assert(math.sin(math.PI), 0, "sin of PI == 0 is not working");
fp_assert(math.sin(math.PI/2), 1, "sin of PI/2 == 1 is not working");

fp_assert(math.max(3.0, 2.8), 3.0, "max function on floats is not working");
assert(math.max(3,2) == 3, "max function on ints is not working");
assert(math.max(0, -0.5) == 0);

fp_assert(math.min(3.0, 2.8), 2.8, "min function on floats is not working");
assert(math.min(3,2) == 2, "min function on ints is not working");

fp_assert(math.abs(-3.5), 3.5, "abs function on floats is not working");
assert(math.abs(-3) == 3, "abs function on ints is not working");

// comparisons
assert(1.0 < 4.0);
assert(1.0 <= 4.0);
assert(4.0 > 1.0);
assert(4.0 >= 1.0);
assert(2.2 > 2.1);
assert(1.11 < 1.12);
assert(-1.1 < 2.0);
assert(10000 > -0.0004);
assert(0.005 > 0.0005);
assert(0.0004 <= 0.0005);
x = 1.0 == 1.0;
assert(typeof x == "bool");
assert(1.0 == 1.0);

// float-string conversion
x = $str_to_f32("1.0");
fp_assert(x, 1.0, "string to float doesn't work");
print(x);

y = $f32_to_str(1.0);
print(y);
assert(y == "1.000000");
