GIT_ROOT ?= $(git rev-parse --git-dir)
ZOLA = bin/zola

init:
	git hooks install

serve:
	@echo "-- serving with Zola --"
	$(ZOLA) -p 1111:1111 -- --config config.dev.toml serve --interface 0.0.0.0

help:
	$(ZOLA) -- --help

build:
	@echo "-- building with Zola --"
	$(ZOLA) -- build

check:
	@echo "-- checking the website with Zola --"
	$(ZOLA) -- check

clean:
	@echo "-- cleanup --"
	rm -rf -- public

.PHONY: static
static: static/assets/webfonts

.PHONY: static/assets/webfonts
static/assets/webfonts:
	curl -o tmp.zip https://use.fontawesome.com/releases/v6.2.0/fontawesome-free-6.2.0-web.zip
	unzip tmp.zip -d tmp
	mkdir -p $@
	mv tmp/fontawesome-free-6.2.0-web/webfonts/* $@
	rm -rf tmp.zip
