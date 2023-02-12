# -*- Makefile -*-
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

SHELL ?= /bin/sh
export SHELL

.DEFAULT_GOAL = all

MAKEFILE_DIR = $(patsubst %/, %, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ---------------------------------------------------------------------------- #

export RM   ?= rm -f
export CXX  ?= c++
export TEST ?= test

# ---------------------------------------------------------------------------- #

CXXFLAGS = -std=c++17

# ---------------------------------------------------------------------------- #

.PHONY: all clean check FORCE

# ---------------------------------------------------------------------------- #

HEADERS = types.hh graph.hh edge.hh
SOURCES = edge.cc node.cc
OBJS    = $(SOURCES:%.cc=%.o)

TEST_SOURCES = tests/test-package.cc
TEST_OBJS    = $(TEST_SOURCES:%.cc=%.o)
TESTS        = $(TEST_SOURCES:%.cc=%)


# ---------------------------------------------------------------------------- #

all: $(OBJS) $(TESTS)

# ---------------------------------------------------------------------------- #

clean: FORCE
	$(RM) $(OBJS)
	$(RM) $(TEST_OBJS)
	$(RM) $(TESTS)


# ---------------------------------------------------------------------------- #

package.hh edge.hh node.hh: types.hh
graph.hh: types.hh

edge.cc: types.hh edge.hh node.hh
node.cc: types.hh package.hh edge.hh


# ---------------------------------------------------------------------------- #

$(TESTS): %: %.o $(OBJS)
	$(CXX) -o $@ $(CXXFLAGS) $(LDFLAGS) $^

tests/test-package.cc: package.hh


# ---------------------------------------------------------------------------- #

check: $(TESTS)
	@_ec=0;                            \
	for t in $(TESTS); do              \
	  echo "---" >&2;                  \
	  echo "Checking: $$t" >&2;        \
	  ./$$t;                           \
	  _tec="$$?";                      \
	  if $(TEST) "$$_tec" -ne 0; then  \
	    _ec="$$(( $$_ec + 1 ))";       \
	    echo "FAIL ($$_tec)" >&2;      \
	  else                             \
	    echo "PASS" >&2;               \
	  fi;                              \
	done;                              \
	echo "===" >&2;                    \
	if $(TEST) "$$_ec" -eq 0; then     \
	  echo "SUCCESS" >&2;              \
	else                               \
	  echo "FAILURE" >&2;              \
	fi;                                \
	exit "$$_ec";


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
