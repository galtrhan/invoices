FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
CONFIG  := $(CURDIR)/config/config.json

LINUX_BUNDLE     := build/linux/x64/release/bundle
WINDOWS_BUNDLE   := build/windows/x64/release/runner
DIST             := dist
DIST_WINDOWS     := dist-windows
DIST_WINDOWS_MSIX := dist-windows/msix

.PHONY: run release run-windows release-windows clean hooks publish-windows

run:
	$(FLUTTER) run -d linux --dart-define=APP_CONFIG_PATH=$(CONFIG)

release:
	$(FLUTTER) build linux --release
	@rm -rf $(DIST)
	@mkdir -p $(DIST)
	@cp -a $(LINUX_BUNDLE)/. $(DIST)/
	@echo
	@echo "Release app ready: $(DIST)/"
	@echo "  Run with: ./$(DIST)/invoices"
	@echo "  Config:  $$HOME/.config/invoices/config.json"

run-windows:
	$(FLUTTER) run -d windows --dart-define=APP_CONFIG_PATH=$(CONFIG)

release-windows:
	$(FLUTTER) build windows --release
	@rm -rf $(DIST_WINDOWS)
	@mkdir -p $(DIST_WINDOWS)
	@cp -a $(WINDOWS_BUNDLE)/. $(DIST_WINDOWS)/
	@echo
	@echo "Release app ready: $(DIST_WINDOWS)/"
	@echo "  Run with: $(DIST_WINDOWS)/invoices.exe"
	@echo "  Config:  %APPDATA%\\invoices\\config.json"

publish-windows: release-windows
	$(FLUTTER) pub get
	dart run msix:create --build
	@mkdir -p $(DIST_WINDOWS_MSIX)
	@mv build/windows/x64/release/msix/*.msix $(DIST_WINDOWS_MSIX)/
	@mv build/windows/x64/release/msix/*.msixupload $(DIST_WINDOWS_MSIX)/ 2>/dev/null || true
	@echo
	@echo "Windows Store package ready: $(DIST_WINDOWS_MSIX)/"
	@echo
	@echo "  Upload *.msixupload to Partner Center"
	@echo "  Before release:"
	@echo "    1. Set your Publisher identity in pubspec.yaml msix_config"
	@echo "    2. Obtain a code-signing cert (or use --store-skip-cert)"
	@echo "    3. Pin pubspec.yaml version matching your Store listing"

clean:
	$(FLUTTER) clean
	@rm -rf $(DIST) $(DIST_WINDOWS)

hooks:
	git config core.hooksPath .githooks
	@chmod +x .githooks/pre-commit
	@echo "Git hooks enabled (core.hooksPath=.githooks)"
