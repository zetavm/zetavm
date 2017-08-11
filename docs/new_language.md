# Implementing a New Language with ZetaVM

## Two Possible Methods

There are currently two ways to implement a language on top of ZetaVM. The
first is to write an external compiler which outputs bytecode
in the [textual image file format (zim)](../tests/vm/ex_image.zim) native to ZetaVM.
The second approach is to write a language package which runs inside Zeta and
generates bytecode in memory on the fly.

### Standalone Compilers

The cplush compiler is
a compiler for the Plush language written in C++. It is an example of an
external compiler which writes Zeta image files (with the zim extension).
This compiler was built to
[bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_(compilers)) the Plush
language and build libraries for the Zeta platform.

See the C++ source and header files under the [plush](../plush) directory
to get an idea of how cplush is implemented.

### Language Packages

The second approach to implementing a language running on ZetaVM is to
implement a language package which generates bytecode on the fly. This is how
the self-hosted Plush implementation works. It generates Zeta bytecode in
memory directly. The downside of this approach is that Plush is currently the
only language that runs on ZetaVM, and so you would have to write your
compiler in Plush, which is very barebone at this stage.

The *major upside* to implementing your language by writing
a language package is that you will eventually be able to upload your
implementation to the Zeta package manager, instantly giving every ZetaVM user
the ability to write code in your language without needing to manually download,
compile or configure anything.

See the self-hosted [Plush package](/plush/plush_pkg.pls) (`plush_pkg.pls`)
for an example implementation of a language package. A [parsing library](/docs/packages.md)
(`std/parsing`) is also available to simplify the parsing process.

## Pull Requests

If you would like your language to become part of the ZetaVM repository, and
you choose to write your own standalone compiler, I would prefer you write the
compiler in C, C++ or Python 3, as I do not want to add additional dependencies
to the ZetaVM repository.

I would also recommend that you begin by creating an issue where you state
that you will be working on an implementation of language X. This will be a
good place for you to ask questions, and, particularly in the case of existing
languages, it will signal your intentions to others who may want to implement
the same language.

## More Information

The design of ZetaVM is currently in flux, and so there is no rigorous and
up-to-date documentation out there. You can start by
reading the ZetaVM [design and principles](design.md) document for some insight
into why Zeta works the way it does. For documentation on the bytecode, you
should look at compiled image examples under [tests](../tests) and directly
refer to the implementation of [the interpreter](../vm/interp.cpp).

If you have any questions, would like clarifications, or if you run
into any bugs/flaws in ZetaVM, do not hesitate to open a new
[issue](https://github.com/maximecb/zetavm/issues). You can also pop by the
[Gitter chatroom](https://gitter.im/zeta-vm-org/Lobby) and introduce yourself. 
