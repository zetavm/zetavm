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
//sin and sqrt

x = sin(50.8);
fp_assert(x, 0.50942, "sin for float doesn't work");
y = sqrt(30.8);
fp_assert(y, 5.54977, "sqrt for float doesn't work");

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
