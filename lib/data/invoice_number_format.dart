/// Default invoice number pattern: `1/2026`, `2/2026`, …
///
/// Placeholders:
/// - `{number}` — yearly sequence (1, 2, 3, …)
/// - `{number:N}` — zero-padded sequence (width N)
/// - `{YEAR}` / `{year}` — four-digit calendar year
const defaultInvoiceNumberFormat = '{number}/{YEAR}';

final _tokenPattern = RegExp(
  r'\{(?:(?:number|NUMBER)(?::(\d+))?|(YEAR|year))\}',
);

String resolveInvoiceNumberFormat(String format) {
  final trimmed = format.trim();
  return trimmed.isEmpty ? defaultInvoiceNumberFormat : trimmed;
}

/// Last stored sequence for [year], or `0` when the year changed.
int lastInvoiceSequenceForYear({
  required int lastSequence,
  required int lastSequenceYear,
  required int year,
}) {
  return lastSequenceYear == year ? lastSequence : 0;
}

String formatInvoiceNumber(
  String format, {
  required int number,
  required int year,
}) {
  final pattern = resolveInvoiceNumberFormat(format);
  return pattern.replaceAllMapped(_tokenPattern, (match) {
    if (match.group(2) != null) {
      return year.toString();
    }
    final width = int.tryParse(match.group(1) ?? '');
    final raw = number.toString();
    if (width == null || width <= 0) {
      return raw;
    }
    return raw.padLeft(width, '0');
  });
}

class _CompiledInvoiceNumberFormat {
  const _CompiledInvoiceNumberFormat(this.regex, this.numberGroup);

  final RegExp regex;
  final int numberGroup;
}

_CompiledInvoiceNumberFormat _compileInvoiceNumberFormat(
  String format, {
  required bool capture,
}) {
  final pattern = resolveInvoiceNumberFormat(format);
  final buffer = StringBuffer('^');
  var start = 0;
  var numberGroup = 0;
  var group = 0;
  for (final match in _tokenPattern.allMatches(pattern)) {
    buffer.write(RegExp.escape(pattern.substring(start, match.start)));
    if (match.group(2) != null) {
      buffer.write(capture ? r'(\d{4})' : r'\d{4}');
      if (capture) {
        group++;
      }
    } else {
      final width = int.tryParse(match.group(1) ?? '');
      final digits =
          (width != null && width > 0) ? '\\d{$width}' : r'\d+';
      if (capture) {
        buffer.write('($digits)');
        group++;
        numberGroup = group;
      } else {
        buffer.write(digits);
      }
    }
    start = match.end;
  }
  buffer.write(RegExp.escape(pattern.substring(start)));
  buffer.write(r'$');
  return _CompiledInvoiceNumberFormat(RegExp(buffer.toString()), numberGroup);
}

RegExp invoiceNumberFormatPattern(String format) {
  return _compileInvoiceNumberFormat(format, capture: false).regex;
}

bool matchesInvoiceNumberFormat(String value, String format) {
  return invoiceNumberFormatPattern(format).hasMatch(value);
}

/// Reads the `{number}` value from a formatted invoice number.
///
/// Returns null when [value] does not match [format], or when the format has
/// no `{number}` placeholder.
int? parseInvoiceSequence(String value, String format) {
  final compiled = _compileInvoiceNumberFormat(format, capture: true);
  if (compiled.numberGroup == 0) {
    return null;
  }
  final match = compiled.regex.firstMatch(value.trim());
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(compiled.numberGroup)!);
}
