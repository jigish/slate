MDFILES := $(wildcard *.md)
HTMLFILES := $(patsubst %.md,%.html,$(MDFILES))

.PHONY: all
all: $(HTMLFILES) $(MAKEFILE_LIST)

%.html: %.md $(MAKEFILE_LIST)
	pandoc $< --output=$@ --from=markdown_github --to=html5 --css=github.css
	perl -i -ple 's/href="([^"]+).md([#"])/href="$$1.html$$2/g' $@

.PHONY: clean
clean: $(MAKEFILE_LIST)
	rm -f $(HTMLFILES)
