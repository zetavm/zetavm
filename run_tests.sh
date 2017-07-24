# Abort on first error
set -e

# Echo test commands
set -x

##############################################################################
# Core zetavm tests
##############################################################################

./zeta --test
./zeta tests/vm/ex_loop_cnt.zim
./zeta tests/vm/sub_fun.zim
./zeta tests/vm/fun_no_args.zim
./zeta tests/vm/throw_exc.zim
./zeta tests/vm/throw_exc2.zim
./zeta tests/vm/throw_exc3.zim
./zeta tests/vm/closure.zim

# Check that loading a non-existent file produces a sensible error
./zeta non_existent_file | grep --quiet "non_existent_file"
./zeta tests/vm/import_missing.zim | grep --quiet "missing_package"

# Check that exceptions work properly with host functions
./zeta tests/vm/hostfn_throw.zim | grep --quiet "missing_file"
./zeta tests/vm/hostfn_catch_exc.zim | grep --quiet "caught hostfn exc"

# Check that a sensible error message is produced if
# temporaries are left on the stack when returning
./zeta tests/vm/regress_ret_stack.zim | grep --quiet "stack"

##############################################################################
# cplush tests (C++ plush compiler implementation)
##############################################################################

# cplush self-tests
./cplush --test

./plush.sh tests/plush/trivial.pls
./plush.sh tests/plush/floats.pls
./plush.sh tests/plush/simple_exprs.pls
./plush.sh tests/plush/identfn.pls
./plush.sh tests/plush/fib.pls
./plush.sh tests/plush/for_loop.pls
./plush.sh tests/plush/for_loop_sum.pls
./plush.sh tests/plush/for_loop_cont.pls
./plush.sh tests/plush/for_loop_break.pls
./plush.sh tests/plush/line_count.pls
./plush.sh tests/plush/array_push.pls
./plush.sh tests/plush/fun_locals.pls
./plush.sh tests/plush/method_calls.pls
./plush.sh tests/plush/obj_ext.pls
./plush.sh tests/plush/throw_exc.pls
./plush.sh tests/plush/throw_exc2.pls

##############################################################################
# Plush language package tests (plush/parser.pls)
##############################################################################

# Run the Plush language package self-tests
./zeta packages/lang/plush/0/tests

# Run Plush code using the Plush language package
./zeta tests/plush/trivial.pls
./zeta tests/plush/floats.pls
./zeta tests/plush/simple_exprs.pls
./zeta tests/plush/identfn.pls
./zeta tests/plush/fib.pls
./zeta tests/plush/for_loop.pls
./zeta tests/plush/for_loop_sum.pls
./zeta tests/plush/for_loop_cont.pls
./zeta tests/plush/for_loop_break.pls
./zeta tests/plush/line_count.pls
./zeta tests/plush/array_push.pls
./zeta tests/plush/method_calls.pls
./zeta tests/plush/obj_field_names.pls
./zeta tests/plush/obj_ext.pls
./zeta tests/plush/import.pls
./zeta tests/plush/circular3.pls
./zeta tests/plush/peval.pls
./zeta tests/plush/random.pls
./zeta tests/plush/throw_exc.pls
./zeta tests/plush/throw_exc2.pls

# Check that source position is reported on errors
./zeta tests/plush/assert.pls | grep --quiet "3:1"
./zeta tests/plush/call_site_pos.pls | grep --quiet "call_site_pos.pls@8:"
./zeta tests/plush/parse_error.pls | grep --quiet "parse_error.pls@5:6"

# Check that uncaught exceptions are handled properly
./zeta tests/plush/throw_str_uncaught.pls | grep --quiet "foobar"

# Check that the Plush language package is
# able to parse its own source code
./zeta tests/plush/self_parse.pls

##############################################################################
# cscheme tests
##############################################################################

./cscheme --test
./scheme.sh tests/scheme/boolean.scm
./scheme.sh tests/scheme/if.scm
./scheme.sh tests/scheme/write.scm

##############################################################################
# espresso tests
##############################################################################

python espresso/main.py test
./espresso.sh tests/espresso/test.espr
