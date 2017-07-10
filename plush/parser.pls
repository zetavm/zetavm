#language "lang/plush/0"

//============================================================================
// Abstract Syntax Tree (AST)
//============================================================================

/// Prototype object for operators
var OpInfo = {
    /// Operator string (e.g. "+")
    str: "",

    /// Closing string (optional)
    closeStr: "",

    /// Operator arity
    arity: 2,

    /// Precedence level
    prec: -1,

    /// Associativity, left-to-right or right-to-left ('l' or 'r')
    assoc: "l",

    /// Non-associative flag (e.g.: - and / are not associative)
    nonAssoc: false,

    /// Flag indicating a binary operator can be folded into an assignment
    foldAssign: false
};

/// List of existing operators
var opList = [];

/// Add an operator to the list
var addOp = function (opInfo)
{
    opList:push(opInfo);
    return opInfo;
};

/// Object member operator
var OP_MEMBER = addOp(OpInfo::{ str:".", arity:2, prec:16 });

/// Array indexing
var OP_INDEX = addOp(OpInfo::{ str:"[", closeStr:"]", arity:2, prec:16 });

/// Object extension
var OP_OBJ_EXT = addOp(OpInfo::{ str:"::", arity:2, prec:16 });

/// Function call, variable arity
var OP_CALL = addOp(OpInfo::{ str:"(", closeStr:")", arity:0, prec:15 });

/// Method call
var OP_M_CALL = addOp(OpInfo::{ str:":", arity:2, prec:15 });

/// Prefix unary operators
var OP_NEG = addOp(OpInfo::{ str:"-", arity:1, prec:13, assoc:'r' });
var OP_NOT = addOp(OpInfo::{ str:"!", arity:1, prec:13, assoc:'r' });
var OP_BIT_NOT = addOp(OpInfo::{ str:"~", arity:1, prec:13, assoc:'r' });
var OP_TYPEOF = addOp(OpInfo::{ str:"typeof", arity:1, prec:13, assoc:'r' });

/// Binary arithmetic operators
var OP_MUL = addOp(OpInfo::{ str:"*", prec:12, foldAssign:true });
var OP_DIV = addOp(OpInfo::{ str:"/", prec:12, foldAssign:true });
var OP_MOD = addOp(OpInfo::{ str:"%", prec:12, foldAssign:true });
var OP_ADD = addOp(OpInfo::{ str:"+", prec:11, foldAssign:true });
var OP_SUB = addOp(OpInfo::{ str:"-", prec:11, foldAssign:true });

/// Bitwise operators
var OP_BIT_SHL = addOp(OpInfo::{ str:"<<", prec:10, foldAssign:true });
var OP_BIT_SHR = addOp(OpInfo::{ str:">>", prec:10, foldAssign:true });
var OP_BIT_USHR = addOp(OpInfo::{ str:">>>", prec:10, foldAssign:true });
var OP_BIT_AND = addOp(OpInfo::{ str:"&", prec:7, foldAssign:true });
var OP_BIT_XOR = addOp(OpInfo::{ str:"^", prec:6, foldAssign:true });
var OP_BIT_OR = addOp(OpInfo::{ str:"|", prec:5, foldAssign:true });

/// Relational operators
var OP_LT = addOp(OpInfo::{ str:"<", prec:9 });
var OP_LE = addOp(OpInfo::{ str:"<=", prec:9 });
var OP_GT = addOp(OpInfo::{ str:">", prec:9 });
var OP_GE = addOp(OpInfo::{ str:">=", prec:9 });
var OP_IN = addOp(OpInfo::{ str:"in", prec:9 });
var OP_INSTOF = addOp(OpInfo::{ str:"instanceof", prec:9 });

/// Equality comparison
var OP_EQ = addOp(OpInfo::{ str:"==", prec:8 });
var OP_NE = addOp(OpInfo::{ str:"!=", prec:8 });

/// Logical operators
var OP_AND = addOp(OpInfo::{ str:"&&", prec:4, foldAssign:true });
var OP_OR = addOp(OpInfo::{ str:"||", prec:3, foldAssign:true });

// Assignment
var OP_ASSIGN = addOp(OpInfo::{str:"=", arity:2, prec:1, assoc:'r'});

/// Prototype for integer expressions
var IntExpr = {
};

var FloatExpr = {
};

/// Prototype for string expressions
var StringExpr = {
};

/// Prototype for identifier expressions
var IdentExpr = {
};

/// Prototype for unary expressions
var UnOpExpr = {
};

/// Prototype for binary expressions
var BinOpExpr = {
};

/// Prototype for array expressions
var ArrayExpr = {
};

/// Prototype for object expressions
var ObjectExpr = {
};

/// Prototype for function call expressions
var CallExpr = {
};

/// Prototype for method call expression
var MethodCallExpr = {
};

/// Prototype for package import expressions
var ImportExpr = {
};

/// Prototype for IR instruction expression
var IRExpr = {
};

/// Prototype for block statements
var BlockStmt = {
};

/// Prototype for variable declaration statements
var VarStmt = {
};

/// Prototype for if statements
var IfStmt = {
};

/// Prototype for or loop statements
var ForStmt = {
};

/// Prototype for or loop statements
var TryStmt = {
};

/// Prototype for expression statements
var ExprStmt = {
};

/// Prototype for return statements
var ReturnStmt = {
};

/// Prototype for throw statements
var ThrowStmt = {
};

/// Prototype for break statements
var BreakStmt = {
};

/// Prototype for continue statements
var ContStmt = {
};

/// Prototype for IR instruction statements
var IRStmt = {
};

/// Prototype for function expressions
var FunExpr = {
};

//============================================================================
// Parser
//============================================================================

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

/// Prototype for all input objects
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

/// Fail if the input doesn't match a given string
Input.expect = function (self, str)
{
    if (!self:match(str))
    {
        parseError(self, "expected to find '" + str + "'");
    }
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

/// Version of next which also eats preceding whitespace
Input.nextWS = function (self, str)
{
    self:eatWS();
    return self:next(str);
};

/// Version of match which also eats preceding whitespace
Input.matchWS = function (self, str)
{
    self:eatWS();
    return self:match(str);
};

/// Version of expect which eats preceding whitespace
Input.expectWS = function (self, str)
{
    self:eatWS();
    self:expect(str);
};

/// Match a keyword string
/// Note: this expects a non-keyword character after the keyword
/// That is, matchKW("assert") will not match "assertFun"
Input.matchKW = function (self, str)
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

/**
Parse a number
*/
var parseNum = function (input, neg)
{
    var literal = "";
    for (;;)
    {
        // Peek at the next character
        var ch = input:readCh();

        if (!isDigit(ch))
            parseError(input, "expected digit");
        literal = literal + ch;
        // If the next character is not a digit, stop
        if (!isDigit(input:peekCh()))
            break;
    }
    var next = input:peekCh();
    if (next == "." || next == "e")
    {
        return parseFloat(input, neg, literal);
    }
    return parseInt(literal, neg);
};

/**
Parse a floating point number
*/
var parseFloat = function (input, neg, literal)
{
    for (;;)
    {
        // Peek at the next character
        var ch = input:readCh();

        if (!isDigit(ch) && ch != "e" && ch != ".")
            parseError(input, "expected digit, dot or e");
        literal = literal + ch;
        // If the next character is not a digit, stop
        if (!isDigit(input:peekCh()) && ch != "e" && ch != ".")
            break;
    }
    input:expect("f");
    var floatVal = $str_to_f32(literal);
    if (neg)
    {
        floatVal *= -1;
    }
    return FloatExpr::{ val: floatVal };
};

/**
Parse a decimal integer
*/
var parseInt = function (literal, neg)
{
    var intVal = 0;

    for (var j = 0;j < literal.length; j += 1)
    {
        // Peek at the next character
        var ch = literal[j];

        if (!isDigit(ch))
            parseError(input, "expected digit");

        // Find the value of the digit
        var digitVal = -1;
        var digitChars = '0123456789';
        for (var i = 0; i < digitChars.length; i += 1)
        {
            if (ch == digitChars[i])
            {
                digitVal = i;
                break;
            }
        }
        assert (
            digitVal != -1,
            "digit not found"
        );

        intVal = 10 * intVal + digitVal;
    }

    // If the value is negative
    if (neg)
    {
        intVal *= -1;
    }

    return IntExpr::{ val: intVal };
};

/**
Parse a string escape sequence.
*/
var parseEscSeq = function (input)
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

/**
Parse a string literal
*/
var parseStringLit = function (input, endCh)
{
    var str = '';

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
        if (ch == endCh)
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
            ch = parseEscSeq(input);
        }

        str += ch;
    }

    return StringExpr::{ val: str };
};

/**
Parse an identifier string. Returns a character string.
*/
var parseIdentStr = function (input)
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
Parse an if statement
if (<test_expr>) <then_stmt> else <else_stmt>
*/
var parseIfStmt = function (input)
{
    input:expectWS("(");
    var testExpr = parseExpr(input);
    input:expectWS(")");

    var thenStmt = parseStmt(input);

    // Parse the else clause, if there is one
    if (input:matchKW("else"))
    {
        var elseStmt = parseStmt(input);
    }
    else
    {
        var elseStmt = BlockStmt::{ stmts: [] };
    }

    return IfStmt::{
        testExpr: testExpr,
        thenStmt: thenStmt,
        elseStmt: elseStmt
    };
};

/**
Parse a for loop statement
*/
var parseForStmt = function (input)
{
    input:expectWS("(");

    // Parse the initialization statement
    var initStmt = false;
    if (input:matchWS(";"))
    {
        initStmt = ExprStmt::{
            expr: IdentExpr::{ name:"true" }
        };
    }
    else
    {
        // Parse the init statement
        initStmt = parseStmt(input);

        if (!(initStmt instanceof VarStmt) &&
            !(initStmt instanceof ExprStmt))
            parseError(input, "invalid for-loop init statement");
    }

    // Parse the test expression
    var testExpr = false;
    if (input:matchWS(";"))
    {
        testExpr = IdentExpr::{ name:"true" };
    }
    else
    {
        testExpr = parseExpr(input);
        input:expectWS(";");
    }

    // Parse the inccrement expression
    var incrExpr = false;
    if (input:matchWS(")"))
    {
        incrExpr = IdentExpr::{ name:"true" };
    }
    else
    {
        incrExpr = parseExpr(input);
        input:expectWS(")");
    }

    // Parse the loop body
    var bodyStmt = parseStmt(input);

    return ForStmt::{
        initStmt: initStmt,
        testExpr: testExpr,
        incrExpr: incrExpr,
        bodyStmt: bodyStmt
    };
};

/**
Parse a try-catch statement
*/
var parseTryStmt = function (input)
{
    var bodyStmt = parseStmt(input);

    input:expectWS("catch");
    input:expectWS("(");
    var catchVar = parseIdentStr(input);
    input:expectWS(")");

    var catchStmt = parseStmt(input);

    return TryStmt::{
        bodyStmt: bodyStmt,
        catchStmt: catchStmt,
        catchVar: catchVar
    };
};

/**
Parse a list of expressions
*/
var parseExprList = function (input, endStr)
{
    var exprs = [];

    // Until the end of the list
    for (;;)
    {
        // If this is the end of the list
        if (input:matchWS(endStr))
        {
            break;
        }

        // Parse an expression
        var expr = parseExpr(input);
        exprs:push(expr);

        // If this is the end of the list
        if (input:matchWS(endStr))
        {
            break;
        }

        // If this is not the first element, there must be a separator
        input:expectWS(",");
    }

    return exprs;
};

/**
Parse an object literal expression
*/
var parseObjExpr = function (input)
{
    var fieldNames = [];
    var valExprs = [];

    // Until the end of the list
    for (;;)
    {
        // If this is the end of the list
        if (input:matchWS("}"))
        {
            break;
        }

        // Parse the property name
        var ident = parseIdentStr(input);

        input:expectWS(":");

        // Parse an expression
        var expr = parseExpr(input);

        fieldNames:push(ident);
        valExprs:push(expr);

        // If this is the end of the list
        if (input:matchWS("}"))
        {
            break;
        }

        // If this is not the first element, there must be a separator
        input:expectWS(",");
    }

    return ObjectExpr::{
        names: fieldNames,
        exprs: valExprs
    };
};

/**
Parse a function (closure) expression
function (x,y,z) <body_expr>
*/
var parseFunExpr = function (input)
{
    // If a function name was specified
    var name = '';
    if (!input:nextWS("("))
    {
        name = parseIdentStr(input);
    }

    input:expectWS("(");

    var params = [];

    // Until the end of the argument list
    for (;;)
    {
        // If this is the end of the list
        if (input:matchWS(")"))
            break;

        // Parse a parameter name
        var identStr = parseIdentStr(input);
        params:push(identStr);

        // If this is the end of the list
        if (input:matchWS(")"))
            break;

        // If this is not the first element, there must be a separator
        input:expect(",");
    }

    // Parse the function body
    input:expectWS("{");
    var body = parseBlockStmt(input, "}");

    return FunExpr::{ name:name, body:body, params:params };
};

/**
Try to match an operator in the input
*/
var matchOp = function (input, minPrec, preUnary)
{
    // FIXME: we probably want to build separate
    // lists and separate matching functions for
    // binary and unary operators
    // the logic here is hairy and inefficient

    // Longest matching operator found
    var match = false;

    // Length of the longest match found
    var matchLen = 0;

    // Search through the operators to try and find a match
    for (var i = 0; i < opList.length; i += 1)
    {
        var op = opList[i];

        // If the operator string doesn't match, skip it
        if (!input:next(op.str))
        {
            continue;
        }

        // If the operator doesn't meet the arity and
        // associativity requirements, skip it
        if ((preUnary && op.arity != 1) ||
            (!preUnary && op.arity == 1) ||
            (preUnary && op.assoc != 'r'))
        {
            continue;
        }

        // Update the longest match found
        var opLen = op.str.length;
        if (opLen > matchLen)
        {
            match = op;
            matchLen = opLen;
        }
    }

    // If no match was found, stop
    if (match == false)
    {
        return false;
    }

    // If the operator has insufficient precedence, no match
    if (match.prec < minPrec)
    {
        return false;
    }

    // Consume the operator string
    input:expect(match.str);

    return match;
};

/**
Parse an atomic expression
*/
var parseAtom = function (input)
{
    // Consume whitespace
    input:eatWS();

    // Numerical constant
    if (isDigit(input:peekCh()))
    {
        return parseNum(input, false);
    }

    // String literal
    if (input:match("\'"))
    {
        return parseStringLit(input, '\'');
    }
    if (input:match("\""))
    {
        return parseStringLit(input, '\"');
    }

    // Array literal
    if (input:match("["))
    {
        return ArrayExpr::{
            exprs: parseExprList(input, "]")
        };
    }

    // Object literal
    if (input:match("{"))
    {
        return parseObjExpr(input);
    }

    // Parenthesized expression
    if (input:match("("))
    {
        var expr = parseExpr(input);
        input:expectWS(")");
        return expr;
    }

    // Try matching a right-associative (prefix) unary operators
    var op = matchOp(input, 0, true);

    // If a matching operator was found
    if (op != false)
    {
        var expr = parseExprPrec(input, op.prec);
        return UnOpExpr::{ op:op, expr:expr };
    }

    // Identifier
    if (isAlnum(input:peekCh()))
    {
        // Function expression
        if (input:match("function"))
        {
            return parseFunExpr(input);
        }

        if (input:match("import"))
        {
            var nameExpr = parseAtom(input);

            if (!('val' in nameExpr))
                parseError(input, "invalid package name expression");

            return ImportExpr::{ pkgName:nameExpr.val };
        }

        // Identifier, variable reference
        return IdentExpr::{ name:parseIdentStr(input) };
    }

    // Inline IR
    if (input:match("$"))
    {
        var opName = parseIdentStr(input);
        input:expect("(");
        var argExprs = parseExprList(input, ")");
        return IRExpr::{ opName:opName, argExprs:argExprs };
    }

    // Parsing failed
    parseError(input, "expected atomic expression");
};

/**
Parse an expression using the precedence climbing algorithm
*/
var parseExprPrec = function (input, minPrec)
{
    // The first call has min precedence 0
    //
    // Each call loops to grab everything of the current precedence or
    // greater and builds a left-sided subtree out of it, associating
    // operators to their left operand
    //
    // If an operator has less than the current precedence, the loop
    // breaks, returning us to the previous loop level, this will attach
    // the atom to the previous operator (on the right)
    //
    // If an operator has the mininum precedence or greater, it will
    // associate the current atom to its left and then parse the rhs

    // Parse the first atom
    var lhsExpr = parseAtom(input);

    for (;;)
    {
        // Consume whitespace
        input:eatWS();

        // Get the current source code position
        var srcPos = input:getPos();

        // Attempt to match an operator in the input
        // with sufficient precedence
        var op = matchOp(input, minPrec, false);

        // If no operator matches, break out
        if (op == false)
            break;

        // Compute the minimum precedence for the recursive call (if any)
        var nextMinPrec = op.prec;
        if (op.assoc == 'l')
        {
            if (op.closeStr.length > 0)
                nextMinPrec = 0;
            else
                nextMinPrec = op.prec + 1;
        }

        // If this is a regular function call expression
        if (op == OP_CALL)
        {
            // Parse the argument list and create the call expression
            var argExprs = parseExprList(input, ")");

            lhsExpr = CallExpr::{
                funExpr:lhsExpr,
                argExprs:argExprs,
                srcPos:srcPos
            };
        }

        // If this is a method call expression
        else if (op == OP_M_CALL)
        {
            // Parse the identifier string
            var identStr = parseIdentStr(input);

            // Parse the argument list and create the call expression
            input:expectWS("(");
            var argExprs = parseExprList(input, ")");

            lhsExpr = MethodCallExpr::{
                baseExpr: lhsExpr,
                nameStr: identStr,
                argExprs: argExprs,
                srcPos: srcPos
            };
        }

        // If this is a member expression
        else if (op == OP_MEMBER)
        {
            // Parse the identifier string
            var identStr = parseIdentStr(input);

            // Produce an indexing expression
            lhsExpr = BinOpExpr::{
                op: op,
                lhsExpr: lhsExpr,
                rhsExpr: IdentExpr::{ name:identStr }
            };
        }

        // If this is an object extension expression (a::{})
        else if (op == OP_OBJ_EXT)
        {
            // Recursively parse the rhs
            var rhsExpr = parseExprPrec(input, nextMinPrec);

            if (!(lhsExpr instanceof IdentExpr))
            {
                parseError(
                    input,
                    "lhs must be identifier in object extension"
                );
            }

            if (!(rhsExpr instanceof ObjectExpr))
            {
                parseError(
                    input,
                    "rhs must be object literal in object extension expression"
                );
            }

            // Create a new parent node for the expressions
            lhsExpr = BinOpExpr::{
                op: op,
                lhsExpr: lhsExpr,
                rhsExpr: rhsExpr
            };
        }

        // If this is a binary operator
        else if (op.arity == 2)
        {
            // If the operator can be folded into an assignment expression
            if (op.foldAssign && input:matchWS("="))
            {
                // Recursively parse the rhs
                var rhsExpr = parseExprPrec(input, OP_ASSIGN.prec + 1);

                // Wrap the binary op in an assignment expression
                var binExpr = BinOpExpr::{
                    op: op,
                    lhsExpr: lhsExpr,
                    rhsExpr: rhsExpr
                };
                var assignExpr = BinOpExpr::{
                    op: OP_ASSIGN,
                    lhsExpr: lhsExpr,
                    rhsExpr: binExpr
                };
                lhsExpr = assignExpr;
            }
            else
            {
                // Recursively parse the rhs
                var rhsExpr = parseExprPrec(input, nextMinPrec);

                // If specified, match the operator closing string
                if (op.closeStr.length > 0 && !input:matchWS(op.closeStr))
                    parseError(input, "expected operator closing");

                // Create a new parent node for the expressions
                lhsExpr = BinOpExpr::{
                    op: op,
                    lhsExpr: lhsExpr,
                    rhsExpr: rhsExpr
                };
            }
        }

        else
        {
            assert (
                false,
                "operator not handled correctly"
            );
        }
    }

    // Return the parsed expression
    return lhsExpr;
};

/**
Recursively parse an expression, starting at the least precedence level
*/
var parseExpr = function (input)
{
    return parseExprPrec(input, 0);
};

/**
Parse a block statement
*/
var parseBlockStmt = function (input, endStr)
{
    var stmts = [];

    // Until the end of the list
    for (;;)
    {
        // Read whitespace
        input:eatWS();

        // If this is the end of the block statement
        if ((endStr == "" && input:eof()) ||
            (endStr != "" && input:match(endStr)))
        {
            break;
        }

        // Parse a statement
        var stmt = parseStmt(input);
        stmts:push(stmt);
    }

    return BlockStmt::{ stmts: stmts };
};

var parseStmt = function (input)
{
    // Sequence/block expression (i.e { a; b; c }
    if (input:matchWS("{"))
    {
        return parseBlockStmt(input, "}");
    }

    // Variable declaration
    if (input:matchKW("var"))
    {
        input:eatWS();
        var ident = parseIdentStr(input);

        input:expectWS("=");

        var initExpr = parseExpr(input);

        input:expectWS(";");

        return VarStmt::{ identName:ident, initExpr:initExpr };
    }

    // If-else statement
    if (input:matchKW("if"))
    {
        return parseIfStmt(input);
    }

    // For loop statement
    if (input:matchKW("for"))
    {
        return parseForStmt(input);
    }

    // Break statement
    if (input:matchKW("break"))
    {
        input:expectWS(";");
        return BreakStmt::{};
    }

    // Continue statement
    if (input:matchKW("continue"))
    {
        input:expectWS(";");
        return ContStmt::{};
    }

    // Try/catch statement
    if (input:matchKW("try"))
    {
        return parseTryStmt(input);
    }

    // Return statement
    if (input:matchKW("return"))
    {
        if (input:matchWS(";"))
        {
            return ReturnStmt::{
                expr: IdentExpr::{ name:"undef" }
            };
        }

        var expr = parseExpr(input);
        input:expectWS(";");

        return ReturnStmt::{ expr: expr };
    }

    // Throw statement
    if (input:matchKW("throw"))
    {
        var expr = parseExpr(input);
        input:expectWS(";");
        return ThrowStmt::{ expr: expr };
    }

    // Get the current position in the input
    input:eatWS();
    var srcPos = input:getPos();

    // Assert statement
    if (input:matchKW("assert"))
    {
        input:expectWS("(");

        var testExpr = parseExpr(input);

        var errMsg = false;
        if (input:matchWS(","))
            errMsg = parseExpr(input);
        else
            errMsg = StringExpr::{ val:"assertion failed" };

        input:expectWS(")");
        input:expectWS(";");

        return IfStmt::{
            testExpr: testExpr,
            thenStmt: BlockStmt::{ stmts:[] },
            elseStmt: IRStmt::{
                instr: {op: "abort", src_pos: srcPos },
                argExprs:[errMsg]
            }
        };
    }

    // Expression statement
    var expr = parseExpr(input);
    input:expectWS(";");
    return ExprStmt::{ expr: expr };
};

/**
Parse a source unit from an input object
*/
var parseUnit = function (input)
{
    var blockStmt = parseBlockStmt(input, "");

    // Create the top-level function
    return FunExpr::{ name: "unit", body: blockStmt, argExprs: [] };
};

/**
Parse a source string as a unit
*/
var parseString = function (str, srcName)
{
    var input = Input::{
        srcName: srcName,
        srcString: str
    };

    return parseUnit(input);
};

/**
Parse a source file as a unit
*/
var parseFile = function (fileName)
{
    var fileData = readFile(fileName);

    var input = Input::{
        srcName: fileName,
        srcString: fileData
    };

    return parseUnit(input);
};

//============================================================================
// Code generation
//============================================================================

var Block = {};

Block.new = function ()
{
    return Block::{
        instrs: [],
    };
};

Block.hasBranch = function (block)
{
    if (block.instrs.length == 0)
        return false;

    var lastInstr = block.instrs[block.instrs.length-1];
    var op = lastInstr.op;

    return (
        op == 'ret' ||
        op == 'jump' ||
        op == 'if_true'
    );
};

Block.addInstr = function (block, instr)
{
    block.instrs:push(instr);
};

var Function = {};

Function.new = function (params, entryBlock)
{
    // Note: functions always have at least 1 local
    // to store the hidden function/closure argument
    return Function::{
        params: params,
        num_locals: 1,
        entry: entryBlock,

        /// List of local variable names
        localNames: []
    };
};

/// Register a local variable declaration
Function.registerDecl = function (fun, identName)
{
    if (fun:hasLocal(identName))
        return;

    var newIdx = fun.num_locals;
    fun.localNames:push(identName);
    fun.num_locals += 1;
};

Function.hasLocal = function (fun, identName)
{
    return fun:getLocalIdx(identName) != -1;
};

Function.getLocalIdx = function (fun, identName)
{
    for (var i = 0; i < fun.localNames.length; i += 1)
    {
        if (fun.localNames[i] == identName)
        {
            return i;
        }
    }

    return -1;
};

var CodeGenCtx = {};

/// Initial context constructor
CodeGenCtx.new = function (
    exportsObj,
    globalObj,
    fun,
    unitFun,
    curBlock
)
{
    return CodeGenCtx::{
        exportsObj: exportsObj,
        globalObj: globalObj,
        fun: fun,
        unitFun: unitFun,
        curBlock: curBlock,
        contBlock: false,
        breakBlock: false,
        catchBlock: false
    };
};

/// Context extension function
CodeGenCtx.subCtx = function (
    ctx,
    startBlock
)
{
    return CodeGenCtx::{
        exportsObj: ctx.exportsObj,
        globalObj: ctx.globalObj,
        fun: ctx.fun,
        unitFun: ctx.unitFun,
        curBlock: startBlock,
        contBlock: ctx.contBlock,
        breakBlock: ctx.breakBlock,
        catchBlock: ctx.catchBlock
    };
};

/// Continue code generation at a given block
CodeGenCtx.merge = function (ctx, block)
{
    ctx.curBlock = block;
};

/// Add an instruction
CodeGenCtx.addInstr = function (ctx, instr)
{
    assert (ctx.curBlock != false);
    ctx.curBlock:addInstr(instr);
};

/// Add an instruction with no arguments by opcode name
CodeGenCtx.addOp = function (ctx, opStr)
{
    ctx.curBlock:addInstr({ op: opStr });
};

/// Add a push instruction
CodeGenCtx.addPush = function (ctx, val)
{
    ctx.curBlock:addInstr({ op:'push', val:val });
};

/**
Register variable declarations within a function body
*/
var registerDecls = function (fun, stmt, unitFun)
{
    if (stmt instanceof BlockStmt)
    {
        for (var i = 0; i < stmt.stmts.length; i += 1)
            registerDecls(fun, stmt.stmts[i], unitFun);
        return;
    }

    if (stmt instanceof VarStmt)
    {
        // If this is not a unit function, create a new local
        if (!unitFun)
            fun:registerDecl(stmt.identName);
        return;
    }

    if (stmt instanceof ExprStmt)
    {
        return;
    }

    if (stmt instanceof IfStmt)
    {
        registerDecls(fun, stmt.thenStmt, unitFun);
        registerDecls(fun, stmt.elseStmt, unitFun);
        return;
    }

    if (stmt instanceof ForStmt)
    {
        registerDecls(fun, stmt.initStmt, unitFun);
        registerDecls(fun, stmt.bodyStmt, unitFun);
        return;
    }

    if (stmt instanceof TryStmt)
    {
        registerDecls(fun, stmt.bodyStmt, unitFun);
        registerDecls(fun, stmt.catchStmt, unitFun);

        // If this is not a unit function, create a new local
        if (!unitFun)
            fun:registerDecl(stmt.catchVar);

        return;
    }

    if (stmt instanceof ContStmt)
    {
        return;
    }

    if (stmt instanceof BreakStmt)
    {
        return;
    }

    if (stmt instanceof ReturnStmt)
    {
        return;
    }

    if (stmt instanceof ThrowStmt)
    {
        return;
    }

    if (stmt instanceof IRStmt)
    {
        return;
    }

    assert (
        false,
        "unknown statement type in registerDecls"
    );
};

/**
Generate code for a code unit
*/
var genUnit = function (unitAST, globalObj)
{
    var entryBlock = Block.new();

    var unitFun = Function.new([], entryBlock);

    // Register variable declarations
    registerDecls(unitFun, unitAST.body, true);

    // Definitions exported by this unit/package
    var exportsObj = { init: unitFun };

    // Create the initial context
    var ctx = CodeGenCtx.new(
        exportsObj,
        globalObj,
        unitFun,
        true,
        entryBlock
    );

    // Generate code for the function body
    genStmt(ctx, unitAST.body);

    // Add a final return statement to the unit function
    if (!ctx.curBlock:hasBranch())
    {
        ctx:addInstr({ op:'push', val:true });
        ctx:addInstr({ op:'ret' });
    }

    return exportsObj;
};

var runtimeCall = function (ctx, fun)
{
    var contBlock = Block.new();

    ctx:addPush(fun);

    var callInstr = {
        op: "call",
        num_args: fun.params.length,
        ret_to: contBlock
    };

    if (ctx.catchBlock != false)
        callInstr.throw_to = ctx.catchBlock;

    ctx:addInstr(callInstr);

    ctx:merge(contBlock);
};

var genExpr = function (ctx, expr)
{
    //print('genExpr');

    if (expr instanceof IntExpr)
    {
        ctx:addPush(expr.val);
        return;
    }

    if (expr instanceof FloatExpr)
    {
        ctx:addPush(expr.val);
        return;
    }

    if (expr instanceof StringExpr)
    {
        ctx:addPush(expr.val);
        return;
    }

    if (expr instanceof IdentExpr)
    {
        if (expr.name == "exports")
        {
            ctx:addPush(ctx.exportsObj);
            return;
        }

        if (expr.name == "true")
        {
            ctx:addPush(true);
            return;
        }

        if (expr.name == "false")
        {
            ctx:addPush(false);
            return;
        }

        if (expr.name == "undef")
        {
            ctx:addPush(undef);
            return;
        }

        if (ctx.fun:hasLocal(expr.name))
        {
            var localIdx = ctx.fun:getLocalIdx(expr.name);
            ctx:addInstr({ op:'get_local', idx:localIdx });
            return;
        }

        ctx:addPush(ctx.globalObj);
        ctx:addPush(expr.name);
        ctx:addOp("get_field");

        return;
    }

    if (expr instanceof UnOpExpr)
    {
        // Logical not
        if (expr.op == OP_NOT)
        {
            genExpr(ctx, expr.expr);
            runtimeCall(ctx, rt_not);
            return;
        }

        // Unary negation
        if (expr.op == OP_NEG)
        {
            // Generate 0 - x
            ctx:addPush(0);
            genExpr(ctx, expr.expr);
            runtimeCall(ctx, rt_sub);
            return;
        }

        // Unary bitwise not; one's-complement
        if (expr.op == OP_BIT_NOT)
        {
            genExpr(ctx, expr.expr);
            runtimeCall(ctx, rt_bit_not);
            return;
        }

        if (expr.op == OP_TYPEOF)
        {
            genExpr(ctx, expr.expr);
            ctx:addOp("get_tag");
            return;
        }

        assert (
            false,
            "unhandled unary op"
        );
    }

    if (expr instanceof BinOpExpr)
    {
        if (expr.op == OP_ASSIGN)
        {
            genAssign(ctx, expr.lhsExpr, expr.rhsExpr);
            return;
        }

        if (expr.op == OP_AND)
        {
            genLogicalAnd(ctx, expr.lhsExpr, expr.rhsExpr);
            return;
        }

        if (expr.op == OP_OR)
        {
            genLogicalOr(ctx, expr.lhsExpr, expr.rhsExpr);
            return;
        }

        if (expr.op == OP_EQ)
        {
            // Expression of the form: typeof x == "type_string"
            if (expr.lhsExpr instanceof UnOpExpr)
            {
                if (expr.lhsExpr.op == OP_TYPEOF)
                {
                    if (expr.rhsExpr instanceof StringExpr)
                    {
                        var tagStr = expr.rhsExpr.val;
                        genExpr(ctx, expr.lhsExpr.expr);
                        ctx:addInstr({ op:'has_tag', tag:tagStr });
                        return;
                    }
                }
            }

            // Equality comparison
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_eq);

            return;
        }

        // Inequality comparison
        if (expr.op == OP_NE)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_ne);
            return;
        }

        if (expr.op == OP_LT)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_lt);
            return;
        }

        if (expr.op == OP_LE)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_le);
            return;
        }

        if (expr.op == OP_GT)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_gt);
            return;
        }

        if (expr.op == OP_GE)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_ge);
            return;
        }

        if (expr.op == OP_IN)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_in);
            return;
        }

        if (expr.op == OP_ADD)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_add);
            return;
        }

        if (expr.op == OP_SUB)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_sub);
            return;
        }

        if (expr.op == OP_MUL)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_mul);
            return;
        }

        if (expr.op == OP_DIV)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_div);
            return;
        }

        if (expr.op == OP_MOD)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_mod);
            return;
        }

        if (expr.op == OP_BIT_SHL)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_shl);
            return;
        }

        if (expr.op == OP_BIT_SHR)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_shr);
            return;
        }

        if (expr.op == OP_BIT_USHR)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_ushr);
            return;
        }

        if (expr.op == OP_BIT_AND)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_and);
            return;
        }

        if (expr.op == OP_BIT_OR)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_or);
            return;
        }

        if (expr.op == OP_BIT_XOR)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_xor);
            return;
        }

        if (expr.op == OP_MEMBER)
        {
            genExpr(ctx, expr.lhsExpr);

            var identExpr = expr.rhsExpr;

            if (!(identExpr instanceof IdentExpr))
                parseError(false, "invalid rhs in member expression");

            ctx:addInstr({ op:'push', val:identExpr.name });

            runtimeCall(ctx, rt_getProp);

            return;
        }

        // Indexing operator: a[b]
        if (expr.op == OP_INDEX)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_getElem);
            return;
        }

        // Object extension
        if (expr.op == OP_OBJ_EXT)
        {
            assert (expr.rhsExpr instanceof ObjectExpr);
            genObjExpr(ctx, expr.lhsExpr, expr.rhsExpr);
            return;
        }

        // Instanceof
        if (expr.op == OP_INSTOF)
        {
            genExpr(ctx, expr.lhsExpr);
            genExpr(ctx, expr.rhsExpr);
            runtimeCall(ctx, rt_instOf);
            return;
        }

        assert (
            false,
            "unhandled binary op " + expr.op.str
        );
    }

    // Object literal expression
    if (expr instanceof ObjectExpr)
    {
        genObjExpr(ctx, false, expr);
        return;
    }

    // Array literal expression
    if (expr instanceof ArrayExpr)
    {
        // Create a new array with a sufficient capacity
        ctx:addInstr({ op:'push', val:expr.exprs.length });
        ctx:addOp("new_array");

        // For each property
        for (var i = 0; i < expr.exprs.length; i += 1)
        {
            // Duplicate the array value
            ctx:addInstr({ op:'dup', idx:0 });

            // Evaluate the property value expression
            genExpr(ctx, expr.exprs[i]);

            // Append the element to the array
            ctx:addOp("array_push");
        }

        return;
    }

    // Function/closure expression
    if (expr instanceof FunExpr)
    {
        var entryBlock = Block.new();

        var fun = Function.new(
            expr.params,
            entryBlock
        );

        // Register the function parameter variables
        for (var i = 0; i < expr.params.length; i += 1)
            fun:registerDecl(expr.params[i]);

        // Register the variable declarations in the function body
        registerDecls(fun, expr.body, false);

        var funCtx = CodeGenCtx.new(
            ctx.exportsObj,
            ctx.globalObj,
            fun,
            false,
            entryBlock
        );

        // Generate code for the function body
        genStmt(funCtx, expr.body);

        if (!funCtx.curBlock:hasBranch())
        {
            // Return the undefined value
            funCtx:addInstr({ op:'push', val:undef });
            funCtx:addOp("ret");
        }

        ctx:addInstr({ op:'push', val:fun });

        return;
    }

    // Function call expression
    if (expr instanceof CallExpr)
    {
        var args = expr.argExprs;

        // Evaluate the arguments in order
        for (var i = 0; i < args.length; i += 1)
            genExpr(ctx, args[i]);

        // Evaluate the function expression
        genExpr(ctx, expr.funExpr);

        var contBlock = Block.new();

        var callInstr = {
            op: "call",
            num_args: args.length,
            src_pos: expr.srcPos,
            ret_to: contBlock
        };

        if (ctx.catchBlock != false)
            callInstr.throw_to = ctx.catchBlock;

        ctx:addInstr(callInstr);

        ctx:merge(contBlock);

        return;
    }

    // Method call expression
    if (expr instanceof MethodCallExpr)
    {
        var args = expr.argExprs;

        // Evaluate the base expression (this value)
        genExpr(ctx, expr.baseExpr);

        // Evaluate the arguments in order
        for (var i = 0; i < args.length; i += 1)
            genExpr(ctx, args[i]);

        // Duplicate the base (this) value
        ctx:addInstr({ op:'dup', idx:args.length });

        // Push the property name
        ctx:addInstr({ op:'push', val:expr.nameStr });

        // Get the function/method value
        runtimeCall(ctx, rt_getProp);

        var contBlock = Block.new();

        ctx:addInstr({
            op: "call",
            ret_to:contBlock,
            num_args: args.length+1,
            src_pos: expr.srcPos
        });

        ctx:merge(contBlock);

        return;
    }

    // Inline IR expression
    if (expr instanceof IRExpr)
    {
        // Evaluate the arguments in the order supplied
        var args = expr.argExprs;
        for (var i = 0; i < args.length; i += 1)
            genExpr(ctx, args[i]);

        ctx:addOp(expr.opName);

        return;
    }

    if (expr instanceof ImportExpr)
    {
        ctx:addPush(expr.pkgName);
        ctx:addOp("import");
        return;
    }

    assert (
        false,
        "unknown expression type in genExpr"
    );
};

var genStmt = function (ctx, stmt)
{
    //print('genStmt');

    if (stmt instanceof BlockStmt)
    {
        // For each statement
        for (var i = 0; i < stmt.stmts.length; i += 1)
        {
            genStmt(ctx, stmt.stmts[i]);

            if (ctx.curBlock:hasBranch())
                break;
        }

        return;
    }

    if (stmt instanceof VarStmt)
    {
        if (ctx.fun:hasLocal(stmt.identName))
        {
            genExpr(ctx, stmt.initExpr);
            var localIdx = ctx.fun:getLocalIdx(stmt.identName);
            ctx:addInstr({ op:'set_local', idx:localIdx });
        }
        else
        {
            ctx:addPush(ctx.globalObj);
            ctx:addPush(stmt.identName);
            genExpr(ctx, stmt.initExpr);
            ctx:addOp("set_field");
        }

        return;
    }

    if (stmt instanceof ReturnStmt)
    {
        genExpr(ctx, stmt.expr);
        ctx:addOp("ret");
        return;
    }

    if (stmt instanceof ThrowStmt)
    {
        genExpr(ctx, stmt.expr);
        runtimeCall(ctx, rt_throw);
        return;
    }

    if (stmt instanceof ExprStmt)
    {
        // Pop (ignore) the value produced by the expression
        genExpr(ctx, stmt.expr);
        ctx:addOp("pop");
        return;
    }

    if (stmt instanceof IfStmt)
    {
        // Evaluate the test expression
        genExpr(ctx, stmt.testExpr);

        var thenBlock = Block.new();
        var thenCtx = ctx:subCtx(thenBlock);
        genStmt(thenCtx, stmt.thenStmt);

        var elseBlock = Block.new();
        var elseCtx = ctx:subCtx(elseBlock);
        genStmt(elseCtx, stmt.elseStmt);

        // Insert the conditional branching instruction
        ctx:addInstr({ op:"if_true", then:thenBlock, else:elseBlock });

        var joinBlock = Block.new();
        ctx:merge(joinBlock);

        if (!thenCtx.curBlock:hasBranch())
            thenCtx:addInstr({ op:"jump", to:joinBlock });
        if (!elseCtx.curBlock:hasBranch())
            elseCtx:addInstr({ op:"jump", to:joinBlock });

        return;
    }

    // For-loop statement
    if (stmt instanceof ForStmt)
    {
        // Loop body and exit blocks
        var testBlock = Block.new();
        var bodyBlock = Block.new();
        var incrBlock = Block.new();
        var exitBlock = Block.new();

        // Generate the initialization statement
        genStmt(ctx, stmt.initStmt);

        // Evaluate the test expression
        ctx:addInstr({ op:"jump", to:testBlock });
        var testCtx = ctx:subCtx(testBlock);
        genExpr(testCtx, stmt.testExpr);

        // Insert the conditional branching instruction
        testCtx:addInstr({ op:"if_true", then:bodyBlock, else:exitBlock });

        // Generate the loop body statement
        var bodyCtx = ctx:subCtx(bodyBlock);
        bodyCtx.contBlock = incrBlock;
        bodyCtx.breakBlock = exitBlock;
        genStmt(bodyCtx, stmt.bodyStmt);
        if (!bodyCtx.curBlock:hasBranch())
            bodyCtx:addInstr({ op:"jump", to:incrBlock });

        // Generate the increment expression
        var incrCtx = ctx:subCtx(incrBlock);
        genExpr(incrCtx, stmt.incrExpr);
        incrCtx:addOp("pop");
        incrCtx:addInstr({ op:"jump", to:testBlock });

        ctx:merge(exitBlock);

        return;
    }

    // Try/catch statement
    if (stmt instanceof TryStmt)
    {
        var bodyBlock = Block.new();
        var catchBlock = Block.new();
        var joinBlock = Block.new();

        ctx:addInstr({ op:"jump", to:bodyBlock });

        // Generate the try body block
        var bodyCtx = ctx:subCtx(bodyBlock);
        bodyCtx.catchBlock = catchBlock;
        genStmt(bodyCtx, stmt.bodyStmt);
        if (!bodyCtx.curBlock:hasBranch())
            bodyCtx:addInstr({ op:"jump", to:joinBlock });
        var catchCtx = ctx:subCtx(catchBlock);

        // Assign the exception value to the catch variable
        if (catchCtx.unitFun)
        {
            catchCtx:addInstr({ op:'push', val:ctx.globalObj });
            catchCtx:addInstr({ op:'push', val:stmt.catchVar });
            catchCtx:addInstr({ op:'dup', idx:2 });
            catchCtx:addInstr({ op: "set_field" });
            catchCtx:addInstr({ op: "pop" });
        }
        else
        {
            var localIdx = ctx.fun:getLocalIdx(stmt.catchVar);
            catchCtx:addInstr({ op:'set_local', idx:localIdx });
        }

        // Generate the catch statement
        genStmt(catchCtx, stmt.catchStmt);
        if (!catchCtx.curBlock:hasBranch())
            catchCtx:addInstr({ op:"jump", to:joinBlock });

        ctx:merge(joinBlock);

        return;
    }

    // Loop break statement
    if (stmt instanceof ContStmt)
    {
        if (!ctx.curBlock:hasBranch())
            ctx:addInstr({ op:"jump", to:ctx.contBlock });
        return;
    }

    // Loop break statement
    if (stmt instanceof BreakStmt)
    {
        if (!ctx.curBlock:hasBranch())
            ctx:addInstr({ op:"jump", to:ctx.breakBlock });
        return;
    }

    // IR instruction statement
    if (stmt instanceof IRStmt)
    {
        // Evaluate the arguments in reverse order
        var args = stmt.argExprs;

        for (var i = 0; i < args.length; i += 1)
            genExpr(ctx, args[i]);

        ctx:addInstr(stmt.instr);

        return;
    }

    assert (
        false,
        "unknown statement in genStmt"
    );
};

var genLogicalAnd = function (ctx, lhsExpr, rhsExpr)
{
    var andBlock = Block.new();
    var doneBlock = Block.new();

    // Evaluate the lhs expression
    genExpr(ctx, lhsExpr);
    ctx:addInstr({ op:'dup', idx:0 });
    ctx:addInstr({ op:"if_true", then:andBlock, else:doneBlock });

    // Evaluate the second expression
    var andCtx = ctx:subCtx(andBlock);
    andCtx:addOp("pop");
    genExpr(andCtx, rhsExpr);
    andCtx:addInstr({ op:"jump", to:doneBlock });

    ctx:merge(doneBlock);
};

var genLogicalOr = function (ctx, lhsExpr, rhsExpr)
{
    var orBlock = Block.new();
    var doneBlock = Block.new();

    // Evaluate the lhs expression
    genExpr(ctx, lhsExpr);
    ctx:addInstr({ op:'dup', idx:0 });
    ctx:addInstr({ op:"if_true", then:doneBlock, else:orBlock });

    // If the first expression fails, evaluate the second one
    var orCtx = ctx:subCtx(orBlock);
    orCtx:addOp("pop");
    genExpr(orCtx, rhsExpr);
    orCtx:addInstr({ op:"jump", to:doneBlock });

    ctx:merge(doneBlock);
};

var genObjExpr = function (ctx, protoExpr, objExpr)
{
    assert (
        objExpr.names.length == objExpr.exprs.length,
        "object property names and init exprs do not match"
    );

    // Create a new object
    ctx:addInstr({ op:'push', val:objExpr.exprs.length });
    ctx:addOp("new_object");

    // If a prototype expression is specified
    if (protoExpr != false)
    {
        // Duplicate the object value
        ctx:addInstr({ op:'dup', idx:0 });

        // Push the prototype property name
        ctx:addPush("proto");

        // Evaluate the prototype expression
        genExpr(ctx, protoExpr);

        // Set the prototype field
        ctx:addOp("set_field");
    }

    // For each property
    for (var i = 0; i < objExpr.names.length; i += 1)
    {
        // Duplicate the object value
        ctx:addInstr({ op:'dup', idx:0 });

        // Push the property name
        ctx:addInstr({ op:'push', val:objExpr.names[i] });

        // Evaluate the property value expression
        genExpr(ctx, objExpr.exprs[i]);

        ctx:addOp("set_field");
    }
};

var genAssign = function (ctx, lhsExpr, rhsExpr)
{
    //print('genAssign');

    // Assignment to a variable
    if (lhsExpr instanceof IdentExpr)
    {
        if (lhsExpr.name == "exports")
        {
            parseError(false, "cannot assign to exports variable");
        }

        if (ctx.fun:hasLocal(lhsExpr.name))
        {
            var localIdx = ctx.fun:getLocalIdx(lhsExpr.name);
            genExpr(ctx, rhsExpr);
            ctx:addInstr({ op:'dup', idx:0 });
            ctx:addInstr({ op:'set_local', idx:localIdx });
        }
        else
        {
            genExpr(ctx, rhsExpr);
            ctx:addPush(ctx.globalObj);
            ctx:addPush(lhsExpr.name);
            ctx:addInstr({ op:'dup', idx:2 });
            ctx:addOp("set_field");
        }

        return;
    }

    // Assignment to a property
    if (lhsExpr instanceof BinOpExpr)
    {
        if (lhsExpr.op == OP_MEMBER)
        {
            var memberOp = lhsExpr;
            var identExpr = memberOp.rhsExpr;

            // Evaluate the rhs value
            genExpr(ctx, rhsExpr);

            // Evaluate the object/base
            genExpr(ctx, memberOp.lhsExpr);

            ctx:addInstr({ op:'push', val:identExpr.name });
            ctx:addInstr({ op:'dup', idx:2 });
            ctx:addOp("set_field");

            return;
        }

        if (lhsExpr.op == OP_INDEX)
        {
            // Evaluate the array
            genExpr(ctx, lhsExpr.lhsExpr);

            // Evaluate the index
            genExpr(ctx, lhsExpr.rhsExpr);

            // Evaluate the rhs value
            genExpr(ctx, rhsExpr);

            runtimeCall(ctx, rt_setElem);

            return;
        }

        assert (false);
    }

    assert (
        false,
        "unhandled expression type in genAssign"
    );
};

//============================================================================
// External interface
//============================================================================

/**
Function to parse a source string
Note: this is used for parser tests.
The output is a Plush AST
*/
exports.parseString = parseString;

/**
Exported function to parse from an input object
Note: this is called by zeta to parse Plush files.
The output is a Zeta package object.
*/
exports.parse_input = function (input)
{
    //print('Entering parse_input');

    /*
    print("input.src_string.length");
    print(input.src_string.length);
    print("input.str_idx");
    print(input.str_idx);
    */

    var input = Input::{
        srcName: input.src_name,
        srcString: input.src_string,
        strIdx: input.str_idx,
        lineNo: input.line_no,
        colNo: input.col_no
    };

    // Parse the unit
    var ast = parseUnit(input);

    // Globally visible definitions
    var globalObj = {
        output: output,
        print: print
    };

    // Generate code for the unit
    var unitFn = genUnit(ast, globalObj);

    return unitFn;
};

/**
The main function is called when this package is run as a standalone
program/script. It implements a Read-Eval-Print Loop (REPL).
*/
exports.main = function ()
{
    var io = import "core/io/0";

    print('Plush Read-Eval-Print Loop (REPL)');
    print('To exit, press Ctrl+D or type "exit"');
    //print('');

    // Global object used by the REPL
    var globalObj = {
        output: output,
        print: print
    };

    for (;;)
    {
        output('\n');
        output("] ");
        var line = io.read_line();

        if (line == undef)
        {
            output('\n');
            break;
        }

        if (line == "exit" || line == "quit")
        {
            break;
        }

        var input = Input::{
            srcName: "console",
            srcString: line,
            strIdx: 0,
            lineNo: 1,
            colNo: 1
        };

        try
        {
            // Parse the unit
            var ast = parseUnit(input);

            // Generate code for the unit
            var unit = genUnit(ast, globalObj);

            // Run the unit function
            unit.init();
        }
        catch (e)
        {
            print("Parse error: " + e.msg);
            continue;
        }
    }

    return 0;
};
