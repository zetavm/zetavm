// Addition operator
var rt_add = function (x, y)
{
    if (typeof x == "int64")
    {
        if (typeof y == "int64")
        {
            return $add_i64(x, y);
        }
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            return $str_cat(x, y);
        }
    }

    /*
    if (typeof x == "array")
    {
        if (typeof y == "array")
        {
            return $array_cat(x, y);
        }
    }
    */

    assert (
        false,
        "unhandled type in addition"
    );
};

/// Subtraction operator
var rt_sub = function (x, y)
{
    if (typeof x == "int64")
    {
        if (typeof y == "int64")
        {
            return $sub_i64(x, y);
        }
    }

    assert (
        false,
        "unhandled type in subtraction"
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
    if (typeof x == "int64")
    {
        if (typeof y == "int64")
        {
            return $eq_i64(x, y);
        }
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
        "unhandled type in equality comparison"
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

/// Less than or equal comparison
var rt_le = function (x, y)
{
    if (typeof x == "int64")
    {
        if (typeof y == "int64")
        {
            return $le_i64(x, y);
        }
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            // TODO: proper string comparison
            assert ($eq_i64($str_len(x), 1), "rt_le");
            assert ($eq_i64($str_len(y), 1), "rt_le");
            return $get_char_code(x, 0) <= $get_char_code(y, 0);
        }
    }

    assert (
        false,
        "unhandled type in less-than or equal comparison"
    );
};

/// Greater than or equal comparison
var rt_ge = function (x, y)
{
    if (typeof x == "int64")
    {
        if (typeof y == "int64")
        {
            return $ge_i64(x, y);
        }
    }

    if (typeof x == "string")
    {
        if (typeof y == "string")
        {
            // TODO: proper string comparison
            assert ($eq_i64($str_len(x), 1), "rt_ge");
            assert ($eq_i64($str_len(y), 1), "rt_ge");
            return $get_char_code(x, 0) >= $get_char_code(y, 0);
        }
    }

    assert (
        false,
        "unhandled type in less-than or equal comparison"
    );
};

/// Property existence check operator
var rt_in = function (x, y)
{
    if (typeof x == "string")
    {
        if (typeof y == "object")
        {
            return $has_field(y, x);
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

        if (name == "push")
        {
            return rt_push;
        }
    }

    if (typeof base == "string")
    {
        if (name == "length")
        {
            return $str_len(base);
        }
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
        // TODO: check bounds
        return $get_elem(base, idx);
    }

    if (typeof base == "string")
    {
        // TODO: check bounds
        //if (index < $str_len(base))
        return $get_char(base, idx);
    }

    assert (false);
};

/// Array push method
var rt_push = function (arr, val)
{
    $array_push(arr, val);
};

var io = import "core/io";

/// Write to standard output
var output = function (x)
{
    if (typeof x == "string")
    {
        call_host io.print_str(x);
        return;
    }

    if (typeof x == "int64")
    {
        call_host io.print_int64(x);
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

/// Read an entire text file into a string
var readFile = function (fileName)
{
    return call_host io.read_file(fileName);
};
