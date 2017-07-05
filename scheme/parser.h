#pragma once

#include <string>
#include <memory>
#include <vector>
#include <unordered_map>

/**
Represents an input character stream to parse from
*/
struct Input
{
private:

    /// Input source name
    std::string srcName;

    /// Input string to be parsed
    std::string inStr;

    /// Current index in the input string
    size_t strIdx;

    /// Current line number
    size_t lineNo;

    /// Current column number
    size_t colNo;

public:

    Input(std::string str, std::string srcName);

    ~Input();

    /// Peek at a character from the input at the given offset
    char peekCh(unsigned int offset = 0);

    /// Read/consume a character from the input
    char readCh();

    /// Test if the end of file has been reached
    bool eof();

    /// Check if a string is next in the input
    bool next(const std::string& str);

    /// Try and match a given string in the input
    /// The string is consumed if matched
    bool match(const std::string& str);

    /// Fail if the input doesn't match a given string
    void expect(const std::string str);

    /// Consume whitespace and comments
    void eatWS();

    /// Version of next which also eats preceding whitespace
    bool nextWS(const std::string& str);

    /// Version of match which also eats preceding whitespace
    bool matchWS(const std::string& str);

    /// Version of expect which eats preceding whitespace
    void expectWS(const std::string str);

    std::string getSrcName() const { return srcName; }
    size_t getLineNo() const { return lineNo; }
    size_t getColNo() const { return colNo; }
};

/**
Parse-time error exception class
*/
class ParseError
{
private:

    std::string msg;

public:

    ParseError(std::string msg)
    {
        this->msg = msg;
    }

    ParseError(Input& input, std::string msg)
    {
        this->msg = (
            input.getSrcName() + "@" +
            std::to_string(input.getLineNo()) + ":" +
            std::to_string(input.getColNo()) + " - " +
            msg
        );
    }

    virtual ~ParseError()
    {
    }

    virtual std::string toString() const
    {
        return msg;
    }
};

/**
Base class for all Scheme values
*/
class Value
{
public:

    virtual ~Value() {}

    virtual std::string toString() const = 0;
};

class Identifier : public Value
{
public:

    Identifier(std::string val): val(val) {}

    virtual ~Identifier() {}

    virtual std::string toString() const
    {
        return val;
    }

    std::string val;
};

class Integer : public Value
{
public:

    Integer(int64_t val): val(val) {}

    virtual ~Integer() {}

    virtual std::string toString() const
    {
        return std::to_string(val);
    }

    int64_t val;
};

class String : public Value
{
public:

    String(const std::string& val): val(val) {}

    virtual ~String() {}

    virtual std::string toString() const
    {
        return "\"" + val + "\"";
    }

    std::string val;
};

class Boolean : public Value
{
public:

    Boolean(bool val): val(val) {}

    virtual ~Boolean() {}

    virtual std::string toString() const
    {
        return val ? "#t" : "#f";
    }

    bool val;
};

class Pair : public Value
{
public:

    Pair() : car(nullptr), cdr(nullptr) {}

    Pair(std::unique_ptr<Value> car, std::unique_ptr<Value> cdr)
        : car(std::move(car)), cdr(std::move(cdr)) {}

    virtual ~Pair() {}

    virtual std::string toString() const
    {
        std::string repr = "(";
        if (car)
        {
            repr += car->toString();
        }

        Value *tail = cdr.get();
        while (tail)
        {
            if (Pair* pair = dynamic_cast<Pair*>(tail))
            {
                if (pair->car)
                {
                    repr += " " + pair->car->toString();
                }
                tail = pair->cdr.get();
            }
        }

        repr += ")";
        return repr;
    }

    std::unique_ptr<Value> car;
    std::unique_ptr<Value> cdr;
};

class Program
{
public:

    Program(std::vector<std::unique_ptr<Value>> &newValues)
    {
        for (auto &value : newValues)
            values.push_back(std::move(value));
    }

    std::string toString() const
    {
        std::string repr;
        for (auto &value : values)
        {
            repr += value->toString();
        }
        return repr;
    }

    std::vector<std::unique_ptr<Value>> values;
};

std::unique_ptr<Program> parseString(const std::string &str, const std::string &srcName);

std::unique_ptr<Program> parseFile(const std::string &fileName);

void testParser();
