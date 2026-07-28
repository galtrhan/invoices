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
  late Stream<CompanyProfile> _companyStream = widget.database.watchCompany();

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
      child: SizedBox(
        width: 220,
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
              selectedColor: scheme.primary,
              selectedForeground: scheme.onPrimary,
              hoverColor: chrome.sidebarHover,
              onTap: () => widget.onSectionSelected(AppSection.settings),
            ),
            Padding(
              padding: const .fromLTRB(10, 4, 10, 12),
              child: Text(
                AppInfo.version,
                textAlign: .center,
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

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.company,
    required this.selected,
    required this.hoverColor,
    required this.onTap,
  });

  final CompanyProfile company;
  final bool selected;
  final Color hoverColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = company.name.trim();
    final displayName = name.isEmpty ? l10n.companyCardEmpty : name;
    final logoPath = company.logoPath;

    return Padding(
      padding: const .fromLTRB(10, 14, 10, 10),
      child: _SidebarTapTarget(
        selected: selected,
        selectedColor: hoverColor,
        hoverColor: hoverColor,
        onTap: onTap,
        padding: const .all(10),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            _CompanyLogo(
              imagePath:
                  logoPath != null ? MediaStore.absolutePath(logoPath) : null,
            ),
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
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage = path != null && path.isNotEmpty;
    final placeholder = Icon(
      Icons.apartment_outlined,
      size: 36,
      color: Colors.white.withValues(alpha: 0.7),
    );

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
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
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.selectedForeground,
    required this.hoverColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final Color selectedForeground;
  final Color hoverColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? selectedForeground : Colors.white;

    return Padding(
      padding: const .symmetric(horizontal: 10, vertical: 2),
      child: _SidebarTapTarget(
        selected: selected,
        selectedColor: selectedColor,
        hoverColor: hoverColor,
        onTap: onTap,
        padding: const .symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
