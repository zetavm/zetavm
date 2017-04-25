#language "lang/plush/0"

var arr = [2,5,7];

var sum = 0;

for (var i = 0; i < arr.length; i = i + 1)
{
    print(arr[i]);

    sum = sum + arr[i];
}

print(sum);

assert (sum == 14);
