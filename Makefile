ZOLA_VERSION ?= 0.5.0
ZOLA_URL = https://github.com/getzola/zola/releases/download/v$(ZOLA_VERSION)/zola-v$(ZOLA_VERSION)-x86_64-unknown-linux-gnu.tar.gz

init:
	git config core.hooksPath .githooks

serve: zola
	@echo "-- serving with Zola --"
	./zola serve ${ARGS}

build: zola
	@echo "-- building with Zola --"
	./zola build ${ARGS}

zola:
	$(if $(shell which zola), \
		@echo "-- symlinking system zola binary --" \
		$(shell ln -s "$(which zola)" zola), \
		@echo "-- downloading zola binary --" \
		$(shell curl -sL $(ZOLA_URL) | tar zxv))

zola-web:
zola-local:

clean:
	@echo "-- cleanup --"
	rm zola
