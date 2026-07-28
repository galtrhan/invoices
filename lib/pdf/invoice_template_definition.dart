import 'package:flutter/foundation.dart';

/// Declarative invoice PDF layout pack loaded from `<configDir>/templates`.
@immutable
class InvoiceTemplateDefinition {
  const InvoiceTemplateDefinition({
    required this.name,
    required this.marginLeft,
    required this.marginTop,
    required this.marginRight,
    required this.marginBottom,
    required this.borderColor,
    required this.headerFill,
    required this.logoMaxWidth,
    required this.logoMaxHeight,
    required this.tableBorderWidth,
    required this.columnService,
    required this.columnUnit,
    required this.columnAmount,
    required this.columnPrice,
    required this.columnSum,
    required this.showLogo,
    required this.showCompanyBlock,
    required this.showPayerBlock,
    required this.showPaymentDetails,
    required this.showAmountInWords,
    required this.showElectronicFooter,
    required this.spacingAfterHeader,
    required this.spacingAfterParties,
    required this.spacingBeforeTable,
  });

  static const defaultName = 'Default';

  final String name;

  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;

  final String borderColor;
  final String headerFill;

  final double logoMaxWidth;
  final double logoMaxHeight;

  final double tableBorderWidth;
  final double columnService;
  final double columnUnit;
  final double columnAmount;
  final double columnPrice;
  final double columnSum;

  final bool showLogo;
  final bool showCompanyBlock;
  final bool showPayerBlock;
  final bool showPaymentDetails;
  final bool showAmountInWords;
  final bool showElectronicFooter;

  final double spacingAfterHeader;
  final double spacingAfterParties;
  final double spacingBeforeTable;

  /// Matches the current hardcoded layout in [buildInvoicePdf].
  static const InvoiceTemplateDefinition builtinDefault =
      InvoiceTemplateDefinition(
    name: defaultName,
    marginLeft: 48,
    marginTop: 48,
    marginRight: 48,
    marginBottom: 48,
    borderColor: '#000000',
    headerFill: '#E0E0E0',
    logoMaxWidth: 72,
    logoMaxHeight: 72,
    tableBorderWidth: 0.7,
    columnService: 3.2,
    columnUnit: 1.1,
    columnAmount: 1.1,
    columnPrice: 1.1,
    columnSum: 1.4,
    showLogo: true,
    showCompanyBlock: true,
    showPayerBlock: true,
    showPaymentDetails: true,
    showAmountInWords: true,
    showElectronicFooter: true,
    spacingAfterHeader: 16,
    spacingAfterParties: 16,
    spacingBeforeTable: 20,
  );

  factory InvoiceTemplateDefinition.fromJson(Map<String, Object?> json) {
    final base = builtinDefault;
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Template pack requires a non-empty name');
    }

    final page = _asMap(json['page']);
    final margin = _asMap(page['margin']);
    final colors = _asMap(json['colors']);
    final logo = _asMap(json['logo']);
    final table = _asMap(json['table']);
    final columns = _asMap(table['columns']);
    final sections = _asMap(json['sections']);
    final spacing = _asMap(json['spacing']);

    return InvoiceTemplateDefinition(
      name: name.trim(),
      marginLeft: _double(margin['left'], base.marginLeft),
      marginTop: _double(margin['top'], base.marginTop),
      marginRight: _double(margin['right'], base.marginRight),
      marginBottom: _double(margin['bottom'], base.marginBottom),
      borderColor: _color(colors['border'], base.borderColor),
      headerFill: _color(colors['header_fill'], base.headerFill),
      logoMaxWidth: _double(logo['max_width'], base.logoMaxWidth),
      logoMaxHeight: _double(logo['max_height'], base.logoMaxHeight),
      tableBorderWidth: _double(table['border_width'], base.tableBorderWidth),
      columnService: _double(columns['service'], base.columnService),
      columnUnit: _double(columns['unit'], base.columnUnit),
      columnAmount: _double(columns['amount'], base.columnAmount),
      columnPrice: _double(columns['price'], base.columnPrice),
      columnSum: _double(columns['sum'], base.columnSum),
      showLogo: _bool(sections['show_logo'], base.showLogo),
      showCompanyBlock:
          _bool(sections['show_company_block'], base.showCompanyBlock),
      showPayerBlock: _bool(sections['show_payer_block'], base.showPayerBlock),
      showPaymentDetails:
          _bool(sections['show_payment_details'], base.showPaymentDetails),
      showAmountInWords:
          _bool(sections['show_amount_in_words'], base.showAmountInWords),
      showElectronicFooter:
          _bool(sections['show_electronic_footer'], base.showElectronicFooter),
      spacingAfterHeader:
          _double(spacing['after_header'], base.spacingAfterHeader),
      spacingAfterParties:
          _double(spacing['after_parties'], base.spacingAfterParties),
      spacingBeforeTable:
          _double(spacing['before_table'], base.spacingBeforeTable),
    );
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }
  return const {};
}

double _double(Object? value, double fallback) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

bool _bool(Object? value, bool fallback) {
  if (value is bool) {
    return value;
  }
  return fallback;
}

String _color(Object? value, String fallback) {
  if (value is! String) {
    return fallback;
  }
  final raw = value.trim();
  if (!RegExp(r'^#([0-9A-Fa-f]{6})$').hasMatch(raw)) {
    return fallback;
  }
  return raw.toUpperCase();
}
