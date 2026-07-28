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

| Build | Preferences | Themes | Localizations | Templates |
|-------|-------------|--------|---------------|-----------|
| Debug (`make run` / `make run-windows`) | `./config/config.json` | `./config/themes/` | `./config/localizations/` | `./config/templates/` |
| Release (Linux) | `~/.config/invoices/config.json` | `~/.config/invoices/themes/` | `~/.config/invoices/localizations/` | `~/.config/invoices/templates/` |
| Release (Windows) | `%APPDATA%/invoices/config.json` | `%APPDATA%/invoices/themes/` | `%APPDATA%/invoices/localizations/` | `%APPDATA%/invoices/templates/` |

Database and media also live under the same config directory (`invoices.db`, `media/`).

### Preferences (`config.json`)

```json
{
  "window_decorations": true,
  "theme": "light",
  "color_theme": "Default",
  "localization": "English",
  "pdf_template": "Default"
}
```

| Key | Values | Notes |
|-----|--------|-------|
| `window_decorations` | `true` / `false` | Linux only. Controls the native GTK title bar. Default is `true`. Set `false` for a borderless window (for example Hyprland). Windows ignores this key. |
| `theme` | `"light"` / `"dark"` | Mode. You can also set this in **Settings → Appearance**. |
| `color_theme` | theme `name` string | Must match a loaded theme `name`, or `"Default"`. |
| `localization` | localization `name` string | Must match a loaded pack `name`, or `"English"`. |
| `pdf_template` | template `name` string | Must match a loaded PDF template `name`, or `"Default"`. |

You can set `APP_CONFIG_PATH` to a preferences file. Sibling folders `themes/`, `localizations/`, and `templates/` sit next to that file.

### Themes (`themes/*.json`)

The built-in **Default** theme is always available. Custom themes are JSON files next to the preferences file. The app ignores the filename. Each file must include:

- `name` — shown in Settings and stored as `color_theme`
- `light` / `dark` — full color maps for each mode

Every color key below is required in both maps. A missing key skips the pack.

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

For release builds, copy `config/themes/` into the release `themes/` path from the table above.

### Localizations (`localizations/*.json`)

Built-in **English** is always available (defined in Dart under `lib/l10n/`). Custom packs are JSON files next to the preferences file. The app ignores the filename. Each file must include:

- `name` — shown in Settings and stored as `localization`
- `strings` — map of message keys to translated text

Optional field:

- `locale_code` — BCP 47 locale tag (for example `lv-LV`, `de-DE`). The app uses the ISO 639-1 language part for PDF **amount in words** via [num2text](https://pub.dev/packages/num2text). Without `locale_code`, the app uses the built-in English amount-in-words formatter. UI strings still come from `strings`. Built-in English does not need this field.

Supported language codes for amount in words: `en`, `lv`, `fr`, `de`, `es`, `it`, `pt`, `nl`, `fi`, `lt`, `sk`, `sl`, `hr`, `el`. Other codes fall back to English.

Override only the keys you need. For missing keys, the app uses English at load time.

Message keys match the `strings` map in `LocalizationDefinition.builtinEnglish`. See `lib/l10n/localization_definition.dart` for the full key list (for example `nav_invoices`, `settings_title`, `settings_pdf_template`).

Shipped pack: **Latviešu** (`config/localizations/latvian.json`).

```json
{
  "name": "Example",
  "locale_code": "lv-LV",
  "strings": {
    "nav_invoices": "Invoices",
    "settings_title": "Settings"
  }
}
```

Add or edit files under `localizations/`, then restart the app. Pick language in **Settings → Language**. The app stores the choice as `localization` in `config.json`.

For release builds, copy `config/localizations/` into the release `localizations/` path from the table above.

### PDF templates (`templates/*.json`)

The built-in **Default** PDF template is always available. Custom packs are JSON files next to the preferences file. The app ignores the filename.

Each file must include a non-empty `name`. That name is shown in Settings and stored as `pdf_template`.

All other fields are optional. Missing fields use Default values from `InvoiceTemplateDefinition.builtinDefault`. See `lib/pdf/invoice_template_definition.dart`.

| Section | Keys | Notes |
|---------|------|-------|
| `page.margin` | `left`, `top`, `right`, `bottom` | Page margins in PDF points. |
| `colors` | `border`, `header_fill` | Hex colors as `#RRGGBB`. Invalid values fall back to Default. |
| `logo` | `max_width`, `max_height` | Max logo size in PDF points. |
| `table` | `border_width` | Table stroke width. |
| `table.columns` | `service`, `unit`, `amount`, `price`, `sum` | Relative column widths. |
| `sections` | `show_logo`, `show_company_block`, `show_payer_block`, `show_payment_details`, `show_amount_in_words`, `show_electronic_footer` | Booleans that show or hide PDF blocks. |
| `spacing` | `after_header`, `after_parties`, `before_table` | Vertical gaps in PDF points. |

Shipped pack: **Compact** (`config/templates/compact.json`).

```json
{
  "name": "Example",
  "page": {
    "margin": { "left": 36, "top": 36, "right": 36, "bottom": 36 }
  },
  "colors": {
    "border": "#000000",
    "header_fill": "#F5F5F5"
  },
  "logo": {
    "max_width": 56,
    "max_height": 56
  },
  "table": {
    "border_width": 0.5,
    "columns": {
      "service": 3.4,
      "unit": 1.0,
      "amount": 1.0,
      "price": 1.1,
      "sum": 1.3
    }
  },
  "sections": {
    "show_logo": true,
    "show_company_block": true,
    "show_payer_block": true,
    "show_payment_details": true,
    "show_amount_in_words": true,
    "show_electronic_footer": true
  },
  "spacing": {
    "after_header": 10,
    "after_parties": 10,
    "before_table": 14
  }
}
```

Add or edit files under `templates/`, then restart the app. Pick a template in **Settings → PDF template**. The app stores the choice as `pdf_template` in `config.json`.

For release builds, copy `config/templates/` into the release `templates/` path from the table above.

Themes, localizations, and PDF templates use the shared helper in `lib/config/named_json_catalog.dart`. That helper scans `*.json`, skips invalid or duplicate entries, and leaves the built-in entry first.

## Layout

```
lib/
  config/     preferences load/save + shared JSON catalog loader
  features/   invoices, clients, company, settings
  l10n/       English strings + LocalizationCatalog
  pdf/        Default PDF template + InvoiceTemplateCatalog
  shell/      window chrome, nav
  theme/      Default theme + ThemeCatalog
  widgets/    shared UI primitives
config/
  config.json     preferences (tracked)
  themes/         custom theme JSON files
  localizations/  custom localization JSON files
  templates/      custom PDF template JSON files
  media/          company and client logos
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
