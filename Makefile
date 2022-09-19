GIT_ROOT ?= $(git rev-parse --git-dir)
ZOLA = bin/zola

init:
	git hooks install

serve:
	@echo "-- serving with Zola --"
	$(ZOLA) --config config.dev.toml serve

help:
	$(ZOLA) --help

build:
	@echo "-- building with Zola --"
	$(ZOLA) build

check:
	@echo "-- checking the website with Zola --"
	$(ZOLA) check

clean:
	@echo "-- cleanup --"
	rm -rf public
