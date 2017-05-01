#include <cassert>
#include <cstring>
#include <iostream>
#include "parser.h"

/// Read an entire file at once
std::string readFile(std::string fileName)
{
    FILE* file = fopen(fileName.c_str(), "r");

    if (!file)
    {
        fprintf(stderr, "failed to open file \"%s\"\n", fileName.c_str());
        exit(-1);
    }

    // Get the file size in bytes
    fseek(file, 0, SEEK_END);
    size_t len = ftell(file);
    fseek(file, 0, SEEK_SET);

    char* buf = (char*)malloc(len+1);

    // Read into the allocated buffer
    int read = fread(buf, 1, len, file);

    if (read != len)
    {
        printf("failed to read file");
        assert (false);
    }

    // Add a null terminator to the string
    buf[len] = '\0';

    // Close the input file
    fclose(file);

    return std::string(buf);
}

Input::Input(std::string str, std::string srcName)
{
    this->srcName = srcName;
    this->inStr = str;
    this->strIdx = 0;
    this->lineNo = 1;
    this->colNo = 1;
}

Input::~Input()
{
}

/// Peek at a character from the input
char Input::peekCh()
{
    if (strIdx >= inStr.length())
        return '\0';

    return inStr[strIdx];
}

/// Read a character from the input
char Input::readCh()
{
    char ch = peekCh();

    // Strictly reject invalid input characters
    if ((ch < 0x20 || ch > 0x7E) &&
        (ch != '\n' && ch != '\t' && ch != '\r'))
    {
        char hexStr[64];
        sprintf(hexStr, "0x%02X", (int)ch);
        throw ParseError(
            *this,
            "invalid character in input, " + std::string(hexStr)
        );
    }

    this->strIdx++;

    if (ch == '\n')
    {
        lineNo++;
        colNo = 1;
    }
    else
    {
        colNo++;
    }

    return ch;
}

/// Test if the end of file has been reached
bool Input::eof()
{
    return peekCh() == '\0';
}

/// Peek to check if a string is next in the input
bool Input::next(const std::string& str)
{
    size_t idx = 0;

    for (; idx < str.length(); idx++)
    {
        if (this->strIdx + idx >= this->inStr.length())
            return false;

        if (str[idx] != this->inStr[this->strIdx + idx])
            return false;
    }

    return true;
}

/// Try and match a given string in the input
/// The string is consumed if matched
bool Input::match(const std::string& str)
{
    assert (str.length() > 0);

    if (next(str))
    {
        for (size_t i = 0; i < str.length(); ++i)
            readCh();

        return true;
    }

    return false;
}

/// Fail if the input doesn't match a given string
void Input::expect(const std::string str)
{
    if (!match(str))
    {
        throw ParseError(*this, "expected to find '" + str + "'");
    }
}

/// Consume whitespace and comments
void Input::eatWS()
{
    //std::cout << "entering eatWS" << std::endl;

    // Until the end of the whitespace
    for (;;)
    {
        // If we are at the end of the input, stop
        if (eof())
        {
            return;
        }

        // Consume whitespace characters
        if (isspace(peekCh()))
        {
            readCh();
            continue;
        }

        // If this is a single-line comment
        if (match("//"))
        {
            // Read until and end of line is reached
            for (;;)
            {
                if (eof())
                    return;

                if (readCh() == '\n')
                    break;
            }

            continue;
        }

        // If this is a multi-line comment
        if (match("/*"))
        {
            // Read until the end of the comment
            for (;;)
            {
                if (eof())
                {
                    throw ParseError(
                        *this,
                        "end of input in multiline comment"
                    );
                }

                if (readCh() == '*' && match("/"))
                {
                    break;
                }
            }

            continue;
        }

        // This isn't whitespace, stop
        break;
    }
}

/// Version of next which also eats preceding whitespace
bool Input::nextWS(const std::string& str)
{
    eatWS();
    return next(str);
}

/// Version of match which also eats preceding whitespace
bool Input::matchWS(const std::string& str)
{
    eatWS();
    return match(str);
}

/// Version of expect which eats preceding whitespace
void Input::expectWS(const std::string str)
{
    eatWS();
    expect(str);
}

/// Check whether the given character can start an identifier
static bool isinitial(char ch)
{
    // Is it an alphabetic character
    if (isalpha(ch))
    {
        return true;
    }

    // Or a "special" initial character
    switch (ch)
    {
        case '!':
        case '$':
        case '%':
        case '&':
        case '*':
        case '/':
        case ':':
        case '<':
        case '=':
        case '>':
        case '?':
        case '^':
        case '_':
        case '~':
            return true;
        default:
            break;
    }

    return false;
}

/// Check whether the given character can follow the start of an identifier
static bool issubsequent(char ch)
{
    // Is it an initial character *or* digit
    if (isinitial(ch) || isdigit(ch))
    {
        return true;
    }

    // Or a "special" subsequent character
    switch (ch)
    {
        case '+':
        case '-':
        case '.':
        case '@':
            return true;
        default:
            break;
    }

    return false;
}

/**
Parse an identifier string
*/
std::string parseIdentStr(Input& input)
{
    std::string ident;

    char firstCh = input.peekCh();

    if (!isinitial(firstCh))
    {
        throw ParseError(input, "invalid identifier start");
    }

    for (;;)
    {
        // Peek at the next character
        char ch = input.peekCh();

        if (!issubsequent(ch))
            break;

        // Consume this character
        ident += input.readCh();
    }

    if (ident.size() == 0)
    {
        throw ParseError(input, "invalid identifier");
    }

    return ident;
}

/**
Parse an atom
*/
std::unique_ptr<Value> parseAtom(Input& input)
{
    // Identifier
    if (isinitial(input.peekCh()))
    {
        std::string identStr = parseIdentStr(input);
        return std::unique_ptr<Identifier>(new Identifier(identStr));
    }

    throw ParseError(input, "unexpected atom");
}

/// Forward declaration
std::unique_ptr<Value> parseSExpr(Input& input);

/**
Cons the two given values into a new pair
*/
std::unique_ptr<Pair> cons(std::unique_ptr<Value> car, std::unique_ptr<Value> cdr)
{
    return std::unique_ptr<Pair>(new Pair(std::move(car), std::move(cdr)));
}

/**
Pares a pair
*/
std::unique_ptr<Value> parseSExprList(Input& input) {
    if (input.eof())
    {
        return nullptr;
    }

    // Consume whitespace
    input.eatWS();

    // Check if the paired list is ending
    if (input.next(")"))
    {
        return std::unique_ptr<Pair>(new Pair());
    }

    // Consume whitespace
    input.eatWS();

    // Parse the head expression
    std::unique_ptr<Value> car = parseSExpr(input);

    // Consume whitespace
    input.eatWS();

    // Parse the tail and cons it with the head
    return cons(std::move(car), parseSExprList(input));
}

/**
 Parse an S-expression
*/
std::unique_ptr<Value> parseSExpr(Input& input)
{
    // Consume whitespace
    input.eatWS();

    if (input.eof())
    {
        return nullptr;
    }

    // Parse a paired list
    if (input.match("("))
    {
        std::unique_ptr<Value> pair = parseSExprList(input);
        if (!input.match(")"))
        {
            throw ParseError(
                        input,
                        "expected ')'"
                    );
        }

        return pair;
    }

    // Parse a quoted list
    else if (input.match("\'"))
    {
        std::unique_ptr<Identifier> quote(new Identifier("quote"));
        std::unique_ptr<Pair> empty(new Pair());
        std::unique_ptr<Value> rest = parseSExpr(input);
        return cons(std::move(quote), cons(std::move(rest), std::move(empty)));
    }

    // Parse an atom
    return parseAtom(input);
}

/**
Parse a program from an input object
*/
std::unique_ptr<Program> parseProgram(Input& input)
{
    // Parse the language directive, if specified
    if (input.match("#language"))
    {
        input.expectWS("\"");

        for (;;)
        {
            // If this is the end of the input
            if (input.eof())
            {
                throw ParseError(
                    input,
                    "end of input inside package name"
                );
            }

            char ch = input.readCh();

            if (ch == '"')
            {
                break;
            }
        }
    }

    // Parse the S-expressions that make up a program
    std::vector<std::unique_ptr<Value>> values;
    while (!input.eof())
    {
        std::unique_ptr<Value> value = parseSExpr(input);
        if (value)
        {
            values.push_back(std::move(value));
        }
    }

    return std::unique_ptr<Program>(new Program(values));
}

/**
Parse a source string as a unit
*/
std::unique_ptr<Program> parseString(const std::string &str, const std::string &srcName)
{
    Input input(
        str,
        srcName
    );

    return parseProgram(input);
}

std::unique_ptr<Program> parseFile(const std::string &fileName)
{
    auto fileData = readFile(fileName);

    Input input(
        fileData,
        fileName
    );

    return parseProgram(input);
}

/// Test that the parsing of a string succeeds
std::unique_ptr<Program> testParse(const std::string &str, const std::string &expectedStr)
{
    std::cout << str << std::endl;

    try
    {
        std::unique_ptr<Program> program = parseString(str, "parser_test");
        std::string actualStr = program->toString();
        if (actualStr != expectedStr)
        {
            std::cerr << "error: '" << actualStr
                      << "' != '" << expectedStr << "'\n";
            exit(-1);
        }
        return program;
    }

    catch (std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        exit(-1);
    }
}

/// Test that the parsing of a string fails
void testParseFail(const std::string &str)
{
    std::cout << str << std::endl;

    try
    {
        auto unit = parseString(str, "parser_fail_test");
    }

    catch (ParseError e)
    {
        return;
    }

    std::cerr << "parsing did not fail for: " << std::endl;
    std::cerr << str << std::endl;
    exit(-1);
}

/// Test that the parsing of a file succeeds
std::unique_ptr<Program> testParseFile(const std::string &fileName)
{
    std::cout << "parsing image file \"" << fileName << "\"" << std::endl;
    return parseFile(fileName);
}

/// Test the functionality of the parser
void testParser()
{
    printf("parser tests\n");

    // Identifiers
    testParse("foobar", "foobar");
    testParse("  foo_bar  ", "foo_bar");
    testParse("lambda", "lambda");
    testParse("empty?", "empty?");
    testParse(":foo", ":foo");
    testParseFail("+bar");
    testParseFail("7up");

    // Lists
    testParse("()", "()");
    testParse("(())", "(())");
    testParse("(a b c d)", "(a b c d)");
    testParse("(a (b (c)) d)", "(a (b (c)) d)");
    testParse("'()", "(quote ())");
    testParse("'(foo bar)", "(quote (foo bar))");
    testParse("(define f (lambda (x) x))", "(define f (lambda (x) x))");
    testParse("(define x y)(define y z)", "(define x y)(define y z)");
    testParseFail("(x y");
    testParseFail("((a b)(c (d)");
    testParseFail("(r s))");
}
