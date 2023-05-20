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

floco-sql.hh: ../pjs-core.sql ../fetch-info.sql ../pdefs.sql ../trees.sql
	echo '#include <string>' > "$@";
	printf 'static const std::string pjsCoreSchemaSQL = R"SQL(' >> "$@";
	$(CAT) ../pjs-core.sql >> "$@";
	echo ')SQL";' >> "$@";
	printf 'static const std::string fetchInfoSchemaSQL = R"SQL(' >> "$@";
	$(CAT) ../fetch-info.sql >> "$@";
	echo ')SQL";' >> "$@";
	printf 'static const std::string pdefsSchemaSQL = R"SQL(' >> "$@";
	$(CAT) ../pdefs.sql >> "$@";
	echo ')SQL";' >> "$@";
	printf 'static const std::string treesSchemaSQL = R"SQL(' >> "$@";
	$(CAT) ../trees.sql >> "$@";
	echo ')SQL";' >> "$@";


# ---------------------------------------------------------------------------- #

floco-db: gen-headers pjs-core.cc
	$(CXX) -std=c++17 $$( $(PKG_CONFIG) --libs --cflags sqlite3; ) *.cc -o "$@"


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
