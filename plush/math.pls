/// Floating-point constants
exports.PI = 3.14159265358979323846f;
exports.E  = 2.71828182845904523536f;
exports.INF = 1.0f / 0.0f;

/// Maximum and mininum representable int32 values
exports.INT32_MAX = 2147483647;
exports.INT32_MIN = -2147483648;

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

exports.fmod = function (x, y)
{
    if (typeof x == "float32" && typeof y == "float32")
    {
        var quot = x / y;
        var iquot = $f32_to_i32(quot);
        var fmod = x - iquot * y;
        return fmod;
    }

    if (typeof x == "int32")
    {
        return exports.fmod($i32_to_f32(x), y);
    }

    if (typeof y == "int32")
    {
        return exports.fmod(x, $i32_to_f32(y));
    }

    assert (
        false,
        "unhandled types in fmod function"
    );
};

exports.idiv = function (x, y)
{
    if (typeof x == "int32" && typeof y == "int32")
    {
        return $div_i32(x, y);
    }

    throw "unhandled type in idiv";
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

exports.ceil = function (x)
{
    if (typeof x == "int32")
    {
        return x;
    }

    if (typeof x == "float32")
    {
        var xi = $f32_to_i32(x);
        if (x <= xi)
            return xi;
        return xi + 1;
    }

    assert(
        false,
        "unhandled type in ceil function"
    );
};

exports.pow = function (base, exp)
{
    if (exp == 0)
    {
        return 1;
    }

    if (base == 0)
    {
        return 0;
    }

    if (typeof base == "int32" && typeof exp == "int32")
    {
        var recip = false;
        var result = 1;
        if (exp < 0)
        {
            exp = -exp; // Make positive.
            recip = true;
        }

        for (;exp != 0;)
        {
            if ( (exp & 1) != 0)
            {
                result *= base;
            }
            exp >>= 1;
            base *= base;
        }

        if (recip)
        {
            return 1.0f / result;
        }
        else
        {
            return result;
        }
    }

    if (typeof base == "int32")
        base = $i32_to_f32(base);

    if (typeof exp == "int32")
        exp = $i32_to_f32(exp);

    if (typeof base == "float32" && typeof exp == "float32")
    {
        assert (
            base >= 0,
            "negative bases in floating-point pow unsupported"
        );

        var logBase = $log_f32(base);
        return $exp_f32(logBase * exp);
    }

    assert(
        false,
        "unhandled type in pow function"
    );
};

exports.log = function (x)
{
    if (typeof x == "int32")
    {
        x = $i32_to_f32(x);
    }

    if (typeof x == "float32")
    {
        assert(x > 0, "log input must be greater than zero");

        return $log_f32(x);
    }

    assert(
        false,
        "unhandled type in log function"
    );
};

exports.exp = function (x)
{
    if (typeof x == "int32")
    {
        x = $i32_to_f32(x);
    }

    if (typeof x == "float32")
    {
        return $exp_f32(x);
    }

    assert(
        false,
        "unhandled type in exp function"
    );
};
