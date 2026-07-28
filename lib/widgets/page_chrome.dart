import 'dart:io';

import 'package:flutter/material.dart';

import 'package:invoices/data/media_store.dart';

ButtonStyle destructiveFilledStyle(ColorScheme scheme) {
  return FilledButton.styleFrom(
    backgroundColor: scheme.error,
    foregroundColor: scheme.onError,
  );
}

BoxDecoration _surfacePanelDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: .circular(8),
    border: Border.all(color: theme.dividerColor),
  );
}

class EmptyPane extends StatelessWidget {
  const EmptyPane({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const .all(32),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text(title, style: textTheme.titleLarge, textAlign: .center),
              const SizedBox(height: 8),
              Text(message, style: textTheme.bodyMedium, textAlign: .center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PageToolbar extends StatelessWidget {
  const PageToolbar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const .fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(title, style: textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class SectionPanel extends StatelessWidget {
  const SectionPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: _surfacePanelDecoration(theme),
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium!,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsDropdownMenu<T> extends StatelessWidget {
  const SettingsDropdownMenu({
    super.key,
    required this.valueKey,
    required this.initialSelection,
    required this.label,
    required this.entries,
    required this.onSelected,
    this.enabled = true,
  });

  factory SettingsDropdownMenu.onChanged({
    Key? key,
    required String valueKey,
    required T initialSelection,
    required Widget label,
    required List<DropdownMenuEntry<T>> entries,
    required ValueChanged<T> onChanged,
    bool enabled = true,
  }) {
    return SettingsDropdownMenu<T>(
      key: key,
      valueKey: valueKey,
      initialSelection: initialSelection,
      label: label,
      entries: entries,
      enabled: enabled,
      onSelected: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  factory SettingsDropdownMenu.onSelected({
    Key? key,
    required String valueKey,
    required T? initialSelection,
    required Widget label,
    required List<DropdownMenuEntry<T>> entries,
    required ValueChanged<T?> onSelected,
    bool enabled = true,
  }) {
    return SettingsDropdownMenu<T>(
      key: key,
      valueKey: valueKey,
      initialSelection: initialSelection,
      label: label,
      entries: entries,
      enabled: enabled,
      onSelected: onSelected,
    );
  }

  final String valueKey;
  final T? initialSelection;
  final Widget label;
  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      key: ValueKey(valueKey),
      initialSelection: initialSelection,
      label: label,
      expandedInsets: .zero,
      enabled: enabled,
      onSelected: onSelected,
      dropdownMenuEntries: entries,
    );
  }
}

class _CachedFileImage extends StatelessWidget {
  const _CachedFileImage({
    required this.filePath,
    required this.size,
    required this.icon,
    this.iconColor,
  });

  final String filePath;
  final double size;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cacheSize =
        (size * MediaQuery.devicePixelRatioOf(context)).round();
    return Image.file(
      File(filePath),
      key: ValueKey(filePath),
      width: size,
      height: size,
      cacheWidth: cacheSize,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) =>
          Icon(icon, color: iconColor),
    );
  }
}

class LogoUploadTile extends StatelessWidget {
  const LogoUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.uploadLabel,
    this.removeLabel,
    this.size = 64,
    this.imagePath,
    this.onUpload,
    this.onRemove,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? uploadLabel;
  final String? removeLabel;
  final double size;
  final String? imagePath;
  final VoidCallback? onUpload;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final muted = theme.textTheme.bodyMedium?.color;
    final resolvedImage = imagePath;
    final hasImage = resolvedImage != null && resolvedImage.isNotEmpty;
    final showUpload = onUpload != null && uploadLabel != null;
    final showRemove =
        hasImage && onRemove != null && removeLabel != null;

    return DecoratedBox(
      decoration: _surfacePanelDecoration(theme),
      child: Padding(
        padding: const .all(16),
        child: Row(
          children: [
            Container(
              width: size,
              height: size,
              clipBehavior: .antiAlias,
              alignment: .center,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: .circular(6),
                border: Border.all(color: theme.dividerColor),
              ),
              child: hasImage
                  ? _CachedFileImage(
                      filePath: resolvedImage,
                      size: size,
                      icon: icon,
                      iconColor: muted,
                    )
                  : Icon(icon, color: muted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),
            if (showRemove) ...[
              OutlinedButton(onPressed: onRemove, child: Text(removeLabel!)),
              if (showUpload) const SizedBox(width: 8),
            ],
            if (showUpload)
              OutlinedButton(onPressed: onUpload, child: Text(uploadLabel!)),
          ],
        ),
      ),
    );
  }
}

/// List-tile leading thumbnail for a stored media path.
class StoredLogoThumbnail extends StatelessWidget {
  const StoredLogoThumbnail({
    super.key,
    this.storedPath,
    this.size = 40,
    this.icon = Icons.image_outlined,
  });

  final String? storedPath;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final path = storedPath;
    if (path == null || path.isEmpty) {
      return Icon(icon);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: _CachedFileImage(
        filePath: MediaStore.absolutePath(path),
        size: size,
        icon: icon,
      ),
    );
  }
}

class FieldGrid extends StatelessWidget {
  const FieldGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                children[i],
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          rows.add(
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
          if (i + 2 < children.length) {
            rows.add(const SizedBox(height: 12));
          }
        }
        return Column(children: rows);
      },
    );
  }
}

class FormPageBody extends StatelessWidget {
  const FormPageBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const .all(24),
        children: [child],
      ),
    );
  }
}

class PageActionBar extends StatelessWidget {
  const PageActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const .fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: child,
    );
  }
}

class FormEditorLayout extends StatelessWidget {
  const FormEditorLayout({
    super.key,
    required this.body,
    required this.actions,
  });

  final Widget body;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: FormPageBody(child: body)),
        PageActionBar(child: actions),
      ],
    );
  }
}
