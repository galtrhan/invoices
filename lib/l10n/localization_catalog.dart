import 'package:invoices/config/named_json_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';

/// Loads custom packs from `<configDir>/localizations/*.json` and prepends English.
class LocalizationCatalog {
  LocalizationCatalog(this.localizations);

  final List<LocalizationDefinition> localizations;

  static Future<LocalizationCatalog> load(String localizationsDirectory) async {
    final loaded = await loadNamedJsonCatalog<LocalizationDefinition>(
      directory: localizationsDirectory,
      parse: LocalizationDefinition.fromJson,
      nameOf: (pack) => pack.name,
      reservedName: LocalizationDefinition.defaultName,
    );
    return LocalizationCatalog([
      LocalizationDefinition.builtinEnglish,
      ...loaded,
    ]);
  }

  LocalizationDefinition resolve(String name) => resolveNamedCatalogItem(
        items: localizations,
        name: name,
        nameOf: (pack) => pack.name,
        fallback: LocalizationDefinition.builtinEnglish,
      );
}
