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
COMMON_HEADERS = pjs-core.hh fetch.hh


# ---------------------------------------------------------------------------- #

CXXFLAGS = -std=c++17

sqlite3_CFLAGS = $(shell $(PKG_CONFIG) --cflags sqlite3)
nljson_CFLAGS  = $(shell $(PKG_CONFIG) --cflags nlohmann_json)
curlpp_CFLAGS  = $(shell $(PKG_CONFIG) --cflags curlpp)

sqlite3_LDFLAGS = $(shell $(PKG_CONFIG) --libs sqlite3)
curlpp_LDFLAGS  = $(shell $(PKG_CONFIG) --libs curlpp)


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

floco-db: CXXFLAGS += $(sqlite3_CFLAGS) $(nljson_CFLAGS)
floco-db: LDFLAGS  += $(sqlite3_LDFLAGS)
floco-db: gen-headers pjs-core.hh pjs-core.cc db-main.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) pjs-core.cc db-main.cc -o "$@"


fetch: CXXFLAGS += $(curlpp_CFLAGS)
fetch: LDFLAGS  += $(curlpp_LDFLAGS)
fetch: fetch.hh fetch.cc fetch-main.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) fetch.cc fetch-main.cc -o "$@"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
