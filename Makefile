init:
	git config core.hooksPath .githooks

serve:
	@echo "-- serving with Zola --"
	zola --config config.dev.toml serve

build:
	@echo "-- building with Zola --"
	zola build ${ARGS}

clean:
	@echo "-- cleanup --"
	rm -rf zola public
