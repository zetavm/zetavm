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

exports.PI = 3.14159265358979323846;
exports.E  = 2.71828182845904523536;