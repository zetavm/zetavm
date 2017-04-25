#language "lang/plush/0"

var arr = [0];

for (var i = 1; i < 6; i = i + 1)
    arr:push(i);

assert (arr.length == 6);
assert (arr[0] == 0);

var sum = 0;
for (var i = 0; i < arr.length; i = i + 1)
    sum = sum + arr[i];

assert (sum == 15);
