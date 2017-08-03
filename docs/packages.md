Packages Included with ZetaVM
=============================

Standard Library
----------------

| Name  | Description | Example Usage |
| --- | --- | --- |
| `std/math/0`       | Collection of useful constants and math functions  | [Float tests](/tests/plush/floats.pls), [audio test](/examples/audio_test.pls) |
| `std/parsing/0`    | String parsing utilities                           | [Plush package](/plush/plush_pkg.pls) |
| `std/peval/0`      | Functional-style partial evaluation                | [Package tests](/tests/plush/peval.pls), [audio render](/examples/audio_render.pls) |
| `std/random/0`     | Random number generation and utilities             | [Package tests](/tests/plush/random.pls) |

Language Packages
-----------------

| Name  | Description |
| --- | --- |
| `lang/plush/0` | Plush programming language |


Core VM Packages
----------------

The core VM packages provide I/O functionality that is implemented directly in the VM itself, and accessible
through wrappers (host functions) written in C++. Note that references to host functions are not serializable.
As a general rule, you should avoid directly using core VM libraries if a higher-level wrapper is available.

| Name  | Description | Example Usage |
| --- | --- | --- |
| `std/audio/0`       | Audio output                           | [Audio test](/examples/audio_test.pls) |
| `core/vm/0`         | Zeta image parsing and serialization   | [Serialization tests](/tests/plush/serialize.pls) |
| `std/window/0`      | 2D graphics, pixel plotting            | [Graphics example](/examples/graphics.pls) |
