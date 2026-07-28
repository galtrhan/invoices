import 'package:invoices/data/media_store.dart';

/// Outcome of [LogoSave.run] after logo commit, persist, and replaced-file cleanup.
class LogoSaveOutcome<T> {
  const LogoSaveOutcome({required this.value, required this.nextLogo});

  final T value;
  final String? nextLogo;
}

/// Shared commit → persist → cleanup flow for company and client logos.
class LogoSave {
  /// Commits a staged logo when needed, runs [persist], then deletes the old file.
  ///
  /// If [persist] fails after a successful commit, the new logo file is removed.
  /// Replacing the previous file runs only after [persist] succeeds, and cleanup
  /// failures do not roll back the committed logo.
  static Future<LogoSaveOutcome<T>> run<T>({
    required String category,
    required String? previousLogo,
    required bool cleared,
    required bool hasStaged,
    required Future<T> Function(String? nextLogo) persist,
  }) async {
    String? committedLogo;
    late final String? nextLogo;

    if (cleared) {
      nextLogo = null;
    } else if (hasStaged) {
      committedLogo = await MediaStore.commitStagedLogo(category: category);
      nextLogo = committedLogo;
    } else {
      nextLogo = previousLogo;
    }

    late final T value;
    try {
      value = await persist(nextLogo);
    } catch (_) {
      if (committedLogo != null && committedLogo != previousLogo) {
        await MediaStore.deleteStored(committedLogo);
      }
      rethrow;
    }

    await MediaStore.deleteReplacedLogo(previousLogo, nextLogo);
    return LogoSaveOutcome(value: value, nextLogo: nextLogo);
  }
}
