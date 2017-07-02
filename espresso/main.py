"""Main for espresso"""

import argparse
from parser import parse_string, test_parser
from e_codegen import gen_unit
from e_nodes import BlockStmt

def testing(args):
    print("testing: ")
    test_parser()

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
    codegen.add_argument("output", help="The output file")
    codegen.set_defaults(func=compiling)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
