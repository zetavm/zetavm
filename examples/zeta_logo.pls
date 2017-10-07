#language "lang/plush/0"

/**
Drawing of a Zeta logo using signed distance functions in 2D
Note: currently needs to be improved
*/

var window = import "core/window/0";
var io = import "core/io/0";
var math = import "std/math/0";
var max = math.max;
var min = math.min;
var abs = math.abs;

var width = 400;
var height = 400;

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

/**
Signed distance field which defines the image.
Returns the closest distance to the logo at point (x,y)
*/
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

    var dImg = union(
        dOutline,
        dZ
    );

    // Scale the distance
    return dImg / 512;
};

/**
This function write PPM image output to stdout
*/
var writePPM = function (fileName, imgData, width, height)
{
    var string = import "std/string/0";
    var io = import "core/io/0";

    print('writing output file: \"' + fileName + '\"');

    var strs = [];

    strs:push('P3\n');
    strs:push($i32_to_str(width) + ' ' + $i32_to_str(height) + '\n');
    strs:push('255\n');

    for (var i = 0; i < imgData.length; i += 1)
    {
        var p = imgData[i];
        var r = (p >>  8) & 255;
        var g = (p >> 16) & 255;
        var b = (p >> 24) & 255;

        strs:push($i32_to_str(r) + ' ');
        strs:push($i32_to_str(g) + ' ');
        strs:push($i32_to_str(b) + ' ');
    }

    strs:push('\n');

    var output = string.join(strs, '');
    io.write_file(fileName, output);
};

var renderFun = function (dstFn, width, height)
{
    // Render the function
    var buf = [];
    for (var y = 0; y < height; y += 1)
    {
        for (var x = 0; x < width; x += 1)
        {
            var dst = dstFn(1.0f * x / width, 1.0f * y / height);

            dst = math.max(0, -dst);
            dst = math.min(dst / 0.006f, 1);

            var v = math.floor(255 * dst);

            // Pixels are in ABGR format
            var c = (v << 24) + (v << 16) + (v << 8);
            buf:push(c);
        }
    }

    return buf;
};

exports.main = function (args)
{
    var string = import "std/string/0";

    // Parse the render size
    var size = 512;
    if (args.length > 1)
        size = string.parseInt(args[args.length-1], 10);
    var width = size;
    var height = size;

    var bitmap = renderFun(dstFn, width, height);

    // If the output is to be written to a PPM file
    if (args.length > 1 && args[1] == "--write_ppm")
    {
        writePPM('zeta_logo.ppm', bitmap, width, height);
        return 0;
    }

    var handle = window.create_window("Zeta Logo", width, height);
    window.draw_bitmap(handle, bitmap);

    // Wait until the window is closed
    for (;;)
    {
        var event = window.get_next_event(handle);

        if (event != false)
        {
            if (event.type == "quit")
                break;
        }
    }

    window.destroy_window(handle);

    return 0;
};
