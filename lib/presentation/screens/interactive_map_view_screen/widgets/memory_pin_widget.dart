import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Custom memory pin widget for map markers
class MemoryPinWidget extends StatelessWidget {
  final String mood;
  final Color moodColor;
  final VoidCallback? onTap;

  const MemoryPinWidget({
    super.key,
    required this.mood,
    required this.moodColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: moodColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: _getMoodIcon(mood),
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  String _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'sentiment_satisfied';
      case 'calm':
        return 'self_improvement';
      case 'excited':
        return 'celebration';
      case 'sad':
        return 'sentiment_dissatisfied';
      default:
        return 'place';
    }
  }
}
