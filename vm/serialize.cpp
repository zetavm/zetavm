#include <unordered_set>
#include <unordered_map>
#include <functional>
#include <vector>
#include <iostream>
#include "serialize.h"

// Forward declaration
std::string nameOrRepr(
    Value val,
    std::unordered_map<refptr, std::string>& valNames,
    bool indent
);

/// Generate the output string for a value
std::string genString(
    Value val,
    std::unordered_map<refptr, std::string>& valNames,
    bool indent
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
                out += nameOrRepr(elemVal, valNames, indent);

                if (i < len - 1)
                {
                    out += ",";
                    if (indent)
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

            // For each object field
            for (auto itr = ObjFieldItr(obj); itr.valid(); itr.next())
            {
                auto fieldName = itr.get();
                auto fieldVal = obj.getField(fieldName);

                // TODO: escape field names
                out += fieldName;

                out += ":";

                out += nameOrRepr(fieldVal, valNames, indent);

                out += ",";
            }

            return out + "}";
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

        // TODO: string escaping
        case TAG_STRING:
        assert (false);

        default:
        assert (false);
    }
};

/// Produce a value's name if it has one, otherwise its string representation
std::string nameOrRepr(
    Value val,
    std::unordered_map<refptr, std::string>& valNames,
    bool indent
)
{
    if (!val.isPointer())
        return genString(val, valNames, indent);

    auto ptr = (refptr)val;
    if (valNames.find(ptr) != valNames.end())
        return "@" + valNames[ptr];

    return genString(val, valNames, indent);
};

std::string serialize(Value rootVal, bool indent)
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

        if (visited.find(ptr) != visited.end())
        {
            // This value has multiple reference, and
            // should get an assigned name
            valNames[ptr] = genName(node);
            namedObjs.push_back(node);
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

        out += name + " = " + genString(val, valNames, indent) + ";";

        if (indent)
            out += "\n\n";
    }

    // Write the root/exported value
    out += nameOrRepr(rootVal, valNames, indent) + ";";

    return out;
}
