#pragma once

#include <cstdlib>
#include <string>
#include <vector>

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

class ASTStmt : public ASTNode
{
};

class IdentExpr : public ASTExpr
{
public:
    IdentExpr(
        std::string name
    )
    : name(name)
    {
    }

    std::string name;
};

class FunExpr : public ASTExpr
{
public:
    FunExpr(
        IdentExpr name,
        std::vector<IdentExpr*> params,
        ASTStmt* bodyStmt
    )
    : name(name),
      params(params),
      bodyStmt(bodyStmt)
    {
    }

    IdentExpr name;

    std::vector<IdentExpr*> params;

    ASTStmt* bodyStmt;
};

class BlockStmt : public ASTStmt
{
public:
    BlockStmt(
        std::vector<ASTStmt*> stmts
    )
    : stmts(stmts)
    {
    }

    std::vector<ASTStmt*> stmts;
};

class ASTProgram : public FunExpr
{
public:
    ASTProgram(
        std::vector<ASTStmt*> stmts
    )
    : FunExpr(std::string(""), {}, new BlockStmt(stmts))
    {
    }
};
