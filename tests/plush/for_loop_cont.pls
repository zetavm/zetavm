#language "lang/plush/0"

var sum = 0;

var odd = true;

for (var i = 1; i < 10; i = i + 1)
{
    if (odd)
    {
        odd = false;
        continue;
    }
    else
    {
        odd = true;
    }

    print(i);

    sum = sum + i;
}

print(sum);
assert (sum == 20);
