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
| `make run` | Debug run on Linux; uses `./config.json` |
| `make release` | Release build into `dist/` |
| `make clean` | Clean Flutter build output and `dist/` |

```bash
make run
make release   # then: ./dist/invoices
```

## Config

JSON file. Missing keys fall back to defaults (`window_decorations: false`, `theme: light`).

| Build | Path |
|-------|------|
| Debug (`make run`) | `./config.json` |
| Release | `~/.config/invoices/config.json` |

```json
{
  "window_decorations": false,
  "theme": "light"
}
```

- `window_decorations` — native GTK title bar (`true` / `false`)
- `theme` — `"light"` or `"dark"` (also set in **Settings**)

`config.json` is gitignored; create it locally when needed.

## Layout

```
lib/
  config/     JSON load/save
  features/   invoices, clients, company, settings
  shell/      window chrome, nav
  theme/      light/dark ThemeData
  widgets/    shared UI primitives
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
