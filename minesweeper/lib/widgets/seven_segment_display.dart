import 'package:flutter/material.dart';

class SevenSegmentDisplay extends StatelessWidget {
  final int value;
  final int digits;

  const SevenSegmentDisplay({
    super.key,
    required this.value,
    this.digits = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.clamp(-99, 999).abs();
    final isNegative = value < 0;
    final valueStr = displayValue.toString().padLeft(digits, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF808080), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isNegative)
            _buildSegment('-')
          else if (digits > valueStr.length)
            _buildSegment('0'),
          ...valueStr.split('').map((char) => _buildSegment(char)),
        ],
      ),
    );
  }

  Widget _buildSegment(String char) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(
        char,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF0000),
          height: 1.0,
        ),
      ),
    );
  }
}
