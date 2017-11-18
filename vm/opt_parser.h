#pragma once

#include <algorithm>
#include <cassert>
#include <cstring>
#include <exception>
#include <functional>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

class ParseException : public std::exception
{
private:
    std::string msg;
public:
    explicit ParseException(std::string msg) : msg(msg) {}

    const char *what () const throw () override
    {
        return msg.c_str();
    }
};

bool isUint(const std::string &s)
{
    return std::all_of(s.begin(), s.end(), ::isdigit);
}

template<class T>
T id (T val) { return val; }

class Opt
{
protected:
    char shortName;
    std::string longName;
    std::string description;
    // Internal; For state tracking
    bool present;
public:
    Opt(char shortName,
        const std::string &longName,
        const std::string &description);

    virtual void defaultHandler(bool isPresent, std::string value) {}
    virtual ~Opt() = default;
    bool operator()();
    void setPresent();
    char getShortName();
    std::string getLongName();
    bool isPresent();
    std::string getDescription();
};

Opt::Opt(const char shortName,
         const std::string &longName,
         const std::string &description)
{
    this->shortName = shortName;
    this->longName = longName;
    this->present = false;
    this->description = description;
}

void Opt::setPresent()
{
    present = true;
}

char Opt::getShortName()
{
    return shortName;
}

std::string Opt::getLongName()
{
    return longName;
}

bool Opt::isPresent()
{
    return present;
}

bool Opt::operator()()
{
    return present;
}

std::string Opt::getDescription() {
    return description;
}

class BoolOpt : public Opt
{
private:
    bool pValue; // Stands for provided value
    std::function<bool(bool)> userHandler;
public:
    BoolOpt (const char shortName,
             const std::string& longName,
             const bool defaultValue,
             const std::string &description,
             std::function<bool(bool)> userHandler = id<bool>)
        : Opt(shortName, longName, description)
    {
        this->pValue = defaultValue;
        this->userHandler = userHandler;
    }

    BoolOpt (const std::string& longName,
             const bool defaultValue,
             const std::string &description,
             std::function<bool(bool)> userHandler = id<bool>)
        : BoolOpt('-', longName, defaultValue, description, userHandler){}

    bool get() { return pValue; }

    void defaultHandler(bool isPresent, std::string value) override
    {
        if (isPresent)
        {
            throw ParseException("Argument does not expect a value");
        }
        pValue = true;
        pValue = userHandler(pValue);
    }
};

class IntOpt : public Opt
{
private:
    int64_t pValue;
    std::function<int64_t(int64_t)> userHandler;
public:
    IntOpt (const char shortName,
            const std::string& longName,
            const int64_t defaultValue,
            const std::string &description,
            std::function<int64_t(int64_t)> userHandler = id<int64_t>)
        : Opt(shortName, longName, description)
    {
        this->pValue = defaultValue;
        this->userHandler = userHandler;
    }

    IntOpt (const std::string& longName,
            const int64_t defaultValue,
            const std::string &description,
            std::function<int64_t(int64_t)> userHandler = id<int64_t>)
        : IntOpt('-', longName, defaultValue, description, userHandler){}

    int64_t get() { return pValue; }

    void defaultHandler(bool isPresent, std::string value) override
    {
        if (!isPresent)
        {
            throw ParseException("Argument expects an integer value");
        }
        try
        {
            pValue = stoll(value);
            pValue = userHandler(pValue);
        }
        catch (const std::out_of_range& exp)
        {
            throw ParseException("Value is not in range of a 64 bit int");
        }
        catch (const std::invalid_argument& exp)
        {
            throw ParseException("Argument expects an integer value");

        }
    }
};

class UintOpt : public Opt
{
private:
    uint64_t pValue;
    std::function<uint64_t(uint64_t)> userHandler;
public:
    UintOpt (const char shortName,
             const std::string& longName,
             const uint64_t defaultValue,
             const std::string &description,
             std::function<uint64_t(uint64_t)> userHandler = id<uint64_t>)
        : Opt(shortName, longName, description)
    {
        this->pValue = defaultValue;
        this->userHandler = userHandler;
    }

    UintOpt (const std::string& longName,
             const uint64_t defaultValue,
             const std::string &description,
             std::function<uint64_t(uint64_t)> userHandler = id<uint64_t>)
        : UintOpt('-', longName, defaultValue, description, userHandler){}


    uint64_t get() { return pValue; }

    void defaultHandler(bool isPresent, std::string value) override
    {
        if (!isPresent || !isUint(value))
        {
            throw ParseException("Argument expects an non negative int value");
        }
        try
        {
            pValue = stoull(value);
            pValue = userHandler(pValue);
        }
        catch (const std::out_of_range& exp)
        {
            throw ParseException("Value is not in range of a 64 bit unsigned integer");
        }
        catch (const std::invalid_argument& exp)
        {
            throw ParseException("Argument expects an non negative int value");
        }
    }

};

class StrOpt : public Opt
{
private:
    std::string pValue;
    std::function<std::string(std::string)> userHandler;
public:
    StrOpt (const char shortName,
            const std::string& longName,
            const std::string &defaultValue,
            const std::string &description,
            std::function<std::string(std::string)> userHandler = id<std::string>)
        : Opt(shortName, longName, description)
    {
        this->pValue = defaultValue;
        this->userHandler = userHandler;
    }

    StrOpt (const std::string& longName,
            const std::string &defaultValue,
            const std::string &description,
            std::function<std::string(std::string)> userHandler = id<std::string>)
        : StrOpt('-', longName, defaultValue, description, userHandler){}

    std::string get() { return pValue; }

    void defaultHandler(bool isPresent, std::string value) override
    {
        if (!isPresent)
        {
            throw ParseException("Argument expects a value");
        }
        pValue = value;
        pValue = userHandler(pValue);
    }
};

class OptParser
{
private:
    std::vector<std::reference_wrapper<Opt>> argOptions;
    std::string programName;
    std::vector<std::string> programArgs;
    std::vector<std::reference_wrapper<Opt>>::iterator findArgByShortName(char c);
    std::vector<std::reference_wrapper<Opt>>::iterator findArgByLongName(std::string &name);
    void parse(std::string key, bool isValPresent, std::string value);
    void parse(char key, bool isValPresent, std::string value);
    void parseShortName(const char *token);
    void parseLongName(const char *token);
    void parseProgramName(const char *name);
public:
    OptParser();
    explicit OptParser(std::vector<std::reference_wrapper<Opt>> argOptions);
    OptParser& add(Opt& opt);
    void parse(int argc, char *argv[]);
    std::string getProgramName();
    std::vector<std::string> getProgramArgs();
    std::string helpString();
};

OptParser::OptParser() = default;

OptParser& OptParser::add(Opt &opt)
{
    argOptions.push_back(std::ref(opt));
    return *this;
}

OptParser::OptParser(std::vector<std::reference_wrapper<Opt>> argOptions)
{
    // TODO: check for duplicates
    this->argOptions = move(argOptions);
}

std::vector<std::reference_wrapper<Opt>>::iterator OptParser::findArgByShortName(char c)
{
    return std::find_if(argOptions.begin(), argOptions.end(),
                        [c](Opt &arg) { return arg.getShortName() == c; });
}

std::vector<std::reference_wrapper<Opt>>::iterator OptParser::findArgByLongName(std::string& name)
{
    return std::find_if(argOptions.begin(), argOptions.end(),
                        [name](Opt &arg) { return arg.getLongName() == name; });
}

void OptParser::parse(std::string key, bool isValPresent = false, std::string value = "")
{
    auto it = findArgByLongName(key);
    if (it == argOptions.end())
    {
        throw ParseException{"No such option " + key };
    }
    else
    {
        try
        {
            it -> get().setPresent();
            it -> get().defaultHandler(isValPresent, move(value));
        }
        catch (ParseException& exp)
        {
            throw ParseException("Parsing of " + key + " failed: " + exp.what());
        }
    }
}

void OptParser::parse(char key, bool isValPresent = false, std::string value = "")
{
    auto it = findArgByShortName(key);
    if (it == argOptions.end())
    {
        throw ParseException{"No such option " + std::string(1, key)};
    }
    else
    {
        try
        {
            it -> get().setPresent();
            it -> get().defaultHandler(isValPresent, move(value));
        }
        catch (ParseException& exp)
        {
            throw ParseException("Parsing of " + std::string(1,key) + " failed: " + exp.what());
        }
    }

}

void OptParser::parseShortName(const char *token)
{
    std::string str{token};
    size_t idx = str.find('=');
    if (idx == std::string::npos)
    {
        // '=' Not Found, Means All should be boolean
        for (auto argName: str)
        {
            parse(argName);
        }
    }
    else
    {
        // Value belongs to last Opt
        auto args = str.substr(0, idx);
        auto value = str.substr(idx+1, str.length());
        for (size_t i = 0; i < args.length(); ++i)
        {
            if (i != args.length() - 1)
            {
                parse(args[i]);
            }
            else
            {
                parse(args[i], true, value);
            }
        }
    }
}

void OptParser::parseLongName(const char *token)
{
    // Len is guaranteed to be at least 1
    std::string str{token};
    size_t idx = str.find('=');
    if (idx == std::string::npos)
    {
        // '=' Not Found, Means should be boolean
        parse(str);
    }
    else
    {
        std::string argName = str.substr(0, idx);
        std::string value = str.substr(idx+1, str.length());
        parse(argName, true, value);
    }

}

void OptParser::parseProgramName(const char *name)
{
    std::string str{name};
    if (!programName.empty())
    {
        throw ParseException{"Bad option - " + str};
    }
    this->programName = str;
}

/**
 * Parses the provided arguments against the argument options. Arguments
 * to this function should be provided as received by main function.

    @param argc argc as received by main.
    @param argv argv as received by main.
*/
void OptParser::parse(int argc, char *argv[])
{
    // Index 0 is name of the program
    auto index = 1;
    while (index < argc)
    {
        char *current = argv[index];
        auto len = strlen(current);
        if (len < 2)
        {
            // This can not be an arg. Probably program name
            parseProgramName(current);
        }
        else
        {
            if (strcmp(current, "--") == 0)
            {
                if (programName.empty())
                {
                    throw ParseException{"Program filename must be specified before arguments"};
                }
                // store Program args and return
                for (int i = index + 1; i < argc; ++i)
                {
                    programArgs.push_back(std::string(argv[i]));
                }
                return;
            }
            if (current[0] == '-')
            {
                if (current[1] == '-')
                {
                    parseLongName(&current[2]);
                }
                else
                {
                    parseShortName(&current[1]);
                }
            }
            else
            {
                parseProgramName(current);
            }
        }
        ++index;
    }
}

/**
 * Returns Program file name as specified in program arguments. It will return
 * empty string if user did not provied any. This function should only be called
 * if call to void parse(int argc, char *argv[]) was finished normally
 * (without exception).
*/
std::string OptParser::getProgramName()
{
    return programName;
}

/**
 * Returns argument vector of Program. This function should only be called if
 * call to void parse(int argc, char *argv[]) was finished normally
 * (without exception).
*/
std::vector<std::string> OptParser::getProgramArgs()
{
    return programArgs;
}

std::vector<std::string> wrap(const std::string &desc, uint8_t width)
{
    std::vector<std::string> lines;
    uint64_t start = 0, end = 0;
    while (start + width < desc.size())
    {
        end = desc.rfind(' ', start + width);
        if (end < start || end == std::string::npos)
        {
           lines.push_back(desc.substr(start, width));
           start += width;
        }
        else
        {
           lines.push_back(desc.substr(start, end - start));
           start = end + 1;
        }
    }
    lines.push_back(desc.substr(start, width));
    return lines;
}


std::string OptParser::helpString()
{
    std::stringstream ss;
    ss << "\n";
    ss << "Usage:   zeta [options] [program file] -- [program args]";
    ss << "\n" << "\n";
    for(auto opt: argOptions)
    {
        ss << "  ";
        if (opt.get().getShortName() != '-')
        {
            ss << "-" << opt.get().getShortName();
            ss << ", ";
        }
        else
        {
            ss << "    ";
        }
        ss << "--" << opt.get().getLongName();
        ss << "\n";
        for (auto &line: wrap(opt.get().getDescription(), 70))
        {
            ss << "         " << line << "\n";
        }
        ss << "\n";
    }
    return ss.str();
}

static char* testStrdup(const std::string &s)
{
    auto *temp = new char[s.length() + 1];
    strcpy(temp, s.c_str());
    return temp;
}

static void testOptParser0()
{
    // check if custom handler works fine
    std::function<int64_t(int64_t)> customChecker = [](int64_t x)
    {
        if (x > 1000)
        {
            throw ParseException("Value is more that 1000");
        }
        return 42;
    };

    IntOpt js('j', "js", 1100, "the value of some field js", customChecker);
    js.defaultHandler(true, "45");
    assert(js.get() == 42);
    try
    {
        js.defaultHandler(true, "2000");
        assert(false);
    }
    catch (ParseException& exp)
    {
    }
}

static void testOptParser1()
{
    // check if int handler works fine
    IntOpt js('j', "js", 1100, "the value of some field js");
    try
    {
        js.defaultHandler(true, "9223372036854775808");
        assert(false);
    }
    catch (ParseException& exp)
    {
        assert(js.get() == 1100);
    }

    js.defaultHandler(true, "4100");
    assert(js.get() == 4100);
}

static void testOptParser2()
{
    // check if uint handler works fine
    UintOpt ks('k', "ks", 2200LL, "the value of some field ks");
    try
    {
        ks.defaultHandler(true, "-22");
        assert(false);
    }
    catch (ParseException& exp)
    {
        assert(ks.get() == 2200);
    }
    ks.defaultHandler(true, "9223372036854775808");
    assert(ks.get() == 9223372036854775808ULL);
}

static void testOptParser3()
{
    // check if parser works fine
    BoolOpt is('i', "is", false, "the value of some field is");
    IntOpt js('j', "js", 1100, "the value of some field js");
    UintOpt ks("ks", 2200, "the value of some field ks");
    StrOpt ls("ls", "Blah", "the value of some field ls");
    OptParser parser;
    parser = parser.add(is)
                   .add(js)
                   .add(ks)
                   .add(ls);
    char *arg1 = testStrdup("--is");
    char *arg2 = testStrdup("-j=4");
    char *arg3 = testStrdup("--ls=some other value");
    char *args[]{arg1, arg1, arg2, arg3}; // First args does not matter
    parser.parse(4, args);
    assert(is());
    assert(is.get());
    assert(js());
    assert(js.get() == 4);
    assert(!ks());
    assert(ks.get() == 2200);
    assert(ls());
    assert(ls.get() == "some other value");

    delete []arg1;
    delete []arg2;
    delete []arg3;

}

static void testOptParser4()
{
    // check if parser handles error
    BoolOpt is('i', "is", false, "the value of some field is");
    IntOpt js('j', "js", 1100, "the value of some field js");
    UintOpt ks("ks", 2200, "the value of some field ks");
    StrOpt ls('l', "ls", "Blah", "the value of some field ls");
    OptParser parser;
    parser = parser.add(is)
                   .add(js)
                   .add(ks)
                   .add(ls);
    char *arg1 = testStrdup("--is");
    char *arg2 = testStrdup("-x=4");
    char *args[]{arg1, arg1, arg2}; // First args does not matter
    try
    {
        parser.parse(3, args);
        assert(false);
    }
    catch (ParseException& exp)
    {
    }

    delete []arg1;
    delete []arg2;
}

static void testOptParser5()
{
    BoolOpt is('i', "is", false, "the value of some field is");
    IntOpt js('j', "js", 1100, "the value of some field js");
    UintOpt ks("ks", 2200, "the value of some field ks");
    StrOpt ls('l', "ls", "Blah", "the value of some field ls");
    OptParser parser;
    parser = parser.add(is)
                   .add(js)
                   .add(ks)
                   .add(ls);
    char *arg1 = testStrdup("-ij=100");
    char *args[]{arg1, arg1}; // First args does not matter
    parser.parse(2, args);
    assert(is());
    assert(is.get());
    assert(js());
    assert(js.get() == 100);
    assert(!ks());
    assert(!ls());

    delete []arg1;
}

static void testOptParser6()
{
    // Test program arguments
    BoolOpt is('i', "is", false, "the value of some field is");
    IntOpt js('j', "js", 1100, "the value of some field js");
    UintOpt ks("ks", 2200, "the value of some field ks");
    StrOpt ls('l', "ls", "Blah", "the value of some field ls");
    OptParser parser;
    parser = parser.add(is)
                   .add(js)
                   .add(ks)
                   .add(ls);
    char *arg1 = testStrdup("-ij=100");
    char *arg2 = testStrdup("hello.pls");
    char *arg3 = testStrdup("--");
    char *arg4 = testStrdup("1");
    char *arg5 = testStrdup("2");
    char *args[]{arg1, arg1, arg2, arg3, arg4, arg5}; // First arg does not matter
    parser.parse(6, args);
    assert(is());
    assert(is.get());
    assert(js());
    assert(js.get() == 100);
    assert(!ks());
    assert(!ls());
    assert(parser.getProgramName() == "hello.pls");
    assert(parser.getProgramArgs().size() == 2);
    assert(parser.getProgramArgs()[0] == "1");
    assert(parser.getProgramArgs()[1] == "2");

    delete []arg1;
    delete []arg2;
    delete []arg3;
    delete []arg4;
    delete []arg5;
}

static void testOptParser()
{
    testOptParser0();
    testOptParser1();
    testOptParser2();
    testOptParser3();
    testOptParser4();
    testOptParser5();
    testOptParser6();
    std::cout << "Opt Parser: All test Passed\n";
}
