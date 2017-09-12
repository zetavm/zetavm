#language "lang/plush/0"

var window = import "core/window/0";
var time = import "core/time/0";
var array = import "std/array/0";
var math = import "std/math/0";
var random = import "std/random/0";

var width = 400;
var height = 300;

var rng = random.globalRNG;

// Window to draw into
var handle = window.create_window("Mini Game", width, height);

// Bitmap of pixels to draw
var bitmap = array.new(width * height, 0);

var RED = 255 << 24;
var GREEN = 255 << 16;
var BLUE = 255 << 8;

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

/*var characterSprite = [ // 8x8 scaled up to 16x16
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 1, 1, 1, 1, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 0,
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 1, 0, 0, 1, 0, 0,
    0, 1, 0, 1, 1, 0, 1, 0,
    1, 0, 1, 0, 0, 1, 0, 1,
];*/

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

var score = 0;
var dead = false;
var gameStart = false;
var completedGame = false;

// Game pillars.
var pillars = [];
var character =
{
        oldx: 0,
        oldy: 0,
        px: 0,
        py: height / 2,
        vx: 1,
        ay: 0,
        vy: 0,
        sprite: characterSprite,
};

var drawText = function(str, px, py, color, scale)
{
    for (var i = 0;i < str.length;i += 1)
    {
        var char = str[i];
        drawBitmap(font[stringMap:indexOf(char)], px+(8*i*scale), py, color, scale);
    }
};

var drawTextCentered = function(str, py, color, scale)
{
    var tWidth = calcTextWidth(str, scale);
    var px = math.idiv(width, 2) - math.idiv(tWidth, 2);
    for (var i = 0;i < str.length;i += 1)
    {
        var char = str[i];
        drawBitmap(font[stringMap:indexOf(char)], px+(8*i*scale), py, color, scale);
    }
};

// pillar has even spacing but random height.

var genPillars = function()
{
    // make some pillars to need to avoid.
    var tx = rng:int(90, 150);
    for (var i = 0;i < 15;i += 1)
    {
        var pillarObj =
        {
            x: tx,
            h: rng:int(40, 150),
        };
        tx += rng:int(70, 150);

        pillars:push(pillarObj);
    }
};

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
                    bitmap[(py+y)*width+(px+x)] = color;
                }
            }
        }
    }
};

var calcTextWidth = function(str, scale)
{
    if (scale < 1 || scale > 2) throw "calcTextWidth expects scale of either 1 or 2";
    return str.length * 8 * scale;
};

var drawSquare = function (startX, endX, startY, endY, color)
{
    for (var y = startY; y < endY; y += 1)
    {
        for (var x = startX; x < endX; x += 1)
        {
            bitmap[y * width + x] = color;
        }
    }
};

var drawCharacter = function()
{
    character.oldx = character.px;
    character.oldy = character.py;
    character.px += character.vx;
    character.vy += character.ay;
    character.py += character.vy;
    // clear old bitmap.
    drawBitmap(character.sprite, 0, math.floor(character.oldy), 0, 2);
    drawBitmap(character.sprite, 0, math.floor(character.py), RED, 2);
};

var clear = function()
{
    for (var i = 0;i < width * height;i += 1)
    {
        bitmap[i] = 0;
    }
};

var draw = function()
{
    // This is quite hit and miss, this isn't good code.
    if (math.ceil(character.py) > height - 20 ||
        character.py <= 4)
    {
        dead = true;
        return;
    }
    drawCharacter();

    var xOffset = character.px;

    var visible = 0;

    for (var i = 0;i < pillars.length;i += 1)
    {
        var pillar = pillars[i];
        var px = pillar.x - xOffset;
        var pxx = pillar.x + 32 - xOffset;
        // This is weird logic, not gonna lie.
        // Also leaves a single pixel line on the left hand side of the screen.
        if (px < 0 && pxx < 0)
            continue;
        if (px >= width && pxx >= width)
            continue;
        if (px < 0) px = 0;
        if (pxx >= width) pxx = width - 1;

        // 48 is the gap width for the pillars.
        // do collision detection with the player.
        if (px >= 0 && px <= 16)
        {
            if (height - (character.py+16) > pillar.h &&
                character.py > height-pillar.h-48)
                {
                    score += 1;
                }
                else
                {
                    dead = true;
                    return;
                }
        }
        visible += 1;
        // clear old pillars, not the best way to do it.
        drawSquare(px+1, pxx+1, height - pillar.h, height, 0);
        drawSquare(px+1, pxx+1, 0, height-pillar.h-48, 0);
        // draw the pillars on the screen.
        drawSquare(px, pxx, height-pillar.h, height, BLUE);
        drawSquare(px, pxx, 0, height-pillar.h-48, BLUE);
    }

    // No more visible blocks, so game is over.
    if (visible == 0)
    {
        completedGame = true;
        dead = true;
        return;
    }

    // ABGR
    var scoreString = "SCORE:{}":format([score]);
    var charWidth = calcTextWidth(scoreString, 2);
    drawSquare(0, width, 0, 16, 0);
    drawText(scoreString, math.floor(width/2) - math.idiv(charWidth, 2), 0, RED + GREEN + BLUE, 2);
    window.draw_bitmap(handle, bitmap);
};

// Make the pillars.
genPillars();
// Setup inital acceleration for player.
character.ay = 0.5f;

for (var i = 0;;i += 1)
{
    var sTime = time.get_time_millis();

    // game start menu.
    if (gameStart == false)
    {
        // Draw start screen.
        drawTextCentered("CONTROLS:", 32+20, RED+GREEN+BLUE, 2);
        drawTextCentered("PRESS SPACE TO GO UP", 32+20+20, RED+GREEN+BLUE, 2);
        drawTextCentered("ESCAPE TO QUIT", 32+20+20+20, RED+GREEN+BLUE, 2);
        drawTextCentered("PRESS ENTER TO START", math.idiv(height, 2), GREEN, 2);
        drawBitmap(smileyFace, math.idiv(width, 2) - 8, math.idiv(height, 2) + 24, RED+GREEN+BLUE, 2);
        window.draw_bitmap(handle, bitmap);
    }
    else // in game.
    {
        if (!dead)
        {
            draw();
        }
        else
        {
            // Draw death screen.
            if (completedGame)
            {
                drawTextCentered("YOU WON!", math.idiv(height, 2)-32, GREEN, 2);
            }
            else
            {
                drawTextCentered("YOU DIED!", math.idiv(height, 2)-32, RED, 2);
            }
            var scoreString = "SCORE:{}":format([score]);
            var scoreWidth = calcTextWidth(scoreString, 2);
            drawTextCentered(scoreString, math.idiv(height, 2)-16, RED+BLUE+GREEN, 2);
            window.draw_bitmap(handle, bitmap);
        }
    }
    fps += 1;

    if (sTime - lastPrint > 1000)
    {
        print("fps: {}":format([fps]));
        lastPrint = sTime;
        fps = 0;
    }

    var event = window.get_next_event(handle);

    // If there is an event to process
    if (event != false)
    {
        if (event.type == "quit")
        {
          break;
        }

        if (gameStart == false && event.type == "key_down" && event.key == "return") {
            gameStart = true; // start the game.
            clear();
        }

        if (event.type == "key_down" && event.key == "space" && gameStart == true)
        {
            character.vy = 0;
            if (character.px > 0) character.ay = -0.5f;
        }
        else
        {
            character.ay = 0.3f;
        }

        // Leave the game when pressing escape.
        if (event.type == "key_down" && event.key == "escape")
        {
            break;
        }
    }

    var eTime = time.get_time_millis();
    var spareTime = (1000 / 30) - (eTime - sTime);
    // Lets waste some time. Not sure I like this really.
    var wasteStart = time.get_time_millis();
    if (spareTime > 0)
    {
        for (;;)
        {
            if (time.get_time_millis() - wasteStart >= spareTime)
                break;
        }
    }
    /*else
    {
        //print("Struggling to keep up!");
    }*/
}

window.destroy_window(handle);
