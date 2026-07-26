FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
DEVICE  := linux
BUNDLE  := build/linux/x64/release/bundle
DIST    := dist
CONFIG  := $(CURDIR)/config.json

.PHONY: run release clean

run:
	$(FLUTTER) run -d $(DEVICE) --dart-define=APP_CONFIG_PATH=$(CONFIG)

release:
	$(FLUTTER) build linux --release
	@rm -rf $(DIST)
	@mkdir -p $(DIST)
	@cp -a $(BUNDLE)/. $(DIST)/
	@echo
	@echo "Release app ready: $(DIST)/"
	@echo "  Run with: ./$(DIST)/invoices"
	@echo "  Config:  $$HOME/.config/invoices/config.json"

clean:
	$(FLUTTER) clean
	@rm -rf $(DIST)
