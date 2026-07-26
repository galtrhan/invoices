import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:invoices/theme/app_theme.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    required this.showWindowControls,
    required this.title,
  });

  final bool showWindowControls;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: .opaque,
      onPanStart: showWindowControls
          ? (_) => windowManager.startDragging()
          : null,
      child: Container(
        height: 40,
        padding: const .symmetric(horizontal: 12),
        decoration: const BoxDecoration(
          color: AppTheme.ink,
          border: Border(bottom: BorderSide(color: Color(0xFF2A3545))),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            if (showWindowControls) const _WindowControls(),
          ],
        ),
      ),
    );
  }
}

class _WindowControls extends StatelessWidget {
  const _WindowControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        _ControlButton(
          icon: Icons.remove,
          onPressed: windowManager.minimize,
        ),
        _ControlButton(
          icon: Icons.crop_square,
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        _ControlButton(
          icon: Icons.close,
          hoverColor: AppTheme.danger,
          onPressed: windowManager.close,
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.hoverColor,
  });

  final IconData icon;
  final Future<void> Function() onPressed;
  final Color? hoverColor;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover
        ? (widget.hoverColor ?? const Color(0xFF2A3545))
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 40,
          height: 32,
          alignment: .center,
          color: bg,
          child: Icon(widget.icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
