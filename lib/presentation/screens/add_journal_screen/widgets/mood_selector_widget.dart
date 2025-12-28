import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Mood selector widget with colorful emotion badges
class MoodSelectorWidget extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const List<Map<String, dynamic>> _moods = [
    {
      'name': 'Happy',
      'icon': 'sentiment_very_satisfied',
      'color': Color(0xFFFFC107),
    },
    {
      'name': 'Calm',
      'icon': 'self_improvement',
      'color': Color(0xFF4A9B8E),
    },
    {
      'name': 'Excited',
      'icon': 'celebration',
      'color': Color(0xFFE8B4B8),
    },
    {
      'name': 'Thoughtful',
      'icon': 'psychology',
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Adventurous',
      'icon': 'explore',
      'color': Color(0xFF2D7D7D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = selectedMood == mood['name'];

              return _buildMoodBadge(
                context,
                theme,
                name: mood['name'] as String,
                icon: mood['icon'] as String,
                color: mood['color'] as Color,
                isSelected: isSelected,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build mood badge
  Widget _buildMoodBadge(
    BuildContext context,
    ThemeData theme, {
    required String name,
    required String icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onMoodSelected(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 20.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              size: 32,
            ),
            SizedBox(height: 0.5.h),
            Text(
              name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
