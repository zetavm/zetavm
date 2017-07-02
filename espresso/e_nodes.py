"""This file contains all the classes which describe an AST Node"""

class ASTNode(object):
    """Basic AST Node"""
    pass
class ASTExpr(ASTNode):
    """Basic expression"""
    pass
class ASTStmt(ASTNode):
    """Basic statement"""
    pass
class IntExpr(ASTExpr):
    """Integer expression"""
    def __init__(self, val):
        self.val = val
class FloatExpr(ASTExpr):
    """Float expression"""
    def __init__(self, val):
        self.val = val
class StringExpr(ASTExpr):
    """String expression"""
    def __init__(self, val):
        self.val = val
class IdentExpr(ASTExpr):
    """Identifier expression"""
    def __init__(self, name):
        self.name = name
class UnOpExpr(ASTExpr):
    """Expression made up of an operator
    with arity equals to 1 and one expression
    """
    def __init__(self, op, expr):
        self.op = op
        self.expr = expr
class BinOpExpr(ASTExpr):
    """Expression made up of an operator
    with arity equals to 2 and two expressions
    """
    def __init__(self, op, lhs_expr, rhs_expr):
        self.op = op
        self.lhs_expr = lhs_expr
        self.rhs_expr = rhs_expr
class ArrayExpr(ASTExpr):
    """Array expression"""
    def __init__(self, exprs):
        self.exprs = exprs
class ObjectExpr(ASTExpr):
    """Object expression"""
    def __init__(self, names, exprs):
        self.names = names
        self.exprs = exprs
class CallExpr(ASTExpr):
    """Function calling expression"""
    def __init__(self, fun_expr, arg_exprs):
        self.fun_expr = fun_expr
        self.arg_exprs = arg_exprs
class IRExpr(ASTExpr):
    """IR expression"""
    def __init__(self, op_name, arg_exprs):
        self.op_name = op_name
        self.arg_exprs = arg_exprs
class ImportStmt(ASTStmt):
    """Import statement"""
    def __init__(self, paths):
        self.paths = paths
class ExportStmt(ASTStmt):
    """Export statement"""
    def __init__(self, names):
        self.names = names
class BlockStmt(ASTStmt):
    """A group of statements"""
    def __init__(self, stmts):
        self.stmts = stmts
class DeclStmt(ASTStmt):
    """Declaration statement"""
    def __init__(self, name, init_expr):
        self.name = name
        self.init_expr = init_expr
class IfStmt(ASTStmt):
    """If statement"""
    def __init__(self, test_expr, then_stmt, else_stmt):
        self.test_expr = test_expr
        self.then_stmt = then_stmt
        self.else_stmt = else_stmt
class ReturnStmt(ASTStmt):
    """Return statement"""
    def __init__(self, expr):
        self.expr = expr
class ExprStmt(ASTStmt):
    """Expression statement. Evaluating an expression with no output"""
    def __init__(self, expr):
        self.expr = expr
class IRStmt(ASTStmt):
    """IR statement. Evaluating an IR with no output"""
    def __init__(self, op_name, arg_exprs):
        self.op_name = op_name
        self.arg_exprs = arg_exprs
class FunExpr(ASTExpr):
    """Function expression"""
    def __init__(self, name, body, params):
        self.name = name
        self.body = body
        self.params = params


