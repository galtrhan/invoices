import 'package:invoices/config/named_json_catalog.dart';

class Currency {
  const Currency(this.code, this.symbol, this.name);

  final String code;
  final String symbol;
  final String name;

  static const defaultCurrency = Currency('EUR', '€', 'Euro');
  static const defaultCode = 'EUR';

  static const List<Currency> supported = [
    defaultCurrency,
    Currency('USD', '\$', 'US Dollar'),
    Currency('GBP', '£', 'British Pound'),
    Currency('JPY', '¥', 'Japanese Yen'),
    Currency('CHF', 'CHF', 'Swiss Franc'),
    Currency('SEK', 'kr', 'Swedish Krona'),
    Currency('NOK', 'kr', 'Norwegian Krone'),
    Currency('DKK', 'kr', 'Danish Krone'),
    Currency('PLN', 'zł', 'Polish Zloty'),
    Currency('CZK', 'Kč', 'Czech Koruna'),
    Currency('HUF', 'Ft', 'Hungarian Forint'),
  ];

  static Currency fromCode(String code) => resolveNamedCatalogItem(
        items: supported,
        name: code,
        nameOf: (currency) => currency.code,
        fallback: defaultCurrency,
      );

  String get settingsLabel => '$symbol  $code  $name';

  String formatUi(double value) => _formatAmount(value, '.');

  String formatPdf(double value) => _formatAmount(value, ',');

  String _formatAmount(double value, String decimalSeparator) =>
      '$symbol ${value.toStringAsFixed(2).replaceAll('.', decimalSeparator)}';
}
