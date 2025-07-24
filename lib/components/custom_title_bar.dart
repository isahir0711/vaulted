import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  final VoidCallback onAddPassword;

  const CustomTitleBar({super.key, required this.onAddPassword});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 36,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            // App controls
            Expanded(
              child: DragToMoveArea(
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: onAddPassword,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: const CircleBorder()),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
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
          height: 40,
          decoration: BoxDecoration(
            color: isHovered ? (widget.isClose ? Colors.red : Colors.grey.withOpacity(0.2)) : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: isHovered && widget.isClose ? Colors.white : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
