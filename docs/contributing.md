Contributing to ZetaVM
======================

This document is meant to regroup useful information for those
who want to contribute to the ZetaVM project.


What to Contribute?
-------------------

If you are wanting to get involved, but do not know what your contribution
could be, we encourage you to check the
[issues page](https://github.com/zetavm/zetavm/issues) on GitHub for a listing
of tasks that are needing to be completed. You can also join the
[Gitter chat](https://gitter.im/zeta-vm-org/Lobby)
and tell us that you are interested, and we can find you something to work on.

For those that are new to coding or not yet comfortable with the codebase,
it's highly valuable to us if you take the time to compile
ZetaVM, play with it, and report any bugs or issues you find along the way.
Chances are, if you ran into a bug, it's existed for some time and
multiple people have run into it, but we aren't aware of it because it
hasn't been reported.
By reporting problems, you will help ensure that other
people who try ZetaVM don't run into the same problems that you did.

We also appreciate it if you help improve the documentation, or tell us about
things you think should be documented but aren't. If there are things about
the workings of ZetaVM that are unclear to you, you can open a GitHub issue
for the purpose of asking us a question, and we will respond.

Lastly, another potential contribution you can make is writing fun programs
that can serve as examples of code running on ZetaVM, or even for testing
and benchmarking purposes. See the programs under the [examples](/examples)
directory of this repo.

Style Guide
-----------

For indentation, 4 spaces are to be used instead of tabs. The main reason not
to use tabs is so the code looks the same everywhere. Mixing spaces and tabs
will result in badly-aligned code when rendered on systems that choose to
represent tabs as having a different width from your text editor.

With respect to formatting, we also recommend that you try to keep the
horizontal width of your code and comments within 80 characters. There
should be exactly one blank line between global function and
variable definitions. No more, no less.

Comments placed above functions, for documentation purposes, should
follow the [Javadoc](https://www.tutorialspoint.com/java/java_documentation.htm) style:

```
/**
Computes x to the nth power. Expects n to be strictly positive.
*/
exports.pow = function (x, y)
{
    // ...
};
```

Curly braces are to go on their own line, because we are civilized folks:

```
// Good
if (foo)
{
    bar();
    bif();
}

// BAD! NOES!
if (foo) {
    bar();
    bif();
}
```

When coding in Plush, there should be a space between the `function`
and `assert` keywords and the opening parenthesis:

```
// Good
var f = function (x, y, z) { ... };
assert (foo);

// Bad
var f = function(x, y, z);
assert(foo);
```

Creating Pull Requests
----------------------

When implementing a new feature or fixing a bug, you should make sure to add
tests. In doing so, try to test corner cases (eg: does your function work
if an empty list is passed as input?). Try to think adversarially, in terms
of which inputs could break your code, and test those inputs.
Most of our tests are run from the `run_tests.sh` script.

You should ideally squash all your commits into one. The motivation for
doing this to keep the commit log short, but also to avoid having broken
commits in the chain. Squashing commits can be achieved with the
[`git rebase -i`](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html) command.
This website has a useful [in-browser tool](http://learngitbranching.js.org/?NODEMO) to help you practice your git-fu.
You can ask us for help on the Gitter chat if you need help.

Lastly, before submitting a pull request, you should look at the "Files changed"
tab and take the time to review your changes. You should check, for instance, if
you've added random spurious newlines through the code, and that you aren't
committing changes you didn't mean to.
