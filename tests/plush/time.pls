#language "lang/plush/0"

var time = import "core/time/0";
var t = time.get_time_millis();
assert (t >= 0);

// test get_local_time outputs
var tm = time.get_local_time();
assert (tm.sec < 60);
assert (tm.sec >= 0);
assert (tm.min < 60);
assert (tm.min >= 0);
assert (tm.hour < 24);
assert (tm.hour >= 0);
assert (tm.day <= 31);
assert (tm.day > 0);
assert (tm.week_day >= 0);
assert (tm.week_day <= 6);
assert (tm.year_day >= 0);
assert (tm.year_day <= 365);
assert (typeof tm.year == "int32");
assert (typeof tm.is_dst == "bool");

print("core/time -> All tests passed");
