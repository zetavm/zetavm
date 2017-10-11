# Overview and Roadmap

This document provides an overview and roadmap for different parts of the ZetaVM project.

## ZetaVM Prototype

The current implementation of ZetaVM is at the prototype stage. There is currently an interpeter, but no garbage collector and no JIT compiler. The current goal is to get the system running quickly with a core set of features, so that we can properly prototype the system, iron out bugs, and alter the design as necessary.

## Plush

The first language implemented on top of ZetaVM is called Plush. This language is inspired by JavaScript and Lua, and serves both to bootstrap the system, and to demonstrate to beginners how they can build their own language targetting ZetaVM. The Plush language may eventually have optional extensions, but the core language itself will intentionally be kept simple so that its implementation remains simple and accessible to beginners.

## Core Packages

A set of [core packages](/docs/packages.md) will be provided as part of ZetaVM. These will be written in C++ and implement a set of intput/output APIs to interface with the outside world. The APIs provided will intentionally be kept low-level, simple and minimalistic to minimize the risk of introducing corner cases and undefined behaviors. It is expected that higher-level libraries will be implemented on top of these and provide more user-friendly interfaces.

The core libraries will cover services such as file I/O, console I/O, basic 2D graphics (pixel plotting and blitting), mouse and keyboard input as well as raw PCM audio output. The early prototype version of the VM will implement only the most essential libraries.

## Image Serialization

ZetaVM uses a text-based file format (ZIM files) to store code and data. This file format resembles JSON, with the important difference that it can represent arbitrary graphs of objects. Zeta will soon acquire the capability not only to read graphs of objects from ZIM files, but also to reverse this process, and serialize graphs of objects into strings or new ZIM files.

The ability to serialize objects into ZIM files will make it easy for languages which run on ZetaVM and generate bytecode in memory to save the generated code into a compiled file. It may also make it possible for programs to suspend their own state to disk and resume execution later on (with some limitations). Lastly, being able to read and write ZIM files opens up the possibility of using this format to easily save data, and to use it to transmit data over the internet.

## Simple Garbage Collector

At the time of this writing, a simple mark & sweep garbage collector is in the works. This collector will be single-threaded and simple in design, with a focus on maintainability over performance. Its main purpose is to provide essential GC functionality (ie: not running out of memory). Future implementations may enable parallel collection and lazy sweeping. The Zeta JIT compiler may also eventually acquire [allocation sinking](http://wiki.luajit.org/Allocation-Sinking-Optimization) capabilities, which would enable it to eliminate many allocations, thereby reducing the GC workload.

## Complete Plush Bootstrap

There currently exist two Plush parsers. The first is written in C++, and produces ZIM files (cplush). The second is the Plush language package, which is itself written in Plush. The cplush parser is used to compile the Plush language package into a ZIM file. Having two implementations of Plush is problematic, because it becomes difficult to keep both implementations tested and up to date, and because it can be confusing to newcomers.

The cplush parser will eventually deprecated, and completely superseded by the Plush language package. In order to do this, the Plush language package will need to be able to compile itself. Image serialization will be used to write the resulting compiled code into a ZIM file which the VM can load directly in future runs.

## Language Extensions

The Plush language will eventually make it possible for people to write parser extensions. This will allow the addition of new operators, new expression types, and new statement types to the language.

Some possible Plush extensions include:
- Closures
- [Template strings](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Template_literals)
- Regular expressions
- Pattern matching
- Gradual typing
- Variable argument count functions, optional arguments

## Immutable Package Manager

The VM will eventually ship with a package manager. This package manager will make it trivial to immediately upload code you have written from the command-line and make it available to anyone. The package manager will also make it possible to upload your own [language package](/docs/new_language.md), making your language instantly accessible to anyone using ZetaVM.

Packages will be versioned and immutable. That is, once a package is uploaded, it will be assigned a version number, e.g. `"user/john/imagelib/56"`. This package version will then be frozen and unchangeable. The aim is to make it so that once code relies on a specific package version, the dependencies can never be changed and broken. Hence, by freezing the core VM semantics, and freezing submitted packages, we will hopefully make it possible to write software that doesn't break.

## JIT Compiler

Once ZetaVM is past the initial prototyping stage, a JIT compiler will be implemented to improve performance. This JIT will likely be based on basic block versioning. The [current plan](https://pointersgonewild.com/2017/06/11/zetas-jitterpreter/) is that the JIT will use the same internal representation as the interpreter, that is, the interpreter will do part of the compilation work.

## SPMD Execution (GPU Support)

Multithreaded programming brings the potential for unpredictability and deadlocks. Zeta will instead offer native support for the Single Program Multiple Data (SPMD) programming model. This is the programming model commonly employed by vertex, pixel and compute shaders running on GPUs. One novel feature, in this respect, is that Zeta will allow the same code to run both on the CPU and GPU, with only minor restrictions. This means that potentially, any language running on Zeta will be able to execute in parallel on GPUs, with some restrictions.
