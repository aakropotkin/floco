# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

.DEFAULT_GOAL = all

# ---------------------------------------------------------------------------- #

.PHONY: all clean FORCE
.PHONY: publish commit-wiki pull-wiki push-wiki update-wiki
.PHONY: pub

# ---------------------------------------------------------------------------- #

all: update-wiki
pub: publish

# ---------------------------------------------------------------------------- #

RM   ?= rm -f
CP   ?= cp
GIT  ?= git
GREP ?= grep
ECHO ?= echo


# ---------------------------------------------------------------------------- #

clean: FORCE
	:;


# ---------------------------------------------------------------------------- #

.PHONY: update-wiki-guides

update-wiki: pull-wiki update-wiki-guides

wiki/Native-Dependencies-and-Packages-with-Installs.org: guides/native-deps.org
	$(CP) $< $@;

wiki/Extending-Package-Definition-Records.org: guides/pdef-extension.org
	$(CP) $< $@;

update-wiki-guides: wiki/Native-Dependencies-and-Packages-with-Installs.org
update-wiki-guides: wiki/Extending-Package-Definition-Records.org


pull-wiki: FORCE
	@$(GIT) -C wiki pull;

commit-wiki: pull-wiki
	@if $(GIT) -C wiki status --short|$(GREP) -q .; then  \
	  $(GIT) -C wiki add .;                               \
	  $(GIT) -C wiki commit -m "Update wiki";             \
	fi

push-wiki: commit-wiki
	@if $(GIT) -C wiki status --short --branch|$(GREP) -q ahead; then  \
	  $(GIT) -C wiki push;                                             \
	  $(ECHO) Pushed wiki;                                             \
	fi;                                                                \

publish: update-wiki push-wiki


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
