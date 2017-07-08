class OpInfo(object):
    "Operators class"
    def __init__(self, op, close_str, arity, prec, assoc, non_assoc):
        self.operator = op
        self.close_str = close_str
        self.arity = arity
        self.prec = prec
        self.assoc = assoc
        self.non_assoc = non_assoc

OP_CALL = OpInfo("(", ")", -1, 15, 'l', False)

OP_M_CALL = OpInfo(".", None, 2, 14, 'l', False)

OP_NEG = OpInfo("-", None, 1, 13, 'r', False)
OP_NOT = OpInfo("not", None, 1, 13, 'r', False)
OP_TYPEOF = OpInfo("typeof", None, 1, 13, 'r', False)

OP_MUL = OpInfo("*", None, 2, 12, 'l', False)
OP_DIV = OpInfo("/", None, 2, 12, 'l', True)
OP_MOD = OpInfo("%", None, 2, 12, 'l', True)
OP_ADD = OpInfo("+", None, 2, 11, 'l', False)
OP_SUB = OpInfo("-", None, 2, 11, 'l', True)

OP_LT = OpInfo("<", None, 2, 9, 'l', False)
OP_LE = OpInfo("<=", None, 2, 9, 'l', False)
OP_GT = OpInfo(">", None, 2, 9, 'l', False)
OP_GE = OpInfo(">=", None, 2, 9, 'l', False)

OP_EQ = OpInfo("=", None, 2, 8, 'l', False)
OP_NE = OpInfo("!=", None, 2, 8, 'l', False)

OP_AND = OpInfo("and", None, 2, 4, 'l', True)
OP_OR = OpInfo("or", None, 2, 3, 'l', True)

OP_ASSIGN = OpInfo(":=", None, 2, 1, 'r', False)