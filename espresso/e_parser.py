"""Parsing espresso files"""

from e_nodes import *
from e_error import ParseError
from e_input import Input
from e_operators import *

def parse_string_literal(input_handler, end_ch):
    string = ""
    while True:
        if input_handler.eof():
            raise ParseError(input_handler, "end of input_handler inside string literal")
        ch = input_handler.read_ch()
        if ch == end_ch:
            break
        if ch == '\r' or ch == '\n':
            raise ParseError(input_handler, "newline in string literal")
        string += ch
    return StringExpr(string)


def parse_float(input_handler, literal):
    """Parse a float"""
    while True:
        next_ch = input_handler.peek_ch()
        if next_ch.isdigit() or next_ch == 'e' or next_ch == '.':
            literal += input_handler.read_ch()
        else:
            break
    input_handler.expect('f')
    return FloatExpr(literal)

def parse_num(input_handler):
    """Parse a number"""
    literal = ""
    while True:
        ch = input_handler.read_ch()
        if not ch.isdigit():
            raise ParseError(input_handler, "expected digit")
        literal += ch
        if not input_handler.peek_ch().isdigit():
            break
    if input_handler.peek_ch() == '.' or input_handler.peek_ch() == 'e':
        return parse_float(input_handler, literal)
    if len(literal) > 64:
        raise ParseError(input_handler, "int is too long")
    return IntExpr(literal)

def parse_obj_literal(input_handler):
    """Parsing an object literal"""
    field_names = []
    val_exprs = []
    while True:
        if input_handler.match_ws('}'):
            break
        field = parse_ident_expr(input_handler)
        input_handler.expect_ws(':')
        expr = parse_expr(input_handler)
        field_names.append(field)
        val_exprs.append(expr)
        if input_handler.match_ws('}'):
            break
        input_handler.expect_ws(',')
    return ObjectExpr(field_names, val_exprs)

def parse_expr_list(input_handler, end_str):
    """Parsing a list of expression"""
    exprs = []
    while True:
        if input_handler.match_ws(end_str):
            break
        expr = parse_expr(input_handler)
        exprs.append(expr)
        if input_handler.match_ws(end_str):
            break
        input_handler.expect_ws(',')
    return exprs

def parse_ident_expr(input_handler):
    """Parse and identifier"""
    ident = ""
    first_ch = input_handler.peek_ch()
    if first_ch != '_' and not first_ch.isalpha():
        raise ParseError(input_handler, "invalid first character for identifier")
    while True:
        ch = input_handler.peek_ch()
        if not ch.isalnum() and ch != '_':
            break
        ident += input_handler.read_ch()
    if len(ident) == 0:
        raise ParseError(input_handler, "invalid identifier")
    return ident

def parse_fun_expr(input_handler):
    """Parsing a function expression"""
    input_handler.expect_ws('(')
    params = []
    while True:
        if input_handler.match_ws(')'):
            break
        param = parse_ident_expr(input_handler)
        params.append(param)
        if input_handler.match_ws(')'):
            break
        input_handler.expect_ws(',')
    input_handler.expect_ws('{')
    body = parse_block_stmt(input_handler, '}')
    return FunExpr(None, body, params)

def parse_expr_prec(input_handler, min_prec):
    """
    The first call has min precedence 0
    Each call loops to grab everything of the current precedence or
    greater and builds a left-sided subtree out of it, associating
    operators to their left operand
    If an operator has less than the current precedence, the loop
    breaks, returning us to the previous loop level, this will attach
    the atom to the previous operator (on the right)
    If an operator has the mininum precedence or greater, it will
    associate the current atom to its left and then parse the rhs
    """
    lhs_expr = parse_atom(input_handler)
    while True:
        input_handler.eat_ws()
        op = match_op(input_handler, min_prec, False)
        if op is None:
            break
        next_min_prec = op.prec
        if op.assoc == 'l':
            if op.close_str is not None:
                next_min_prec = 0
            else:
                next_min_prec = op.prec + 1
        if op == OP_CALL:
            arg_exprs = parse_expr_list(input_handler, ')')
            lhs_expr = CallExpr(lhs_expr, arg_exprs)
        elif op.arity == 2:
            rhs_expr = parse_expr_prec(input_handler, next_min_prec)
            lhs_expr = BinOpExpr(op, lhs_expr, rhs_expr)
            if op.close_str is not None and not input_handler.match_ws(op.close_str):
                raise ParseError(input_handler, "expecting: " + op.close_str)
        else:
            raise ParseError(input_handler, "unhandled operator")
    return lhs_expr


def parse_expr(input_handler):
    """Parse an expression"""
    return parse_expr_prec(input_handler, 0)

def match_op(input_handler, min_prec, pre_unary):
    """matching operators"""
    ch = input_handler.peek_ch()
    op = None
    if ch == '(':
        op = OP_CALL
    elif ch == '+':
        op = OP_ADD
    elif ch == '-':
        if pre_unary:
            op = OP_NEG
        else:
            op = OP_SUB
    elif ch == '*':
        op = OP_MUL
    elif ch == '/':
        op = OP_DIV
    elif ch == '%':
        op = OP_MOD
    elif ch == '<':
        if input_handler.next("<="):
            op = OP_LE
        elif input_handler.next("<"):
            op = OP_LT
    elif ch == '>':
        if input_handler.next(">="):
            op = OP_GE
        elif input_handler.next(">"):
            op = OP_GT
    elif ch == '=':
        op = OP_EQ
    elif ch == ':':
        if input_handler.next(":="):
            op = OP_ASSIGN
    elif ch == '!':
        if input_handler.next('!='):
            op = OP_NE
    elif ch == 'n':
        if input_handler.next('not'):
            op = OP_NOT
    elif ch == 'o':
        if input_handler.next('or'):
            op = OP_OR
    elif ch == 'a':
        if input_handler.next('and'):
            op = OP_AND
    elif ch == 't':
        if input_handler.next('typeof'):
            op = OP_TYPEOF

    if op is not None:
        if op.prec < min_prec or (pre_unary and op.arity != 1) or (pre_unary and op.assoc != 'r'):
            return None
        assert input_handler.match(op.operator)
    return op

def parse_atom(input_handler):
    """Parsing an atomic expression"""
    input_handler.eat_ws()
    if input_handler.peek_ch().isdigit():
        return parse_num(input_handler)
    if input_handler.match('"'):
        return parse_string_literal(input_handler, '"')
    if input_handler.match("'"):
        return parse_string_literal(input_handler, "'")
    if input_handler.match('['):
        return ArrayExpr(parse_expr_list(input_handler, "]"))
    if input_handler.match("{"):
        return parse_obj_literal(input_handler)
    if input_handler.match("("):
        expr = parse_expr(input_handler)
        input_handler.expect_ws(")")
        return expr
    op = match_op(input_handler, 0, True)
    if op is not None:
        expr = parse_expr_prec(input_handler, op.prec)
        return UnOpExpr(op, expr)
    if input_handler.peek_ch().isalnum():
        if input_handler.match_kw("fun"):
            return parse_fun_expr(input_handler)
        return IdentExpr(parse_ident_expr(input_handler))
    if input_handler.match("$"):
        op_name = parse_ident_expr(input_handler)
        input_handler.expect('(')
        arg_exprs = parse_expr_list(input_handler, ')')
        return IRExpr(op_name, arg_exprs)
    raise ParseError(input_handler, "invalid expression")

def parse_stmt(input_handler):
    """Parse a statement"""

    # eat whitespace
    input_handler.eat_ws()

    # a block statement
    if input_handler.match("{"):
        return parse_block_stmt(input_handler, "}")
    # a variable statement
    if input_handler.match_kw("let"):
        input_handler.eat_ws()
        ident = parse_ident_expr(input_handler)

        input_handler.expect_ws(":=")

        init_expr = parse_expr(input_handler)
        input_handler.expect_ws(";")
        return DeclStmt(ident, init_expr)
    if input_handler.match_kw("if"):
        return parse_if_stmt(input_handler)
    if input_handler.match_kw("assert"):
        input_handler.expect_ws("(")
        test_expr = parse_expr(input_handler)
        err_msg = StringExpr("assertion failed")
        if input_handler.match_ws(","):
            err_msg = parse_expr(input_handler)
        input_handler.expect_ws(")")
        input_handler.expect(";")
        return IfStmt(
            test_expr,
            BlockStmt([]),
            IRStmt("abort", [err_msg])
        )
    if input_handler.match_kw("return"):
        if input_handler.match_ws(";"):
            return ReturnStmt(IdentExpr("null"))
        expr = parse_expr(input_handler)
        input_handler.expect_ws(";")
        return ReturnStmt(expr)
    if input_handler.match_kw("import"):
        input_handler.expect_ws("(")
        paths = []
        while True:
            if input_handler.match_ws(")"):
                break
            if input_handler.match_ws("'"):
                path = parse_string_literal(input_handler, "'")
                name = None
                input_handler.expect_ws("as")
                input_handler.eat_ws()
                name = parse_ident_expr(input_handler)
                paths.append((path, name))
            else:
                input_handler.expect_ws('"')
                path = parse_string_literal(input_handler, '"')
                name = None
                input_handler.expect_ws("as")
                input_handler.eat_ws()
                name = parse_ident_expr(input_handler)
                paths.append((path, name))
            if input_handler.match_ws(")"):
                break
            input_handler.expect_ws(",")
        return ImportStmt(paths)
    if input_handler.match_kw("export"):
        input_handler.expect_ws("(")
        names = []
        while True:
            if input_handler.match_ws(")"):
                break
            input_handler.eat_ws()
            name = parse_ident_expr(input_handler)
            names.append(name)
            if input_handler.match_ws(")"):
                break
            input_handler.expect_ws(',')
        return ExportStmt(names)
    if input_handler.match("$"):
        op_name = parse_ident_expr(input_handler)
        input_handler.expect("(")
        arg_exprs = parse_expr_list(input_handler, ")")
        input_handler.expect_ws(";")
        return IRStmt(op_name, arg_exprs)
    expr = parse_expr(input_handler)
    input_handler.expect_ws(";")
    return ExprStmt(expr)

def parse_if_stmt(input_handler):
    """Parse an if statement"""
    input_handler.expect_ws('(')
    test_expr = parse_expr(input_handler)
    input_handler.expect(')')
    then_stmt = parse_stmt(input_handler)
    else_stmt = BlockStmt([])
    if input_handler.match_kw("else"):
        else_stmt = parse_stmt(input_handler)
    return IfStmt(test_expr, then_stmt, else_stmt)

def parse_block_stmt(input_handler, end_str):
    """Parse a block statement"""
    stmts = []
    while True:
        input_handler.eat_ws()
        if end_str == "" and input_handler.eof() or end_str != "" and input_handler.match(end_str):
            break
        stmt = parse_stmt(input_handler)
        stmts.append(stmt)
    return BlockStmt(stmts)

def parse_unit(input_handler):
    """Parse a source unit from an input_handler object"""
    if input_handler.match('#language'):
        input_handler.expect_ws('"')
        while True:
            if input_handler.eof():
                raise ParseError(input_handler, "end of input_handler inside language declaration")
            if input_handler.read_ch() == '"':
                break
    block_stmt = parse_block_stmt(input_handler, "")
    return FunExpr("unit", block_stmt, [])



def parse_string(string, src_name):
    """Parse a string and returns a function"""
    input_handler_handler = Input(src_name, string)
    return parse_unit(input_handler_handler)

def test_parse(string):
    """Testing success"""
    parse_string(string, "test success")

def test_parse_fail(string):
    """Testing failure"""
    try:
        parse_string(string, "test fail")
    except ParseError:
        return
    raise Exception("Parsing did not fail for: " + string)

def test_parser():
    """Testing"""
    print("parser tests")
    # ids
    test_parse("foo;")
    test_parse("   foo    ;")
    test_parse("  foo;")
    # literals
    test_parse("42;")
    test_parse("42.42f;")
    test_parse("42e42f;")
    test_parse("42.4e4f;")
    test_parse('"test me!";')
    test_parse('"test me! \'lol\'";')
    test_parse("'test \\n newline';")
    test_parse("true;")
    test_parse("false;")
    test_parse_fail("invalid \\iesc")
    # arrays
    test_parse("[];")
    test_parse("[1,2];")
    test_parse("[1,e];")
    test_parse("['aa', 'bb', 4.4f];")
    test_parse("[1, \n3];")
    test_parse_fail("[,];")

    # objects
    test_parse("let a := {a:2, b:'c'};")
    test_parse_fail("a := {,}")

    # Comments
    test_parse("1; // comment")
    test_parse("[ 1//comment\n,a ];")
    test_parse_fail("1; // comment\n#1")

    # Unary and binary expressions
    test_parse("-1;")
    test_parse("-x + 2;")
    test_parse("x + -1;")
    test_parse("a + b;")
    test_parse("a + b + c;")
    test_parse("a + b - c;")
    test_parse("a + b * c + d;")
    test_parse("a or b or c;")
    test_parse("(a);")
    test_parse("(b ) ;")
    test_parse("(a + b);")
    test_parse("(a + (b + c));")
    test_parse("((a + b) + c);")
    test_parse("(a + b) * (c + d);")
    test_parse_fail("*a;")
    test_parse_fail("a*;")
    test_parse_fail("a # b;")
    test_parse_fail("a +;")
    test_parse_fail("a + b # c;")
    test_parse_fail("(a;")
    test_parse_fail("(a + b))")
    test_parse_fail("((a + b)")

    # Assignment
    test_parse("x := 1;")
    test_parse("x := -1;")
    test_parse("x := y := 1;")
    test_parse("let x := 3;")
    test_parse_fail("let")
    test_parse_fail("var")
    test_parse_fail("var x")
    test_parse_fail("var x:=")
    test_parse_fail("let +")
    test_parse_fail("let 3")

    # Call expressions
    test_parse("a();")
    test_parse("a(b);")
    test_parse("a(b,c);")
    test_parse("a(b,c+1);")
    test_parse("a(b,c+1,);")
    test_parse("x + a(b,c+1);")
    test_parse("x + a(b,c+1) + y;")
    test_parse("a(); b();")
    test_parse_fail("a(b c+1);")

    # package import
    test_parse("import( 'package/math' as math )")
    test_parse("import( 'package/math' as m )")
    test_parse_fail("import( '1' as one, '2', '3' as three )")

    # export statement
    test_parse("export(a, b)")
    test_parse("export(c)")
    test_parse_fail("export(1)")
    test_parse_fail("export('a')")

    # Inline IR
    test_parse("let s := $add_i32(1, 2);")
    test_parse("$array_push(arr, val);")

    # If statements
    test_parse("if (true) {x + 1;}")
    test_parse("if (x) {x+1;} else {y+1;}")

    # Assert statement
    test_parse("assert(x);")
    test_parse("assert(x, 'foo');")
    test_parse_fail("assert(x, 'foo', z);")

    # Function expression
    test_parse("fun () { return 0; }; ")
    test_parse("fun (x) {return x;};")
    test_parse("fun (x) { return x; };")
    test_parse("fun (x,y) { return x; };")
    test_parse("fun (x,y,) { return x; };")
    test_parse("fun (x,y) { return x+y; };")
    test_parse_fail("fun (x,y)")

    # Sequence/block expression
    test_parse("{ 1; 2; }")
    test_parse("fun (x) { print(x); print(y); };")
    test_parse("fun (x) { let y := x + 1; print(y); };")
    test_parse_fail("{ a, }")
    test_parse_fail("{ a, b }")
    test_parse_fail("fun () { a, };")

    # There is no empty statement
    test_parse_fail(";")
