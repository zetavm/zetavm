#include <unordered_set>
#include <unordered_map>
#include <vector>
#include <iostream>
#include "serialize.h"

// Forward declaration
std::string nameOrRepr(
    Value val,
    std::unordered_map<refptr, std::string>& valNames,
    bool minify,
    std::string indent
);

std::string escapeStr(std::string str)
{
    std::string out = "\"";

    for (size_t i = 0; i < str.size(); ++i)
    {
        unsigned char ch = str[i];

        if (ch == '\n')
        {
            out += "\\n";
            continue;
        }

        if (ch == '\r')
        {
            out += "\\r";
            continue;
        }

        if (ch == '\t')
        {
            out += "\\t";
            continue;
        }

        if (ch == '\\')
        {
            out += "\\\\";
            continue;
        }

        if (ch == '\"')
        {
            out += "\\\"";
            continue;
        }

        if (ch == '\'')
        {
            out += "\\\'";
            continue;
        }

        if (ch >= 32 && ch <= 126)
        {
            out += ch;
            continue;
        }

        char hexStr[8];
        sprintf(hexStr, "\\x%02X", (int)ch);
        out += hexStr;
    }

    return out + "\"";
}

/// Generate the output string for a value
std::string genString(
    Value val,
    std::unordered_map<refptr, std::string>& valNames,
    bool minify,
    std::string indent
)
{
    switch (val.getTag())
    {
        case TAG_ARRAY:
        {
            auto arr = Array(val);
            auto len = arr.length();

            std::string out = "[";

            // For each array element
            for (size_t i = 0; i < len; ++i)
            {
                auto elemVal = arr.getElem(i);
                out += nameOrRepr(elemVal, valNames, minify, indent);

                if (i < len - 1)
                {
                    out += ",";
                    if (!minify)
                        out += " ";
                }
            }

            return out + "]";
        }
        break;

        case TAG_OBJECT:
        {
            auto obj = Object(val);

            std::string out = "{";

            // First field being printed
            bool first = true;

            // For each object field
            for (auto itr = ObjFieldItr(obj); itr.valid(); itr.next())
            {
                auto fieldName = itr.get();
                auto fieldVal = obj.getField(fieldName);

                if (first)
                    first = false;
                else
                    out += ",";

                // Indent this field
                if (!minify)
                {
                    out += "\n";
                    out += indent + "  ";
                }

                if (isValidIdent(fieldName))
                    out += fieldName;
                else
                    out += escapeStr(fieldName);

                out += ":";

                out += nameOrRepr(
                    fieldVal,
                    valNames,
                    minify,
                    indent + "  "
                );
            }

            // Indent the closing brace
            if (!minify)
            {
                out += "\n";
                out += indent;
            }

            out += "}";

            return out;
        }
        break;

        // TODO: naming of long strings
        case TAG_STRING:
        {
            auto str = (std::string)val;
            return escapeStr(str);
        }
        break;

        case TAG_UNDEF:
        return std::string("$undef");

        case TAG_BOOL:
        return std::string((val == Value::TRUE)? "$true":"$false");

        case TAG_INT32:
        return std::to_string(int32_t(val));

        case TAG_FLOAT32:
        return std::to_string(float(val)) + "f";

        default:
        auto tagStr = tagToStr(val.getTag());
        throw RunError("cannot serialize values with tag \"" + tagStr + "\"");
    }
};

/// Produce a value's name if it has one, otherwise its string representation
std::string nameOrRepr(
    Value val,
    std::unordered_map<refptr, std::string>& valNames,
    bool minify,
    std::string indent
)
{
    if (!val.isPointer())
        return genString(val, valNames, minify, indent);

    auto ptr = (refptr)val;
    if (valNames.find(ptr) != valNames.end())
        return "@" + valNames[ptr];

    return genString(val, valNames, minify, indent);
};

/// Serialize the graph indirectly referenced by a root value
std::string serialize(Value rootVal, bool minify)
{
    // Visited set for the naming traversal
    std::unordered_set<refptr> visited;

    // Map of objects to names
    // Notes: only objects with multiple references get a name
    std::unordered_map<refptr, std::string> valNames;

    // List of objects with assigned names
    std::vector<Value> namedObjs;

    size_t lastIdx = 0;

    /// Generate a name for a value
    auto genName = [&lastIdx] (Value val)
    {
        return "n_" + std::to_string(++lastIdx);
    };

    // Stack of nodes to visit
    std::vector<Value> stack;

    stack.push_back(rootVal);

    // Until we are done
    while (!stack.empty())
    {
        // Pop a node off the stack
        auto node = stack.back();
        stack.pop_back();

        if (!node.isPointer())
            continue;

        auto ptr = (refptr)node;

        // If this value has been previously visited
        if (visited.find(ptr) != visited.end())
        {
            // If minification is disabled and this is a short string
            if (!minify && node.isString() && String(node).length() <= 16)
            {
                continue;
            }

            // This value has multiple reference, and
            // should get an assigned name
            if (valNames.find(ptr) == valNames.end())
            {
                valNames[ptr] = genName(node);
                namedObjs.push_back(node);
            }

            // Don't visit this value's children
            continue;
        }

        // Mark the value as visited
        visited.insert(ptr);

        switch (node.getTag())
        {
            case TAG_ARRAY:
            {
                auto arr = Array(node);
                auto len = arr.length();

                // For each array element
                for (size_t i = 0; i < len; ++i)
                {
                    auto elemVal = arr.getElem(i);
                    stack.push_back(elemVal);
                }
            }
            break;

            case TAG_OBJECT:
            {
                auto obj = Object(node);

                // For each object field
                for (auto itr = ObjFieldItr(obj); itr.valid(); itr.next())
                {
                    auto fieldName = itr.get();
                    auto fieldVal = obj.getField(fieldName);
                    stack.push_back(fieldVal);
                }
            }
            break;

            case TAG_UNDEF:
            case TAG_BOOL:
            case TAG_INT32:
            case TAG_INT64:
            case TAG_FLOAT32:
            case TAG_STRING:
            continue;

            default:
            assert (false);
        }
    }

    std::string out;

    // For each object with an assigned name
    for (size_t i = 0; i < namedObjs.size(); ++i)
    {
        auto val = namedObjs[i];
        auto ptr = (refptr)val;
        auto name = valNames[ptr];

        out += name + " = " + genString(val, valNames, minify, "") + ";";

        if (!minify)
            out += "\n\n";
    }

    // Write the root/exported value
    out += nameOrRepr(rootVal, valNames, minify, "") + ";";

    return out;
}
