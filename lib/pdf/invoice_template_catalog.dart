import 'package:invoices/config/named_json_catalog.dart';
import 'package:invoices/pdf/invoice_template_definition.dart';

/// Loads packs from `<configDir>/templates/*.json` and prepends Default.
class InvoiceTemplateCatalog {
  InvoiceTemplateCatalog(this.templates);

  final List<InvoiceTemplateDefinition> templates;

  static Future<InvoiceTemplateCatalog> load(String templatesDirectory) async {
    final loaded = await loadNamedJsonCatalog<InvoiceTemplateDefinition>(
      directory: templatesDirectory,
      parse: InvoiceTemplateDefinition.fromJson,
      nameOf: (template) => template.name,
      reservedName: InvoiceTemplateDefinition.defaultName,
    );
    return InvoiceTemplateCatalog([
      InvoiceTemplateDefinition.builtinDefault,
      ...loaded,
    ]);
  }

  InvoiceTemplateDefinition resolve(String name) => resolveNamedCatalogItem(
        items: templates,
        name: name,
        nameOf: (template) => template.name,
        fallback: InvoiceTemplateDefinition.builtinDefault,
      );

  /// Client override, then Settings default, then builtin Default.
  InvoiceTemplateDefinition resolvePreferred({
    String? clientTemplate,
    required String settingsTemplate,
  }) {
    final override = clientTemplate?.trim();
    if (override != null && override.isNotEmpty) {
      return resolve(override);
    }
    return resolve(settingsTemplate);
  }
}
