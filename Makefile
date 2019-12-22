init:
	git config core.hooksPath .githooks

serve:
	@echo "-- serving with Zola --"
	zola --config config.dev.toml serve

build:
	@echo "-- building with Zola --"
	zola build ${ARGS}

check:
	@echo "-- checking the website with Zola --"
	zola check ${ARGS}

clean:
	@echo "-- cleanup --"
	rm -rf zola public
