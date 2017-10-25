# Abort on first error
set -e

# Echo test commands
set -x

##############################################################################
# Core ZetaVM tests
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
./zeta non_existent_file | grep -q "non_existent_file"
./zeta tests/vm/import_missing.zim | grep -q "missing_package"

# Check that exceptions work properly with host functions
./zeta tests/vm/hostfn_throw.zim | grep -q "missing_file"
./zeta tests/vm/hostfn_catch_exc.zim | grep -q "caught hostfn exc"

# Check that a sensible error message is produced if
# temporaries are left on the stack when returning
./zeta tests/vm/regress_ret_stack.zim | grep -q "stack"

# Test that the help option is recognized
./zeta --help | grep -q "Usage"

##############################################################################
# cplush tests (C++ plush compiler implementation)
##############################################################################

# cplush self-tests
./cplush --test

./plush.sh tests/plush/trivial.pls
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
# Plush language package tests (plush/plush_pkg.pls)
##############################################################################

# Run the Plush language package self-tests
./zeta packages/lang/plush/0/tests

# Run Plush code using the Plush language package
./zeta tests/plush/trivial.pls
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
./zeta tests/plush/load.pls
./zeta tests/plush/circular3.pls
./zeta tests/plush/throw_exc.pls
./zeta tests/plush/throw_exc2.pls
./zeta tests/plush/catch_import_missing.pls
./zeta tests/plush/cmdline_args.pls -- foo bar

# Regression tests
./zeta tests/plush/regress_cr_char.pls
./zeta tests/plush/regress_exc_var.pls
./zeta tests/plush/regress_exc_idx.pls
./zeta tests/plush/regress_throw_str.pls | grep -q "foobar"
./zeta tests/plush/regress_method_exc.pls
./zeta tests/plush/regress_arr_idx.pls | grep -q "index"
./zeta tests/plush/regress_import.pls | grep -q "parse_error.pls"

# Check that source position is reported on errors
./zeta tests/plush/assert.pls | grep -q "3:1"
./zeta tests/plush/call_site_pos.pls | grep -q "call_site_pos.pls@8:"
./zeta tests/plush/parse_error.pls | grep -q "parse_error.pls@5:6"

# Check that the Plush language package is
# able to parse its own source code
./zeta tests/plush/self_parse.pls

# Image parsing and serialization tests
./zeta tests/plush/serialize.pls

##############################################################################
# Packages included with ZetaVM
##############################################################################

./zeta tests/packages/time.pls
./zeta tests/packages/array.pls
./zeta tests/packages/map.pls
./zeta tests/packages/math.pls
./zeta tests/packages/peval.pls
./zeta tests/packages/random.pls
./zeta tests/packages/string.pls
./zeta tests/packages/audio.pls

##############################################################################
# espresso tests
##############################################################################

python2 espresso/main.py test
./espresso.sh tests/espresso/test.espr

##############################################################################
# Benchmarks & example programs
##############################################################################

# Benchmarks
./zeta benchmarks/img_fill.pls -- 32
./zeta benchmarks/fib.pls -- 29
./zeta benchmarks/func_audio.pls -- 1
./zeta benchmarks/loop_cnt.pls -- 3
./zeta benchmarks/plush_parser.zim
./zeta benchmarks/rand_floats.pls -- 10
./zeta benchmarks/saw_wave.pls -- 10
./zeta benchmarks/sine_wave.pls -- 10
./zeta benchmarks/zsdf.pls -- 16

# Example programs
./zeta examples/line_count.pls -- examples/line_count.pls | grep -q "54"
./zeta examples/csv_parsing.pls -- examples/GOOG.csv | grep -q "rows: 23"
./zeta tests/examples/test_harness.pls -- ./examples/audio_render.pls
./zeta tests/examples/test_harness.pls -- ./examples/graphics.pls
./zeta tests/examples/test_harness.pls -- ./examples/click_grid.pls
./zeta tests/examples/test_harness.pls -- ./examples/zeta_logo.pls
./zeta tests/examples/test_harness.pls -- ./examples/game.pls
