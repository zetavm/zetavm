#language "lang/plush/0"

var window = import "core/window/0";
var time = import "core/time/0";
var array = import "std/array/0";
var math = import "std/math/0";
var random = import "std/random/0";
var string = import "std/string/0";

var width = 400;
var height = 300;
var fps_target = 30;

var rng = random.newRNG(time.get_time_millis());

// Window to draw into
var handle = window.create_window("Mini Game", width, height);

// Bitmap of pixels to draw
var bitmap = array.new(width * height, 0);

var RED = 255 << 24;
var GREEN = 255 << 16;
var BLUE = 255 << 8;

// Below is the character set for the text renderer.
// This uses an 8x8 array for each character where each cell
// acts like a pixel which can be turned on (1) or off (0)
// More can easily be added by appending to the end and adding the
// character to the end of the stringMap variable.
var font =
[
    [ // A
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // B
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // C
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // D
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // E
    1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // F
    1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // G
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // H
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // I
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // J
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // K
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 1, 1, 0, 0,
    1, 1, 1, 1, 1, 0, 0, 0,
    1, 1, 0, 0, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // L
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // M
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 0, 1, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 1, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // N
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 0, 0, 1, 1, 0,
    1, 1, 0, 1, 0, 1, 1, 0,
    1, 1, 0, 0, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // O
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // P
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // Q
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 1, 1, 0, 0,
    0, 1, 1, 1, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // R
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // S
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // T
    1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // U
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // V
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 0, 1, 1, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 0, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // W
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 1, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 0, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // X
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 0, 1, 1, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 0, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 1, 1, 0, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // Y
    1, 0, 0, 0, 0, 0, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // Z
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 1, 1, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 0
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 1, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 1
    0, 0, 0, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 1, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 2
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 1, 1, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 3
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 4
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 5
    1, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 6
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 7
    1, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 1, 1, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 8
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 0, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // 9
    0, 1, 1, 1, 1, 1, 0, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0,
    0, 1, 1, 1, 1, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // SPACE
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // !
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 0, 0, 0,
    0, 1, 1, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // ?
    0, 1, 1, 1, 1, 0, 0, 0,
    1, 1, 0, 0, 1, 1, 0, 0,
    0, 0, 0, 0, 1, 1, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
    [ // :
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    ],
];

// :)
var smileyFace =
[
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 1, 1, 0,
    0, 1, 1, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    1, 0, 0, 0, 0, 0, 0, 1,
    0, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
];

// :(
var sadFace =
[
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 1, 1, 0,
    0, 1, 1, 0, 0, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 0,
    1, 0, 0, 0, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0, 0, 0,
];


var characterSprite =
[ // 8x8 scaled up to 16x16
    1, 0, 0, 1, 1, 0, 0, 0,
    0, 1, 0, 1, 1, 1, 0, 0,
    1, 0, 1, 1, 0, 1, 1, 0,
    0, 1, 0, 1, 1, 1, 1, 1,
    0, 1, 0, 1, 1, 1, 1, 1,
    1, 0, 1, 1, 0, 1, 1, 0,
    0, 1, 0, 1, 1, 1, 0, 0,
    1, 0, 0, 1, 1, 0, 0, 0,
];

var stringMap = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !?:";

var fps = 0;
var lastPrint = time.get_time_millis();

// Game state variables for choosing what to show in the game.
var prevScore = 0;
var score = 0;
var dead = false;
var gameStart = false;
var completedGame = false;

// Game pillars.
var pillars = [];
// Character state.
var character = {};

var createCharacter = function()
{
    character =
    {
            oldx: 0, // Old x position
            oldy: 0, // Old y position
            px: 0, // Current x position.
            py: height / 2, // Current y position. (Player starts in the center of the screen)
            vx: 1, // X Velocity
            ay: 0, // Y Acceleration
            vy: 0, // Y Velocity
            sprite: characterSprite, // Sprite which represents player.
    };
};

/**
* Draws text at a specific position on the screen with a color and scale.
* The scale can be either 1 or 2.
*/
var drawText = function(str, px, py, color, scale)
{
    for (var i = 0;i < str.length;i += 1)
    {
        var char = str[i];
        drawBitmap(font[stringMap:indexOf(char)], px+(8*i*scale), py, color, scale);
    }
};

/**
* Draws text horizontally centered on the screen with a color and scale.
* The scale can be either 1 or 2.
*/
var drawTextCentered = function(str, py, color, scale)
{
    var tWidth = calcTextWidth(str, scale);
    // Calculate the starting position of the string.
    var px = math.idiv(width, 2) - math.idiv(tWidth, 2);
    for (var i = 0;i < str.length;i += 1)
    {
        var char = str[i];
        drawBitmap(font[stringMap:indexOf(char)], px+(8*i*scale), py, color, scale);
    }
};

/**
* Randomly generates the height and space between pillars.
*/
var genPillars = function()
{
    // make some pillars to need to avoid.
    var tx = rng:int(90, 150); // This is the cumulative distance between each pillar.
    for (var i = 0;i < 15;i += 1)
    {
        var pillarObj =
        {
            x: tx,
            h: rng:int(40, 150), // Varying height of each pillar.
            color: rng:int(string.parseInt("111111", 16), string.parseInt("FFFFFF", 16)) << 8, // RGB
        };
        tx += rng:int(70, 150);

        pillars:push(pillarObj);
    }
};

/**
* Draws a single color bitmask using a mask (array encoded using 1 for color, 0 to discard)
* The bitmap given has to be 8x8 and the scale can be either 1 or 2.
*/
var drawBitmap = function(bmap, px, py, color, scale)
{
    if (scale < 1 || scale > 2) throw "drawBitmap expects scale of either 1 or 2";
    var w = 8;
    var h = 8;

    // can only scale by 2.
    if (scale == 2)
    {
        for (var y = 0; y < h;y += 1)
        {
            for (var x = 0; x < w;x += 1)
            {
                if (bmap[y*w+x] == 1)
                {
                    // Scales up the image by factor of 2 and draws a 2x2 square
                    // in place of a single pixel.
                    bitmap[((py+y)*2+0-py)*width+((px+x)*2+0-px)] = color;
                    bitmap[((py+y)*2+0-py)*width+((px+x)*2+1-px)] = color;
                    bitmap[((py+y)*2+1-py)*width+((px+x)*2+0-px)] = color;
                    bitmap[((py+y)*2+1-py)*width+((px+x)*2+1-px)] = color;
                }
            }
        }
    }
    else if (scale == 1)
    {
        for (var y = 0; y < h;y += 1)
        {
            for (var x = 0; x < w;x += 1)
            {
                if (bmap[y*w+x] == 1)
                {
                    // Direct pixel to pixel translation from the bitmap.
                    bitmap[(py+y)*width+(px+x)] = color;
                }
            }
        }
    }
};

/**
* Calculates the pixel width of a string at a given scale.
* The scale can be either 1 or 2.
*/
var calcTextWidth = function(str, scale)
{
    if (scale < 1 || scale > 2) throw "calcTextWidth expects scale of either 1 or 2";
    // Each character is the same width (8 pixels).
    return str.length * 8 * scale;
};

/**
* Draws a rectangle with no bounds checking for the pixels.
*/
var drawRect = function (startX, endX, startY, endY, color)
{
    for (var y = startY; y < endY; y += 1)
    {
        for (var x = startX; x < endX; x += 1)
        {
            bitmap[y * width + x] = color;
        }
    }
};

/**
* Draws and updates the character
*/
var drawCharacter = function()
{
    // clear old bitmap.
    drawBitmap(character.sprite, 0, math.floor(character.oldy), 0, 2);
    drawBitmap(character.sprite, 0, math.floor(character.py), RED, 2);
    character.oldx = character.px;
    character.oldy = character.py;
    character.px += character.vx;
    character.vy += character.ay;
    character.py += character.vy;
};

/**
* Clears the screen bitmap so it is black.
*/
var clear = function()
{
    for (var i = 0;i < width * height;i += 1)
    {
        bitmap[i] = 0;
    }
};

/**
* Draws and updates the games state.
*/
var drawAndUpdate = function()
{
    oldScore = score;
    // Used for checking if the player has gone above or below the screen.
    if (math.ceil(character.py) + 16 >= height ||
        math.ceil(character.py) <= 0)
    {
        clear();
        dead = true;
        return;
    }

    drawCharacter();
    // The player's x position is used to make the pillars scroll.
    // The player doesn't actually move on the screen in the x-direction.
    var xOffset = character.px;

    // The amount of visible pillars on the screen, used for checking
    // if the player has completed the level.
    var visible = 0;

    // Render the pillars.
    for (var i = 0;i < pillars.length;i += 1)
    {
        var pillar = pillars[i];
        // Each pillar has a fixed width of 32 pixels.
        // px = left hand side of the pillar.
        // pxx = rigt hand side of the pillar.
        var px = pillar.x - xOffset;
        var pxx = px + 32;

        // Just gone off the screen so remove the last pixel strip of that column else
        // it won't be cleaned.
        if (pxx == 0)
        {
            // Clear a 1 pixel groove
            drawRect(0, 1, 0, height, 0);
        }
        // If the pillar has gone off the left side of the screen don't draw it.
        if (px < 0 && pxx < 0)
            continue;
        // If the pillar is still yet to be drawn. (On the right side) don't draw it as it isn't visible.
        if (px >= width && pxx >= width)
            continue;

        // Checks if a pillar is only partially visible on the screen
        // and rectifies the x positions of the pillar to stop index out of bounds.
        if (px < 0) px = 0;
        if (pxx >= width) pxx = width - 1;

        // The pillar is going to be rendered. So increment the visible pillars var.
        visible += 1;

        // 48 is the gap width between the top and bottom pillars.
        // do collision detection with the player.
        if (px >= 0 && px <= 16)
        {
            // Is the player in the free space between the bottom and top pillar?
            if (height - (character.py + 16) > pillar.h &&
                character.py > height - pillar.h - 48)
            {
                score += 1;
            }
            else // No, they collided so they loose.
            {
                clear();
                dead = true;
                return;
            }
        }
        // clear old pillars.
        drawRect(px+1, pxx+1, height - pillar.h, height, 0);
        drawRect(px+1, pxx+1, 0, height-pillar.h-48, 0);
        // draw the pillar on the screen.
        drawRect(px, pxx, height-pillar.h, height, pillar.color);
        drawRect(px, pxx, 0, height-pillar.h-48, pillar.color);
    }

    // No more visible blocks, so game is over and player won.
    if (visible == 0)
    {
        clear();
        completedGame = true;
        dead = true;
        return;
    }

    // ABGR
    var oldScoreString = "SCORE:{}":format([oldScore]);
    var scoreString = "SCORE:{}":format([score]);
    //drawRect(0, width, 0, 16, 0);
    // Clear previous score string.
    drawTextCentered(oldScoreString, 0, 0, 2);
    // Draw new score string.
    drawTextCentered(scoreString, 0, RED + GREEN + BLUE, 2);
    // Then draw it all to the screen.
    window.draw_bitmap(handle, bitmap);
};

var drawTitleScreen = function()
{
    drawTextCentered("CONTROLS:", 32+20, RED+GREEN+BLUE, 2);
    drawTextCentered("SPACE TO GO UP", 32+20+20, RED+GREEN+BLUE, 2);
    drawTextCentered("ESCAPE TO QUIT", 32+20+20+20, RED+GREEN+BLUE, 2);
    drawTextCentered("ENTER TO START", math.idiv(height, 2), GREEN, 2);
    drawBitmap(smileyFace, math.idiv(width, 2) - 8, math.idiv(height, 2) + 24, RED+GREEN+BLUE, 2);
    window.draw_bitmap(handle, bitmap);
};

var drawDeathScreen = function()
{
    if (completedGame)
    {
        drawTextCentered("YOU WON!", math.idiv(height, 2)-32, GREEN, 2);
    }
    else
    {
        var textWidth = calcTextWidth("YOU DIED!", 2);
        drawTextCentered("YOU DIED!", math.idiv(height, 2)-32, RED, 2);
        drawBitmap(sadFace, math.idiv(width, 2) + math.idiv(textWidth, 2) + 4,math.idiv(height, 2) - 32, RED, 2);
    }
    var scoreString = "SCORE:{}":format([score]);
    var scoreWidth = calcTextWidth(scoreString, 2);
    drawTextCentered(scoreString, math.idiv(height, 2)-16, RED+BLUE+GREEN, 2);
    drawTextCentered("ENTER TO RETRY!", math.idiv(height, 2), RED+BLUE+GREEN, 2);
    window.draw_bitmap(handle, bitmap);
};

// Make the pillars.
genPillars();
// Initalise the character state.
createCharacter();
// Setup inital acceleration for player.
character.ay = 0.5f;

// Game loop
for (var i = 0;;i += 1)
{
    var sTime = time.get_time_millis();

    // game start menu.
    if (gameStart == false)
    {
        // Draw start screen.
        drawTitleScreen();
    }
    else // in game.
    {
        if (!dead)
        {
            // Draws and updates the game state for the player.
            drawAndUpdate();
        }
        else
        {
            // Draw death screen.
            drawDeathScreen();
        }
    }
    fps += 1;

    // Print fps every second.
    if (sTime - lastPrint > 1000)
    {
        print("fps: {}":format([fps]));
        lastPrint = sTime;
        fps = 0;
    }

    // Poll for input events.
    var event = window.get_next_event(handle);

    // If there is an event to process
    if (event != false)
    {
        if (event.type == "quit")
        {
          break;
        }

        if (gameStart == false && event.type == "key_down" && event.key == "return")
        {
            gameStart = true; // start the game.
            clear();
        }

        // Press enter to retry.
        if (dead == true && event.type == "key_down" && event.key == "return")
        {
            // reset game state.
            clear();
            gameStart = true;
            score = 0;
            oldScore = 0;
            completedGame = false;
            dead = false;
            pillars = [];
            genPillars();
            createCharacter();
        }

        // Pressing the space key makes the player accelerate upwards.
        if (event.type == "key_down" && event.key == "space" && gameStart == true)
        {
            character.vy = 0;
            // Accelerate the player upwards.
            character.ay = -0.5f;
        }
        else
        {
            // Accelerate the player downwards.
            character.ay = 0.3f;
        }

        // Leave the game when pressing escape.
        if (event.type == "key_down" && event.key == "escape")
        {
            break;
        }
    }

    var eTime = time.get_time_millis();
    var spareTime = (1000 / fps_target) - (eTime - sTime);
    // Lets waste some time. This is quite a primitive way but works reasonably well.
    // Any left over time after doing all the rendering is used in this loop to reach
    // the fps goal.
    var wasteStart = time.get_time_millis();
    if (spareTime > 0)
    {
        for (;;)
        {
            if (time.get_time_millis() - wasteStart >= spareTime)
                break;
        }
    }
}

// Destroy the window upon game exit.
window.destroy_window(handle);
