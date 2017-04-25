# ZetaVM

**Please note that ZetaVM is currently at the early prototype stage. As such,
it is incomplete and breaking changes may happen often.**

ZetaVM is a Virtual machine and JIT compiler for dynamic programming languages.
It implements a basic core runtime environment on top of which programming
dynamic languages can be implemented with relatively little effort.

Features of the VM will include:

- Built-in support for dynamic typing

- Garbage collection

- JIT compilation

- Dynamically growable objects (JS-like)

- Dynamically-typed arrays (JS/Python-like)

- 64-bit integer and floating-point arithmetic

- Immutable UTF-8 strings

- Text-based [image files](zetavm/tests/ex_image.zim) (JSON-like)

- Ability to suspend and resume programs

- Graphical and audio libraries

Zeta image files (.zim) are JSON-like, human-readable text files containing
objects, data and bytecodes to be executed by ZetaVM.
They are intended to serve as a compilation target, and may contain
executable programs, or libraries/packages.

## Goals and Guiding Principles

This section aims to explicitly state the design goals and principles underlying ZetaVM. These should be used to guide the design of the VM.

1. ZetaVM should make it relatively easy to implement dynamic languages with common features such as dynamic typing, eval, dynamic arrays and dynamically-extensible objects.

2. ZetaVM aims to reach, after an initial prototyping phase, a stable set of core features which will eventually become completely frozen/unchanging, so that software compiled for ZetaVM can keep running, even decades after it has been written.

3. The core features provided by ZetaVM should be minimalistic. It is not possible, nor desirable to try to accomodate every possible use case. A large set of features is more likely to lead to the introduction of corner cases and unpredictable behaviors.

4. The semantics of the features provided by ZetaVM should be simple and straightforward. These should be as few corner cases as possible.

5. The semantics of the ZetaVM core should be strict and precise, leaving as few undefined behaviors as possible (ideally none). Predictable semantics should be favored over small potential optimization opportunities. This will increase the likelihood that ZetaVM programs behave the same on every platform.

6. Often, it is preferable to be too strict in defining VM behavior and capabilities rather than too lax. Limitations on inputs the VM can take, for instance, can always be removed later, but are difficult to add later without breaking programs. In the same vein, ZetaVM should be strict in rejecting non-conforming inputs and program behaviors, so that programs do not begin to rely on unanticipated corner cases of the implementation.

7. Silent failures and nondeterministic behaviors should be avoided. Type errors and invalid pointer dereferences, for instance, should result in immediate program termination.

8. ZetaVM should be designed with some regard for performance. That is, its core semantics should be chosen so that known optimizations may be applies. However, performance is not the ultimate goal, and robustness should be favored over performance.

9. Core APIs and libraries provided by ZetaVM should intentionally be kept simple, low-level and minimalistic, again so that there are as few corner cases as possible. However, in order to enable forward-compatibility, core APIs should also be built with as few arbitrary limits as possible.

10. Some consideration needs to be given to extensibility and future-proofing. ZetaVM aims to provide a simple and stable environment, but if it is to last, it is inevitable that additions and extensions will be made.

## Game Plan

This section roughly outlines medium-term plans for the ZetaVM project.

### ZetaVM Prototype

A first prototype of ZetaVM will be implemented. For this first prototype, there will only be an interpeter, and no garbage collector. The goal here is to get the system running quickly with a core set of features, so that we can begin prototyping and altering the design as necessary.

### MiniLISP

The first language implemented on top of ZetaVM will be a simple LISP subset. The main motivation is that a LISP-like syntax can be extremely simple to parse, but also highly extensible and expressive. This language will likely be implemented in Python, and will serve both to bootstrap the system, and to demonstrate to beginners how they can build their own language targetting ZetaVM.

### Core Libraries

A set of core libraries/packages will be provided as part of ZetaVM. These will implement a set of simple intput/output APIs to interface with the outside world. The APIs provided will intentionally be kept low-level, simple and minimalistic to minimize the risk of introducing corner cases and undefined behaviors. It is expected that higher-level, more user friendly libraries will be implemented on top of these.

Libraries should cover services such as file I/O, console I/O, basic 2D graphics (pixel plotting and blitting), mouse and keyboard input as well as raw PCM audio output. The early prototype version of the VM will implement only the most essential libraries.

### JIT Compiler

Once ZetaVM is past the initial prototyping stage, a JIT compiler will be implemented to improve performance. This JIT will likely be based on basic block versioning.

### Immutable Package Manager

The VM will eventually ship with a package manager. This package manager will make it trivial to immediately upload code you have written from the command-line and make it available to anyone.

Packages will be versioned and immutable. That is, once a package is uploaded, it will be assigned a verison number, e.g. `"john.imagelib.56"`. This package version will then be frozen and unchangeable. What this means is that once code relies on a specific package version, the dependencies can never be changed and broken. Hence, by freezing the core VM semantics, and freezing submitted packages, we make it possible to write software that never breaks.

## Design Decisions

### Virtual Machine Design

Stack vs register-based VM:
- Register may be easier for BBV to deal with, but stack is more compact
- Stack-based gives us implicit liveness, which is nice for code generation
- Try stack-based first

Plain function calls vs `call/cc`:
- If continuations, how do we deal with local variables?
  - Don't like the whole closure-based everything
- For prototype, KISS, just use a plain old call stack

Memory accesses, loads and stores:
- Don't expose memory bytes and object headers directly
  - This is better for optimization and safety
- For prototype, want `get_field` and `set_field` for objects, `get_elem` and
  `set_elem` for arrays,
  `get_char` for strings

### Type System

Static vs dynamic typing:
- Supporting dynamic typing directly in the VM it makes easier to do monkey patching and get old/incompatible
packages working together.
- Dynamic typing and textual image files means any kid who knows Python can easily create their own language. This is clearly good for attracting contributors and growing the ecosystem.
- With a dynamic system, we can use objects as metadata for documentation. This makes things intrinsically highly extensible and retrofittable.

Immutable objects:
Do we want the ability to tag object fields as constant/immutable? This may be good for optimization
and safety. However, this is somewhat bad for monkey-patching and
forward-compatibility. May want to just let people shoot themselves in the
foot if they want to. Also, keeping things simple, particularly for the prototype, is important.

### Type Tags

In ZetaVM, every value implicitly has an associated type tag which tells us
which kind of value it is.

The type tags are:
- undef: special value for uninitialized variables, uninitialized arrays
- bool: boolean values (`$true` and `$false`)
- int64: 64-bit integers
- float64: 64-bit floating-point numbers
- string: immutable UTF-8 strings
- array: ordered lists of values, as in Python and JS
- object: dynamically extensible objects (JS-like, no prototypes)

More complex datatypes, such as functions, variable-length lists and
objects with prototypal inheritance are to be implemented by composing
objects, arrays and other simpler types.

Type tags will be internally represented by the VM as 4-bit integer values.
Note that in some cases, a JIT compiler may be able to avoid storing those
values in memory, that is, the type tags can be implicitly known by the
compiler at code generation time.

Type tags will be accessible to bytecode as strings, through the
`has_tag <val>`, `<tag_str>` and `get_tag <val>` instructions. The `has_tag`
instruction is a dynamic type test which makes it possible to answer questions
such as "is this value of type `int64`?" at run time.

### Type Errors

What should happen when an operation expecting values of a certain type
(e.g. `add_i64` expects two `int64` values) receives operands of the wrong type?
In order to avoid corner cases and undefined behaviors, we will guarantee that
the VM will halt program execution should a type error of this kind occur.

By halt, we mean that the VM will abort execution and report an error to the
process that instantiated it. Type errors will not produce an exception that
can be caught by running programs because we do not want code to rely on type
errors to infer types. Correct programs should insert dynamic type checks where
appropriate.

My work on Higgs and [basic block versioning](http://2016.ecoop.org/event/ecoop-2016-papers-interprocedural-type-specialization-of-javascript-programs-without-type-analysis) leads me to believe
that it should be possible for the VM to determine the types of operands in almost
every case. This is because typed operations such as `add_i64` should be guarded by
dynamic type tests. Hence, I do not believe that guaranteeing program
termination on type errors will cause performance issues. If there is a
performance cost, it will be small.

### Closures

If we do not implement closures natively in ZetaVM, language implementers have
to do it themselves. That means they must do closure conversion and allocate
mutable cells or store values on functions. This is actually not that hard
given that people will need to do some kind of scope analysis. Probably
better to keep the VM implementation as simple as possible and not implement
closures at the VM level, only plain function callls. MiniLISP will exemplify
a simple implementation of closures.

### Objects

Objects will follow a model that is similar to JS, where new properties
can be added dynamically, with some simplifications:

1. Objects in ZetaVM will not support prototypal inheritance natively.
Supporting this will be left to language implementers. This only requires
implementing a recursive property lookup function.

2. ZetaVM will not support hidden properties in objects. If you want to hide
properties from language users, you can always prefix user properties by some
special character. Remapping names is not difficult.

3. JS supports arbitrary values as property names (keys). ZetaVM will limit
property names to valid ZetaVM identifiers. Supporting other property names can
be done through remapping. This is to facilitate the serialization of ZetaVM objects.

4. Unless a very convincing use case is found, property deletion will not be supported.
Property deletion seems to be rarely needed in practice and is complex to implement efficiently.

### Arrays

I initially thought that ZetaVM should implement fixed-length arrays only, since these are simpler to implement than dynamically growable arrays. However, since Python, JS and Lua all have dynamically growable arrays, I think the VM should support growable arrays natively. If the VM does not provide growable arrays, then many language implementations running on top of ZetaVM will end up implementing their own incompatible array/list types, which will make language interoperability difficult. Hence, the arrays that ZetaVM implements should be growable, so that they are "good enough" for most language implementations.

The ZetaVM arrays will follow a model similar to JS, with some simplifications and corner cases removed. In JS, it's possible to create an array with "holes" (non-existent elements) that have `undefined` values. ZetaVM won't permit this. It also won't be possible to write out of the bounds of an arrays. This is to avoid the case where uninitialized array elements have `undefined` values. We will limit array instructions in ways that force people to initialize all values contained in arrays. The main advantage of this is that ZetaVM should be able to fairly easily infer array types as arrays are grown. This will be good for performance.

Because arrays are extensible, they will have both an associated length (number of elements currently contained) and a capacity (the number of elements the array is cabaple of containing). It will be possible to provide a minimum capacity hint when allocating an array, but it will not be possible to query the VM to know the current capacity of an array. The reason for this is that the capacity is essentially a "hidden state", an implementation detail which we do not want to expose. When serializing arrays to text, the capacity will not be present in the textual representation.

### Bytecode

Below is a tentative list of bytecodes to be provided by ZetaVM:

- stack manipulation: `push_i64`, `push_str`, `pop`, `dup`
- integer arithmetic: `add_i64`, `sub_i64`, `mul_i64`, `div_i64`, `mod_i64`
- floating-point arithmetic: `add_f64`, `sub_f64`, `mul_f64`, `div_f64`, `sqrt_f64`
- bit manipulation: `lsft_i64`, `ulsft_i64`, `rsft_i64`, `and_i64`, `or_i64`, `xor_i64`, `not_i64`
- comparisons: `lt_i64`, `gt_i64`, ...
- type tests: `get_tag <val>`, `has_tag <val> <tag>`
- conditional branches: `if_true <bool_val>`
- direct branches: `jump`
- function calls: `call`, `return`
- object and array allocation: `new_obj`, `new_array`
- object property access: `get_field`, `set_field`, `has_field`
- array element access: `get_elem`, `set_elem`, `arr_len`
- string character access: `get_char`, `str_len`

### Integer Arithmetic

Integer arithmetic operations that produce results that are out of bounds
will result in overflows. There will be no undefined behaviors in this regard.

The ZetaVM prototype will not offer any special mechanisms for overflow detection,
but the final version will support integer arithmetic operations both with and
without overflow checking. This is because efficient overflow checks are useful
to implement bignums, saturation and other such language features.

### Image Files

There are example image files in the [/tests](tests) directory of this
repository. Image files have a ".zim" file name extension.

Why not use pure JSON:
- Images may contain circular references, and so a syntax is needed to
  express that in terms of global definitions and global references.
- Some of the data items we will allow do not have a JSON representation.
- Would also like images to be as user-friendly as possible. In this respect,
  having our own format is useful.

Why not use s-expressions, or something LISP-like?
- This isn't actually LISP, packages are pure data, not commands being executed
- Although s-expressions could express references, they would make for a less
  readable and less intuitive format.
- S-expressions are very powerful, and would encourage the use of all kinds
  of commands and special tricks in the image format, which is definitely not
  what we want. We want image format to be as plain, simple and idiotproof as
  possible, we definitely do not want image formats and ZetaVM to end up
  implementing a LISP dialect.

Special definitions:
- Some special definitions may be provided by the implementation
  - Symbols provided by the VM/implementation
- These will be identifiers preceded by a dollar sign, e.g. `$foobar`
- Global definitions defined in the image cannot contain a dollar sign, which
  makes it impossible for them to collide with special definitions. This adds
  some amount of futureproofing to the image format, as we can add new
  special definitions later without invalidating existing images.
- The boolean values `$true` and `$false` are special definitions
- The special undefined value `$undef` is a special definition

Top-level definitions:
- We use an equal-sign for top-level definitions. The reason we do not use
  a colon as in JSON is that top-level definitions are not semantically the
  same as object properties. Top-level identifiers are handles which serve
  to allow circular definitions, and these only exist while an image file
  is being parsed.
- Top-level definitions will be separated by semicolons. The motivation for
  this is that it may enable the eventual implementation of a multithreaded
  image parser. That is, locating a semicolon near the middle of the input
  allows us to split the input into two halves and parse them independently.

Comments:
- Only single-line comments are allowed. This is both for simplicity, and
  again because it could make the implementation of a multithreaded parser
  easier. Locating a newline necessarily means that we are not within a
  comment.

Library/package dependencies:
- Do we want to force upfront declaration of dependencies or not?
  - Do we want to force people to declare all imports, or allow dynamic package loading at run time?
- With dynamic loading, we can have some APIs be exposed as packages that are not
present on some machines. Could allow dynamic at first, and change this
later if it makes no sense.
- Packages will be loaded through a special `load()` API call
  - If necessary, package loading can be optimized by predictive/preemptive
    downloading by the package manager
