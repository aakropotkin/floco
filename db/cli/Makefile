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

GEN_HEADERS    = floco-sql.hh
BINS           = floco-db fetch
SQL_SCHEMAS    = ../pjs-core.sql ../fetch-info.sql ../pdefs.sql ../trees.sql
COMMON_HEADERS = pjs-core.hh


# ---------------------------------------------------------------------------- #

CXXFLAGS =                                                      \
  -std=c++17                                                    \
  $(shell $(PKG_CONFIG) --cflags sqlite3 nlohmann_json curlpp)

LDFLAGS = $(shell $(PKG_CONFIG) --libs sqlite3 curlpp)


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

floco-db: gen-headers $(COMMON_HEADERS) pjs-core.cc db-main.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) db-main.cc pjs-core.cc -o "$@"


fetch: fetch.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) fetch.cc -o "$@"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
