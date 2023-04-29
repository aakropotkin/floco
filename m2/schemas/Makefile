##
# Floco Schemas
#
# @file
# @version 0.1

NIX ?= nix
JQ  ?= jq
RM  ?= rm -f

.DEFAULT_GOAL = schemas.json

.PHONY: FORCE clean

schemas.json: generic.nix
	$(NIX) eval --json --impure -f $<|$(JQ) >$@

CLEANFILES = schemas.json

clean: FORCE
	$(RM) $(CLEANFILES)


# end
