"""Parsing espresso files"""

class OpInfo(object):
    "Operators class"
    def __init__(self, op, close_str, arity, prec, assoc, non_assoc, fold_assign):
        self.operator = op
        self.close_str = close_str
        self.arity = arity
        self.prec = prec
        self.assoc = assoc
        self.non_assoc = non_assoc
        self.fold_assign = fold_assign

OP_CALL = OpInfo("(", ")", -1, 15, 'l', False, False)

OP_NEG = OpInfo("-", None, 1, 13, 'r', False, False)
OP_NOT = OpInfo("not", None, 1, 13, 'r', False, False)
OP_TYPEOF = OpInfo("typeof(", ")", 1, 13, 'r', False, False)

OP_MUL = OpInfo("*", None, 2, 12, 'l', False, True)
OP_DIV = OpInfo("/", None, 2, 12, 'l', True, True)
OP_MOD = OpInfo("%", None, 2, 12, 'l', True, True)
OP_ADD = OpInfo("+", None, 2, 11, 'l', False, True)
OP_SUB = OpInfo("-", None, 2, 11, 'l', True, True)

OP_LT = OpInfo("<", None, 2, 9, 'l', False, False)
OP_LE = OpInfo("<=", None, 2, 9, 'l', False, False)
OP_GT = OpInfo(">", None, 2, 9, 'l', False, False)
OP_GE = OpInfo(">=", None, 2, 9, 'l', False, False)

OP_EQ = OpInfo("=", None, 2, 8, 'l', False, False)
OP_NE = OpInfo("!=", None, 2, 8, 'l', False, False)

OP_AND = OpInfo("&&", None, 2, 4, 'l', True, False)
OP_OR = OpInfo("||", None, 2, 3, 'l', True, False)

OP_ASSIGN = OpInfo("=", None, 2, 1, 'r', False, False)


