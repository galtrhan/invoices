import 'package:file_picker/file_picker.dart';

import 'package:invoices/data/media_store.dart';

/// In-memory logo edit state shared by company and client editors.
class LogoDraft {
  LogoDraft({required this.category, this.storedPath});

  final String category;
  String? storedPath;
  String? stagedPath;
  var cleared = false;

  String? get previewPath {
    final staged = stagedPath;
    if (staged != null) {
      return MediaStore.absolutePath(staged);
    }
    if (cleared || storedPath == null) {
      return null;
    }
    return MediaStore.absolutePath(storedPath!);
  }

  bool get hasStaged => stagedPath != null;

  void resetFromStored(String? path) {
    storedPath = path;
    stagedPath = null;
    cleared = false;
  }

  void acceptSaved(String? next) {
    storedPath = next;
    stagedPath = null;
    cleared = false;
  }

  Future<void> discardStaging() {
    return MediaStore.discardStagedLogo(category: category);
  }

  Future<void> clear() async {
    await discardStaging();
    stagedPath = null;
    cleared = true;
  }

  /// Stages a picked image. Returns false when the user cancels.
  Future<bool> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: MediaStore.allowedExtensions,
      allowMultiple: false,
    );
    final sourcePath = result?.files.single.path;
    if (sourcePath == null) {
      return false;
    }
    stagedPath = await MediaStore.stageImage(
      sourcePath: sourcePath,
      category: category,
    );
    cleared = false;
    return true;
  }
}
