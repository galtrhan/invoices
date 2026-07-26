import 'package:flutter_test/flutter_test.dart';
import 'package:invoices/config/app_config.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/l10n/localization_catalog.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/main.dart';
import 'package:invoices/theme/theme_catalog.dart';
import 'package:invoices/theme/theme_definition.dart';

void main() {
  testWidgets('Shows invoices shell home', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    addTearDown(database.close);

    await tester.pumpWidget(
      InvoicesApp(
        config: AppConfig.defaults,
        themes: ThemeCatalog([ThemeDefinition.builtinDefault]),
        localizations: LocalizationCatalog([
          LocalizationDefinition.builtinEnglish,
        ]),
        database: database,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New invoice'), findsWidgets);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
