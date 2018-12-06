init:
	git config core.hooksPath .githooks

build:
	@echo "-- building with Gutenberg --"
	zola build

serve:
	@echo "-- serving with Gutenberg --"
	zola serve
