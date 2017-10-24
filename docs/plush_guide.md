# Plush Language Guide

Plush is a dynamically typed language inspired by JavaScript and Lua, which
was created for the purpose of bootstrapping ZetaVM. The language is
intentionally kept simple and minimalistic. The intentional minimalism means
that Plush may be lacking features you are familiar with. The upside is that
the amount of things to learn about is limited, and the language is fairly
stable.

The documentation found here is meant to outline the notable features of
the Plush language. You may also find it helpful to look at code examples
found under [/examples](/examples), and Plush tests found under
[/tests/plush](/tests/plush).

## Running Plush Code

In order to try playing with some Plush code, you can start up the
Plush shell by running:

```
./zeta lang/plush/0
```

Alternatively, you can create a source file starting with the
Plush language line (this tells Zeta that your file contains Plush code):

```
#language "lang/plush/0"
print('Hello World!');
```

And run it with ZetaVM as follows:

```
./zeta mysourcefile.pls
```

## Basic Types

The basic types found in Plush mirror those supported by the VM. They are:
- `undef` (similar to JS undefined)
- `bool` (`true` and `false`)
- `int32`
- `float64`
- `string`
- `array`
- `object`

The type of a value can be obtained with the `typeof` operator:

```
print(typeof 3)
int32
```

One important difference with JS is that there is a difference between
integer and floating-point values, as they have distinc types. Integers
will wrap around on overflow. Floating-point number literals use the same
notation as C floats, that is, you should write `3.5f` and not just `3.5`.
This is because Zeta may eventually support a `float64` type, which will be
distinct from the `float32` type.

Another important thing to note is that there is no special function type.
Functions, in ZetaVM, are simply objects containing bytecode. If an object
contains valid bytecode, it is callable as a function.

## Objects and Prototypal Inheritance

Objects in Plush work similarly to those of JavaScript, with the differences
that you cannot delete properties, and objects can only be indexed with
string keys. Also note that it is not recommended to use objects as hash
maps, you should use the `std/map` library for this purpose.

Similarly to JS, the Plush language supports prototypal inheritance. However,
Plush does not have a `new` operator. This [example](/tests/plush/obj_ext.pls)
shows how to create an object which inherits from another object.

## Functions and Method Calls

The first thing to note is that Plush, being very minimalistic, has no
variadic function calls and no default argument values.

Similarly to the Lua language, Plush uses
[different syntax](/tests/plush/method_calls.pls) for regular
function calls and for method calls. It makes the `this` argument explicit,
and forces you to make function calls explicit as well using the `obj:method()`
method call operator. This is to avoid the issue that
JavaScript faces regarding shadowing of the `this` argument.

There are no closures in Plush. This is again done to minimize
implementation complexity. However, Plush does have function expressions,
and the `std/peval` library can be used to do [currying and partial
evaluation](/tests/plush/peval.pls), which can be used to create functions with bound variables
which act like closures.

## The Import Expression

In Plush, `import "package_name"` is an expression. This makes it possible
to import code lazily, that is, when needed, as opposed to always at the
beginning of source files. This is useful in some cases to minimize overhead.

Plush will try to find packages in its own [/packages](/packages)
directory by default. It's also possible to perform relative to the current
working directory by preceding the package path with `./`, for example:

```
var myPackage = import "./local/package/file.pls";
```

## Standard Library

See the [packages](/docs/packages.md) documentation for a list and
description of packages included with ZetaVM.

## Peculiarities

The only kind of loop supported by Plush is the `for` loop. You can
implement endless loops by writing `for (;;) {}`, as in C.

By default, the division operator produces floating-point values. If you
wish to perform integer divison, use the `math.idiv(x,y)` function defined
in the `std/math` package.

## Inline Bytecode Instructions

Plush allows you to directly use specific bytecode instructions specified by
ZetaVM in your code. This is useful to access features of Zeta not directly
exposed by Plush, and to implement higher-level features in terms of
low-level constructs.

For example, the VM has an instruction to convert `int32` values to `float32`:

```
var floatVal = $i32_to_f32(35);
```

A potential pitfall is that Plush semantically distinguishes between
bytecode instructions used as expressions, versus those used as statements.
Namely, using a bytecode expression as a statement assumes that the instruction
produces no output on the temporary stack, whereas using it as an expression
will pop the value off the temporary stack. The VM will likely crash if
you get this wrong.

Note that directly using bytecode instructions is not recommended if you
can avoid it. You should ideally use functions from the standard library
that provide equivalent functionality if possible.
