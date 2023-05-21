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


# ---------------------------------------------------------------------------- #

GEN_HEADERS = floco-sql.hh
BINS        = floco-db
SQL_SCHEMAS = ../pjs-core.sql ../fetch-info.sql ../pdefs.sql ../trees.sql


# ---------------------------------------------------------------------------- #

.PHONY: gen-headers bin
gen-headers: $(GEN_HEADERS)
bins:        $(BINS)


# ---------------------------------------------------------------------------- #

clean: FORCE
	$(RM) $(GEN_HEADERS) $(BINS)


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

CXXFLAGS = -std=c++23 $(shell $(PKG_CONFIG) --cflags sqlite3 nlohmann_json)
LDFLAGS  = $(shell $(PKG_CONFIG) --libs sqlite3)

floco-db: gen-headers pjs-core.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $ *.cc -o "$@"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
