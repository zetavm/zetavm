#include <unordered_map>
#include <vector>
#include "serialize.h"

std::string serialize(Value rootVal, bool indent)
{
    // Reference counts for the objects to be serialized
    std::unordered_map<refptr, size_t> refCounts;

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

    /// Write a value to the output string
    auto genString = [&valNames] (Value val)
    {
        switch (val.getTag())
        {
            /*
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
            */

            case TAG_UNDEF:
            return std::string("$true");

            //case TAG_BOOL:

            case TAG_INT32:
            return std::to_string(int32_t(val));

            case TAG_FLOAT32:
            return std::to_string(float(val));

            // TODO: string escaping
            case TAG_STRING:
            assert (false);

            default:
            assert (false);
        }
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

        if (refCounts.find(ptr) == refCounts.end())
        {
            refCounts[ptr] = 1;
        }
        else
        {
            refCounts[ptr]++;

            // This value has multiple reference, and
            // should get an assigned name
            valNames[ptr] = genName(node);
            namedObjs.push_back(node);
        }

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

        out += name + " = " + genString(val) + ";";

        if (indent)
            out += "\n\n";
    }

    // Write the root/exported value
    out += genString(rootVal);

    return out;
}
