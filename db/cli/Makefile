# ============================================================================ #
#
#
#
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


# ---------------------------------------------------------------------------- #

OS ?= $(shell $(UNAME))
ifndef libExt
ifeq (Linux,$(OS))
	libExt ?= .so
else
	libExt ?= .dylib
endif  # ifeq (Linux,$(OS))
endif  # ifndef libExt

# FIXME
MAKEFILEDIR ?= $(CURDIR)


# ---------------------------------------------------------------------------- #

LIBFLOCODB = libflocodb$(libExt)

GEN_HEADERS    = floco-sql.hh
BINS           = floco-db fetch packument
LIBS           = $(LIBFLOCODB)
SQL_SCHEMAS    = ../pjs-core.sql ../fetch-info.sql ../pdefs.sql ../trees.sql
COMMON_HEADERS = pjs-core.hh fetch.hh


# ---------------------------------------------------------------------------- #

CXXFLAGS     = -std=c++17
lib_CXXFLAGS = -shared -fPIC

sqlite3_CFLAGS  = $(shell $(PKG_CONFIG) --cflags sqlite3)
nljson_CFLAGS   = $(shell $(PKG_CONFIG) --cflags nlohmann_json)
argparse_CFLAGS = $(shell $(PKG_CONFIG) --cflags argparse)
boost_CFLAGS    ?=                                                             \
  -I$(shell $(NIX) build --no-link --print-out-paths 'nixpkgs#boost')/include

sqlite3_LDFLAGS =  $(shell $(PKG_CONFIG) --libs sqlite3)
flocodb_LDFLAGS =  -L$(MAKEFILEDIR) -lflocodb
flocodb_LDFLAGS += -Wl,--enable-new-dtags '-Wl,-rpath,$$ORIGIN:$$ORIGIN/../lib'


nix_LDFLAGS =  $(shell $(PKG_CONFIG) --libs nix-main nix-cmd nix-expr nix-store)
nix_LDFLAGS += -lnixfetchers

nix_CFLAGS =  $(boost_CFLAGS)
nix_CFLAGS += $(shell $(PKG_CONFIG) --cflags nix-main nix-cmd nix-expr)
nix_CFLAGS += -isystem $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)
nix_CFLAGS +=                                                                 \
  -include $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)/nix/config.h


# ---------------------------------------------------------------------------- #

.PHONY: gen-headers bin lib
gen-headers: $(GEN_HEADERS)
bin:         $(BINS)
lib:         $(LIBS)


# ---------------------------------------------------------------------------- #

clean: FORCE
	$(RM) $(GEN_HEADERS) $(BINS)
	$(RM) result


# ---------------------------------------------------------------------------- #

all: gen-headers bin lib


# ---------------------------------------------------------------------------- #

floco-sql.hh: Makefile $(SQL_SCHEMAS)
	printf 'static const char pjsCoreSchemaSQL[] = R"SQL(' > "$@";
	$(CAT) ../pjs-core.sql >> "$@";
	echo ')SQL";' >> "$@";
	printf 'static const char fetchInfoSchemaSQL[] = R"SQL(' >> "$@";
	$(CAT) ../fetch-info.sql >> "$@";
	echo ')SQL";' >> "$@";
	printf 'static const char pdefsSchemaSQL[] = R"SQL(' >> "$@";
	$(CAT) ../pdefs.sql >> "$@";
	echo ')SQL";' >> "$@";
	printf 'static const char treesSchemaSQL[] = R"SQL(' >> "$@";
	$(CAT) ../trees.sql >> "$@";
	echo ')SQL";' >> "$@";


# ---------------------------------------------------------------------------- #

fetch.o: fetch.hh
date.o: date.hh
pjs-core.o: floco-sql.hh pjs-core.hh fetch.hh
packument.o: packument.hh date.hh


# ---------------------------------------------------------------------------- #

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -c "$<"


$(LIBFLOCODB): CXXFLAGS += $(lib_CXXFLAGS)
$(LIBFLOCODB): pjs-core.o fetch.o packument.o date.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ -o "$@"



# ---------------------------------------------------------------------------- #

floco-db: CXXFLAGS += $(sqlite3_CFLAGS) $(nljson_CFLAGS) $(nix_CFLAGS)
floco-db: LDFLAGS  += $(sqlite3_LDFLAGS) $(nix_LDFLAGS) $(flocodb_LDFLAGS)
floco-db: db-main.cc $(LIBFLOCODB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) db-main.cc -o "$@"


fetch: CXXFLAGS += $(argparse_CFLAGS) $(nix_CFLAGS)
fetch: LDFLAGS  += $(nix_LDFLAGS) $(flocodb_LDFLAGS)
fetch: fetch-main.cc $(LIBFLOCODB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) fetch-main.cc -o "$@"


packument: CXXFLAGS += $(nljson_CFLAGS)
packument: LDFLAGS  += $(flocodb_LDFLAGS)
packument: packument-main.cc $(LIBFLOCODB)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) packument-main.cc -o "$@"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
