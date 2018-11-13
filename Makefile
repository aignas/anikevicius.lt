init:
	git config core.hooksPath .githooks

build:
	@echo "-- building with Gutenberg --"
	gutenberg build

serve:
	@echo "-- serving with Gutenberg --"
	gutenberg serve
