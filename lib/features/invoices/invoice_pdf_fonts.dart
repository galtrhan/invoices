import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'package:invoices/data/system_font_catalog.dart';
import 'package:invoices/data/system_fonts.dart';

class InvoicePdfFonts {
  InvoicePdfFonts._({
    required this.regular,
    required this.bold,
  });

  final ByteData regular;
  final ByteData bold;

  static final _cache = <String, ({ByteData regular, ByteData bold})>{};

  static const _autoPreferredKeys = [
    'dejavu sans',
    'liberation sans',
    'noto sans',
    'arial',
  ];

  static Future<InvoicePdfFonts> load({
    required SystemFontCatalog catalog,
    SystemFontFamily? family,
  }) async {
    if (family != null) {
      return _loadFromFamily(family);
    }

    for (final key in _autoPreferredKeys) {
      final match = catalog.resolve(key);
      if (match != null) {
        return _loadFromFamily(match);
      }
    }

    return InvoicePdfFonts._(
      regular: await rootBundle.load('assets/fonts/DejaVuSans.ttf'),
      bold: await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'),
    );
  }

  static Future<InvoicePdfFonts> _loadFromFamily(SystemFontFamily family) {
    return _loadFromPaths(
      family.regularPath,
      family.boldPath ?? family.regularPath,
    );
  }

  static Future<InvoicePdfFonts> _loadFromPaths(
    String regularPath,
    String boldPath,
  ) async {
    final cacheKey = '$regularPath|$boldPath';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return InvoicePdfFonts._(regular: cached.regular, bold: cached.bold);
    }

    final regular = await _readFile(regularPath);
    final bold = await _readFile(boldPath);
    final result = (
      regular: regular ?? await rootBundle.load('assets/fonts/DejaVuSans.ttf'),
      bold: bold ??
          regular ??
          await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'),
    );
    _cache[cacheKey] = result;
    return InvoicePdfFonts._(regular: result.regular, bold: result.bold);
  }

  static Future<ByteData?> _readFile(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return ByteData.view(bytes.buffer);
    } on FileSystemException {
      return null;
    }
  }
}
