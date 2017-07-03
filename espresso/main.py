"""Main for espresso"""

import argparse
from e_parser import parse_string, test_parser
from e_codegen import gen_unit
from e_nodes import BlockStmt

def testing(args):
    print("testing: ")
    test_parser()

def no_runtime(args):
    with open(args.input) as input_file:
        src_data = input_file.read()
        src_unit = parse_string(src_data, args.input)
        result = gen_unit(src_unit)
        print(result)

def compiling(args):
    with open(args.input) as input_file:
        with open("espresso/runtime.espr") as rt_file:
            rt_data = rt_file.read()
            rt_unit = parse_string(rt_data, "runtime")
            src_data = input_file.read()
            src_unit = parse_string(src_data, args.input)

            stmts = [rt_unit.body, src_unit.body]
            src_unit.body = BlockStmt(stmts)
            result = gen_unit(src_unit)
            print(result)

def main():
    """Main function"""
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()
    test = subparsers.add_parser('test', help="testing suite")
    test.set_defaults(func=testing)
    codegen = subparsers.add_parser('compile', help="compile to Bytecode")
    codegen.add_argument("input", help="The input file")
    codegen.set_defaults(func=compiling)
    noruntime = subparsers.add_parser('noruntime', help="compile to Bytecode")
    noruntime.add_argument("input", help="The input file")
    noruntime.set_defaults(func=no_runtime)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
