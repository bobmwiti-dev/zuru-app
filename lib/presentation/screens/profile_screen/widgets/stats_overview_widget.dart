import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Stats Overview Widget - Displays user statistics and achievements
class StatsOverviewWidget extends StatelessWidget {
  const StatsOverviewWidget({super.key});

  // Mock stats data - in production, this would come from a repository
  static const _stats = [
    {
      'label': 'Total Memories',
      'value': '42',
      'icon': 'auto_stories',
      'color': Color(0xFF6366F1), // Primary
    },
    {
      'label': 'Places Visited',
      'value': '18',
      'icon': 'location_on',
      'color': Color(0xFF10B981), // Accent
    },
    {
      'label': 'Current Streak',
      'value': '7',
      'icon': 'local_fire_department',
      'color': Color(0xFFF59E0B), // Warning
    },
    {
      'label': 'Favorite Mood',
      'value': 'Calm',
      'icon': 'sentiment_satisfied',
      'color': Color(0xFF4A9B8E), // Custom green
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your Journey',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 1.5,
            ),
            itemCount: _stats.length,
            itemBuilder: (context, index) {
              final stat = _stats[index];
              return _buildStatCard(context, stat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, Map<String, dynamic> stat) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: stat['icon'] as String,
              color: stat['color'] as Color,
              size: 20,
            ),
          ),

          SizedBox(height: 1.h),

          // Value
          Text(
            stat['value'] as String,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: 18.sp,
            ),
          ),

          SizedBox(height: 0.5.h),

          // Label
          Text(
            stat['label'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}