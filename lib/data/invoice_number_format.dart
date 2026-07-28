import 'package:intl/intl.dart';

/// Default invoice number pattern: `1/2026`, `2/2026`, …
///
/// Placeholders:
/// - `{number}` — yearly sequence (1, 2, 3, …)
/// - `{number:N}` — zero-padded sequence (width N)
/// - `{yyyy}`, `{yyyy-MM-dd}`, … — any [DateFormat] pattern in braces
///
/// Date patterns use ICU/`intl` syntax (Flutter standard). Examples:
/// `yyyy` (PHP `Y`), `yy` (PHP `y`), `MM` (PHP `m`), `dd` (PHP `d`).
const defaultInvoiceNumberFormat = '{number}/{yyyy}';

final _tokenPattern = RegExp(
  r'\{(?:(?:number|NUMBER)(?::(\d+))?|([^}]+))\}',
);

String resolveInvoiceNumberFormat(String format) {
  final trimmed = format.trim();
  if (trimmed.isEmpty) {
    return defaultInvoiceNumberFormat;
  }
  // Legacy tokens from the first format release.
  return trimmed
      .replaceAll('{YEAR}', '{yyyy}')
      .replaceAll('{year}', '{yyyy}');
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
  required DateTime issuedOn,
}) {
  final pattern = resolveInvoiceNumberFormat(format);
  return pattern.replaceAllMapped(_tokenPattern, (match) {
    final datePattern = match.group(2);
    if (datePattern != null) {
      return DateFormat(datePattern).format(issuedOn);
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
    final datePattern = match.group(2);
    if (datePattern != null) {
      final dateRegex = _dateFormatToRegex(datePattern);
      if (capture) {
        buffer.write('($dateRegex)');
        group++;
      } else {
        buffer.write(dateRegex);
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

/// Maps a DateFormat pattern fragment to a matching regex.
String _dateFormatToRegex(String pattern) {
  final out = StringBuffer();
  var i = 0;
  while (i < pattern.length) {
    final char = pattern[i];
    if (_isPatternLetter(char)) {
      var end = i + 1;
      while (end < pattern.length && pattern[end] == char) {
        end++;
      }
      out.write(_patternFieldRegex(char, end - i));
      i = end;
      continue;
    }
    out.write(RegExp.escape(char));
    i++;
  }
  return out.toString();
}

bool _isPatternLetter(String char) {
  final code = char.codeUnitAt(0);
  return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
}

String _patternFieldRegex(String letter, int count) {
  switch (letter) {
    case 'y':
      return count == 2 ? r'\d{2}' : r'\d{4}';
    case 'M':
      if (count >= 3) {
        return r'[^\W\d_]+';
      }
      return count == 2 ? r'\d{2}' : r'\d{1,2}';
    case 'd':
      return count == 2 ? r'\d{2}' : r'\d{1,2}';
    default:
      return RegExp.escape(letter * count);
  }
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
