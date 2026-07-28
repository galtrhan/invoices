import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoices/app_info.dart';
import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/main.dart';
import 'package:invoices/pdf/invoice_template_catalog.dart';
import 'package:invoices/pdf/invoice_template_definition.dart';
import 'package:invoices/theme/theme_catalog.dart';
import 'package:invoices/theme/theme_definition.dart';

void main() {
  testWidgets('Shows invoices shell home', (WidgetTester tester) async {
    final database = AppDatabase.memory();

    await tester.pumpWidget(
      InvoicesApp(
        config: AppConfig.defaults,
        themes: ThemeCatalog([ThemeDefinition.builtinDefault]),
        localizations: LocalizationCatalog([
          LocalizationDefinition.builtinEnglish,
        ]),
        templates: InvoiceTemplateCatalog([
          InvoiceTemplateDefinition.builtinDefault,
        ]),
        database: database,
      ),
    );
    await tester.pump();

    expect(find.text('New invoice'), findsWidgets);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Your company'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text(AppInfo.version), findsOneWidget);

    // Dispose Drift StreamBuilders, then advance time so cancel timers flush.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
