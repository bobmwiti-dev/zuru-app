import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Memory Streak Widget - Shows current memory creation streak and insights
class MemoryStreakWidget extends StatelessWidget {
  const MemoryStreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Streak Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_fire_department',
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memory Streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Keep the momentum going!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Streak Number
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '7',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Streak Visualization
          _buildStreakVisualization(context, theme),

          SizedBox(height: 3.h),

          // Streak Insights
          _buildStreakInsights(context, theme),

          SizedBox(height: 2.h),

          // Motivation Message
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'celebration',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    '"You\'re on fire! Creating memories daily boosts happiness by 40%."',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakVisualization(BuildContext context, ThemeData theme) {
    // Mock streak data for the last 7 days
    final streakDays = [true, true, true, true, true, true, true]; // All days completed
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Text(
          'This Week',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isCompleted = streakDays[index];
            final dayLabel = dayLabels[index];

            return Column(
              children: [
                // Day Circle
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: theme.colorScheme.primary,
                            size: 16,
                          )
                        : Text(
                            dayLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  dayLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStreakInsights(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Longest Streak
        Expanded(
          child: _buildInsightCard(
            context,
            theme,
            icon: 'emoji_events',
            title: 'Longest',
            value: '14 days',
            color: Colors.yellow,
          ),
        ),

        SizedBox(width: 2.w),

        // Weekly Goal
        Expanded(
          child: _buildInsightCard(
            context,
            theme,
            icon: 'flag',
            title: 'Weekly Goal',
            value: '7/7',
            color: Colors.green,
          ),
        ),

        SizedBox(width: 2.w),

        // Mood Impact
        Expanded(
          child: _buildInsightCard(
            context,
            theme,
            icon: 'trending_up',
            title: 'Mood Boost',
            value: '+40%',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    ThemeData theme, {
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}