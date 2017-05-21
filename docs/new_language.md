# Implementing a New Language with ZetaVM

## Two Possile Methods

There are currently two ways to implement a language on top of ZetaVM. The
first is to write an external compiler which directly outputs bytecode
in the [textual image format (zim)](../tests/vm/ex_image.zim) native to ZetaVM.

The cplush compiler is written in C++ and is an example of the approach just
outlined:
https://github.com/maximecb/zetavm/tree/master/plush

The second approach is to write a Zeta bytecode compiler which runs
inside Zeta. This is how the self-hosted Plush implementation works. It
generates Zeta IR in memory. The downside of this approach is that Plush is
currently the only language that runs on ZetaVM, and so you would have to
write your compiler in this very barebones language.

See the self-hosted plush `parser.pls` parser for an example:
https://github.com/maximecb/zetavm/blob/master/plush/parser.pls

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
up-to-date documentation out there. I would recommend that you start by
reading the ZetaVM [design and principles](design.md) document for some insight
into why Zeta works the way it does. For documentation on the bytecode, you
should look at compiled image examples under [tests](../tests) and directly
refer to the implementation of [the interpreter](../vm/interp.cpp).

If you have any questions or would like clarifications, do not hesitate
to open a new [issue](https://github.com/maximecb/zetavm/issues) and tag
it as a question.
