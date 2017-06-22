exports.PI = 3.14159265358979323846f;
exports.E  = 2.71828182845904523536f;
exports.INF = 1.0f / 0.0f;

exports.isNaN = function (x)
{
    if (typeof x == "float32")
    {
        return x != x;
    }

    return false;
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

exports.floor = function (x)
{
    if (typeof x == "int32")
    {
        return x;
    }

    if (typeof x == "float32")
    {
        var xi = $f32_to_i32(x);
        if (x < xi)
            return xi - 1;
        return xi;
    }

    assert(
        false,
        "unhandled type in floor function"
    );
};

exports.fmod = function (x, y)
{
    if (typeof x == "float32" && typeof y == "float32")
    {
        var quot = x / y;
        var iquot = $f32_to_i32(quot);
        var fmod = x - iquot * y;
    }

    assert (
        false,
        "unhandled types in fmod function"
    );
};

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
        "unhandled type in sqrt function"
    );
};
