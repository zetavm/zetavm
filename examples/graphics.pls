#language "lang/plush/0"

var window = import "core/window/0";
assert (window != undef, "no window");
assert (typeof window == "object");
assert ("create_window" in window);

var width = 256;
var height = 256;

var handle = window.create_window("Graphics Test", width, height);

var buf = [];
for (var y = 0; y < height; y += 1)
{
    for (var x = 0; x < width; x += 1)
    {
        // Colors are in ABGR format (alpha least significant)
        var color = (x << 24) + (y << 16);
        buf:push(color);
    }
}

for (var i = 0;; i += 1)
{
    var event = window.get_next_event(handle);

    // If there is an event to process
    if (event != false)
    {
        if (event.type == "quit")
            break;
    }

    window.draw_bitmap(handle, buf);
}

window.destroy_window(handle);
