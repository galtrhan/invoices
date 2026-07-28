import 'package:invoices/config/named_json_catalog.dart';
import 'package:invoices/data/system_fonts.dart';

/// System-installed font families discovered at startup.
class SystemFontCatalog {
  SystemFontCatalog(this.families);

  final List<SystemFontFamily> families;

  static Future<SystemFontCatalog> load() async {
    return SystemFontCatalog(await SystemFontScanner.scan());
  }

  /// Returns the canonical family name, or null when [name] is unknown.
  String? resolveName(String? name) => resolve(name)?.name;

  SystemFontFamily? resolve(String? name) {
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    final needle = catalogNameKey(name);
    for (final family in families) {
      if (catalogNameKey(family.name) == needle) {
        return family;
      }
    }
    return null;
  }

  /// Template `font` overrides the settings-level PDF font.
  String? resolvePreferred({
    String? templateFont,
    String? settingsFont,
  }) {
    final override = templateFont?.trim();
    if (override != null && override.isNotEmpty) {
      return resolveName(override);
    }
    return resolveName(settingsFont);
  }
}
