// assigning floats;
x = 1.0;
y = 1e2;

// arithmetic

x = 1.0 + 3.5;
y = 5.5 - 2.8;
w = 9.0 / 3.0;
z = 4.4 * 3.3;

// automatic type casting

x = 3 + 4.5 * 5.4 / 3;

//sin and sqrt

x = sin(50.8);
y = sqrt(30.8);

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

//float-string conversion

x = $str_to_f32("1.0");
assert(typeof x == "float32");
print(x);

y = $f32_to_str(1.0);
print(y);
assert(y == "1.000000");
