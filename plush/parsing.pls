#language "lang/plush/0"

/// Check if a character is whitespace
var isSpace = function (ch)
{
    // Note: we don't allow other whitespace characters
    return (ch == ' ' || ch == '\t' || ch == '\n');
};

/// Check if a character is a digit
var isDigit = function (ch)
{
    return (ch >= '0' && ch <= '9');
};

/// Check if a character is a letter
var isAlpha = function (ch)
{
    return (
        (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z')
    );
};

/// Check if a character is alphanumerical
var isAlnum = function (ch)
{
    return (
        (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z') ||
        (ch >= '0' && ch <= '9')
    );
};

/// Report a parsing error and abort parsing
var parseError = function (input, errorStr)
{
    var srcPos = false;

    if (input != false)
    {
        srcPos = {
            src_name: input.srcName,
            line_no: input.lineNo,
            col_no: input.colNo
        };
    }

    throw {
        msg: errorStr,
        src_pos: srcPos
    };
};

/**
Prototype for all Input objects
The Input class serves to represent and manipulate an
input stream for a parser.
*/
var Input = {
    srcName: "input prototype object",
    srcString: "",
    strIdx: 0,
    lineNo: 1,
    colNo: 1
};

/// Get a source position object for the current position
Input.getPos = function (self)
{
    return {
        line_no: self.lineNo,
        col_no: self.colNo,
        src_name: self.srcName
    };
};

/// Peek at a character from the input
Input.peekCh = function (self)
{
    if (self.strIdx >= self.srcString.length)
        return '\0';

    return self.srcString[self.strIdx];
};

/// Read a character from the input
Input.readCh = function (self)
{
    var ch = self:peekCh();

    assert (
        !self:eof(),
        "tried to read past end of input"
    );

    // Strictly reject invalid input characters
    if ((ch <= '\x1F' || ch >= '\x7F') &&
        (ch != '\n' && ch != '\t' && ch != '\r'))
    {
        //var hexStr[64];
        //sprintf(hexStr, "0x%02X", (int)ch);
        parseError(
            self,
            //"invalid character in input, " + std::string(hexStr)
            "invalid character in input"
        );
    }

    self.strIdx += 1;

    if (ch == '\n')
    {
        self.lineNo += 1;
        self.colNo = 1;
    }
    else
    {
        self.colNo += 1;
    }

    return ch;
};

/// Test if the end of file has been reached
Input.eof = function (self)
{
    return self:peekCh() == '\0';
};

/// Peek to check if a string is next in the input
Input.next = function (self, str)
{
    var idx = 0;

    for (; idx < str.length; idx += 1)
    {
        if (self.strIdx + idx >= self.srcString.length)
            return false;

        if (str[idx] != self.srcString[self.strIdx + idx])
            return false;
    }

    return true;
};

/// Version of next which also eats preceding whitespace
Input.nextWS = function (self, str)
{
    self:eatWS();
    return self:next(str);
};

/// Try and match a given string in the input
/// The string is consumed if matched
Input.match = function (self, str)
{
    assert (
        str.length > 0,
        "match with empty string"
    );

    if (self:next(str))
    {
        for (var i = 0; i < str.length; i += 1)
        {
            self:readCh();
        }
        return true;
    }

    return false;
};

/// Version of match which also eats preceding whitespace
Input.matchWS = function (self, str)
{
    self:eatWS();
    return self:match(str);
};

/// Fail if the input doesn't match a given string
Input.expect = function (self, str)
{
    if (!self:match(str))
    {
        parseError(self, "expected to find '" + str + "'");
    }
};

/// Version of expect which eats preceding whitespace
Input.expectWS = function (self, str)
{
    self:eatWS();
    self:expect(str);
};

/// Match a keyword string
/// Note: this expects a non-keyword character after the keyword
/// That is, keyword("assert") will not match "assertFun"
Input.keyword = function (self, str)
{
    // Whitespace before keywords doesn't matter
    self:eatWS();

    // If the string is not next in the input, no match
    if (!self:next(str))
        return false;

    var len = str.length;

    // If we're at the end of the string, this is a match
    if (self.strIdx + len >= self.srcString.length)
    {
        self:match(str);
        return true;
    }

    // Get the character after the keyword
    var postCh = self.srcString[self.strIdx + len];

    // If the next character is valid in an identifier, then
    // this is not a real match
    if (isAlnum(postCh) || postCh == '_')
    {
        return false;
    }

    // This is a match, consume the keyword string
    self:match(str);
    return true;
};

/// Consume whitespace and comments
Input.eatWS = function (self)
{
    // Until the end of the whitespace
    for (;;)
    {
        // If we are at the end of the input, stop
        if (self:eof())
        {
            return;
        }

        // Consume whitespace characters
        if (isSpace(self:peekCh()))
        {
            self:readCh();
            continue;
        }

        // If this is a single-line comment
        if (self:match("//"))
        {
            // Read until and end of line is reached
            for (;;)
            {
                if (self:eof())
                    return;

                if (self:readCh() == '\n')
                    break;
            }

            continue;
        }

        // If this is a multi-line comment
        if (self:match("/*"))
        {
            // Read until the end of the comment
            for (;;)
            {
                if (self:eof())
                {
                    parseError(
                        self,
                        "end of input in multiline comment"
                    );
                }

                if (self:readCh() == '*' && self:match("/"))
                {
                    break;
                }
            }

            continue;
        }

        // This isn't whitespace, stop
        break;
    }
};

/**
Parse a C-style identifier string ([a-zA-Z_][a-zA-Z0-9_]*)
eg:
    foo_bar
    _foobar
    foobarbif123
Returns a character string.
*/
Input.parseIdent = function (input)
{
    var ident = '';

    var firstCh = input:peekCh();

    if (firstCh != '_' && !isAlpha(firstCh))
        parseError(input, "invalid identifier start");

    for (;;)
    {
        // Peek at the next character
        var ch = input:peekCh();

        if (!isAlnum(ch) && ch != '_')
            break;

        // Consume this character
        ident += input:readCh();
    }

    if (ident.length == 0)
        parseError(input, "invalid identifier");

    return ident;
};

/**
Parse a string literal, possibly contained escape characters
eg:
    "abcdef"
    "foo\nbar"
    'foobar'
*/
Input.parseStringLit = function (input, delimCh)
{
    var str = '';

    input:match(delimCh);

    for (;;)
    {
        // If this is the end of the input
        if (input:eof())
        {
            parseError(
                input,
                "end of input inside string literal"
            );
        }

        // Consume this character
        var ch = input:readCh();

        // If this is the end of the string
        if (ch == delimCh)
        {
            break;
        }

        // Disallow newlines inside strings
        if (ch == '\r' || ch == '\n')
        {
            parseError(
                input,
                "newline character in string literal"
            );
        }

        // If this is an escape sequence
        if (ch == '\\')
        {
            ch = input:parseEscSeq();
        }

        str += ch;
    }

    return str;
};

/**
Parse a string escape sequence.
Of the form \c or \xNN (hexadecimal)
*/
Input.parseEscSeq = function (input)
{
    var esc = input:readCh();

    if (esc == 'n')
        return '\n';
    if (esc == 'r')
        return '\r';
    if (esc == 't')
        return '\t';
    if (esc == '0')
        return '\0';
    if (esc == '\'')
        return '\'';
    if (esc == '\"')
        return '\"';
    if (esc == '\\')
        return '\\';

    // Hexadecimal escape
    if (esc == 'x')
    {
        var escVal = 0;
        for (var i = 0; i < 2; i += 1)
        {
            var ch = input:readCh();
            var charCode = $get_char_code(ch, 0);

            if (ch >= '0' && ch <= '9')
            {
                // ch - '0'
                escVal = 16 * escVal + (charCode - 48);
            }
            else if (ch >= 'A' && ch <= 'F')
            {
                // ch - 'A'
                escVal = 16 * escVal + (charCode - 65 + 10);
            }
            else
            {
                parseError(
                    input,
                    "invalid hexadecimal character escape code"
                );
            }
        }

        assert (
            escVal >= 0 && escVal <= 255,
            "invalid hexadecimal escape sequence"
        );

        return $char_to_str(escVal);
    }

    parseError(
        input,
        "invalid character escape sequence"
    );
};

// Exported definitions
exports.isSpace = isSpace;
exports.isDigit = isDigit;
exports.isAlpha = isAlpha;
exports.isAlnum = isAlnum;
exports.parseError = parseError;
exports.Input = Input;
