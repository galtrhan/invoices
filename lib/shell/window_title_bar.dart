import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:invoices/theme/theme_definition.dart';

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
    final chrome = Theme.of(context).extension<AppChromeColors>()!;

    return GestureDetector(
      behavior: .opaque,
      onPanStart: showWindowControls
          ? (_) => windowManager.startDragging()
          : null,
      child: Container(
        height: 40,
        padding: const .symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: chrome.sidebar,
          border: Border(bottom: BorderSide(color: chrome.sidebarBorder)),
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
            if (showWindowControls)
              _WindowControls(
                hoverColor: chrome.sidebarHover,
                dangerColor: chrome.danger,
              ),
          ],
        ),
      ),
    );
  }
}

class _WindowControls extends StatelessWidget {
  const _WindowControls({
    required this.hoverColor,
    required this.dangerColor,
  });

  final Color hoverColor;
  final Color dangerColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        _ControlButton(
          icon: Icons.remove,
          hoverColor: hoverColor,
          onPressed: windowManager.minimize,
        ),
        _ControlButton(
          icon: Icons.crop_square,
          hoverColor: hoverColor,
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
          hoverColor: dangerColor,
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
    required this.hoverColor,
  });

  final IconData icon;
  final Future<void> Function() onPressed;
  final Color hoverColor;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? widget.hoverColor : Colors.transparent;

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
