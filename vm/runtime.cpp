#include <cassert>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include "runtime.h"

/// Undefined value constant
const Value Value::UNDEF(Word((int64_t)0), TAG_UNDEF);

/// Boolean constants
const Value Value::FALSE(Word((int64_t)0), TAG_BOOL);
const Value Value::TRUE(Word(1l), TAG_BOOL);

/// Numerical constants
const Value Value::ZERO(0l);
const Value Value::ONE(1l);
const Value Value::TWO(2l);

// Global virtual machine instance
VM vm;

Value::Value(Word w, Tag t)
{
    word = w;
    tag = t;
}

/// Produce a string representation of a value
std::string Value::toString() const
{
    switch (tag)
    {
        case TAG_UNDEF:
        return "$undef";

        case TAG_BOOL:
        return (*this == Value::TRUE)? "$true":"$false";

        case TAG_INT64:
        return std::to_string(word.int64);

        case TAG_STRING:
        //return (std::string)*this;
        return "string";

        case TAG_ARRAY:
        return "array";

        case TAG_OBJECT:
        return "object";

        default:
        assert (false);
    }
}

/// Determine if this value is of a pointer type
bool Value::isPointer() const
{
    switch (tag)
    {
        case TAG_STRING:
        case TAG_ARRAY:
        case TAG_OBJECT:
        case TAG_IMGREF:
        return true;

        default:
        return false;
    }
}

Value::operator bool () const
{
    assert (tag == TAG_BOOL);
    return word.int64? 1:0;
}

Value::operator int64_t () const
{
    assert (tag == TAG_INT64);
    return word.int64;
}

Value::operator refptr () const
{
    assert (isPointer());
    return word.ptr;
}

Value::operator std::string () const
{
    assert (isString());
    return String(*this);
}

VM::VM()
{
}

/**
Allocates a block of memory
Note that this function guarantees that the memory is zeroed out
*/
Value VM::alloc(uint32_t size, Tag tag)
{
    // FIXME: use an alloc pool of some kind
    auto ptr = (refptr)calloc(1, size);

    // Set the tag in the object header
    *(Tag*)ptr = tag;

    // Wrap the pointer in a tagged value
    return Value(ptr, tag);
}

void Wrapper::setNextPtr(refptr obj, refptr nextPtr)
{
    // Get the object header
    auto header = *(uint64_t*)obj;

    // Set the next pointer
    *(refptr*)(obj + OBJ_OF_NEXT) = nextPtr;

    // Set the next pointer flag bit in the object header
    *(uint64_t*)(obj) = header | HEADER_MSK_NEXT;
}

refptr Wrapper::getNextPtr(refptr obj, refptr notFound)
{
    auto header = *(uint64_t*)obj;
    bool hasNextPtr = header & HEADER_MSK_NEXT;

    if (!hasNextPtr)
        return notFound;

    auto nextPtr = *(refptr*)(obj + OBJ_OF_NEXT);
    assert (nextPtr != nullptr);

    return nextPtr;
}

refptr Wrapper::getObjPtr()
{
    auto objPtr = (refptr)val;
    assert (objPtr != nullptr);
    return getNextPtr(objPtr, objPtr);
}

String::String(std::string str)
{
    auto len = str.length();

    // Compute the string object size
    auto numBytes = memSize(len);

    // Allocate memory
    val = vm.alloc(numBytes, TAG_STRING);
    auto ptr = (refptr)val;

    // Set the string length
    *(uint32_t*)(ptr + OF_LEN) = len;

    // Copy the string data
    strcpy((char*)(ptr + OF_DATA), str.c_str());
}

String::String(Value value)
{
    assert (value.isString());
    this->val = value;
}

uint32_t String::length() const
{
    auto ptr = (refptr)val;
    assert (ptr != nullptr);
    auto len = *(uint32_t*)(ptr + OF_LEN);
    return len;
}

const char* String::getDataPtr() const
{
    auto ptr = (refptr)val;
    assert (ptr != nullptr);
    auto strdata = (char*)(ptr + OF_DATA);
    return strdata;
}

/// Casting operator to extract a string value
String::operator std::string ()
{
    auto len = length();

    std::string str;
    str.reserve(len);

    for (size_t i = 0; i < len; ++i)
        str += (*this)[i];

    return str;
}

bool String::operator == (const char* that) const
{
    return strcmp(getDataPtr(), that) == 0;
}

/// Get the ith character code
char String::operator [] (size_t i)
{
    auto len = length();
    auto strdata = getDataPtr();
    assert (i < len);
    return strdata[i];
}

String String::concat(String a, String b)
{
    auto lenA = a.length();
    auto lenB = b.length();

    std::string c;
    c.resize(lenA + lenB);

    for (size_t i = 0; i < lenA; ++i)
        c[i] = a[i];

    for (size_t i = 0; i < lenB; ++i)
        c[lenA + i] = b[i];

    return String(c);
}

/// Allocate a new array of a given length
Array::Array(size_t minCap)
{
    // Compute the object size
    auto numBytes = memSize(minCap);

    // Allocate memory
    val = vm.alloc(numBytes, TAG_ARRAY);
    auto ptr = (refptr)val;

    // Set the array capacity and length
    *(uint32_t*)(ptr + OF_CAP) = minCap;
    *(uint32_t*)(ptr + OF_LEN) = 0;

    // No initialization necessary because vm.alloc
    // provides zeroed out memory, initialized to all zeroes,
    // which evaluates to $undef.
}

Array::Array(Value value)
{
    assert (value.isArray());
    this->val = value;
}

size_t Array::getCap()
{
    auto ptr = getObjPtr();
    auto cap = *(uint32_t*)(ptr + OF_CAP);
    return cap;
}

uint32_t Array::length()
{
    auto ptr = getObjPtr();
    auto len = *(uint32_t*)(ptr + OF_LEN);
    return len;
}

/// Set the value of the ith element
void Array::setElem(size_t i, Value v)
{
    auto ptr = getObjPtr();
    auto cap = length();

    auto words = (Word*)(ptr + OF_DATA);
    auto tags  = (Tag*) (ptr + OF_DATA + cap * sizeof(Word));

    assert (length() <= getCap());
    assert (i < length());
    words[i] = v.getWord();
    tags[i] = v.getTag();
}

/// Get the value of the ith element
Value Array::getElem(size_t i)
{
    auto ptr = getObjPtr();
    auto cap = getCap();

    auto words = (Word*)(ptr + OF_DATA);
    auto tags  = (Tag*) (ptr + OF_DATA + cap * sizeof(Word));

    assert (length() <= getCap());
    assert (i < length());
    auto word = words[i];
    auto tag = tags[i];

    return Value(word, tag);
}

void Array::push(Value val)
{
    auto ptr = getObjPtr();
    auto cap = getCap();
    auto len = length();
    assert (len <= cap);

    // If the array is at capacity
    if (len == cap)
    {
        // Create a new array with twice the capacity
        auto newCap = 2 * cap + 1;
        //std::cerr << "extending array capacity from " << cap << " to " << newCap << std::endl;
        auto newArr = Array(newCap);

        // Copy elements to the new array
        for (size_t i = 0; i < len; ++i)
            newArr.push(getElem(i));

        // Set the next pointer on this object
        auto rootObjPtr = (refptr)this->val;
        setNextPtr(rootObjPtr, newArr.getObjPtr());
        assert (getObjPtr() != ptr);

        ptr = getObjPtr();
        cap = newCap;

        //std::cout << "done extending array" << std::endl;
    }

    auto words = (Word*)(ptr + OF_DATA);
    auto tags  = (Tag*) (ptr + OF_DATA + cap * sizeof(Word));

    words[len] = val.getWord();
    tags[len] = val.getTag();

    // Increment the length
    *(uint32_t*)(ptr + OF_LEN) = len + 1;
}

/*
Array Array::concat(Array a, Array b)
{
    auto lenA = a.length();
    auto lenB = b.length();

    Array c(lenA + lenB);

    for (size_t i = 0; i < lenA; ++i)
        c.setElem(i, a.getElem(i));

    for (size_t i = 0; i < lenB; ++i)
        c.setElem(lenA + i, b.getElem(i));

    return c;
}
*/

/// Allocate a new empty object
Object Object::newObject(size_t cap)
{
    if (cap < MIN_CAP)
        cap = MIN_CAP;

    // Compute the object size
    auto numBytes = memSize(cap);

    // Allocate memory
    auto val = vm.alloc(numBytes, TAG_OBJECT);
    auto ptr = (refptr)val;

    // Set the object capacity
    *(uint32_t*)(ptr + OF_CAP) = cap;

    // TODO: init object shape, when shapes actually implemented!

    // No field initialization necessary

    return val;
}

Object::Object(Value value)
{
    assert (value.getTag() == TAG_OBJECT);
    assert ((refptr)value != nullptr);
    val = value;
}

size_t Object::getCap()
{
    auto ptr = getObjPtr();
    auto cap = *(uint32_t*)(ptr + OF_CAP);
    assert (cap > 0);
    return cap;
}

size_t Object::getSlotIdx(
    refptr ptr,
    size_t cap,
    String fieldName,
    bool newField
)
{
    auto values = (Value*)(ptr + OF_FIELDS);

    // FIXME: for now, we use a dumb key-pair linear search strategy
    size_t idx = 0;
    for (; idx < cap; idx += 2)
    {
        // Empty slot, property name not found
        if (values[idx] == Value::UNDEF)
            return newField? idx:cap;

        assert (values[idx].isString());

        // Slot found
        if ((String)values[idx] == fieldName)
            return idx;
    }

    return cap;
}

bool Object::hasField(String fieldName)
{
    auto ptr = getObjPtr();
    auto cap = getCap();

    auto slotIdx = getSlotIdx(ptr, cap, fieldName, false);

    return (slotIdx < cap);
}

void Object::setField(String name, Value value)
{
    auto ptr = getObjPtr();
    auto cap = getCap();

    auto slotIdx = getSlotIdx(ptr, cap, name, true);

    // If we've exceeded the object capacity
    if (slotIdx >= cap)
    {
        // Create a new object with twice the capacity
        assert (cap > 0);
        auto newCap = 2 * cap;
        std::cerr << "extending object capacity from " << cap << " to " << newCap << std::endl;
        auto newObj = Object::newObject(newCap);

        // Copy properties to the new object
        for (auto itr = ObjFieldItr(*this); itr.valid(); itr.next())
        {
            auto fieldName = itr.get();
            auto fieldVal = getField(fieldName);
            newObj.setField(fieldName, fieldVal);
        }

        // Set the next pointer on this object
        auto newObjPtr = newObj.getObjPtr();
        auto rootObjPtr = (refptr)val;
        setNextPtr(rootObjPtr, newObjPtr);
        assert (getObjPtr() != ptr);

        ptr = getObjPtr();
        cap = getCap();
    }

    // Write the new property
    assert (slotIdx + 1 < cap);
    auto values = (Value*)(ptr + OF_FIELDS);
    values[slotIdx + 0] = name;
    values[slotIdx + 1] = value;
}

Value Object::getField(String name)
{
    auto ptr = getObjPtr();
    auto cap = getCap();
    auto values = (Value*)(ptr + OF_FIELDS);

    size_t slotIdx = getSlotIdx(ptr, cap, name, false);

    assert (slotIdx < cap);
    return values[slotIdx + 1];
}

bool Object::getField(const char* name, Value& value, size_t& idxCache)
{
    auto ptr = getObjPtr();
    auto cap = getCap();
    auto values = (Value*)(ptr + OF_FIELDS);

    //std::cout << "Lookup" << std::endl;
    //std::cout << "  name=" << name << std::endl;
    //std::cout << "  idxCache=" << idxCache << std::endl;

    assert (idxCache < cap);
    auto nameSlot = values[idxCache];
    if (nameSlot.isString())
    {
        auto nameSlotStr = String(nameSlot);
        if (strcmp(nameSlotStr.getDataPtr(), name) == 0)
        {
            //std::cout << "  cache hit" << std::endl;
            value = values[idxCache + 1];
            return true;
        }
    }

    //std::cout << "cache miss" << std::endl;
    //std::cout << "  name=" << name << std::endl;


    size_t slotIdx = getSlotIdx(ptr, cap, String(name), false);

    if (slotIdx >= cap)
    {
        return false;
    }

    idxCache = slotIdx;

    //std::cout << "  cache miss" << std::endl;
    //std::cout << "  slotIdx=" << slotIdx << std::endl;

    value = values[slotIdx + 1];
    return true;
}

ObjFieldItr::ObjFieldItr(Object obj)
: obj(obj)
{
}

bool ObjFieldItr::valid()
{
    //std::cout << "valid" << std::endl;

    auto ptr = obj.getObjPtr();
    auto cap = obj.getCap();
    auto values = (Value*)(ptr + Object::OF_FIELDS);

    return slotIdx < cap && values[slotIdx].isString();
}

std::string ObjFieldItr::get()
{
    auto ptr = obj.getObjPtr();
    auto cap = obj.getCap();
    auto values = (Value*)(ptr + Object::OF_FIELDS);

    //std::cout << "cap=" << cap << std::endl;
    //std::cout << "tag=" << (int)values[slotIdx].getTag() << std::endl;

    assert (values[slotIdx].isString());

    return values[slotIdx];
}

void ObjFieldItr::next()
{
    auto ptr = obj.getObjPtr();
    auto cap = obj.getCap();
    auto values = (Value*)(ptr + Object::OF_FIELDS);

    slotIdx += 2;

    if (slotIdx >= cap)
        return;

    if (values[slotIdx] == Value::UNDEF)
        slotIdx = cap;
}

ImgRef::ImgRef(String symbol)
{
    // Allocate memory
    val = vm.alloc(ImgRef::SIZE, TAG_IMGREF);
    auto ptr = (refptr)val;

    // Set the string pointer
    *(refptr*)(ptr + OF_SYM) = (refptr)symbol;
}

ImgRef::ImgRef(Value val)
{
    assert (val.getTag() == TAG_IMGREF);
    this->val = val;
}

std::string ImgRef::getName() const
{
    auto ptr = (refptr)val;
    assert (ptr != nullptr);

    auto strPtr = *(refptr*)(ptr + OF_SYM);
    Value strVal = Value(strPtr, TAG_STRING);

    return (std::string)strVal;
}

bool isValidIdent(std::string identStr)
{
    if (identStr.length() == 0)
        return false;

    // First character must be underscore or a letter
    if (identStr[0] != '_' && !isalpha(identStr[0]))
    {
        return false;
    }

    // Remaining characters must be underscore or alphanumerical
    for (size_t i = 1; i < identStr.length(); ++i)
    {
        auto ch = identStr[i];
        if (!isalnum(ch) && ch != '_')
            return false;
    }

    return true;
}

/// Unit test for the runtime
void testRuntime()
{
    std::cout << "runtime tests" << std::endl;

    // Strings
    auto str = String("foobar");
    assert (str.length() == 6);
    assert ((std::string)str == "foobar");
    assert (str[1] == 'o');
    auto str2 = String("foobar");
    assert (str.length() == 6);
    assert (str2.length() == 6);
    assert (str == str2);
    assert ((std::string)str == (std::string)str2);

    // Arrays
    auto arr = Array(2);
    assert (arr.length() == 0);
    arr.push(Value::ONE);
    assert (arr.length() == 1);
    assert (arr.getElem(0) == Value::ONE);
    arr.push(Value::TWO);
    assert (arr.length() == 2);
    assert (arr.getElem(0) == Value::ONE);
    assert (arr.getElem(1) == Value::TWO);
    arr.setElem(0, Value::ZERO);
    assert (arr.length() == 2);
    assert (arr.getElem(0) == Value::ZERO);

    // Array extension
    auto arr2 = Array(0);
    assert (arr2.length() == 0);
    arr2.push(Value::ONE);
    assert (arr2.length() == 1);
    assert (arr2.getElem(0) == Value::ONE);
    arr2.push(Value::TWO);
    assert (arr2.length() == 2);
    assert (arr2.getElem(0) == Value::ONE);
    assert (arr2.getElem(1) == Value::TWO);

    // Objects
    auto obj = Object::newObject();
    assert (!obj.hasField("foo"));
    obj.setField("foo", Value::ONE);
    obj.setField("bar", Value::TWO);
    assert (obj.getField("foo") == Value::ONE);
    assert (obj.getField("bar") == Value::TWO);
    obj.setField("foo", Value::TRUE);
    assert (obj.getField("foo") == Value::TRUE);
    assert (obj.getField("bar") == Value::TWO);
    assert (obj.hasField("foo"));
    assert (obj.hasField("bar"));

    // Field iteration
    std::string fieldStr;
    for (auto itr = ObjFieldItr(obj); itr.valid(); itr.next())
        fieldStr += itr.get();
    assert (fieldStr == "foobar");




}
