# ZetaVM

[![Build Status](https://travis-ci.org/zetavm/zetavm.svg?branch=master)](https://travis-ci.org/zetavm/zetavm) [![Build status](https://ci.appveyor.com/api/projects/status/a99mx86i78vjmgln?svg=true)](https://ci.appveyor.com/project/maximecb/zetavm)

**Please note that ZetaVM is currently at the early prototype stage. As such,
it is incomplete and breaking changes may happen often.**

## Installation and Basic Usage

```
# Clone this repository
git clone git@github.com:maximecb/zetavm.git

# Run the configure script and compile zetavm
# Note: run configure with `--with-sdl2` to build audio and graphics support
cd zetavm
./configure
make

# Optionally run tests to check that everything works properly
make test

# To run programs, pass the path to a source file to zeta, for example:
./zeta benchmarks/fib29.pls

# To start up the Plush REPL (interactive shell),
# you can run the Plush language package as a program:
./zeta lang/plush/0
```

## About ZetaVM

ZetaVM is a Virtual machine and JIT compiler for dynamic programming languages.
It implements a basic core runtime environment on top of which programming
dynamic languages can be implemented with relatively little effort.

Features of the VM will include:

- Built-in support for dynamic typing

- Garbage collection

- JIT compilation

- Dynamically growable objects (JS-like)

- Dynamically-typed arrays (JS/Python-like)

- Integer and floating-point arithmetic

- Immutable UTF-8 strings

- Text-based [image files](/tests/vm/ex_image.zim) (JSON-like)

- First-class stack-based bytecode

- Ability to suspend and resume programs

- Built-in graphical and audio libraries

Zeta image files (.zim) are JSON-like, human-readable text files containing
objects, data and bytecodes to be executed by ZetaVM.
They are intended to serve as a compilation target, and may contain
executable programs, or libraries/packages.

## More Information

For more information, see the documentation in the [docs](docs) directory:

- [Overview and Roadmap](docs/roadmap.md)

- [Design and Guiding Principles of ZetaVM](docs/design.md)

- [Creating your own Language with ZetaVM](docs/new_language.md)

There are also a few blog post about [Zeta](https://pointersgonewild.com/category/zeta/) and its design.

For additional questions and clarifications, [open a GitHub issue](https://github.com/maximecb/zetavm/issues) and tag it as a question.
