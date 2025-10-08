import 'package:flutter/material.dart';
import '../multiverse/game_dimension.dart';
import '../multiverse/dimension_config.dart';

/// Widget that displays the current dimension in the header
class DimensionIndicator extends StatelessWidget {
  final DimensionConfig config;
  final VoidCallback? onTap;

  const DimensionIndicator({
    super.key,
    required this.config,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: config.accentColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          color: config.accentColor.withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.icon,
              size: 20,
              color: config.accentColor,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: config.accentColor,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  config.tagline,
                  style: TextStyle(
                    fontSize: 9,
                    color: config.accentColor.withOpacity(0.7),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact dimension indicator for smaller spaces
class CompactDimensionIndicator extends StatelessWidget {
  final DimensionConfig config;
  final VoidCallback? onTap;

  const CompactDimensionIndicator({
    super.key,
    required this.config,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: '${config.name}\n${config.tagline}',
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(
              color: config.accentColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
            color: config.accentColor.withOpacity(0.1),
          ),
          child: Icon(
            config.icon,
            size: 20,
            color: config.accentColor,
          ),
        ),
      ),
    );
  }
}
