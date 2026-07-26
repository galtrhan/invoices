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

```bash
make run
make release   # then: ./dist/invoices
```

## Config

Tracked under `config/` in the repo. Missing keys fall back to defaults.

| Build | Preferences | Themes |
|-------|-------------|--------|
| Debug (`make run`) | `./config/config.json` | `./config/themes/` |
| Release | `~/.config/invoices/config.json` | `~/.config/invoices/themes/` |

### Preferences (`config.json`)

```json
{
  "window_decorations": false,
  "theme": "light",
  "color_theme": "Default"
}
```

| Key | Values | Notes |
|-----|--------|-------|
| `window_decorations` | `true` / `false` | Native GTK title bar |
| `theme` | `"light"` / `"dark"` | Mode; also set in **Settings → Appearance** |
| `color_theme` | theme `name` string | Must match a loaded theme’s `name`, or `"Default"` |

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

## Layout

```
lib/
  config/     preferences load/save
  features/   invoices, clients, company, settings
  shell/      window chrome, nav
  theme/      Default + JSON theme loader
  widgets/    shared UI primitives
config/
  config.json preferences (tracked)
  themes/     custom theme JSON files
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
