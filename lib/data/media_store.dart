import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import 'package:invoices/config/app_config.dart';

/// Copies images into `<configDir>/media` and resolves stored relative paths.
class MediaStore {
  static const allowedExtensions = ['png', 'jpg', 'jpeg', 'webp', 'gif'];

  /// Longest edge after import; large enough for invoice logos, small on disk.
  static const maxEdgePx = 1024;

  static const _logoBasename = 'logo';
  static const _stagingBasename = 'logo.staging';

  static final _allowedDotExtensions = {
    for (final ext in allowedExtensions) '.$ext',
  };

  static String absolutePath(String stored) {
    if (p.isAbsolute(stored)) {
      return stored;
    }
    return p.join(File(AppConfig.configPath).parent.path, stored);
  }

  /// Stages a picker file under `media/<category>/logo.staging.*` (resized).
  static Future<String> stageImage({
    required String sourcePath,
    required String category,
  }) {
    return _writePreparedImage(
      sourcePath: sourcePath,
      category: category,
      basename: _stagingBasename,
    );
  }

  /// Promotes staged logo to `media/<category>/logo.*` and returns its path.
  ///
  /// Does not delete other `logo.*` variants — callers remove the previous
  /// stored path after the database write succeeds.
  static Future<String> commitStagedLogo({required String category}) async {
    final dir = Directory(p.join(AppConfig.mediaDirectory, category));
    final staged = await _findBasenameFile(dir, _stagingBasename);
    if (staged == null) {
      throw const FileSystemException('No staged logo to commit');
    }

    final ext = p.extension(staged.path).toLowerCase();
    final dest = File(p.join(dir.path, '$_logoBasename$ext'));
    if (await dest.exists()) {
      await FileImage(dest).evict();
      await dest.delete();
    }
    await staged.rename(dest.path);
    await FileImage(dest).evict();

    final relative = p.join('media', category, '$_logoBasename$ext');
    return relative.replaceAll(r'\', '/');
  }

  static Future<void> discardStagedLogo({required String category}) async {
    final dir = Directory(p.join(AppConfig.mediaDirectory, category));
    await _clearBasenameVariants(dir, _stagingBasename);
  }

  static Future<void> deleteStored(String? stored) async {
    if (stored == null || stored.isEmpty) {
      return;
    }
    final file = File(absolutePath(stored));
    if (await file.exists()) {
      await FileImage(file).evict();
      await file.delete();
    }
  }

  static Future<String> _writePreparedImage({
    required String sourcePath,
    required String category,
    required String basename,
  }) async {
    final ext = p.extension(sourcePath).toLowerCase();
    if (!_allowedDotExtensions.contains(ext)) {
      throw const FormatException('Unsupported image type');
    }

    final bytes = await File(sourcePath).readAsBytes();
    final prepared = await Isolate.run(
      () => _prepareImageBytes(bytes, ext, maxEdgePx),
    );

    final destDir = Directory(p.join(AppConfig.mediaDirectory, category));
    await destDir.create(recursive: true);
    await _clearBasenameVariants(destDir, basename);

    final dest = File(p.join(destDir.path, '$basename${prepared.extension}'));
    await dest.writeAsBytes(prepared.bytes, flush: true);
    await FileImage(dest).evict();

    final relative = p.join('media', category, '$basename${prepared.extension}');
    return relative.replaceAll(r'\', '/');
  }

  static Future<File?> _findBasenameFile(
    Directory directory,
    String basename,
  ) async {
    if (!await directory.exists()) {
      return null;
    }
    await for (final entity in directory.list()) {
      if (entity is File &&
          p.basenameWithoutExtension(entity.path) == basename) {
        return entity;
      }
    }
    return null;
  }

  static Future<void> _clearBasenameVariants(
    Directory directory,
    String basename,
  ) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }
      if (p.basenameWithoutExtension(entity.path) == basename) {
        await FileImage(entity).evict();
        await entity.delete();
      }
    }
  }
}

class _PreparedImage {
  const _PreparedImage({required this.bytes, required this.extension});

  final Uint8List bytes;
  final String extension;
}

_PreparedImage _prepareImageBytes(
  Uint8List bytes,
  String sourceExt,
  int maxEdge,
) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Could not decode image');
  }

  final needsResize = decoded.width > maxEdge || decoded.height > maxEdge;
  final canPassthrough = sourceExt == '.png' ||
      sourceExt == '.jpg' ||
      sourceExt == '.jpeg' ||
      sourceExt == '.webp' ||
      sourceExt == '.gif';

  if (!needsResize && canPassthrough) {
    return _PreparedImage(bytes: bytes, extension: sourceExt);
  }

  var image = decoded;
  if (needsResize) {
    image = image.width >= image.height
        ? img.copyResize(
            image,
            width: maxEdge,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            image,
            height: maxEdge,
            interpolation: img.Interpolation.average,
          );
  }

  if (sourceExt == '.jpg' || sourceExt == '.jpeg') {
    return _PreparedImage(
      bytes: Uint8List.fromList(img.encodeJpg(image, quality: 85)),
      extension: sourceExt,
    );
  }

  return _PreparedImage(
    bytes: Uint8List.fromList(img.encodePng(image)),
    extension: '.png',
  );
}
