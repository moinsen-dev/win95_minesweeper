import 'package:flutter/material.dart';

class Win95Panel extends StatelessWidget {
  final Widget child;
  final bool inset;
  final EdgeInsets? padding;

  const Win95Panel({
    super.key,
    required this.child,
    this.inset = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFC0C0C0),
        border: Border(
          top: BorderSide(
            color: inset ? const Color(0xFF808080) : const Color(0xFFFFFFFF),
            width: 2,
          ),
          left: BorderSide(
            color: inset ? const Color(0xFF808080) : const Color(0xFFFFFFFF),
            width: 2,
          ),
          bottom: BorderSide(
            color: inset ? const Color(0xFFFFFFFF) : const Color(0xFF808080),
            width: 2,
          ),
          right: BorderSide(
            color: inset ? const Color(0xFFFFFFFF) : const Color(0xFF808080),
            width: 2,
          ),
        ),
      ),
      child: child,
    );
  }
}
