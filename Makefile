GIT_ROOT ?= $(git rev-parse --git-dir)
ZOLA = zola

init:
	git hooks install

serve:
	@echo "-- serving with Zola --"
	$(ZOLA) --config config.dev.toml serve

build:
	@echo "-- building with Zola --"
	$(ZOLA) build ${ARGS}

check:
	@echo "-- checking the website with Zola --"
	$(ZOLA) check ${ARGS}

clean:
	@echo "-- cleanup --"
	rm -rf public
