import 'package:invoices/config/named_json_catalog.dart';
import 'package:invoices/data/system_fonts.dart';

class SystemFontCatalog {
  SystemFontCatalog(this.families);

  final List<SystemFontFamily> families;

  static Future<SystemFontCatalog> load() async {
    return SystemFontCatalog(await SystemFontScanner.scan());
  }

  String? resolveName(String? name) => resolve(name)?.name;

  SystemFontFamily? resolve(String? name) {
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    return findNamedCatalogItem(
      items: families,
      name: name,
      nameOf: (family) => family.name,
    );
  }

  /// Template `font` overrides the settings-level PDF font.
  SystemFontFamily? resolvePreferred({
    String? templateFont,
    String? settingsFont,
  }) {
    final override = templateFont?.trim();
    if (override != null && override.isNotEmpty) {
      return resolve(override);
    }
    return resolve(settingsFont);
  }
}
