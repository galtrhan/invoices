import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:invoices/l10n/localization_definition.dart';

class InvoicePdfPreviewPage extends StatelessWidget {
  const InvoicePdfPreviewPage({
    super.key,
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 96,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.invoicesPreviewCancel),
        ),
        title: Text(l10n.invoicesPreviewTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.invoicesPreviewSave),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => Future<Uint8List>.value(bytes),
        pdfFileName: fileName,
        useActions: false,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}
