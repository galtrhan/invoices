# Invoices

Linux desktop app for creating client invoices. Flutter only — no mobile/web targets for now.

## Requirements

- Linux desktop
- [FVM](https://fvm.app/) (preferred) or Flutter stable **3.41+**
- Linux toolchain: `clang`, `cmake`, `ninja`, GTK 3 development packages

```bash
fvm use
fvm flutter doctor
```

## Makefile

| Command | Description |
|---------|-------------|
| `make run` | Debug run on Linux; uses `./config/config.json` |
| `make release` | Release build into `dist/` |
| `make clean` | Clean Flutter build output and `dist/` |
| `make hooks` | Enable tracked git hooks (`.githooks/`) |

```bash
make hooks     # once per clone
make run
make release   # then: ./dist/invoices
```

## Git hooks

Tracked under `.githooks/`. After clone, run `make hooks` once so Git uses them
(`core.hooksPath=.githooks`).

| Hook | Runs |
|------|------|
| `pre-commit` | `fvm flutter analyze` (or `flutter analyze` if FVM is missing) |

## Config

Tracked under `config/` in the repo. Missing keys fall back to defaults.

| Build | Preferences | Themes | Localizations |
|-------|-------------|--------|---------------|
| Debug (`make run`) | `./config/config.json` | `./config/themes/` | `./config/localizations/` |
| Release | `~/.config/invoices/config.json` | `~/.config/invoices/themes/` | `~/.config/invoices/localizations/` |

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
| `window_decorations` | `true` / `false` | Native GTK title bar (default `true`; set `false` for borderless, e.g. Hyprland) |
| `theme` | `"light"` / `"dark"` | Mode; also set in **Settings → Appearance** |
| `color_theme` | theme `name` string | Must match a loaded theme’s `name`, or `"Default"` |
| `localization` | localization `name` string | Must match a loaded pack’s `name`, or `"English"` |

### Themes (`themes/*.json`)

Built-in **Default** is always available. Custom themes are JSON files next to
the preferences file. The **filename is ignored**; each file must include:

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

Add or edit files under `themes/`, then restart the app. Pick theme and mode in
**Settings → Appearance**.

For release builds, copy `config/themes/` into `~/.config/invoices/themes/`
(or point `APP_CONFIG_PATH` at a config file whose sibling `themes/` folder
holds the JSON).

### Localizations (`localizations/*.json`)

Built-in **English** is always available (defined in Dart under `lib/l10n/`).
Custom packs are JSON files next to the preferences file. The **filename is
ignored**; each file must include:

- `name` — shown in Settings and stored as `localization`
- `strings` — map of message keys to translated text

Only override the keys you need; missing keys fall back to English at load
time. Message keys match the getters in `LocalizationDefinition` (e.g.
`nav_invoices`, `settings_title`, `invoices_new`).

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

Add or edit files under `localizations/`, then restart the app. Pick language in
**Settings → Language** (persisted as `localization` in `config.json`).

For release builds, copy `config/localizations/` into
`~/.config/invoices/localizations/` (same sibling-folder rules as themes).

Themes and localizations both load through the shared helper in
`lib/config/named_json_catalog.dart` (scan `*.json`, skip invalid/duplicates,
prepend the built-in entry).

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
linux/runner/ native GTK bootstrap + decoration config
```

## Coding standard

- Dart / Flutter with `package:flutter_lints`
- Prefer small feature folders over deep nesting
- Shared chrome/widgets before duplicating page UI
- Keep Linux runner changes minimal; prefer Dart for app logic
- Config defaults must stay in sync in Dart (`AppConfig`) and C++ (`app_config.cc`) when native options are added

```bash
fvm flutter analyze
fvm flutter test
```

## License

[MIT](LICENSE)
