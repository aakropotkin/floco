# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR ?= $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ---------------------------------------------------------------------------- #

.PHONY: all clean FORCE
.DEFAULT_GOAL = all


# ---------------------------------------------------------------------------- #

CXX        ?= c++
RM         ?= rm -f
CAT        ?= cat
PKG_CONFIG ?= pkg-config
NIX        ?= nix
UNAME      ?= uname
MKDIR      ?= mkdir
MKDIR_P    ?= $(MKDIR) -p
CP         ?= cp


# ---------------------------------------------------------------------------- #

OS ?= $(shell $(UNAME))
ifndef libExt
ifeq (Linux,$(OS))
	libExt ?= .so
else
	libExt ?= .dylib
endif  # ifeq (Linux,$(OS))
endif  # ifndef libExt


# ---------------------------------------------------------------------------- #

PREFIX     ?= $(MAKEFILE_DIR)/out
BINDIR     ?= $(PREFIX)/bin
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include


# ---------------------------------------------------------------------------- #

LIBFLOCODB = libflocodb$(libExt)

GEN_HEADERS    = floco-sql.hh
BINS           = floco-db fetch
LIBS           = $(LIBFLOCODB)
COMMON_HEADERS = pjs-core.hh fetch.hh packument.hh date.hh vinfo.hh bin-info.hh
TESTS          = $(wildcard tests/*.cc)

SQL_SCHEMAS =  ../pjs-core.sql ../fetch-info.sql ../pdefs.sql ../trees.sql
SQL_SCHEMAS += ../packument.sql


# ---------------------------------------------------------------------------- #

CXXFLAGS     = -std=c++17 '-I$(MAKEFILE_DIR)/include'
lib_CXXFLAGS = -shared -fPIC
lib_LDFLAGS  = -shared -fPIC -Wl,--no-undefined


nljson_CFLAGS   = $(shell $(PKG_CONFIG) --cflags nlohmann_json)
argparse_CFLAGS = $(shell $(PKG_CONFIG) --cflags argparse)
boost_CFLAGS    ?=                                                             \
  -I$(shell $(NIX) build --no-link --print-out-paths 'nixpkgs#boost')/include

sqlite3_CFLAGS  = $(shell $(PKG_CONFIG) --cflags sqlite3)
sqlite3_LDFLAGS =  $(shell $(PKG_CONFIG) --libs sqlite3)

nix_CFLAGS =  $(boost_CFLAGS)
nix_CFLAGS += $(shell $(PKG_CONFIG) --cflags nix-main nix-cmd nix-expr)
nix_CFLAGS += -isystem $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)
nix_CFLAGS +=                                                                 \
  -include $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)/nix/config.h
nix_LDFLAGS =  $(shell $(PKG_CONFIG) --libs nix-main nix-cmd nix-expr nix-store)
nix_LDFLAGS += -lnixfetchers

flocodb_LDFLAGS =  '-L$(MAKEFILE_DIR)/lib' -lflocodb
flocodb_LDFLAGS += -Wl,--enable-new-dtags '-Wl,-rpath,$$ORIGIN/../lib'


# ---------------------------------------------------------------------------- #

.PHONY: gen-headers bin lib include
gen-headers: $(addprefix include/,$(GEN_HEADERS))

bin: $(addprefix bin/,$(BINS))
lib: $(addprefix lib/,$(LIBS))
include: $(addprefix include/,$(GEN_HEADERS) $(COMMON_HEADERS))


# ---------------------------------------------------------------------------- #

clean: FORCE
	$(RM) $(GEN_HEADERS) $(addprefix include/,$(GEN_HEADERS))
	$(RM) $(addprefix bin/,$(BINS))
	$(RM) $(addprefix lib/,$(LIBS))
	$(RM) src/*.o
	$(RM) result
	$(RM) -r $(PREFIX)


# ---------------------------------------------------------------------------- #

src/bin-info.o: $(addprefix include/,bin-info.hh)
src/vinfo.o: $(addprefix include/,floco-sql.hh pjs-core.hh fetch.hh vinfo.hh)
src/fetch.o: $(addprefix include/,fetch.hh)
src/date.o: $(addprefix include/,date.hh)
src/pjs-core.o: $(addprefix include/,floco-sql.hh pjs-core.hh fetch.hh)


# ---------------------------------------------------------------------------- #

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -c "$<"


lib/$(LIBFLOCODB): CXXFLAGS += $(lib_CXXFLAGS) $(nix_CFLAGS) $(sqlite3_CFLAGS)
lib/$(LIBFLOCODB): CXXFLAGS += $(nljson_CFLAGS)
lib/$(LIBFLOCODB): LDFLAGS  += $(lib_LDFLAGS)
lib/$(LIBFLOCODB): LDFLAGS  += -Wl,--as-needed
lib/$(LIBFLOCODB): LDFLAGS  += $(nix_LDFLAGS) $(sqlite3_LDFLAGS)
lib/$(LIBFLOCODB): LDFLAGS  += -Wl,--no-as-needed
lib/$(LIBFLOCODB): $(addprefix src/,pjs-core.o fetch.o packument.o date.o)
lib/$(LIBFLOCODB): $(addprefix src/,vinfo.o bin-info.o)
	$(CXX) $^ $(LDFLAGS) -o "$@"



# ---------------------------------------------------------------------------- #

bin/floco-db: CXXFLAGS += $(sqlite3_CFLAGS) $(nljson_CFLAGS) $(nix_CFLAGS)
bin/floco-db: LDFLAGS  += $(sqlite3_LDFLAGS) $(nix_LDFLAGS) $(flocodb_LDFLAGS)
bin/floco-db: src/db-main.cc lib/$(LIBFLOCODB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) "$<" -o "$@"


bin/fetch: CXXFLAGS += $(argparse_CFLAGS) $(nix_CFLAGS)
bin/fetch: LDFLAGS  += $(nix_LDFLAGS) $(flocodb_LDFLAGS)
bin/fetch: src/fetch-main.cc lib/$(LIBFLOCODB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) "$<" -o "$@"


# ---------------------------------------------------------------------------- #

.PHONY: install-dirs install-bin install-lib install-include install
install: install-dirs install-bin install-lib install-include

install-dirs: FORCE
	$(MKDIR_P) $(BINDIR) $(LIBDIR) $(INCLUDEDIR)

$(INCLUDEDIR)/%: include/% | install-dirs
	$(CP) -- "$<" "$@"

$(LIBDIR)/%: lib/% | install-dirs
	$(CP) -- "$<" "$@"

$(BINDIR)/%: bin/% | install-dirs
	$(CP) -- "$<" "$@"

install-bin: $(addprefix $(BINDIR)/,$(BINS))
install-lib: $(addprefix $(LIBDIR)/,$(LIBS))
install-include: $(addprefix $(INCLUDEDIR)/,$(GEN_HEADERS) $(COMMON_HEADERS))


# ---------------------------------------------------------------------------- #

.PHONY: tests check

tests/%: CXXFLAGS += $(sqlite3_CFLAGS) $(nljson_CFLAGS)
tests/%: CXXFLAGS += $(nix_CFLAGS) $(nljson_CFLAGS)
tests/%: LDFLAGS  += $(sqlite3_LDFLAGS) $(nix_LDFLAGS)
tests/%: LDFLAGS  += $(flocodb_LDFLAGS)
$(TESTS:.cc=): %: %.cc lib/$(LIBFLOCODB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) "$<" -o "$@"


check: $(TESTS:.cc=)
	@_ec=0;                     \
	echo '';                    \
	for t in $(TESTS:.cc=); do  \
	  echo "Testing: $$t";      \
	  if "./$$t"; then          \
	    echo "PASS: $$t";       \
	  else                      \
	    _ec=1;                  \
	    echo "FAIL: $$t";       \
	  fi;                       \
	  echo '';                  \
	done;                       \
	exit "$$_ec"


# ---------------------------------------------------------------------------- #

all: gen-headers bin lib tests


# ---------------------------------------------------------------------------- #

include gen-floco-sql.mk


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
