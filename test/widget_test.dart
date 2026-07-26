import 'package:flutter_test/flutter_test.dart';
import 'package:invoices/config/app_config.dart';
import 'package:invoices/main.dart';

void main() {
  testWidgets('Shows invoices shell home', (WidgetTester tester) async {
    await tester.pumpWidget(const InvoicesApp(config: AppConfig.defaults));
    await tester.pumpAndSettle();

    expect(find.text('New invoice'), findsWidgets);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Company'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
