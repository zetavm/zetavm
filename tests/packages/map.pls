#language "lang/plush/0"

/// Tests for std/map

var map = import "std/map/0";
var strings = import "std/string/0";

var mymap = map.new();
var keyArr = ["name", 42, "type"];
var count = 0;

// Asserts that calling the `fun` throws some exception
var assertThrows = function(fun)
{
    try { fun(); } catch (e) { return; }
    assert(false);
};

var sanityTest = function()
{
    assert(mymap:size() == 0);
    assertThrows(function() { mymap:get(42); });
    assert(!mymap:has("zeta"));

    /// map:set
    mymap:set(42, "Answer to life, universe and everything");
    mymap:set("name", "plush");
    mymap:set("type", "hashtable");
    assert(mymap:size() == 3);

    /// map:set (update)
    mymap:set("type", "hashtable");
    assert(mymap:size() == 3);

    mymap:set("package", "std/map");
    assert(mymap:size() == 4);

    /// map:get
    assert(mymap:get("package") == "std/map");
    assert(mymap:get("type") == "hashtable");
    assert(mymap:get("name") == "plush");
    assert(mymap:get(42) == "Answer to life, universe and everything");

    assertThrows(function() { mymap:get(48); });

    /// map:remove
    mymap:remove("package");
    assertThrows(function() { mymap:get("package"); });
    assert(mymap:size() == 3);


    /// map:has
    assert(!mymap:has("package"));
    assert(mymap:has("type"));
    assert(mymap:has("name"));
    assert(mymap:has(42));
    assert(!mymap:has(48));

    // map:forEach
    count = 0;
    mymap:forEach(function(key, value) {
        assert(keyArr:contains(key));
        count += 1;
    });

    assert(count == 3);
    keyArr:forEach(function(key) {
        mymap:remove(key);
    });
    assert(mymap:size() == 0);

    assert(mymap:getOrDefault("name", "plush") == "plush");

};

var bigMap = map.new();
bigMap:reserve(300);

var regressionTest = function()
{
    var fileName = "tests/plush/a_lot_of_strings";
    var io = import "core/io/0";

    var data = io.read_file(fileName)
        :split("\n")
        :map(function (line) {
            var tokens = line:split(",");
            var kvp = [tokens[0], tokens[1]];
            return kvp;
        });

    data:forEach(function(kvp) {
        bigMap:set(kvp[0], kvp[1]);
    });

    assert(bigMap:size() == data.length);

    /// map:has
    /// map:get
    data:forEach(function(kvp) {
        assert(bigMap:has(kvp[0]));
        assert(bigMap:get(kvp[0]) == kvp[1]);
    });

    var math = import "std/math/0";
    var K = math.idiv(data.length, 2);
    var firstK = data:slice(0, K);
    var rest = data:slice(K, data.length);

    /// Remove first K entries
    firstK:forEach(function(kvp) {
        bigMap:remove(kvp[0]);
    });

    /// Removed data should not be there
    firstK:forEach(function(kvp) {
        assert(!bigMap:has(kvp[0]));
        count += 1;
    });

    /// Size should come down
    assert(bigMap:size() == data.length - K);

    /// Rest of the elements should be there
    rest:forEach(function(kvp) {
        assert(bigMap:has(kvp[0]));
        assert(bigMap:get(kvp[0]) == kvp[1]);
    });

    /// Remove all of the elements
    rest:forEach(function(kvp) {
        bigMap:remove(kvp[0]);
    });

    /// capacity now should be initialCapacity (8);
    /// assert(bigMap._capacity == 8);
    /// size should be zero
    assert(bigMap:size() == 0);
};

sanityTest();
regressionTest();
sanityTest();

print("std/map, All tests passed");
