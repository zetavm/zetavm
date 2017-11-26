# ZetaVM

[![Build Status](https://travis-ci.org/zetavm/zetavm.svg?branch=master)](https://travis-ci.org/zetavm/zetavm) [![Build status](https://ci.appveyor.com/api/projects/status/a99mx86i78vjmgln?svg=true)](https://ci.appveyor.com/project/maximecb/zetavm) [![Gitter chat](https://badges.gitter.im/zeta-vm-org/gitter.png)](https://gitter.im/zeta-vm-org/Lobby)

**Please note that ZetaVM is currently at the early prototype stage. As such,
it is incomplete and breaking changes may happen often.**

## Requirements:

- GNU Make
- GCC 5.4+ (linux) or clang (OSX), or cygwin (Windows)
- Optional: autoconf and pkg-config, if needing to edit the configure file
- Optional: sdl2, if wanting to use audio and graphics capabilities
- Optional: Python 2 is needed to run the benchmark.py script

## Installation

```
# Clone this repository
git clone git@github.com:maximecb/zetavm.git

# Run the configure script and compile zetavm
# Note: run configure with `--with-sdl2` to build audio and graphics support
cd zetavm
./configure
make -j4

# Optionally run tests to check that everything works properly
make test
```

## Basic Usage

```
# To run programs, pass the path to a source file to zeta, for example:
./zeta benchmarks/fib.pls -- 29

# To start up the Plush REPL (interactive shell),
# you can run the Plush language package as a program:
./zeta lang/plush/0
```

## About ZetaVM

ZetaVM is a Virtual machine and JIT compiler for dynamic programming languages.
It implements a basic core runtime environment on top of which programming
dynamic languages can be implemented with relatively little effort.

Features of the VM include:

- Built-in support for dynamic typing

- Garbage collection

- JIT compilation

- Dynamically growable objects (JS-like)

- Dynamically-typed arrays (JS/Python-like)

- Integer and floating-point arithmetic

- Immutable UTF-8 strings

- Text-based [code and data storage format](/tests/vm/ex_image.zim) (JSON-like)

- First-class stack-based bytecode (code is data)

- Built-in graphical and audio libraries

- Coming soon: built-in package manager

Zeta image files (.zim) are JSON-like, human-readable text files containing
objects, data and bytecodes to be executed by ZetaVM.
They are intended to serve as a compilation target, and may contain
executable programs, or libraries/packages.

## More Information

A recording of a [talk about ZetaVM](https://eventil.com/presentations/5dszyA) given at PolyConf 2017 is available.

For more information, see the documentation in the [docs](docs) directory:

- [Overview and Roadmap](docs/roadmap.md)

- [Design and Guiding Principles of ZetaVM](docs/design.md)

- [Packages included with ZetaVM](docs/packages.md)

- [Plush Language Guide](docs/plush_guide.md)

- [Plush Bootstrap Process](docs/bootstrap.md)

- [Execution Model and Semantics](docs/exec_model.md)

- [Contributing to ZetaVM](docs/contributing.md)

- [Creating your own Language with ZetaVM](docs/new_language.md)

There are also a few blog post about [Zeta](https://pointersgonewild.com/category/zeta/) and its design.

For additional questions and clarifications, [open a GitHub issue](https://github.com/maximecb/zetavm/issues) and tag it as a question, or join the [ZetaVM Gitter chat](https://gitter.im/zeta-vm-org/Lobby).
