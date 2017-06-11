exports.sin = function (x)
{
    if (typeof x == "int32")
    {
        return $sin_f32($i32_to_f32(x));
    }

    if (typeof x == "float32")
    {
        return $sin_f32(x);
    }

    assert(
        false,
        "unhandled type in sin function"
    );
};

exports.cos = function (x)
{
    if (typeof x == "int32")
    {
        return $cos_f32($i32_to_f32(x));
    }

    if (typeof x == "float32")
    {
        return $cos_f32(x);
    }

    assert(
        false,
        "unhandled type in cos function"
    );
};

exports.max = function (x, y)
{
    if (x > y)
        return x;
    return y;
};

exports.min = function (x, y)
{
    if (x < y)
        return x;
    return y;
};

exports.abs = function (x) 
{
    if (x < 0)
        return -x;
    return x;
};

exports.sqrt = function (x)
{

    if (typeof x == "int32")
    {
        return $sqrt_f32($i32_to_f32(x));
    }

    if (typeof x == "float32")
    {
        return $sqrt_f32(x);
    }

    assert(
        false,
        "unhandled type in sin function"
    );
};

exports.PI = 3.14159265358979323846f;
exports.E  = 2.71828182845904523536f;