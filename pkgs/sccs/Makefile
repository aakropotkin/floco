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

export RM         ?= rm -f
export CXX        ?= c++
export TEST       ?= test
export MKDIR      ?= mkdir
export MKDIR_P    ?= $(MKDIR) -p
export PKG_CONFIG ?= pkg-config


# ---------------------------------------------------------------------------- #

PREFIX ?= /usr/local

# ---------------------------------------------------------------------------- #

NLOHMANN_JSON_CXXFLAGS ?= $(PKG_CONFIG) --cflags nlohmann_json
NLOHMANN_JSON_LDFLAGS  ?= $(PKG_CONFIG) --libs nlohmann_json


# ---------------------------------------------------------------------------- #

CXXFLAGS = -std=c++17
CXXFLAGS += $(NLOHMANN_JSON_CXXFLAGS)

LDFLAGS =
LDFLAGS += $(NLOHMANN_JSON_LDFLAGS)

# ---------------------------------------------------------------------------- #

.PHONY: all clean check install FORCE

# ---------------------------------------------------------------------------- #

HEADERS = types.hh graph.hh edge.hh
SOURCES = edge.cc node.cc package.cc
OBJS    = $(SOURCES:%.cc=%.o)

TEST_SOURCES = tests/test-package.cc tests/test-trivial.cc
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
tests/test-trivial.cc: package.hh edge.hh node.hh


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

install: FORCE
	$(MKDIR_P) $(PREFIX)


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
