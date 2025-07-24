import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  final VoidCallback onAddPassword;

  const CustomTitleBar({super.key, required this.onAddPassword});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1)),
      ),
      child: Row(
        children: [
          // App controls
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onAddPassword,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Window controls
          Row(
            children: [
              WindowButton(icon: Icons.minimize, onPressed: () => windowManager.minimize()),
              WindowButton(
                icon: Icons.crop_square,
                onPressed: () async {
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                },
              ),
              WindowButton(icon: Icons.close, onPressed: () => windowManager.close(), isClose: true),
            ],
          ),
        ],
      ),
    );
  }
}

class WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const WindowButton({super.key, required this.icon, required this.onPressed, this.isClose = false});

  @override
  State<WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<WindowButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 44,
          decoration: BoxDecoration(
            color: isHovered
                ? (widget.isClose ? const Color(0xFFDC3545) : const Color(0xFFF8F9FA))
                : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: isHovered && widget.isClose ? Colors.white : const Color(0xFF6C757D),
          ),
        ),
      ),
    );
  }
}
