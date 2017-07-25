"""Code generation"""

last_id = 0

global_variables = {}

from e_nodes import *
from e_error import EspressoRuntimeError
from e_operators import *

class Function(object):
    def __init__(self, params, entry_block):
        global last_id
        self.params = params
        self.entry_block = entry_block
        self.id = last_id
        last_id += 1
        self.locals = {}
        self.local_no = 1 + len(params)
    def get_handle(self):
        return "fun_" + str(self.id)
    def register_local_decl(self, name):
        self.locals[name] = self.local_no
        self.local_no += 1
        return self.locals[name]
    def register_global_decl(self, name):
        self.locals[name] = 1
        global_variables[name] = 1
    def has_decl(self, name):
        return self.locals.has_key(name)
    def get_local(self, name):
        return self.locals[name]
    def finalise(self, result):
        param_str = "["
        for index in range(len(self.params)):
            param_str += "\'" + self.params[index] + "\'"
            if index < len(self.params) -1:
                param_str += ", "
        param_str += "]"
        out = self.get_handle() + " = {\n"
        out += "  entry:@" + self.entry_block.get_handle() + ",\n"
        out += "  params:" + param_str + ",\n"
        out += "  num_locals:" + str(self.local_no) + ",\n"
        out += "};\n\n"

        self.entry_block = None
        result.append(out)

class Block(object):
    def __init__(self):
        global last_id
        self.id = last_id
        last_id += 1
        self.instrs = []
        self.finalised = False
    def get_handle(self):
        return "block_" + str(self.id)
    def is_finalised(self):
        return self.finalised
    def add(self, string):
        if self.finalised:
            raise EspressoRuntimeError("block is finalised")
        self.instrs.append("{ " + string + " }")
    def finalise(self, result):
        assert not self.finalised
        out = self.get_handle() + " = {\n"
        out += "  instrs: [\n"
        for instr in self.instrs:
            out += "    " + instr + ",\n"
        out += "  ]\n"
        out += "};\n\n"
        self.finalised = True
        result.append(out)



class CodeGenCtx(object):
    def __init__(self, result, function, block, is_global):
        self.function = function
        self.block = block
        self.result = result
        self.is_global = is_global
    def sub_ctx(self, block):
        return CodeGenCtx(
            self.result,
            self.function,
            block,
            self.is_global
        )
    def merge(self, block):
        self.block = block
    def add_op(self, string):
        self.block.add(string)
    def add_branch(self, op, name0="", target0=None, name1="", target1=None, extra_args=""):
        args = (", " if len(extra_args) > 0 else "") + extra_args
        if target0 is not None and target1 is not None:
            self.add_op("op:'" + op + "', " +
                        name0 + ":@" + target0.get_handle() + ", " +
                        name1 + ":@" + target1.get_handle() + args)
        elif target0 is not None:
            self.add_op("op:'" + op + "', " + name0 + ":@" + target0.get_handle() + args)
        else:
            self.add_op("op:'" + op + "'" + args)

        self.block.finalise(self.result)

def gen_unit(unit_ast):
    result = ["#zeta-image\n\n"]
    entry_block = Block()
    unit_fun = Function([], entry_block)
    ctx = CodeGenCtx(result, unit_fun, entry_block, True)
    result += "exports_obj = { init: @" + unit_fun.get_handle() + " };\n"
    result += "global_obj = { exports: @exports_obj };\n\n"
    gen_stmt(ctx, unit_ast.body)

    if not ctx.block.is_finalised():
        ctx.add_op("op:'push', val:$true")
        ctx.add_branch("ret")
    unit_fun.finalise(result)
    result += "@exports_obj;\n"
    return ''.join(result)

# def native_call(ctx, fun_name, num_args):
#     ctx.add_op("op:'push', val:@" + fun_name + "_func")
#     cont_block = Block()
#     ctx.add_branch(
#         "call",
#         "ret_to",
#         cont_block,
#         None,
#         None,
#         "num_args:" + str(num_args)
#     )
#     ctx.merge(cont_block)

def runtime_call(ctx, fun_name, num_args):
    ctx.add_op("op:'push', val:@global_obj")
    ctx.add_op("op:'push', val:'rt_" + fun_name + "'")
    ctx.add_op("op: 'get_field'")
    cont_block = Block()
    ctx.add_branch(
        "call",
        "ret_to",
        cont_block,
        None,
        None,
        "num_args:" + str(num_args)
    )
    ctx.merge(cont_block)

def gen_expr(ctx, expr):
    if isinstance(expr, IntExpr):
        ctx.add_op("op:'push', val:" + str(expr.val))
    elif isinstance(expr, FloatExpr):
        ctx.add_op("op:'push', val:" + str(expr.val))
    elif isinstance(expr, StringExpr):
        esc_str = ""
        for char in expr.val:
            esc_str += char
        ctx.add_op("op:'push', val:'" + esc_str + "'")
    elif isinstance(expr, IdentExpr):
        if expr.name == 'true':
            ctx.add_op("op:'push', val:$true")
        elif expr.name == 'false':
            ctx.add_op("op:'push', val:$false")
        elif expr.name == 'null':
            ctx.add_op("op:'push', val:$undef")
        elif expr.name == "map":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "get":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "push":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "set":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "has":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "repeat":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "len":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "print":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "reduce":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif expr.name == "filter":
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'rt_" + expr.name + "'")
            ctx.add_op("op: 'get_field'")
        elif ctx.function.has_decl(expr.name):
            if ctx.is_global:
                ctx.add_op("op:'push', val:@global_obj")
                ctx.add_op("op:'push', val:'" + expr.name + "'")
                ctx.add_op("op:'get_field'")
                return
            local_id = ctx.function.get_local(expr.name)
            ctx.add_op("op:'get_local', idx:" + str(local_id))
        elif expr.name in ctx.function.params:
            params = ctx.function.params
            param_id = params.index(expr.name)
            ctx.add_op("op:'get_local', idx:" + str(param_id))
        elif global_variables.has_key(expr.name):
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'" + expr.name + "'")
            ctx.add_op("op:'get_field'")
        else:
            raise EspressoRuntimeError("No variable called: " + expr.name)
    elif isinstance(expr, UnOpExpr):
        if expr.op == OP_NOT:
            gen_expr(ctx, expr.expr)
            runtime_call(ctx, "not", 1)
        elif expr.op == OP_NEG:
            ctx.add_op("op:'push', val:0")
            gen_expr(ctx, expr.expr)
            runtime_call(ctx, "sub", 2)
        else:
            raise EspressoRuntimeError("unhandled unary op")
    elif isinstance(expr, BinOpExpr):
        if expr.op == OP_ASSIGN:
            gen_assign(ctx, expr.lhs_expr, expr.rhs_expr)
        elif expr.op == OP_AND:
            gen_logical_and(ctx, expr.lhs_expr, expr.rhs_expr)
        elif expr.op == OP_OR:
            gen_logical_or(ctx, expr.lhs_expr, expr.rhs_expr)
        elif expr.op == OP_EQ:
            if isinstance(expr.lhs_expr, UnOpExpr):
                if expr.lhs_expr.op == OP_TYPEOF:
                    if isinstance(expr.rhs_expr, StringExpr):
                        gen_expr(ctx, expr.lhs_expr.expr)
                        ctx.add_op("op:'has_tag', tag:'" + expr.rhs_expr.val + "'")
            else:
                gen_expr(ctx, expr.lhs_expr)
                gen_expr(ctx, expr.rhs_expr)
                runtime_call(ctx, "eq", 2)
        elif expr.op == OP_NE:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "ne", 2)
        elif expr.op == OP_LT:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "lt", 2)
        elif expr.op == OP_LE:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "le", 2)
        elif expr.op == OP_GT:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "gt", 2)
        elif expr.op == OP_GE:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "ge", 2)
        elif expr.op == OP_ADD:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "add", 2)
        elif expr.op == OP_SUB:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "sub", 2)
        elif expr.op == OP_MUL:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "mul", 2)
        elif expr.op == OP_DIV:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            runtime_call(ctx, "div", 2)
        elif expr.op == OP_MOD:
            gen_expr(ctx, expr.lhs_expr)
            gen_expr(ctx, expr.rhs_expr)
            ctx.add_op("op:'mod_i32'")
    elif isinstance(expr, ObjectExpr):
        gen_obj_expr(ctx, expr)
    elif isinstance(expr, ArrayExpr):
        ctx.add_op("op:'push', val:" + str(len(expr.exprs)))
        ctx.add_op("op:'new_array'")

        # For each property
        for element in expr.exprs:
            # Duplicate the array value
            ctx.add_op("op:'dup', idx:0")

            # Evaluate the property value expression
            gen_expr(ctx, element)

            # Append the element to the array
            ctx.add_op("op:'array_push'")
    elif isinstance(expr, FunExpr):
        entry_block = Block()
        function = Function(expr.params, entry_block)
        fun_ctx = CodeGenCtx(ctx.result, function, entry_block, False)
        gen_stmt(fun_ctx, expr.body)
        if not fun_ctx.block.is_finalised():
            fun_ctx.add_op("op:'push', val:$undef")
            fun_ctx.add_branch("ret")
        function.finalise(ctx.result)
        ctx.add_op("op:'push', val:@" + function.get_handle())
    elif isinstance(expr, CallExpr):
        args = expr.arg_exprs
        for arg in args:
            gen_expr(ctx, arg)
        gen_expr(ctx, expr.fun_expr)
        cont_block = Block()
        ctx.add_branch("call", "ret_to", cont_block, None, None, "num_args:" + str(len(args)))
        ctx.merge(cont_block)
    elif isinstance(expr, IRExpr):
        args = expr.arg_exprs
        for arg in args:
            gen_expr(ctx, arg)
        ctx.add_op("op:'" + expr.op_name + "'")
    else:
        raise EspressoRuntimeError("wat")

def gen_obj_expr(ctx, expr):
    ctx.add_op("op:'push', val:" + str(len(expr.names)))
    ctx.add_op("op:'new_object'")
    for idx in range(len(expr.names)):
        name = expr.names[idx]
        val = expr.exprs[idx]
        ctx.add_op("op:'dup', idx:0")
        ctx.add_op("op:'push', val:'" + name + "'")
        gen_expr(ctx, val)
        ctx.add_op("op:'set_field'")

def gen_logical_or(ctx, lhs, rhs):
    or_block = Block()
    done_block = Block()
    gen_expr(ctx, lhs)
    ctx.add_op("op:'dup', idx:0")
    ctx.add_branch("if_true", "then", done_block, "else", or_block)

    or_ctx = ctx.sub_ctx(or_block)
    or_ctx.add_op("op:'pop'")
    gen_expr(or_ctx, rhs)
    or_ctx.add_branch("jump", "to", done_block)
    ctx.merge(done_block)

def gen_logical_and(ctx, lhs, rhs):
    and_block = Block()
    done_block = Block()
    gen_expr(ctx, lhs)
    ctx.add_op("op:'dup', idx:0")
    ctx.add_branch("if_true", "then", and_block, "else", done_block)

    and_ctx = ctx.sub_ctx(and_block)
    and_ctx.add_op("op:'pop'")
    gen_expr(and_ctx, rhs)
    and_ctx.add_branch("jump", "to", done_block)
    ctx.merge(done_block)

def gen_assign(ctx, lhs, rhs):
    if isinstance(lhs, IdentExpr):
        if ctx.function.has_decl(lhs.name):
            if ctx.is_global:
                gen_expr(ctx, rhs)
                ctx.add_op("op:'push', val:@global_obj")
                ctx.add_op("op:'push', val:'" + lhs.name + "'")
                ctx.add_op("op:'dup', idx:2")
                ctx.add_op("op:'set_field'")
                return
            local_id = ctx.function.get_local(lhs.name)
            gen_expr(ctx, rhs)
            ctx.add_op("op:'dup', idx:0")
            ctx.add_op("op:'set_local', idx:" + str(local_id))
        elif lhs.name in ctx.function.params:
            raise EspressoRuntimeError("You can't assign to a paramater")
        elif global_variables.has_key(lhs.name):
            gen_expr(ctx, rhs)
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'" + lhs.name + "'")
            ctx.add_op("op:'dup', idx:2")
            ctx.add_op("op:'set_field'")

def gen_stmt(ctx, stmt):
    if isinstance(stmt, BlockStmt):
        for stmt in stmt.stmts:
            gen_stmt(ctx, stmt)
            if ctx.block.is_finalised():
                break
    elif isinstance(stmt, DeclStmt):
        if ctx.function.has_decl(stmt.name) or stmt.name in ctx.function.params:
            raise EspressoRuntimeError("You can't redefine variable: " + stmt.name)
        if ctx.is_global:
            ctx.function.register_global_decl(stmt.name)
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'" + stmt.name + "'")
            gen_expr(ctx, stmt.init_expr)
            ctx.add_op("op:'set_field'")
            return
        gen_expr(ctx, stmt.init_expr)
        local_no = ctx.function.register_local_decl(stmt.name)
        ctx.add_op("op:'set_local', idx:" + str(local_no))
    elif isinstance(stmt, ReturnStmt):
        gen_expr(ctx, stmt.expr)
        ctx.add_branch("ret")
    elif isinstance(stmt, IfStmt):
        gen_expr(ctx, stmt.test_expr)

        then_block = Block()
        then_ctx = ctx.sub_ctx(then_block)
        gen_stmt(then_ctx, stmt.then_stmt)

        else_block = Block()
        else_ctx = ctx.sub_ctx(else_block)
        gen_stmt(else_ctx, stmt.else_stmt)
        ctx.add_branch("if_true", "then", then_block, "else", else_block)
        join_block = Block()
        ctx.merge(join_block)
        if not then_ctx.block.is_finalised():
            then_ctx.add_branch("jump", "to", join_block)
        if not else_ctx.block.is_finalised():
            else_ctx.add_branch("jump", "to", join_block)
    elif isinstance(stmt, ExprStmt):
        gen_expr(ctx, stmt.expr)
        ctx.add_op("op:'pop'")
        return
    elif isinstance(stmt, IRStmt):
        for arg in stmt.arg_exprs:
            gen_expr(ctx, arg)
        ctx.add_op("op:'"+stmt.op_name+"'")
    elif isinstance(stmt, ImportStmt):
        for path in stmt.paths:
            actual_path = path[0].val
            alias = path[1]
            if ctx.is_global:
                ctx.function.register_global_decl(alias)
                ctx.add_op("op:'push', val:@global_obj")
                ctx.add_op("op:'push', val:'" + alias + "'")

                ctx.add_op("op:'push', val:'" + actual_path + "'")
                cont_block = Block()
                ctx.add_branch(
                    "import",
                    "ret_to",
                    cont_block,
                    None,
                    None
                )
                ctx.merge(cont_block)

                ctx.add_op("op:'set_field'")
                return

            ctx.add_op("op:'push', val:'" + actual_path + "'")
            cont_block = Block()
            ctx.add_branch(
                "import",
                "ret_to",
                cont_block,
                None,
                None
            )
            ctx.merge(cont_block)

            local_no = ctx.function.register_local_decl(alias)
            ctx.add_op("op:'set_local', idx:" + local_no)
    elif isinstance(stmt, ExportStmt):
        if not ctx.is_global:
            raise EspressoRuntimeError("You can only  while being in the global scope")
        for name in stmt.names:
            if not global_variables.has_key(name):
                raise EspressoRuntimeError("You can only export global variables")
            ctx.add_op("op:'push', val:@global_obj")
            ctx.add_op("op:'push', val:'exports'")
            ctx.add_op("op:'get_field'")
            ctx.add_op("op:'push', val:'" + name + "'")
            gen_expr(ctx, name)
            ctx.add_op("op:'set_field'")
    else:
        raise EspressoRuntimeError("wat stmt")
