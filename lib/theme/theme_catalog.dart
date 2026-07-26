import 'package:invoices/config/named_json_catalog.dart';
import 'package:invoices/theme/theme_definition.dart';

/// Loads custom themes from `<configDir>/themes/*.json` and prepends Default.
class ThemeCatalog {
  ThemeCatalog(this.themes);

  final List<ThemeDefinition> themes;

  static Future<ThemeCatalog> load(String themesDirectory) async {
    final loaded = await loadNamedJsonCatalog<ThemeDefinition>(
      directory: themesDirectory,
      parse: ThemeDefinition.fromJson,
      nameOf: (theme) => theme.name,
      reservedName: ThemeDefinition.defaultName,
    );
    return ThemeCatalog([ThemeDefinition.builtinDefault, ...loaded]);
  }

  ThemeDefinition resolve(String name) => resolveNamedCatalogItem(
        items: themes,
        name: name,
        nameOf: (theme) => theme.name,
        fallback: ThemeDefinition.builtinDefault,
      );
}
