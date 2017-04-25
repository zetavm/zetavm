CXXFLAGS=-std=c++11 -O0 -g -ftrapv -fbounds-check
LDFLAGS=

# TODO: change this when doing make install? Move to configure?
# Directory in which packages are found
PKGS_DIR=\"$(shell pwd)/packages/\"

# Add a preprocessor definition for the packages directory
CXXFLAGS:=${CXXFLAGS} -DPKGS_DIR="${PKGS_DIR}"

all: zetavm cplush plush-pkg

test: zetavm cplush plush-pkg
	# Core zetavm teats
	./$(ZETA_BIN) --test
	./$(ZETA_BIN) tests/zetavm/ex_loop_cnt.zim
	# cplush compiler tests
	./$(CPLUSH_BIN) --test
	./plush.sh tests/plush/trivial.pls
	./plush.sh tests/plush/simple.pls
	./plush.sh tests/plush/identfn.pls
	./plush.sh tests/plush/fib.pls
	./plush.sh tests/plush/for_loop_sum.pls
	./plush.sh tests/plush/for_loop_cont.pls
	./plush.sh tests/plush/for_loop_break.pls
	./plush.sh tests/plush/line_count.pls
	./plush.sh tests/plush/array_push.pls
	./plush.sh tests/plush/fun_locals.pls
	./plush.sh tests/plush/method_calls.pls
	./plush.sh tests/plush/obj_ext.pls
	./plush.sh plush/parser.pls tests/plush/parser.pls
	# Plush parser package tests
	./$(ZETA_BIN) tests/plush/trivial.pls
	./$(ZETA_BIN) tests/plush/simple.pls
	./$(ZETA_BIN) tests/plush/identfn.pls
	./$(ZETA_BIN) tests/plush/fib.pls
	./$(ZETA_BIN) tests/plush/for_loop_sum.pls
	./$(ZETA_BIN) tests/plush/for_loop_cont.pls
	./$(ZETA_BIN) tests/plush/for_loop_break.pls
	./$(ZETA_BIN) tests/plush/array_push.pls
	./$(ZETA_BIN) tests/plush/method_calls.pls
	./$(ZETA_BIN) tests/plush/obj_ext.pls
	./$(ZETA_BIN) tests/plush/import.pls
	./$(ZETA_BIN) tests/plush/circular3.pls
	# Check that source position is reported on assertion failure
	./$(ZETA_BIN) tests/plush/assert.pls | grep --quiet "3:1"

clean:
	rm -rf *.o *.dSYM $(ZETA_BIN) $(CPLUSH_BIN) config.status config.log

# Tells make which targets are not files
.PHONY: all test clean zetavm cplush plush-pkg

##############################################################################
# ZetaVM
##############################################################################

ZETA_BIN=zeta

ZETA_SRCS=       \
vm/runtime.cpp  \
vm/parser.cpp   \
vm/interp.cpp   \
vm/core.cpp     \
vm/main.cpp     \

zetavm: vm/*.cpp vm/*.h
	$(CXX) $(CXXFLAGS) -o $(ZETA_BIN) $(ZETA_SRCS)

##############################################################################
# Plush compiler
##############################################################################

CPLUSH_BIN=cplush

CPLUSH_SRCS=    \
plush/parser.cpp   \
plush/codegen.cpp  \
plush/main.cpp     \

cplush: plush/*.cpp plush/*.h
	$(CXX) $(CXXFLAGS) -o $(CPLUSH_BIN) $(CPLUSH_SRCS)

plush-pkg: plush/parser.pls
	mkdir -p packages/lang/plush/0
	./$(CPLUSH_BIN) plush/parser.pls > packages/lang/plush/0/package
