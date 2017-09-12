#language "lang/plush/0"

var window = import "core/window/0";
var time = import "core/time/0";
var array = import "std/array/0";
var math = import "std/math/0";

var size = 256;
var width = size;
var height = size;
var gridSize = 8;
var cellSize = math.idiv(size, gridSize);

// Colors are in ABGR format, 32-bits per pixel (int32)
var COLOR_RED = (255 << 24);
var COLOR_BLACK = 0;

// Window to draw into
var handle = window.create_window("Clickable Grid UI", width, height);

// Bitmap of pixels to draw
var bitmap = array.new(width * height, 0);

// Grid of clickable squares
var grid = array.new(gridSize * gridSize, false);

var toggleCell = function (x, y)
{
    var i = math.min(math.floor(x / cellSize), gridSize);
    var j = math.min(math.floor(y / cellSize), gridSize);

    print('toggle at {},{}':format([i,j]));

    grid[j * gridSize + i] = !grid[j * gridSize + i];

    // Redraw the grid
    drawGrid();
};

var drawSquare = function (startX, endX, startY, endY, color)
{
    for (var y = startY; y < endY; y += 1)
        for (var x = startX; x < endX; x += 1)
            bitmap[y * width + x] = color;
};

var drawGrid = function ()
{
    var startTime = time.get_time_millis();

    for (var j = 0; j < gridSize; j += 1)
    {
        for (var i = 0; i < gridSize; i += 1)
        {
            var topX = cellSize * i;
            var topY = cellSize * j;
            var startX = topX + 2;
            var startY = topY + 2;
            var endX = topX + cellSize - 2;
            var endY = topY + cellSize - 2;

            var cellOn = grid[j * gridSize + i];

            // Red outline
            drawSquare(
                startX,
                endX,
                startY,
                endY,
                COLOR_RED
            );

            if (!cellOn)
            {
                // Black center
                drawSquare(
                    startX + 2,
                    endX - 2,
                    startY + 2,
                    endY - 2,
                    COLOR_BLACK
                );
            }
        }
    }

    window.draw_bitmap(handle, bitmap);

    var endTime = time.get_time_millis();

    print("redraw time: {}ms":format([endTime-startTime]));
};

// Draw the initial empty grid
drawGrid();

for (var i = 0;; i += 1)
{
    var event = window.get_next_event(handle);

    // If there is an event to process
    if (event != false)
    {
        if (event.type == "quit")
        {
            break;
        }

        if (event.type == "mouse_down")
        {
            toggleCell(event.x, event.y);
        }

        if (event.type == "key_down" && event.key == "escape")
        {
            break;
        }
    }
}

window.destroy_window(handle);
