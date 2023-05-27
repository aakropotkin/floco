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


# ---------------------------------------------------------------------------- #

GEN_HEADERS    = floco-sql.hh
BINS           = floco-db fetch packument-main
SQL_SCHEMAS    = ../pjs-core.sql ../fetch-info.sql ../pdefs.sql ../trees.sql
COMMON_HEADERS = pjs-core.hh fetch.hh


# ---------------------------------------------------------------------------- #

CXXFLAGS = -std=c++17

sqlite3_CFLAGS  = $(shell $(PKG_CONFIG) --cflags sqlite3)
nljson_CFLAGS   = $(shell $(PKG_CONFIG) --cflags nlohmann_json)
curlpp_CFLAGS   = $(shell $(PKG_CONFIG) --cflags curlpp)
argparse_CFLAGS = $(shell $(PKG_CONFIG) --cflags argparse)
boost_CFLAGS    ?=                                                             \
  -I$(shell $(NIX) build --no-link --print-out-paths 'nixpkgs#boost')/include

sqlite3_LDFLAGS     =  $(shell $(PKG_CONFIG) --libs sqlite3)
curlpp_LDFLAGS      =  $(shell $(PKG_CONFIG) --libs curlpp)


nix_LDFLAGS =  $(shell $(PKG_CONFIG) --libs nix-main nix-cmd nix-expr nix-store)
nix_LDFLAGS += -lnixfetchers

nix_CFLAGS =  $(boost_CFLAGS)
nix_CFLAGS += $(shell $(PKG_CONFIG) --cflags nix-main nix-cmd nix-expr)
nix_CFLAGS += -isystem $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)
nix_CFLAGS += -DHAVE_NIX_FETCHERS=1
nix_CFLAGS +=                                                                 \
  -include $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)/nix/config.h


# ---------------------------------------------------------------------------- #

.PHONY: gen-headers bin
gen-headers: $(GEN_HEADERS)
bins:        $(BINS)


# ---------------------------------------------------------------------------- #

clean: FORCE
	$(RM) $(GEN_HEADERS) $(BINS)
	$(RM) result


# ---------------------------------------------------------------------------- #

all: gen-headers bins


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

floco-db: CXXFLAGS += $(sqlite3_CFLAGS) $(nljson_CFLAGS) $(nix_CFLAGS)
floco-db: LDFLAGS  += $(sqlite3_LDFLAGS) $(curlpp_LDFLAGS) $(nix_LDFLAGS)
floco-db: gen-headers pjs-core.hh pjs-core.cc db-main.cc fetch.hh fetch.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) fetch.cc pjs-core.cc db-main.cc -o "$@"


fetch: CXXFLAGS += $(curlpp_CFLAGS) $(argparse_CFLAGS) $(nix_CFLAGS)
fetch: LDFLAGS  += $(curlpp_LDFLAGS) $(nix_LDFLAGS)
fetch: fetch.hh fetch.cc fetch-main.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) fetch.cc fetch-main.cc -o "$@"


packument: CXXFLAGS += $(nljson_CFLAGS)
packument: packument.hh packument-main.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) packument-main.cc -o "$@"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
