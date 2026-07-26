import 'dart:convert';
import 'dart:io';

String catalogNameKey(String name) => name.trim().toLowerCase();

/// Loads `*.json` packs from [directory], skipping invalid/duplicate names.
///
/// Does not include a builtin entry — callers prepend their own default.
Future<List<T>> loadNamedJsonCatalog<T>({
  required String directory,
  required T Function(Map<String, Object?> json) parse,
  required String Function(T item) nameOf,
  required String reservedName,
}) async {
  final dir = Directory(directory);
  if (!await dir.exists()) {
    return const [];
  }

  final files = await dir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.json'))
      .cast<File>()
      .toList();

  final decoded = await Future.wait(files.map((file) async {
    try {
      final raw = jsonDecode(await file.readAsString());
      if (raw is! Map) {
        return null;
      }
      return parse(Map<String, Object?>.from(raw));
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }));

  final seen = {catalogNameKey(reservedName)};
  final loaded = <T>[];
  for (final item in decoded) {
    if (item == null) {
      continue;
    }
    if (!seen.add(catalogNameKey(nameOf(item)))) {
      continue;
    }
    loaded.add(item);
  }

  loaded.sort(
    (a, b) => catalogNameKey(nameOf(a)).compareTo(catalogNameKey(nameOf(b))),
  );
  return loaded;
}

T resolveNamedCatalogItem<T>({
  required List<T> items,
  required String name,
  required String Function(T item) nameOf,
  required T fallback,
}) {
  final needle = catalogNameKey(name);
  for (final item in items) {
    if (catalogNameKey(nameOf(item)) == needle) {
      return item;
    }
  }
  return fallback;
}
