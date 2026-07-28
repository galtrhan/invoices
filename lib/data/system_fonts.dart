import 'dart:io';
import 'dart:typed_data';

class SystemFontFamily {
  const SystemFontFamily({
    required this.name,
    required this.regularPath,
    this.boldPath,
  });

  final String name;
  final String regularPath;
  final String? boldPath;
}

class SystemFontScanner {
  static List<SystemFontFamily>? _cached;
  static Future<List<SystemFontFamily>>? _scanInFlight;

  static Future<List<SystemFontFamily>> scan() {
    final cached = _cached;
    if (cached != null) {
      return Future.value(cached);
    }
    return _scanInFlight ??= _scan().then((result) {
      _cached = result;
      return result;
    });
  }

  static Future<List<SystemFontFamily>> _scan() async {
    final dirs = _fontDirectories();
    final ttfFiles = <String>[];
    for (final dir in dirs) {
      await _collectTtfFiles(Directory(dir), ttfFiles);
    }

    final families = <String, _FamilyBuilder>{};
    for (final path in ttfFiles) {
      final info = await _parseFontInfo(path);
      if (info == null) continue;
      families.putIfAbsent(info.family, () => _FamilyBuilder(info.family));
      if (_isRegular(info.subfamily)) {
        families[info.family]!.regularPath = path;
      } else if (_isBold(info.subfamily)) {
        families[info.family]!.boldPath = path;
      } else if (families[info.family]!.regularPath == null) {
        families[info.family]!.regularPath = path;
      }
    }

    final result = families.values
        .where((fb) => fb.regularPath != null)
        .map((fb) => SystemFontFamily(
              name: fb.name,
              regularPath: fb.regularPath!,
              boldPath: fb.boldPath,
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return result;
  }

  static List<String> _fontDirectories() {
    if (Platform.isWindows) {
      return [
        '${Platform.environment['WINDIR'] ?? r'C:\Windows'}\\Fonts',
      ];
    }
    if (Platform.isMacOS) {
      return [
        '/Library/Fonts',
        '/System/Library/Fonts',
        '/System/Library/Fonts/Supplemental',
        '${Platform.environment['HOME']}/Library/Fonts',
      ];
    }
    return [
      '/usr/share/fonts',
      '/usr/local/share/fonts',
      '${Platform.environment['HOME']}/.fonts',
      '${Platform.environment['HOME']}/.local/share/fonts',
    ];
  }

  static Future<void> _collectTtfFiles(
    Directory dir,
    List<String> results,
  ) async {
    try {
      await for (final entry in dir.list(followLinks: false)) {
        if (entry is File && entry.path.endsWith('.ttf')) {
          results.add(entry.path);
        } else if (entry is Directory) {
          await _collectTtfFiles(entry, results);
        }
      }
    } on FileSystemException {
      // Skip unreadable font directories.
    }
  }
}

class _FontInfo {
  const _FontInfo({required this.family, required this.subfamily});
  final String family;
  final String subfamily;
}

class _FamilyBuilder {
  _FamilyBuilder(this.name);
  final String name;
  String? regularPath;
  String? boldPath;
}

bool _isRegular(String name) {
  final lowered = name.toLowerCase();
  return lowered == 'regular' ||
      lowered == 'normal' ||
      lowered == 'roman' ||
      lowered == 'book' ||
      lowered == 'medium' ||
      lowered.isEmpty;
}

bool _isBold(String name) {
  return name.toLowerCase().contains('bold');
}

Future<_FontInfo?> _parseFontInfo(String path) async {
  try {
    final file = File(path);
    final bytes = await file.readAsBytes();
    if (bytes.length < 12) return null;

    final view = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length);
    final numTables = view.getUint16(4, Endian.big);
    if (numTables < 1 || numTables > 100) return null;

    var nameTableOffset = 0;
    var nameTableLength = 0;
    for (var i = 0; i < numTables; i++) {
      final recordOffset = 12 + i * 16;
      if (recordOffset + 16 > bytes.length) break;
      final tag = String.fromCharCodes(
        bytes.sublist(recordOffset, recordOffset + 4),
      );
      final offset = view.getUint32(recordOffset + 8, Endian.big);
      final length = view.getUint32(recordOffset + 12, Endian.big);
      if (tag == 'name') {
        nameTableOffset = offset;
        nameTableLength = length;
        break;
      }
    }

    if (nameTableOffset == 0) return null;
    if (nameTableOffset + nameTableLength > bytes.length) return null;

    String? familyName;
    String? subfamilyName;

    final nameView = ByteData.view(
      bytes.buffer,
      bytes.offsetInBytes + nameTableOffset,
      nameTableLength,
    );
    final count = nameView.getUint16(2, Endian.big);
    final stringOffset = nameView.getUint16(4, Endian.big);

    for (var i = 0; i < count; i++) {
      final recordStart = 6 + i * 12;
      if (recordStart + 12 > nameTableLength) break;

      final platformId = nameView.getUint16(recordStart, Endian.big);
      final nameId = nameView.getUint16(recordStart + 6, Endian.big);
      final length = nameView.getUint16(recordStart + 8, Endian.big);
      final offset = nameView.getUint16(recordStart + 10, Endian.big);
      final strStart = stringOffset + offset;
      if (strStart + length > nameTableLength) continue;

      if (nameId == 1 && familyName == null) {
        familyName = _decodeNameEntry(
          bytes,
          nameTableOffset + strStart,
          length,
          platformId,
        );
      } else if (nameId == 2 && subfamilyName == null) {
        subfamilyName = _decodeNameEntry(
          bytes,
          nameTableOffset + strStart,
          length,
          platformId,
        );
      }
    }

    if (familyName == null || familyName.trim().isEmpty) return null;
    return _FontInfo(
      family: familyName.trim(),
      subfamily: (subfamilyName ?? '').trim(),
    );
  } catch (_) {
    return null;
  }
}

String _decodeNameEntry(
  Uint8List bytes,
  int offset,
  int length,
  int platformId,
) {
  try {
    if (platformId == 3) {
      final codeUnits = Uint16List.view(
        bytes.buffer,
        bytes.offsetInBytes + offset,
        length ~/ 2,
      );
      final le = Uint16List(codeUnits.length);
      for (var i = 0; i < codeUnits.length; i++) {
        le[i] = (codeUnits[i] >> 8) | ((codeUnits[i] & 0xFF) << 8);
      }
      return String.fromCharCodes(le);
    }
    return String.fromCharCodes(bytes.sublist(offset, offset + length));
  } catch (_) {
    return '';
  }
}
