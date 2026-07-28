import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:invoices/config/currency.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/pdf/invoice_template_definition.dart';

class InvoicePdfLabels {
  const InvoicePdfLabels({
    required this.title,
    required this.numberPrefix,
    required this.regNo,
    required this.payer,
    required this.tel,
    required this.email,
    required this.service,
    required this.unit,
    required this.amount,
    required this.price,
    required this.sumHeader,
    required this.payBy,
    required this.sum,
    required this.paymentAmount,
    required this.amountInWords,
    required this.amountInWordsFn,
    required this.electronicFooter,
  });

  factory InvoicePdfLabels.fromLocalization(LocalizationDefinition l10n) {
    return InvoicePdfLabels(
      title: l10n.pdfInvoiceTitle,
      numberPrefix: l10n.pdfNumberPrefix,
      regNo: l10n.pdfRegNo,
      payer: l10n.pdfPayer,
      tel: l10n.pdfTel,
      email: l10n.pdfEmail,
      service: l10n.pdfService,
      unit: l10n.pdfUnit,
      amount: l10n.pdfAmount,
      price: l10n.pdfPrice,
      sumHeader: l10n.pdfSumHeader,
      payBy: l10n.pdfPayBy,
      sum: l10n.pdfSum,
      paymentAmount: l10n.pdfPaymentAmount,
      amountInWords: l10n.pdfAmountInWords,
      amountInWordsFn: l10n.amountInWords,
      electronicFooter: l10n.pdfElectronicFooter,
    );
  }

  final String title;
  final String numberPrefix;
  final String regNo;
  final String payer;
  final String tel;
  final String email;
  final String service;
  final String unit;
  final String amount;
  final String price;
  final String sumHeader;
  final String payBy;
  final String sum;
  final String paymentAmount;
  final String amountInWords;
  final Future<String> Function(double) amountInWordsFn;
  final String electronicFooter;
}

class InvoicePdfLine {
  const InvoicePdfLine({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.unit = '',
  });

  final String description;
  final String unit;
  final double quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;
}

class InvoicePdfData {
  const InvoicePdfData({
    required this.number,
    required this.issuedOn,
    required this.dueOn,
    required this.companyName,
    required this.companyTaxId,
    required this.companyAddress,
    required this.companyPaymentDetails,
    required this.clientName,
    required this.clientTaxId,
    required this.clientAddress,
    required this.clientPhone,
    required this.clientEmail,
    required this.lines,
    required this.labels,
    required this.fontRegular,
    required this.fontBold,
    required this.currency,
    this.logoBytes,
    this.template = InvoiceTemplateDefinition.builtinDefault,
  });

  final String number;
  final DateTime issuedOn;
  final DateTime dueOn;
  final String companyName;
  final String companyTaxId;
  final String companyAddress;
  final String companyPaymentDetails;
  final Uint8List? logoBytes;
  final ByteData fontRegular;
  final ByteData fontBold;
  final String clientName;
  final String clientTaxId;
  final String clientAddress;
  final String clientPhone;
  final String clientEmail;
  final List<InvoicePdfLine> lines;
  final InvoicePdfLabels labels;
  final InvoiceTemplateDefinition template;
  final Currency currency;

  double get total =>
      lines.fold<double>(0, (sum, line) => sum + line.total);
}

Future<Uint8List> buildInvoicePdf(InvoicePdfData data) async {
  final doc = pw.Document();
  final template = data.template;
  final logo =
      data.logoBytes == null ? null : pw.MemoryImage(data.logoBytes!);
  final total = data.total;
  final labels = data.labels;
  final border = pw.TableBorder.all(
    width: template.tableBorderWidth,
    color: _pdfColor(template.borderColor),
  );
  final headerFill = _pdfColor(template.headerFill);
  final theme = _pdfTheme(data.fontRegular, data.fontBold);
  final showLogo = template.showLogo && logo != null;
  final amountInWordsStr = template.showAmountInWords
      ? '${labels.amountInWords} ${await labels.amountInWordsFn(total)}'
      : null;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.fromLTRB(
        template.marginLeft,
        template.marginTop,
        template.marginRight,
        template.marginBottom,
      ),
      theme: theme,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    labels.title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (showLogo)
                      pw.Container(
                        width: template.logoMaxWidth,
                        height: template.logoMaxHeight,
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Image(logo, fit: pw.BoxFit.contain),
                      ),
                    pw.Text('${labels.numberPrefix} ${data.number}'),
                    pw.SizedBox(height: 2),
                    pw.Text(_pdfFormatDate(data.issuedOn)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: template.spacingAfterHeader),
            if (template.showCompanyBlock) ...[
              ..._companyBlock(data, template),
              if (template.showPayerBlock)
                pw.SizedBox(height: template.spacingAfterParties),
            ],
            if (template.showPayerBlock) ..._payerBlock(data),
            if (template.showCompanyBlock || template.showPayerBlock)
              pw.SizedBox(height: template.spacingBeforeTable),
            pw.Table(
              border: border,
              columnWidths: {
                0: pw.FlexColumnWidth(template.columnService),
                1: pw.FlexColumnWidth(template.columnUnit),
                2: pw.FlexColumnWidth(template.columnAmount),
                3: pw.FlexColumnWidth(template.columnPrice),
                4: pw.FlexColumnWidth(template.columnSum),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerFill),
                  children: [
                    _headerCell(labels.service),
                    _headerCell(labels.unit, align: pw.TextAlign.center),
                    _headerCell(labels.amount, align: pw.TextAlign.center),
                    _headerCell(labels.price, align: pw.TextAlign.center),
                    _headerCell(labels.sumHeader, align: pw.TextAlign.right),
                  ],
                ),
                for (final line in data.lines)
                  pw.TableRow(
                    children: [
                      _bodyCell(line.description),
                      _bodyCell(line.unit, align: pw.TextAlign.center),
                      _bodyCell(
                        _pdfFormatQuantity(line.quantity),
                        align: pw.TextAlign.center,
                      ),
                      _bodyCell(
                        _pdfFormatQuantity(line.unitPrice),
                        align: pw.TextAlign.center,
                      ),
                      _bodyCell(
                        data.currency.formatPdf(line.total),
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                pw.TableRow(
                  children: [
                    _bodyCell(
                      '${labels.payBy} ${_pdfFormatDate(data.dueOn)}',
                    ),
                    _bodyCell(''),
                    _bodyCell(''),
                    _bodyCell(''),
                    _bodyCell(''),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _bodyCell(labels.sum),
                    _bodyCell(''),
                    _bodyCell(''),
                    _bodyCell(''),
                    _bodyCell(
                      data.currency.formatPdf(total),
                      align: pw.TextAlign.right,
                      bold: true,
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _bodyCell(labels.paymentAmount, bold: true),
                    _bodyCell(''),
                    _bodyCell(''),
                    _bodyCell(''),
                    _bodyCell(
                      data.currency.formatPdf(total),
                      align: pw.TextAlign.right,
                      bold: true,
                    ),
                  ],
                ),
              ],
            ),
            if (amountInWordsStr != null) ...[
              pw.SizedBox(height: 14),
              pw.Text(amountInWordsStr),
            ],
            pw.Spacer(),
            if (template.showElectronicFooter)
              pw.Text(labels.electronicFooter),
          ],
        );
      },
    ),
  );

  return doc.save();
}

PdfColor _pdfColor(String hex) {
  final raw = hex.startsWith('#') ? hex.substring(1) : hex;
  final value = int.tryParse(raw, radix: 16) ?? 0;
  return PdfColor.fromInt(0xFF000000 | value);
}

pw.ThemeData? _cachedPdfTheme;
ByteData? _cachedThemeRegular;
ByteData? _cachedThemeBold;

pw.ThemeData _pdfTheme(ByteData regular, ByteData bold) {
  if (_cachedPdfTheme != null &&
      identical(_cachedThemeRegular, regular) &&
      identical(_cachedThemeBold, bold)) {
    return _cachedPdfTheme!;
  }
  _cachedThemeRegular = regular;
  _cachedThemeBold = bold;
  return _cachedPdfTheme = pw.ThemeData.withFont(
    base: pw.Font.ttf(regular),
    bold: pw.Font.ttf(bold),
  );
}

List<pw.Widget> _companyBlock(
  InvoicePdfData data,
  InvoiceTemplateDefinition template,
) {
  final lines = <String>[
    if (data.companyName.trim().isNotEmpty) data.companyName.trim(),
    if (data.companyTaxId.trim().isNotEmpty)
      '${data.labels.regNo} ${data.companyTaxId.trim()}',
    ..._splitLines(data.companyAddress),
    if (template.showPaymentDetails)
      ..._splitLines(data.companyPaymentDetails),
  ];
  return [
    for (final line in lines)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1),
        child: pw.Text(
          line,
          style: pw.TextStyle(
            fontWeight: line == data.companyName.trim()
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
      ),
  ];
}

List<pw.Widget> _payerBlock(InvoicePdfData data) {
  final nameTax = [
    if (data.clientName.trim().isNotEmpty) data.clientName.trim(),
    if (data.clientTaxId.trim().isNotEmpty) 'NIF: ${data.clientTaxId.trim()}',
  ].join(' ');

  final lines = <String>[
    if (nameTax.isNotEmpty) nameTax,
    ..._splitLines(data.clientAddress),
    if (data.clientPhone.trim().isNotEmpty)
      '${data.labels.tel} ${data.clientPhone.trim()}',
    if (data.clientEmail.trim().isNotEmpty)
      '${data.labels.email} ${data.clientEmail.trim()}',
  ];

  return [
    pw.Text(
      data.labels.payer,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    ),
    for (final line in lines)
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1),
        child: pw.Text(line),
      ),
  ];
}

pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    ),
  );
}

pw.Widget _bodyCell(
  String text, {
  pw.TextAlign align = pw.TextAlign.left,
  bool bold = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

List<String> _splitLines(String raw) {
  return raw
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

String _pdfFormatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m.${date.year}';
}

String _pdfFormatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String invoicePdfFileName({
  required String number,
  required DateTime issuedOn,
  required String clientName,
  String? languageName,
}) {
  final date =
      '${issuedOn.day.toString().padLeft(2, '0')}'
      '${issuedOn.month.toString().padLeft(2, '0')}'
      '${issuedOn.year}';
  final parts = <String>[
    _safeFilePart(number),
    date,
    if (clientName.trim().isNotEmpty) _safeFilePart(clientName),
    if (languageName != null && languageName.trim().isNotEmpty)
      _safeFilePart(languageName),
  ];
  return '${parts.join('-')}.pdf';
}

String _safeFilePart(String raw) {
  final cleaned = raw
      .trim()
      .replaceAll(RegExp(r'[^\w\-]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return cleaned.isEmpty ? 'invoice' : cleaned.toLowerCase();
}


