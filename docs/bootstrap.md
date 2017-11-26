# Plush Bootstrap Process

## Motivation

The [Plush language](/docs/plush_guide.md) package is itself written in Plush.
As of this writing (2017-11-21), the Plush package is compiled into
[Zeta bytecode](/docs/exec_model.md) by an external compiler written in C++
(cplush). The external compiler is also used to precompile packages shipping
with Zeta. Having two Plush implementations is problematic because it means
language features must be implemented twice, and these two implementations
have to be kept in sync. This can also make writing Plush code somewhat
confusing to newcomers. For instance, error reporting in code compiled by
cplush is not as good as with the Plush language package.

Currently, the Plush package compiles source code into bytecode that is
directly allocated in memory. If the Plush language package can parse and
compile itself, it should be possible to serialize the resulting bytecode
into a Zeta Image (ZIM) file. This would make it possible to eliminate the
external C++ Plush implementation.

## Potential Difficulties

One difficulty with the bootstrap is that the Plush package runs on ZetaVM.
If you remove some instruction from the VM or change its semantics, then
you need a new version of the Plush package.
The old version of the package may not work once the IR is changed, but the new
version of the package may not be able to run until the IR is changed.

One way to mitigate this is to avoid changing the IR, or to replace and modify
instructions in successive steps (eg: start by supporting both the old and new
semantics). Alternatively, if this is not possible, one can change Plush first,
and use it to recompile versions of all packages in a new directory. Then,
the VM can be changed and recompiled, and the new package versions can run on
the new VM.

## Plan of Action

The Plush package is already able to parse itself, and code serialization to
ZIM files has also been implemented. However, some refactorings are still
needed to make the Plush runtime library its own package. Currently, the
C++ Plush compiler simply concatenates the source code of the runtime with
every package it compiles.

Currently, running `make` builds the VM, builds the C++ Plush compiler (cplush),
and then uses cplush to build packages shipping with Zeta. If we eliminate
cplush, then we will need to ship precompiled ZIM packages with Zeta.

To begin, we will proceed towards bootstrap capability, but avoid immeditately
getting rid of cplush. The legacy Plush implementation will only be removed
once the bootstrap has been completed and the resulting code passes all the
tests.
