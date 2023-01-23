.DEFAULT_GOAL = all
.PHONY: all clean org man FORCE

SCRIPT_BNAMES =   \
  run-script      \
  install-module  \
  npm-plock       \
  from-registry

NIX ?= nix
CAT ?= cat
RM  ?= rm -f

%.org: FORCE
	$(CAT) $$(  \
	  $(NIX) build -f ./gen-docs.nix $*-org --no-link --print-out-paths;  \
	) > $@

%.1: FORCE
	$(CAT) $$(  \
	  $(NIX) build -f ./gen-docs.nix $*-man --no-link --print-out-paths;  \
	) > $@

clean: FORCE
	$(RM) $(foreach s,$(SCRIPT_BNAMES),$(s).org $(s).1)

org: $(foreach s,$(SCRIPT_BNAMES),$(s).org)

man: $(foreach s,$(SCRIPT_BNAMES),$(s).1)

all: org man
