import 'package:flutter/material.dart';

class Win95Button extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const Win95Button({
    super.key,
    required this.child,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<Win95Button> createState() => _Win95ButtonState();
}

class _Win95ButtonState extends State<Win95Button> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFC0C0C0),
          border: Border(
            top: BorderSide(
              color: _isPressed
                  ? const Color(0xFF808080)
                  : const Color(0xFFFFFFFF),
              width: 2,
            ),
            left: BorderSide(
              color: _isPressed
                  ? const Color(0xFF808080)
                  : const Color(0xFFFFFFFF),
              width: 2,
            ),
            bottom: BorderSide(
              color: _isPressed
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF808080),
              width: 2,
            ),
            right: BorderSide(
              color: _isPressed
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFF808080),
              width: 2,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
