#pragma once

#include <string>
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

    /// Peek at a character from the input
    char peekCh();

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
Operator information structure
*/
struct OpInfo
{
    /// Operator string (e.g. "+")
    std::string str;

    /// Closing string (optional)
    std::string closeStr;

    /// Operator arity
    int arity;

    /// Precedence level
    int prec;

    /// Associativity, left-to-right or right-to-left ('l' or 'r')
    char assoc;

    /// Non-associative flag (e.g.: - and / are not associative)
    bool nonAssoc;

    /// Flag indicating a binary operator can be folded into an assignment
    bool foldAssign;
};

/// Operator definitions
extern const OpInfo OP_MEMBER;
extern const OpInfo OP_INDEX;
extern const OpInfo OP_OBJ_EXT;
extern const OpInfo OP_M_CALL;
extern const OpInfo OP_CALL;
extern const OpInfo OP_NEG;
extern const OpInfo OP_NOT;
extern const OpInfo OP_TYPEOF;
extern const OpInfo OP_ADD;
extern const OpInfo OP_SUB;
extern const OpInfo OP_MUL;
extern const OpInfo OP_DIV;
extern const OpInfo OP_MOD;
extern const OpInfo OP_LT;
extern const OpInfo OP_LE;
extern const OpInfo OP_GT;
extern const OpInfo OP_GE;
extern const OpInfo OP_IN;
extern const OpInfo OP_INSTOF;
extern const OpInfo OP_EQ;
extern const OpInfo OP_NE;
extern const OpInfo OP_BIT_AND;
extern const OpInfo OP_BIT_XOR;
extern const OpInfo OP_BIT_OR;
extern const OpInfo OP_BIT_NOT;
extern const OpInfo OP_BIT_SHL;  // shift left
extern const OpInfo OP_BIT_SHR;  // sign-extending shift right
extern const OpInfo OP_BIT_USHR; // unsigned shift right
extern const OpInfo OP_AND;
extern const OpInfo OP_OR;
extern const OpInfo OP_ASSIGN;

/**
Base class for all AST nodes
*/
class ASTNode
{
public:

    virtual ~ASTNode() {}
};

class ASTExpr : public ASTNode
{
public:

    virtual ~ASTExpr() {}
};

class IntExpr : public ASTExpr
{
public:

    IntExpr(int64_t val): val(val) {}
    virtual ~IntExpr() {}

    int64_t val;
};

class FloatExpr : public ASTExpr
{
public:

    FloatExpr(float val): val(val) {}
    virtual ~FloatExpr() {}

    float val;
};

class StringExpr : public ASTExpr
{
public:

    StringExpr(std::string val): val(val) {}
    virtual ~StringExpr() {}

    std::string val;
};

/// Identifier expression
class IdentExpr : public ASTExpr
{
public:

    IdentExpr(std::string name): name(name) {}
    virtual ~IdentExpr() {}

    std::string name;
};

class UnOpExpr : public ASTExpr
{
public:

    UnOpExpr(const OpInfo* op, ASTExpr* expr)
    : op(op),
      expr(expr)
    {
    }

    virtual ~UnOpExpr() {}

    const OpInfo* op;

    ASTExpr* expr;
};

class BinOpExpr : public ASTExpr
{
public:

    BinOpExpr(const OpInfo* op, ASTExpr* lhsExpr, ASTExpr* rhsExpr)
    : op(op),
      lhsExpr(lhsExpr),
      rhsExpr(rhsExpr)
    {
    }

    virtual ~BinOpExpr() {}

    const OpInfo* op;

    ASTExpr* lhsExpr;
    ASTExpr* rhsExpr;
};

class ArrayExpr : public ASTExpr
{
public:

    ArrayExpr(std::vector<ASTExpr*> exprs)
    : exprs(exprs)
    {
    }

    virtual ~ArrayExpr() {}

    std::vector<ASTExpr*> exprs;
};

class ObjectExpr : public ASTExpr
{
public:

    ObjectExpr(
        std::vector<std::string> names,
        std::vector<ASTExpr*> exprs
    )
    : names(names),
      exprs(exprs)
    {
    }

    virtual ~ObjectExpr() {}

    std::vector<std::string> names;
    std::vector<ASTExpr*> exprs;
};

class CallExpr : public ASTExpr
{
public:

    CallExpr(
        ASTExpr* funExpr,
        std::vector<ASTExpr*> argExprs
    )
    : funExpr(funExpr),
      argExprs(argExprs)
    {
    }

    virtual ~CallExpr() {}

    ASTExpr* funExpr;
    std::vector<ASTExpr*> argExprs;
};

class MethodCallExpr : public ASTExpr
{
public:

    MethodCallExpr(
        ASTExpr* baseExpr,
        std::string nameStr,
        std::vector<ASTExpr*> argExprs
    )
    : baseExpr(baseExpr),
      nameStr(nameStr),
      argExprs(argExprs)
    {
    }

    virtual ~MethodCallExpr() {}

    ASTExpr* baseExpr;
    std::string nameStr;
    std::vector<ASTExpr*> argExprs;
};

class IRExpr : public ASTExpr
{
public:

    IRExpr(
        std::string opName,
        std::vector<ASTExpr*> argExprs
    )
    : opName(opName),
      argExprs(argExprs)
    {
    }

    virtual ~IRExpr() {}

    std::string opName;
    std::vector<ASTExpr*> argExprs;
};

class ImportExpr : public ASTExpr
{
public:

    ImportExpr(std::string pkgName)
    : pkgName(pkgName)
    {
    }

    virtual ~ImportExpr() {}

    std::string pkgName;
};

class ASTStmt : public ASTNode
{
public:

    virtual ~ASTStmt() {}
};

class BlockStmt : public ASTStmt
{
public:

    BlockStmt(std::vector<ASTStmt*> stmts)
    : stmts(stmts)
    {
    }

    virtual ~BlockStmt() {}

    std::vector<ASTStmt*> stmts;
};

class VarStmt : public ASTStmt
{
public:

    VarStmt(
        std::string identName,
        ASTExpr* initExpr
    )
    : identName(identName),
      initExpr(initExpr)
    {
    }

    std::string identName;
    ASTExpr* initExpr;
};

class IfStmt : public ASTStmt
{
public:

    IfStmt(
        ASTExpr* testExpr,
        ASTStmt* thenStmt,
        ASTStmt* elseStmt
    )
    : testExpr(testExpr),
      thenStmt(thenStmt),
      elseStmt(elseStmt)
    {
    }

    virtual ~IfStmt() {}

    ASTExpr* testExpr;
    ASTStmt* thenStmt;
    ASTStmt* elseStmt;
};

class ForStmt : public ASTStmt
{
public:

    ForStmt(
        ASTStmt* initStmt,
        ASTExpr* testExpr,
        ASTExpr* incrExpr,
        ASTStmt* bodyStmt
    )
    : initStmt(initStmt),
      testExpr(testExpr),
      incrExpr(incrExpr),
      bodyStmt(bodyStmt)
    {
    }

    virtual ~ForStmt() {}

    ASTStmt* initStmt;
    ASTExpr* testExpr;
    ASTExpr* incrExpr;
    ASTStmt* bodyStmt;
};

class TryStmt : public ASTStmt
{
public:

    TryStmt(
        ASTStmt* bodyStmt,
        ASTStmt* catchStmt,
        std::string catchVar
    )
    : bodyStmt(bodyStmt),
      catchStmt(catchStmt),
      catchVar(catchVar)
    {
    }

    virtual ~TryStmt() {}

    ASTStmt* bodyStmt;
    ASTStmt* catchStmt;
    std::string catchVar;
};

class ReturnStmt : public ASTStmt
{
public:

    ReturnStmt(ASTExpr* expr)
    : expr(expr)
    {
    }

    virtual ~ReturnStmt() {}

    ASTExpr* expr;
};

class ThrowStmt : public ASTStmt
{
public:

    ThrowStmt(ASTExpr* expr)
    : expr(expr)
    {
    }

    virtual ~ThrowStmt() {}

    ASTExpr* expr;
};

/// Loop break statement
class BreakStmt : public ASTStmt
{
public:

    BreakStmt()
    {
    }

    virtual ~BreakStmt() {}
};

/// Loop continue statement
class ContStmt : public ASTStmt
{
public:

    ContStmt()
    {
    }

    virtual ~ContStmt() {}
};

class ExprStmt : public ASTStmt
{
public:

    ExprStmt(ASTExpr* expr)
    : expr(expr)
    {
    }

    virtual ~ExprStmt() {}

    ASTExpr* expr;
};

/// IR statement, corresponds to IR instructions producing no output
class IRStmt : public ASTStmt
{
public:

    IRStmt(
        std::string instrName,
        std::vector<ASTExpr*> argExprs
    )
    : instrName(instrName),
      argExprs(argExprs)

    {
    }

    IRStmt(
        std::string instrName,
        ASTExpr* arg0
    )
    : instrName(instrName)
    {
        argExprs.push_back(arg0);
    }

    virtual ~IRStmt() {}

    std::string instrName;
    std::vector<ASTExpr*> argExprs;
};

class FunExpr : public ASTExpr
{
public:

    FunExpr(
        std::string name,
        ASTStmt* body,
        std::vector<std::string> params
    )
    : name(name),
      params(params),
      body(body)
    {
    }

    virtual ~FunExpr() {}

    std::string name;

    std::vector<std::string> params;
    
    ASTStmt* body;

};

FunExpr* parseString(std::string str, std::string srcName);

FunExpr* parseFile(std::string fileName);

void testParser();
