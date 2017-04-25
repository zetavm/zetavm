#language "lang/plush/0"

var sum = 0;

var odd = true;

for (var i = 1; i < 10; i = i + 1)
{
    if (i == 5)
    {
        print("break");
        break;
    }

    print(i);
    sum = sum + i;
}

print(sum);
assert (sum == 10);
