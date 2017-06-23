"""Main for espresso"""

import argparse

def main():
    """Main function"""
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="The input file")
    parser.add_argument("output", help="The output file")
    args = parser.parse_args()
    with open(args.input) as input_file:
        data = input_file.read()
        print(data)

if __name__ == "__main__":
    main()
