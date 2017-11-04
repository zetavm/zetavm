/// Throw an exception
var rt_throw = function (e)
{
    $throw(e);
};

/// Addition operator
var rt_add = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $add_f32($i32_to_f32(x), y);
        }
        if (typeof y == "int32")
        {
            return $add_i32(x, y);
        }
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $add_f32(x, y);
        }
        if (typeof y == "int32")
        {
            return $add_f32(x, $i32_to_f32(y));
        }
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            return $str_cat(x, y);
        }
    }

    assert (
        false,
        "unhandled type in addition"
    );
};

/// Subtraction operator
var rt_sub = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $sub_f32($i32_to_f32(x), y);
        }
        if (typeof y == "int32")
        {
            return $sub_i32(x, y);
        }
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $sub_f32(x, y);
        }
        if (typeof y == "int32")
        {
            return $sub_f32(x, $i32_to_f32(y));
        }
    }

    assert (
        false,
        "unhandled type in subtraction"
    );
};

var rt_mul = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $mul_f32($i32_to_f32(x), y);
        }
        if (typeof y == "int32")
        {
            return $mul_i32(x, y);
        }
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $mul_f32(x, y);
        }
        if (typeof y == "int32")
        {
            return $mul_f32(x, $i32_to_f32(y));
        }
    }

    assert (
        false,
        "unhandled type in multiplication"
    );
};

var rt_div = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $div_f32($i32_to_f32(x), y);
        }

        if (typeof y == "int32")
        {
            return $div_f32($i32_to_f32(x), $i32_to_f32(y));
        }
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $div_f32(x, y);
        }

        if (typeof y == "int32")
        {
            return $div_f32(x, $i32_to_f32(y));
        }
    }

    assert (
        false,
        "unhandled type in division"
    );
};

/// Integer modulo/remainer operator
var rt_mod = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $mod_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in modulo"
    );
};

/// bitwise left-shift operator
var rt_shl = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $shl_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in bitwise left shift"
    );
};

/// bitwise right-shift operator (sign-extending)
var rt_shr = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $shr_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in bitwise right shift"
    );
};

/// bitwise unsigned right-shift operator
var rt_ushr = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $ushr_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in bitwise unsigned right shift"
    );
};

/// bitwise and operator
var rt_and = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $and_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in bitwise and"
    );
};

/// bitwise or operator
var rt_or = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $or_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in bitwise or"
    );
};

/// bitwise exclusive-or operator
var rt_xor = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "int32")
        {
            return $xor_i32(x, y);
        }
    }

    assert (
        false,
        "unhandled type in xor"
    );
};

/// Bitwise not; one's-complement
var rt_bit_not = function (x)
{
    if (typeof x == "int32")
    {
        return $not_i32(x);
    }

    assert (
        false,
        "unhandled type in bitwise not"
    );
};

/// Logical negation
var rt_not = function (x)
{
    if (x)
        return false;
    else
        return true;
};

/// Equality comparison
var rt_eq = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $eq_f32($i32_to_f32(x), y);
        }

        if (typeof y == "int32")
        {
            return $eq_i32(x, y);
        }

        return false;
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $eq_f32(x, y);
        }

        if (typeof y == "int32")
        {
            return $eq_f32(x, $i32_to_f32(y));
        }

        return false;
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            return $eq_str(x, y);
        }

        return false;
    }

    if (typeof x == "object")
    {
        if (typeof y == "object")
        {
            return $eq_obj(x, y);
        }

        return false;
    }

    if (typeof x == "array")
    {
        if (typeof y == "array")
        {
            return $eq_array(x, y);
        }

        return false;
    }

    if (typeof x == "bool")
    {
        if (typeof y == "bool")
        {
            return $eq_bool(x, y);
        }

        return false;
    }

    if (typeof x == "undef")
    {
        if (typeof y == "undef")
        {
            return true;
        }

        return false;
    }

    assert (
        false,
        "unhandled type in equality comparison: " + typeof x
    );
};

/// Inequality comparison
var rt_ne = function (x, y)
{
    if (rt_eq(x, y))
        return false;
    else
        return true;
};

var rt_lt = function(x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $lt_f32($i32_to_f32(x), y);
        }

        if (typeof y == "int32")
        {
            return $lt_i32(x, y);
        }

        throw "incompatible types in comparison";
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $lt_f32(x, y);
        }

        if (typeof y == "int32")
        {
            return $lt_f32(x, $i32_to_f32(y));
        }

        throw "incompatible types in comparison";
    }

    throw "invalid types in comparison";
};

/// Less than or equal comparison
var rt_le = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $le_f32($i32_to_f32(x), y);
        }

        if (typeof y == "int32")
        {
            return $le_i32(x, y);
        }

        throw "incompatible types in comparison";
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $le_f32(x, y);
        }

        if (typeof y == "int32")
        {
            return $le_f32(x, $i32_to_f32(y));
        }

        throw "incompatible types in comparison";
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            // TODO: proper string comparison
            assert ($eq_i32($str_len(x), 1), "rt_le");
            assert ($eq_i32($str_len(y), 1), "rt_le");
            return $get_char_code(x, 0) <= $get_char_code(y, 0);
        }
    }

    throw "invalid types in comparison";
};

var rt_gt = function(x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $gt_f32($i32_to_f32(x), y);
        }

        if (typeof y == "int32")
        {
            return $gt_i32(x, y);
        }

        throw "incompatible types in comparison";
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $gt_f32(x, y);
        }

        if (typeof y == "int32")
        {
            return $gt_f32(x, $i32_to_f32(y));
        }

        throw "incompatible types in comparison";
    }

    throw "invalid types in comparison";
};

/// Greater than or equal comparison
var rt_ge = function (x, y)
{
    if (typeof x == "int32")
    {
        if (typeof y == "float32")
        {
            return $ge_f32($i32_to_f32(x), y);
        }

        if (typeof y == "int32")
        {
            return $ge_i32(x, y);
        }

        throw "incompatible types in comparison";
    }

    if (typeof x == "float32")
    {
        if (typeof y == "float32")
        {
            return $ge_f32(x, y);
        }

        if (typeof y == "int32")
        {
            return $ge_f32(x, $i32_to_f32(y));
        }

        throw "incompatible types in comparison";
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            // TODO: proper string comparison
            assert ($eq_i32($str_len(x), 1), "rt_ge");
            assert ($eq_i32($str_len(y), 1), "rt_ge");
            return $get_char_code(x, 0) >= $get_char_code(y, 0);
        }
    }

    throw "invalid types in comparison";
};

/// Property existence check operator
var rt_in = function (x, y)
{
    if (typeof x == "string")
    {
        if (typeof y == "object")
        {
            if ($has_field(y, x))
                return true;

            if ($has_field(y, 'proto') && typeof y.proto == "object")
                return rt_in(x, y.proto);

            return false;
        }
    }

    assert (
        false,
        "unhandled type in the 'in' operator"
    );
};

/// Instanceof operator
var rt_instOf = function (obj, proto)
{
    assert (
        typeof obj == "object",
        "instanceof only applies to objects"
    );

    assert (
        typeof proto == "object",
        "prototype in instanceof must be an object"
    );

    if ($has_field(obj, "proto"))
    {
        var objProto = $get_field(obj, "proto");

        if ($eq_obj(objProto, proto))
            return true;

        return rt_instOf(objProto, proto);
    }

    // This object has no prototype
    return false;
};

/// Property access
var rt_getProp = function (base, name)
{
    if (typeof base == "object")
    {
        if ($has_field(base, name))
        {
            return $get_field(base, name);
        }

        if ($has_field(base, "proto"))
        {
            var proto = $get_field(base, "proto");
            return rt_getProp(proto, name);
        }

        assert (false, 'undefined property "' + name + '"');
    }

    if (typeof base == "array")
    {
        if (name == "length")
        {
            return $array_len(base);
        }

        // TODO: replace by array library method
        // Note: may need to optimize `import` with caching
        //       in order to avoid a perf impact
        if (name == "push")
        {
            return rt_push;
        }

        // Lazily import the array library
        var array = import "std/array/0";

        // Lookup the property on the array prototype object
        return array.prototype[name];
    }

    if (typeof base == "string")
    {
        if (name == "length")
        {
            return $str_len(base);
        }

        // Lazily import the string library
        var string = import "std/string/0";

        // Lookup the property on the string prototype object
        return string.prototype[name];
    }

    assert (
        false,
        'unhandled base type in read of property \"' + name + '"'
    );
};

/// Indexing operator implementation (ie: base[idx])
var rt_getElem = function (base, idx)
{
    if (typeof base == "array")
    {
        assert (
            typeof idx == "int32",
            "unhandled index type in getElem with array base; should be int32"
        );

        // TODO: check bounds
        return $get_elem(base, idx);
    }

    if (typeof base == "string")
    {
        assert (
            typeof idx == "int32",
            "unhandled index type in getElem with string base; should be int32"
        );

        // TODO: check bounds
        //if (index < $str_len(base))
        return $get_char(base, idx);
    }

    if (typeof base == "object")
    {
        assert (
            typeof idx == "string",
            "unhandled index type in getElem with object base; should be string"
        );

        return $get_field(base, idx);
    }

    assert (
        false,
        "unhandled base type in getElem; should be array, string, or object"
    );
};

/// Assign-to-index operator implementation (ie: base[idx] = val)
var rt_setElem = function (base, idx, val)
{
    if (typeof base == "array")
    {
        assert (
            typeof idx == "int32",
            "unhandled index type in setElem with array base; should be int32"
        );

        // TODO: check bounds
        $set_elem(base, idx, val);
        return val;
    }

    if (typeof base == "object")
    {
        assert (
            typeof idx == "string",
            "unhandled index type in setElem with object base; should be string"
        );

        $set_field(base, idx, val);
        return val;
    }

    assert (
        false,
        "unhandled base type in setElem; should be array or object"
    );
};

/// Array push method
var rt_push = function (arr, val)
{
    $array_push(arr, val);
};

/// Write to standard output
var output = function (x)
{
    // Note: we lazily import core packages because references to
    // host functions can't be serialized, and so should not be stored
    // in the global object.
    var io = import "core/io/0";

    if (typeof x == "string")
    {
        io.print_str(x);
        return;
    }

    if (typeof x == "int32")
    {
        io.print_int32(x);
        return;
    }

    if (typeof x == "float32")
    {
        io.print_float32(x);
        return;
    }

    if (typeof x == "array" || typeof x == "object")
    {
        // Lazily import the std/string package
        var string = import "std/string/0";
        io.print_str(string.toString(x));
        return;
    }

    if (x == true)
    {
        output("true");
        return;
    }

    if (x == false)
    {
        output("false");
        return;
    }

    assert (
        false,
        "unhandled type in output function"
    );
};

/// Print to standard output and include a line terminator
var print = function (x)
{
    output(x);
    output('\n');
};
