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
var OP_TYPEOF = addOp(OpInfo::{ str:"typeof", arity:1, prec:13, assoc:'r' });

/// Binary arithmetic operators
var OP_MUL = addOp(OpInfo::{ str:"*", prec:12, foldAssign:true });
var OP_ADD = addOp(OpInfo::{ str:"+", prec:11, foldAssign:true });
var OP_SUB = addOp(OpInfo::{ str:"-", prec:11, foldAssign:true });

/// Relational operators
var OP_LT = addOp(OpInfo::{ str:"<", prec:9 });
var OP_LE = addOp(OpInfo::{ str:"<=", prec:9 });
var OP_GT = addOp(OpInfo::{ str:">", prec:9 });
var OP_GE = addOp(OpInfo::{ str:">=", prec:9 });
var OP_IN = addOp(OpInfo::{ str:"in", prec:9 });
//const OpInfo OP_INSTOF = { "instanceof", "", 2, 9, 'l', false, false };

/// Equality comparison
var OP_EQ = addOp(OpInfo::{ str:"==", prec:8 });
var OP_NE = addOp(OpInfo::{ str:"!=", prec:8 });

/// Bitwise operators
//const OpInfo OP_BIT_AND = { "&", "", 2, 7, 'l', false, true };
//const OpInfo OP_BIT_XOR = { "^", "", 2, 6, 'l', false, true };
//const OpInfo OP_BIT_OR = { "|", "", 2, 5, 'l', false, true };

/// Logical operators
var OP_AND = addOp(OpInfo::{ str:"&&", prec:4, foldAssign:true });
var OP_OR = addOp(OpInfo::{ str:"||", prec:3, foldAssign:true });

// Assignment
var OP_ASSIGN = addOp(OpInfo::{str:"=", arity:2, prec:1, assoc:'r'});

/// Prototype for integer expressions
var IntExpr = {
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

/// Prototype for expression statements
var ExprStmt = {
};

/// Prototype for return statements
var ReturnStmt = {
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
    if (input != false)
    {
        output(input.srcName);
        output("@");
        output(input.lineNo);
        output(":");
        output(input.colNo);
        output(" - ");
    }

    print(errorStr);

    assert (false);

    /*
    assert (
        false,
        //input.srcName + "@" + input.lineNo + ":" + input.colNo + " - " +
        errorStr
    );
    */
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
    assert (str.length > 0);

    if (self:next(str))
    {
        for (var i = 0; i < str.length; i += 1)
            self:readCh();

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

/**
Parse a decimal integer
*/
var parseInt = function (input, neg)
{
    var intVal = 0;

    for (;;)
    {
        // Peek at the next character
        var ch = input:readCh();

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

        // If the next character is not a digit, stop
        if (!isDigit(input:peekCh()))
            break;
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
        // TODO: need charcode to string
        assert (false, "hexadecimal escape sequence");

        /*
        int escVal = 0;
        for (var i = 0; i < 2; i += 1)
        {
            var ch = input:readCh();
            if (ch >= '0' && ch <= '9')
            {
                escVal = 16 * escVal + (ch - '0');
            }
            else if (ch >= 'A' && ch <= 'F')
            {
                escVal = 16 * escVal + (ch - 'A' + 10);
            }
            else
            {
                parseError(
                    input,
                    "invalid hexadecimal character escape code"
                );
            }
        }

        assert (escVal >= 0 && escVal <= 255);
        return (char)escVal;
        */
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
    if (input:matchWS("else"))
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

        // FIXME: need sanitization check here once we have instanceof
        //if (cast(VarStmt)initStmt is null && cast(ExprStmt)initStmt is null)
        //    throw new parseError("invalid for-loop init statement", initStmt.pos);
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

        // If it doesn't have enough precedence or doesn't meet
        // the arity and associativity requirements, skip it
        if ((op.prec < minPrec) ||
            (preUnary && op.arity != 1) ||
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
        return parseInt(input, false);
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
                srcPos:srcPos
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

                // Create a new parent node for the expressions
                lhsExpr = BinOpExpr::{
                    op: op,
                    lhsExpr: lhsExpr,
                    rhsExpr: rhsExpr
                };

                // If specified, match the operator closing string
                if (op.closeStr.length > 0 && !input:matchWS(op.closeStr))
                    parseError(input, "expected operator closing");
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
    if (input:matchWS("var"))
    {
        input:eatWS();
        var ident = parseIdentStr(input);

        input:expectWS("=");

        var initExpr = parseExpr(input);

        input:expectWS(";");

        return VarStmt::{ identName:ident, initExpr:initExpr };
    }

    // If-else statement
    if (input:matchWS("if"))
    {
        return parseIfStmt(input);
    }

    // For loop statement
    if (input:matchWS("for"))
    {
        return parseForStmt(input);
    }

    // Return statement
    if (input:matchWS("break"))
    {
        input:expectWS(";");
        return BreakStmt::{};
    }

    // Return statement
    if (input:matchWS("continue"))
    {
        input:expectWS(";");
        return ContStmt::{};
    }

    // Return statement
    if (input:matchWS("return"))
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

    // Assert statement
    if (input:nextWS("assert"))
    {
        // Get the current position in the input
        input:eatWS();
        var srcPos = input:getPos();

        input:matchWS("assert");
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

Function.new = function (numParams, entryBlock)
{
    return Function::{
        num_params: numParams,
        num_locals: 0,
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
        breakBlock: false
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
        breakBlock: ctx.breakBlock
    };
};

/// Context extension function for loop contexts
CodeGenCtx.subCtxLoop = function (
    ctx,
    startBlock,
    contBlock,
    breakBlock
)
{
    return CodeGenCtx::{
        exportsObj: ctx.exportsObj,
        globalObj: ctx.globalObj,
        fun: ctx.fun,
        unitFun: ctx.unitFun,
        curBlock: startBlock,
        contBlock: contBlock,
        breakBlock: breakBlock
    };
};

/// Continue code generation at a given block
CodeGenCtx.merge = function (ctx, block)
{
    ctx.curBlock = block;
};

/// Add an instructionN
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
var genUnit = function (unitAST)
{
    var entryBlock = Block.new();

    var unitFun = Function.new(0, entryBlock);

    // Register variable declarations
    registerDecls(unitFun, unitAST.body, true);

    var exportsObj = { init: unitFun };

    var globalObj = {
        exports: exportsObj,
        print: print
    };

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

    ctx:addInstr({
        op: "call",
        ret_to: contBlock,
        num_args: fun.num_params
    });

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
            ctx:addOp("lt_i32");
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
            ctx:addOp("gt_i32");
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
            ctx:addOp("mul_i32");
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
            var objExpr = expr.rhsExpr;

            if (!(expr.rhsExpr instanceof ObjectExpr))
                parseError(input, "invalid rhs in objext extension expression");

            genObjExpr(ctx, expr.lhsExpr, expr.rhsExpr);

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
            expr.params.length,
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

        ctx:addInstr({
            op: "call",
            ret_to: contBlock,
            num_args: args.length,
            src_pos: expr.srcPos
        });

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
        //print('*** ReturnStmt');
        genExpr(ctx, stmt.expr);
        ctx:addOp("ret");
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
        var bodyCtx = ctx:subCtxLoop(
            bodyBlock,
            incrBlock,
            exitBlock
        );
        genStmt(bodyCtx, stmt.bodyStmt);

        // Generate the increment expression
        if (!bodyCtx.curBlock:hasBranch())
            bodyCtx:addInstr({ op:"jump", to:incrBlock });
        var incrCtx = ctx:subCtx(incrBlock);
        genExpr(incrCtx, stmt.incrExpr);
        incrCtx:addInstr({ op:"jump", to:testBlock });

        ctx:merge(exitBlock);

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

        assert (false);
    }

    assert (
        false,
        "unhandled expression type in genAssign"
    );
};

//============================================================================
// Tests
//============================================================================

/// Test that the parsing of a string succeeds
var testParse = function (str)
{
    print(str);

    return parseString(str, "parser_test");
};

/// Test the functionality of the parser
var testParser = function ()
{
    print("parser tests");

    // Identifiers
    testParse("foobar;");
    testParse("  foo_bar;  ");
    testParse("  foo_bar ; ");

    // Literals
    testParse("123;");
    testParse("'abc';");
    testParse("\"double-quoted string!\";");
    testParse("\"double-quoted string, 'hi'!\";");
    testParse("'hi'; // comment");
    testParse("'hi';");
    testParse("'new\\nline';");
    testParse("true;");
    testParse("false;");

    // Array literals
    testParse("[];");
    testParse("[1];");
    testParse("[1,a];");
    testParse("[1 , a];");
    testParse("[1,a, ];");
    testParse("[ 1,\na ];");

    // Object literals
    testParse("var x = {x:3};");
    testParse("var x = {x:3,y:2};");
    testParse("var x = {x:3,y:2+z};");
    testParse("var x = {x:3,y:2+z,};");

    // Comments
    testParse("1; // comment");
    testParse("[ 1//comment\n,a ];");
    testParse("1 /* comment */ + x;");
    testParse("1 /* // comment */ + x;");

    // Unary and binary expressions
    testParse("-1;");
    testParse("-x + 2;");
    testParse("x + -1;");
    testParse("a + b;");
    testParse("a + b + c;");
    testParse("a + b - c;");
    testParse("a + b * c + d;");
    testParse("a || b || c;");
    testParse("a && b;");
    testParse("(a);");
    testParse("(b ) ;");
    testParse("(a + b);");
    testParse("(a + (b + c));");
    testParse("((a + b) + c);");
    testParse("(a + b) * (c + d);");

    // Member expression
    testParse("a.b;");
    testParse("a.b + c;");

    // Array indexing
    testParse("a[0];");
    testParse("a[b];");
    testParse("a[b+2];");
    testParse("a[2*b+1];");

    // If statement
    testParse("if (1) 2; ");
    testParse("if (1) return 2;");
    testParse("if (!x) return 1; else return 2;");
    testParse("if (x <= 2) return 0; ");
    testParse("if (x == 1) return 2; ");
    testParse("if (typeof x == 'string') return 2; ");
    testParse("if ('foo' in obj) return 1;");

    // For loop
    testParse("for (a; b; c) d;");
    testParse("for (a; b; c) continue;");
    testParse("for (a; b; c) break;");
    testParse("for (;;) d;");
    testParse("for (i = 0; i < 10; i = i + 1) x;");

    // Assignment
    testParse("x = 1;");
    testParse("x = -1;");
    testParse("a.b = x + y;");
    testParse("x = y = 1;");
    testParse("var x = 3;");
    testParse("x += 3;");

    // Call expressions
    testParse("a();");
    testParse("a(b);");
    testParse("a(b,c);");
    testParse("a(b,c+1);");
    testParse("a(b,c+1,);");
    testParse("x + a(b,c+1);");
    testParse("x + a(b,c+1) + y;");
    testParse("a(); b();");

    // Package import
    testParse("var io = import 'core/io/0';");

    // Inline IR
    testParse("$add_i32(1, 2);");

    // Assert statement
    testParse("assert(x);");
    testParse("assert(x, 'foo');");

    // Function expression
    testParse("function () { return 0; }; ");
    testParse("function (x) {return x;};");
    testParse("function foo(x) { return x; };");
    testParse("function (x,y) { return x; };");
    testParse("function (x,y,) { return x; };");
    testParse("function (x,y) { return x+y; };");
    testParse("obj.method = function (this, x) { this.x = x; }; ");

    // Sequence/block expression
    testParse("{ 1; 2; }");
    testParse("function (x) { print(x); print(y); };");
    testParse("function (x) { var y = x + 1; print(y); };");

    // Method calls
    testParse("o:foo();");
    testParse("o:foo(1,2);");
    testParse("x + o:foo(1,2);");
};

// Run the parser tests
testParser();
