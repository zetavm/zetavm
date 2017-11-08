#language "lang/plush/0"

/// HashMap is associative list Implementation using HashTables
var math = import "std/math/0";
var string = import "std/string/0";

/// maxloadfactor -> Upper threshold for load. Capacity should increase
///                   if current load is more than this value.
var maxloadFactor = 0.75f;

/// minloadfactor -> Lower threshold for load. Capacity should decrease
///                   if current load is lower that this value.
///
var minloadFactor = 0.25f;

/// Internal representation of hashtable
/// _arr           -> Array to hold entries. An Entry is currently array
///                   of size 2 where first element is key and second is value.
/// _size          -> Number of elements in the table
/// _capacity      -> Size of _arr (capacity of hashtable);
/// _minCapacity   -> Reserved capacity (can not shrink beyond this)
var HashMap = {
    _arr: [],
    _size: 0,
    _capacity: 8,
    _minCapacity: 8
};

/// Current implementation supports only string and int32
HashMap._hash = function(key, capacity)
{
    var hash = 0;
    /// djb2 hash
    if (typeof key == "string")
    {
        hash = 5381;
        var len = key.length;
        for (var i = 0; i < len; i += 1)
        {
            hash = ((hash << 5)  + hash) ^ string.toCharCode(key[i]);
        }
    }
    else if (typeof key == "int32")
    {
        hash = key;
    }
    else
    {
        throw string.format("{} as a key to HashMap is not supported", [typeof key]);
    }

    /// 2147483647 == 0x7fffffff
    /// Unset MSB (to keep hash positive)
    return (hash & 2147483647) % capacity;
};

HashMap._resizeArrToCapacity = function(self)
{
    self._arr = [];
    for (var i = 0; i < self._capacity; i += 1)
    {
        self._arr:push([]);
    }
};

// Resizes the hashmap to newCapacity
HashMap._reserve = function(self, newCapacity)
{
    // print(string.format("Resizing : {}", [newCapacity]));
    var oldArr = self._arr;
    var oldCapacity = self._capacity;
    self._capacity = newCapacity;
    self._size = 0;
    self:_resizeArrToCapacity();
    for (var i = 0; i < oldCapacity; i += 1)
    {
        var bucket = oldArr[i];
        var len = bucket.length;
        for (var j = 0; j < len; j += 1)
        {
            var entry = bucket[j];
            self:set(entry[0], entry[1]);
        }
    }
};

/// Returns the number of entries in hashmap
HashMap.size = function(self)
{
    return self._size;
};

/// Inserts key and value in hashmap if key is not present. Otherwise updates
/// the value of the key with then provided value.
HashMap.set = function(self, key, value)
{
    var index = self._hash(key, self._capacity);
    var bucket = self._arr[index];
    var len = bucket.length;
    if (len > 0)
    {
        // If key exists, replace and return
        for (var i = 0; i < len; i += 1)
        {
            if (bucket[i][0] == key)
            {
                bucket[i][1] = value;
                return ;
            }
        }
    }
    bucket:push([key, value]);
    self._size += 1;
    var load = (self._size / self._capacity);
    if (load >= maxloadFactor)
    {
        self:_reserve(self._capacity * 2);
    }
};

/// Returns value corresponding to the key if present. Otherwise throws
/// KeyNotFound exception. Either handle the exception properly or make sure
/// key is present before calling this function.
HashMap.get = function(self, key)
{
    var index = self._hash(key, self._capacity);
    var bucket = self._arr[index];
    var len = bucket.length;
    for (var i = 0; i < len; i += 1)
    {
        var entry = bucket[i];
        if (entry[0] == key)
        {
            return entry[1];
        }
    }
    throw string.format("KeyNotFound: {}", [key]);
};

/// Returns value corresponding to the key if present. Otherwise
/// returns provided value
HashMap.getOrDefault = function(self, key, defaultValue)
{
    var index = self._hash(key, self._capacity);
    var bucket = self._arr[index];
    var len = bucket.length;
    for (var i = 0; i < len; i += 1)
    {
        var entry = bucket[i];
        if (entry[0] == key)
        {
            return entry[1];
        }
    }
    return defaultValue;
};

/// Returns true if the key is present in hashmap otherwise false
HashMap.has = function(self, key)
{
    var index = self._hash(key, self._capacity);
    var bucket = self._arr[index];
    var len = bucket.length;
    for (var i = 0; i < len; i += 1)
    {
        var entry = bucket[i];
        if (entry[0] == key)
        {
            return true;
        }
    }
    return false;
};

/// Removes the entry corresponding to the key if present. Otherwise does nothing.
HashMap.remove = function(self, key)
{
    var index = self._hash(key, self._capacity);
    var bucket = self._arr[index];
    var len = bucket.length;
    for (var i = 0; i < len; i += 1)
    {
        var entry = bucket[i];
        if (entry[0] == key)
        {
            var left = bucket:slice(0, i);
            var right = bucket:slice(i+1, len);
            for (var j = 0; j < right.length; j += 1)
            {
                left:push(right[j]);
            }
            self._arr[index] = left;
            self._size -= 1;
            var load = (self._size / self._capacity);
            var newCapacity = math.idiv(self._capacity,  2);
            // Only shrink if newcapacity is larger than reserved;
            if (load < minloadFactor && newCapacity >= self._minCapacity)
            {
                self:_reserve(newCapacity);
            }
        }
    }
};

/// Calls the consumer function over each entry of the hashmap.
/// consumer function should take 2 arguments corresponding to the key and
/// value of the entry.
HashMap.forEach = function(self, consumer)
{
    for (var i = 0; i < self._capacity; i += 1)
    {
        var bucket = self._arr[i];
        var len = bucket.length;
        for (var j = 0; j < len; j += 1)
        {
            var entry = bucket[j];
            consumer(entry[0], entry[1]);
        }
    }
};

/// Maps the mapper function over each value of the hashmap.
/// mapper function should take 2 arguments corresponding to the key and
/// value of the entry and return the newValue.
HashMap.map = function(self, mapper)
{
    for (var i = 0; i < self._capacity; i += 1)
    {
        var bucket = self._arr[i];
        var len = bucket.length;
        for (var j = 0; j < len; j += 1)
        {
            var entry = bucket[j];
            entry[1] = mapper(key, value);
        }
    }
};

/// Returns array of all the keys
HashMap.keys = function(self)
{
    var keys = [];
    for (var i = 0; i < self._capacity; i += 1)
    {
        var bucket = self._arr[i];
        var len = bucket.length;
        for (var j = 0; j < len; j += 1)
        {
            var entry = bucket[j];
            keys:push(entry[0]);
        }
    }
    return keys;
};

/// Allocates enough space to store `n` entries.
HashMap.reserve = function(self, n)
{
    var newCapacity = math.ceil(n / 0.75f);
    self._minCapacity = newCapacity;
    self:_reserve(newCapacity);
};

/// Returns new instance of the hashmap
exports.new = function()
{
    var map = HashMap::{};
    map:_resizeArrToCapacity();
    return map;
};
