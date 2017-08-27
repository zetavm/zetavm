Execution Model and Semantics
=============================

The purpose of this document is to discuss the
[execution model](https://en.wikipedia.org/wiki/Execution_model) for code
running on ZetaVM.

An important thing to note is that ZetaVM tries to be flexible, but also
to remain fairly minimalistic in what it defines. The VM defines simple
semantics for strings, arrays and objects. Functions and the bytecode they
contain are defined in terms of objects and arrays.

Features such as closures and prototype-based inheritance are not directly
supported at the VM level, but instead implemented at the language/runtime
level in terms of lower-level primitives.

Bytecode Format
---------------

Zeta uses a [stack-based](https://en.wikipedia.org/wiki/Stack_machine) bytecode
format, meaning that instructions push and pop values from a stack of temporary
values. This design was chosen with the optic that a stack-based architecture
gives us some implicit information about the liveness of values for free. That
is, when a value is popped off the temporary stack, the VM knows that it is
dead and will never be used again.

The bytecode, as executed by the VM, is defined in terms of objects and arrays.
Functions are objects, which contain an entry basic block. Each basic block
contains an array of instructions. The instructions themselves are objects with
fields defining whavever information the VM requires. The Zeta image files
(ZIM) are a serialization of this object-based bytecode into a flat
textual representation.

The design of the VM is becoming increasingly stable, but is still changing,
so a listing of every opcode supported is not yet provided in this document.
To get an idea of which opcodes are supported, and which associated fields
are present, you should look at the tests found under [`/tests/vm`](/tests/vm).
You can also look at [`vm/interp.cpp`](/vm/interp.cpp). In particular, you
should look at the `compile` function, which translates the
outward-facing bytecode (defined in terms of objects) into the internal IR
which the interpreter runs.

Dynamic Type Checks
-------------------

Zeta has native support for dynamic typing, but takes an approach that is
slightly different from most dynamic language VMs.
Every value, be it local variables or object fields, has an
associated implicit type tag. However, the low-level operations supported by
the VM are all explicitly typed. That is, there is an `add_int32` opcode,
which adds `int32` values, and an `add_f32` opcode to add `float32` values.

Concretely, because low-level operations such as addition are typed, but values
have dynamic types, it means that programs must explicitly check the types
of values before operating on them. This is done using the `has_tag`
instruction. When writing Plush code, one can simply use the form
`if (typeof x == "int32") {}`, which gets automatically translated into
a `has_tag` instruction. For an example of this, you should look at
[`plush/runtime.pls`](/plush/runtime.pls).

The responsibility of ensuring correct typing is entirely placed on
running programs. Should values of incorrect types be passed to a
low-level instruction (ie: `float32` values fed into `add_i32`), then the
VM will terminate the program. Type errors are not recoverable, that is,
they cannot be caught as exceptions. This is intentional, as we do not
want internal VM safety checks to be used as part of normal program execution.

Stack Frame Layout
------------------

Functions have a number of locals on the stack. This number must include the
visible function parameters, and the hidden closure argument, so the
`num_locals` field of every function has to be at least 1. The closure
argument maps to stack slot index 0. This argument provides functions with a
reference to the function object being called, which can be used to implement
closures. The visible parameters map to slot indices 1 to N. Slots above that
are for local variables that are not function arguments. These are all
accessed with the `set_local` and `get_local` instructions.

Above the local variables, there are stack slots for the return address and
temporaries. These are not (or should not be) directly accessible through
`get_local`. The values in the temp stack are conceptually in a different
memory space from the local variables. They are stored on the same stack, but
that should be considered an implementation detail.
