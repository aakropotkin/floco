# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

include/floco-sql.hh: gen-floco-sql.mk $(SQL_SCHEMAS)
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
#
#
#
# ============================================================================ #
