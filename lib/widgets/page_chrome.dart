import 'package:flutter/material.dart';

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

class LogoUploadTile extends StatelessWidget {
  const LogoUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.size = 64,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final muted = theme.textTheme.bodyMedium?.color;

    return DecoratedBox(
      decoration: _surfacePanelDecoration(theme),
      child: Padding(
        padding: const .all(16),
        child: Row(
          children: [
            Container(
              width: size,
              height: size,
              alignment: .center,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: .circular(6),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(icon, color: muted),
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
            OutlinedButton(onPressed: () {}, child: const Text('Upload')),
          ],
        ),
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
