#language "lang/plush/0"

var time = import "core/time/0";

var t = time.get_time_millis();

assert (t >= 0);
