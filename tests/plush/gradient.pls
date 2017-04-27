#language "lang/plush/0"

var window = import "core/window";
assert (window != undef);
assert (typeof window == "object");
assert ("create_window" in window);

var width = 256;
var height = 256;

window.create_window("Window Gradient Test", width, height);

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

for (var i = 0;; i += 1)
{
    var result = window.process_events();

    if (result == false)
        break;

    print(i);

    window.draw_pixels(buf);
}

window.destroy_window();
