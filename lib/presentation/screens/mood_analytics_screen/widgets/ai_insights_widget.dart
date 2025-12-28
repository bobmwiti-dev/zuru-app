import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:zuru_app/core/app_export.dart';
import 'package:zuru_app/widgets/custom_icon_widget.dart';

/// AI Insights Widget - Displays personalized observations and recommendations
class AIInsightsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> insights;

  const AIInsightsWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'psychology',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'AI Insights',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: insights.length,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            return _buildInsightCard(insights[index], theme);
          },
        ),
      ],
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight, ThemeData theme) {
    final type = insight["type"] as String;
    Color cardColor;
    Color iconColor;

    if (type == 'positive') {
      cardColor = theme.colorScheme.tertiaryContainer;
      iconColor = theme.colorScheme.tertiary;
    } else if (type == 'achievement') {
      cardColor = theme.colorScheme.primaryContainer;
      iconColor = theme.colorScheme.primary;
    } else {
      cardColor = theme.colorScheme.secondaryContainer;
      iconColor = theme.colorScheme.secondary;
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: insight["icon"] as String,
              color: iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight["title"] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  insight["description"] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
