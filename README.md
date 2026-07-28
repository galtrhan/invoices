# Invoices

Desktop app that creates client invoices. Default target is Linux. Windows is also supported. The app does not target mobile or web.

## Requirements

- Linux or Windows desktop
- [FVM](https://fvm.app/) (preferred) or Flutter stable **3.41+**
- Linux toolchain: `clang`, `cmake`, `ninja`, GTK 3 development packages
- Windows toolchain: Visual Studio with the "Desktop development with C++" workload

```bash
fvm use
fvm flutter doctor
```

Build Windows on a Windows host. Flutter does not cross-compile Windows from Linux.

## Makefile

| Command | Description |
|---------|-------------|
| `make run` | Debug run on Linux (default). Uses `./config/config.json`. |
| `make release` | Linux release build into `dist/` |
| `make run-windows` | Debug run on Windows. Uses `./config/config.json`. |
| `make release-windows` | Windows release build into `dist-windows/` |
| `make clean` | Remove Flutter build output, `dist/`, and `dist-windows/` |
| `make hooks` | Enable tracked git hooks (`.githooks/`) |

```bash
make hooks     # once per clone
make run
make release   # then: ./dist/invoices
# On Windows:
make run-windows
make release-windows   # then: dist-windows/invoices.exe
```

## Git hooks

Hooks live in `.githooks/`. After you clone, run `make hooks` once so Git uses them (`core.hooksPath=.githooks`).

| Hook | Runs |
|------|------|
| `pre-commit` | `fvm flutter analyze` (or `flutter analyze` if FVM is missing) |

## Config

Config files live under `config/` in the repo. For missing keys, the app uses defaults.

| Build | Preferences | Themes | Localizations |
|-------|-------------|--------|---------------|
| Debug (`make run` / `make run-windows`) | `./config/config.json` | `./config/themes/` | `./config/localizations/` |
| Release (Linux) | `~/.config/invoices/config.json` | `~/.config/invoices/themes/` | `~/.config/invoices/localizations/` |
| Release (Windows) | `%APPDATA%/invoices/config.json` | `%APPDATA%/invoices/themes/` | `%APPDATA%/invoices/localizations/` |

### Preferences (`config.json`)

```json
{
  "window_decorations": true,
  "theme": "light",
  "color_theme": "Default",
  "localization": "English"
}
```

| Key | Values | Notes |
|-----|--------|-------|
| `window_decorations` | `true` / `false` | Native GTK title bar. Default is `true`. Set `false` for a borderless window (for example Hyprland). |
| `theme` | `"light"` / `"dark"` | Mode. You can also set this in **Settings → Appearance**. |
| `color_theme` | theme `name` string | Must match a loaded theme `name`, or `"Default"`. |
| `localization` | localization `name` string | Must match a loaded pack `name`, or `"English"`. |

### Themes (`themes/*.json`)

The built-in **Default** theme is always available. Custom themes are JSON files next to the preferences file. The app ignores the filename. Each file must include:

- `name` — shown in Settings and stored as `color_theme`
- `light` / `dark` — full color maps for each mode

Shipped themes: **Catppuccin**, **Nord**, **Tokyo Night**, **Gruvbox**.

```json
{
  "name": "Example",
  "light": {
    "primary": "#0F6E56",
    "on_primary": "#FFFFFF",
    "surface": "#FFFFFF",
    "on_surface": "#1A2332",
    "scaffold": "#F3F5F7",
    "muted": "#5C6B7A",
    "field_fill": "#FFFFFF",
    "outline": "#D8DEE6",
    "sidebar": "#1A2332",
    "sidebar_hover": "#243041",
    "sidebar_border": "#2A3545",
    "danger": "#B42318"
  },
  "dark": {
    "primary": "#3D9B7F",
    "on_primary": "#FFFFFF",
    "surface": "#1A2332",
    "on_surface": "#E8EEF4",
    "scaffold": "#10161E",
    "muted": "#9AA8B6",
    "field_fill": "#243041",
    "outline": "#2F3B4C",
    "sidebar": "#10161E",
    "sidebar_hover": "#243041",
    "sidebar_border": "#2F3B4C",
    "danger": "#B42318"
  }
}
```

Add or edit files under `themes/`, then restart the app. Pick theme and mode in **Settings → Appearance**.

For release builds, copy `config/themes/` into `~/.config/invoices/themes/`. You can also set `APP_CONFIG_PATH` to a config file whose sibling `themes/` folder holds the JSON.

### Localizations (`localizations/*.json`)

Built-in **English** is always available (defined in Dart under `lib/l10n/`). Custom packs are JSON files next to the preferences file. The app ignores the filename. Each file must include:

- `name` — shown in Settings and stored as `localization`
- `strings` — map of message keys to translated text

Override only the keys you need. For missing keys, the app uses English at load time. Message keys match the getters in `LocalizationDefinition` (for example `nav_invoices`, `settings_title`, `invoices_new`).

Shipped pack: **Latviešu** (`config/localizations/latvian.json`).

```json
{
  "name": "Example",
  "strings": {
    "nav_invoices": "Invoices",
    "settings_title": "Settings"
  }
}
```

Add or edit files under `localizations/`, then restart the app. Pick language in **Settings → Language**. The app stores the choice as `localization` in `config.json`.

For release builds, copy `config/localizations/` into `~/.config/invoices/localizations/`. Use the same sibling-folder rules as themes.

Themes and localizations both use the shared helper in `lib/config/named_json_catalog.dart`. That helper scans `*.json`, skips invalid or duplicate entries, and adds the built-in entry first.

## Layout

```
lib/
  config/     preferences load/save + shared JSON catalog loader
  features/   invoices, clients, company, settings
  l10n/       English strings + LocalizationCatalog
  shell/      window chrome, nav
  theme/      Default theme + ThemeCatalog
  widgets/    shared UI primitives
config/
  config.json     preferences (tracked)
  themes/         custom theme JSON files
  localizations/  custom localization JSON files
linux/runner/   native GTK bootstrap + decoration config
windows/runner/ Win32 bootstrap
```

## Coding standard

- Dart / Flutter with `package:flutter_lints`
- Prefer small feature folders over deep nesting
- Use shared chrome and widgets before you copy page UI
- Keep platform runner changes small. Prefer Dart for app logic.
- When you add native options, keep config defaults in sync in Dart (`AppConfig`) and C++ (`app_config.cc`)

```bash
fvm flutter analyze
fvm flutter test
```

## License

[MIT](LICENSE)
