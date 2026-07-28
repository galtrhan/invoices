import 'dart:io';

import 'package:flutter/material.dart';

import 'package:invoices/app_info.dart';
import 'package:invoices/data/app_database.dart';
import 'package:invoices/data/media_store.dart';
import 'package:invoices/l10n/localization_definition.dart';
import 'package:invoices/theme/theme_definition.dart';

enum AppSection { invoices, clients, company, settings }

class SideNav extends StatefulWidget {
  const SideNav({
    super.key,
    required this.database,
    required this.section,
    required this.onSectionSelected,
  });

  final AppDatabase database;
  final AppSection section;
  final ValueChanged<AppSection> onSectionSelected;

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  static const double _expandedWidth = 220;
  static const double _collapsedWidth = 64;

  late Stream<CompanyProfile> _companyStream = widget.database.watchCompany();
  bool _collapsed = false;

  @override
  void didUpdateWidget(SideNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.database, widget.database)) {
      _companyStream = widget.database.watchCompany();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chrome = theme.extension<AppChromeColors>()!;
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final items = [
      (AppSection.clients, l10n.navClients, Icons.people_outline),
      (AppSection.invoices, l10n.navInvoices, Icons.receipt_long_outlined),
    ];

    return ColoredBox(
      color: chrome.sidebar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: _collapsed ? _collapsedWidth : _expandedWidth,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            StreamBuilder<CompanyProfile>(
              stream: _companyStream,
              initialData: AppDatabase.emptyCompany,
              builder: (context, snapshot) {
                return _CompanyCard(
                  company: snapshot.requireData,
                  selected: widget.section == AppSection.company,
                  collapsed: _collapsed,
                  hoverColor: chrome.sidebarHover,
                  onTap: () => widget.onSectionSelected(AppSection.company),
                );
              },
            ),
            for (final item in items)
              _NavItem(
                label: item.$2,
                icon: item.$3,
                selected: widget.section == item.$1,
                collapsed: _collapsed,
                selectedColor: scheme.primary,
                selectedForeground: scheme.onPrimary,
                hoverColor: chrome.sidebarHover,
                onTap: () => widget.onSectionSelected(item.$1),
              ),
            const Spacer(),
            _NavItem(
              label: l10n.navSettings,
              icon: Icons.settings_outlined,
              selected: widget.section == AppSection.settings,
              collapsed: _collapsed,
              selectedColor: scheme.primary,
              selectedForeground: scheme.onPrimary,
              hoverColor: chrome.sidebarHover,
              onTap: () => widget.onSectionSelected(AppSection.settings),
            ),
            _NavItem(
              label: _collapsed ? l10n.navExpand : l10n.navCollapse,
              icon: _collapsed
                  ? Icons.keyboard_double_arrow_right
                  : Icons.keyboard_double_arrow_left,
              selected: false,
              collapsed: _collapsed,
              selectedColor: chrome.sidebarHover,
              selectedForeground: Colors.white,
              hoverColor: chrome.sidebarHover,
              onTap: () => setState(() => _collapsed = !_collapsed),
            ),
            Padding(
              padding: const .fromLTRB(4, 4, 4, 12),
              child: Text(
                AppInfo.version,
                textAlign: .center,
                overflow: .ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _collapsedTooltip(String message, Widget child) {
  return Tooltip(
    message: message,
    waitDuration: const Duration(milliseconds: 400),
    child: child,
  );
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.company,
    required this.selected,
    required this.collapsed,
    required this.hoverColor,
    required this.onTap,
  });

  final CompanyProfile company;
  final bool selected;
  final bool collapsed;
  final Color hoverColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = company.name.trim();
    final displayName = name.isEmpty ? l10n.companyCardEmpty : name;
    final logoPath = company.logoPath;

    final logo = _CompanyLogo(
      imagePath: logoPath != null ? MediaStore.absolutePath(logoPath) : null,
      compact: collapsed,
    );

    final child = collapsed
        ? logo
        : Column(
            crossAxisAlignment: .stretch,
            children: [
              logo,
              const SizedBox(height: 10),
              Text(
                displayName,
                maxLines: 2,
                overflow: .ellipsis,
                textAlign: .center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: name.isEmpty ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ],
          );

    final target = _SidebarTapTarget(
      selected: selected,
      selectedColor: hoverColor,
      hoverColor: hoverColor,
      onTap: onTap,
      padding: EdgeInsets.all(collapsed ? 8 : 10),
      child: child,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        collapsed ? 8 : 10,
        14,
        collapsed ? 8 : 10,
        10,
      ),
      child: collapsed ? _collapsedTooltip(displayName, target) : target,
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({this.imagePath, this.compact = false});

  final String? imagePath;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = path != null && path.isNotEmpty;
    final placeholder = Icon(
      Icons.apartment_outlined,
      size: compact ? 22 : 36,
      color: Colors.white.withValues(alpha: 0.7),
    );

    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: .circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: .circular(6),
        child: hasImage
            ? Image.file(
                File(path),
                fit: .contain,
                cacheWidth:
                    (200 * MediaQuery.devicePixelRatioOf(context)).round(),
                errorBuilder: (context, error, stackTrace) => placeholder,
              )
            : placeholder,
      ),
    );

    if (compact) {
      return SizedBox(width: 40, height: 40, child: box);
    }

    return AspectRatio(aspectRatio: 1, child: box);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.collapsed,
    required this.selectedColor,
    required this.selectedForeground,
    required this.hoverColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool collapsed;
  final Color selectedColor;
  final Color selectedForeground;
  final Color hoverColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedForeground : Colors.white;

    final target = _SidebarTapTarget(
      selected: selected,
      selectedColor: selectedColor,
      hoverColor: hoverColor,
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 0 : 12,
        vertical: 10,
      ),
      child: collapsed
          ? Center(child: Icon(icon, size: 18, color: fg))
          : Row(
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    overflow: .ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 8 : 10,
        vertical: 2,
      ),
      child: collapsed ? _collapsedTooltip(label, target) : target,
    );
  }
}

class _SidebarTapTarget extends StatefulWidget {
  const _SidebarTapTarget({
    required this.selected,
    required this.selectedColor,
    required this.hoverColor,
    required this.onTap,
    required this.padding,
    required this.child,
  });

  final bool selected;
  final Color selectedColor;
  final Color hoverColor;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  State<_SidebarTapTarget> createState() => _SidebarTapTargetState();
}

class _SidebarTapTargetState extends State<_SidebarTapTarget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? widget.selectedColor
        : _hover
        ? widget.hoverColor
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg,
        borderRadius: .circular(6),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: .circular(6),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
