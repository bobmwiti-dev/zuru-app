import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:zuru_app/core/app_export.dart';
import 'package:zuru_app/widgets/custom_icon_widget.dart';

/// Mood Streak Header Widget - Displays current streak and weekly summary
class MoodStreakHeaderWidget extends StatelessWidget {
  final int currentStreak;
  final int weeklyEntries;

  const MoodStreakHeaderWidget({
    super.key,
    required this.currentStreak,
    required this.weeklyEntries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStreakCard(
                  theme,
                  'Current Streak',
                  '$currentStreak days',
                  'local_fire_department',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStreakCard(
                  theme,
                  'This Week',
                  '$weeklyEntries entries',
                  'edit_note',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'celebration',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    'Keep it up! You\'re building a great journaling habit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
    ThemeData theme,
    String label,
    String value,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
