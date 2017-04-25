#language "lang/plush/0"

var counter = { count: 0 };

counter.incr = function (self)
{
    self.count += 1;
};

counter:incr();
print(counter.count);

counter:incr();
print(counter.count);

assert (counter.count == 2);
