#language "lang/plush/0"

/**
Drawing of a zeta logo using signed distance functions in 2D
Note: currently needs to be improved
*/

var math = import "std/math/0";
var max = math.max;
var min = math.min;
var abs = math.abs;

var length = function (x, y)
{
    return math.sqrt(x * x + y * y);
};

var circle = function (px, py, r)
{
    return length(px, py) - r;
};

var box = function (px, py, bx, by)
{
    var dx = abs(px) - bx;
    var dy = abs(py) - by;
    var l = length(max(dx, 0), max(dy, 0));
    return min(max(dx, dy), 0) + l;
};

var roundBox = function (px, py, bx, by, r)
{
    var dx = abs(px) - bx;
    var dy = abs(py) - by;
    var l = length(max(dx, 0), max(dy, 0));
    return l - r;
};

var subtract = function (d1, d2)
{
    return max(-d1, d2);
};

var union = min;

var dstFn = function (x, y)
{
    // Scale the points, input is in [0,1]
    x *= 512;
    y *= 512;

    var dRoundBox = roundBox(
        x - 256,
        y - 256,
        256 - 64,
        256 - 64,
        25
    );

    var dInnerBox = box(
        x - 256,
        y - 256,
        256 - 96,
        256 - 96
    );

    var dZBox = box(
        x - 256,
        y - 256,
        256 - 128,
        256 - 128
    );

    var dTopBox = box(
        x - 256,
        y - 148,
        256 - 128,
        32
    );

    var dBotBox = box(
        x - 256,
        y - (512 - 148),
        256 - 128,
        32
    );

    var cos = math.cos((math.PI / 4) - 0.053f);
    var sin = math.sin((math.PI / 4) - 0.053f);
    var xb1 = x - 256;
    var yb1 = y - 256 + 100;
    var rx = xb1 * cos - yb1 * sin;
    var ry = xb1 * sin + yb1 * cos;
    var dDiagBox = box(
        rx,
        ry,
        256 - 4,
        40
    );

    var cos = math.cos((math.PI / 4) - 0.053f);
    var sin = math.sin((math.PI / 4) - 0.053f);
    var xb2 = x - 256;
    var yb2 = y - 256 - 100;
    var rx = xb2 * cos - yb2 * sin;
    var ry = xb2 * sin + yb2 * cos;
    var dDiagBox2 = box(
        rx,
        ry,
        256 - 4,
        40
    );

    var dZ = union(
        subtract(dDiagBox2, subtract(dDiagBox, dZBox)),
        union(dTopBox, dBotBox)
    );

    var dOutline = subtract(dInnerBox, dRoundBox);

    return union(
        dOutline,
        dZ
    );
};

exports.main = function (args)
{
    var string = import "std/string/0";
    var size = string.parseInt(args[1], 10);
    var width = size;
    var height = size;

    // Render the function
    var buf = [];
    for (var y = 0; y < height; y += 1)
    {
        for (var x = 0; x < width; x += 1)
        {
            var dst = dstFn(1.0f * x / width, 1.0f * y / height);

            dst = math.max(0, -dst);
            dst = math.min(dst / 0.006f, 1);

            var c = math.floor(255 * dst);

            buf:push(c);
            buf:push(c);
            buf:push(c);
        }
    }

    return 0;
};
