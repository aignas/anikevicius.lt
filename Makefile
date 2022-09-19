GIT_ROOT ?= $(git rev-parse --git-dir)
ZOLA = docker run -u "$(shell id -u):$(shell id -g)" -v $(PWD):/app --workdir /app ghcr.io/getzola/zola:v0.16.0

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
