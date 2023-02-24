
.DEFAULT_GOAL = all

.PHONY: all clean FORCE
.PHONY: update-wiki
.PHONY: update-wiki-guides

all: update-wiki
update-wiki: update-wiki-guides

RM ?= rm -f
CP ?= cp

wiki/Native-Dependencies-and-Packages-with-Installs.org: guides/native-deps.org
	$(CP) $< $@

wiki/Extending-Package-Definition-Records.org: guides/pdef-extension.org
	$(CP) $< $@

update-wiki-guides: wiki/Native-Dependencies-and-Packages-with-Installs.org
update-wiki-guides: wiki/Extending-Package-Definition-Records.org

clean: FORCE
	:
