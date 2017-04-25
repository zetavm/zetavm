#language "lang/plush/0"

var width = 256;
var height = 256;

var buf = [];

for (var y = 0; y < height; y += 1)
{
    for (var x = 0; x < width; x += 1)
    {
        buf:push(x);
        buf:push(y);
        buf:push(0);
    }
}
