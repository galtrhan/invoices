import 'package:flutter/material.dart';

import 'package:invoices/app_info.dart';
import 'package:invoices/theme/app_theme.dart';

enum AppSection { invoices, clients, company, settings }

class SideNav extends StatelessWidget {
  const SideNav({
    super.key,
    required this.section,
    required this.onSectionSelected,
  });

  final AppSection section;
  final ValueChanged<AppSection> onSectionSelected;

  static const _items = [
    (AppSection.invoices, 'Invoices', Icons.receipt_long_outlined),
    (AppSection.clients, 'Clients', Icons.people_outline),
    (AppSection.company, 'Company', Icons.apartment_outlined),
    (AppSection.settings, 'Settings', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.ink,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const Padding(
              padding: .fromLTRB(20, 20, 20, 24),
              child: Text(
                AppInfo.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            for (final item in _items)
              _NavItem(
                label: item.$2,
                icon: item.$3,
                selected: section == item.$1,
                onTap: () => onSectionSelected(item.$1),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppTheme.accent
        : _hover
        ? const Color(0xFF243041)
        : Colors.transparent;

    return Padding(
      padding: const .symmetric(horizontal: 10, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Material(
          color: bg,
          borderRadius: .circular(6),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: .circular(6),
            child: Padding(
              padding: const .symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight:
                          widget.selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
