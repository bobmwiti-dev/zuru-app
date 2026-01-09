import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Location Insights Widget - AI analysis of location-based patterns and preferences
class LocationInsightsWidget extends StatelessWidget {
  const LocationInsightsWidget({super.key});

  // Mock location insights data
  static const _locationInsights = [
    {
      'location': 'Karura Forest',
      'category': 'Nature',
      'visitCount': 8,
      'averageMood': 9.2,
      'moodImpact': '+25%',
      'bestTime': 'Weekends',
      'companion': 'Alone',
      'insights': [
        'Highest mood elevation (+25%)',
        'Best visited on weekends',
        'Often visited alone for reflection',
      ],
      'recommendation': 'Perfect for stress relief and recharging',
    },
    {
      'location': 'Java House Westlands',
      'category': 'Cafe',
      'visitCount': 12,
      'averageMood': 8.1,
      'moodImpact': '+15%',
      'bestTime': 'Morning',
      'companion': 'Friends',
      'insights': [
        'Consistent morning visits',
        'Social hub for friend meetups',
        'Coffee boosts productivity',
      ],
      'recommendation': 'Great for morning caffeine and conversations',
    },
    {
      'location': 'National Museum',
      'category': 'Culture',
      'visitCount': 3,
      'averageMood': 7.8,
      'moodImpact': '+12%',
      'bestTime': 'Afternoon',
      'companion': 'Family',
      'insights': [
        'Educational and inspiring',
        'Family-friendly environment',
        'Cultural enrichment',
      ],
      'recommendation': 'Ideal for learning and family bonding',
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Location Intelligence',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: theme.colorScheme.secondary,
                size: 20,
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Top Locations Summary
          _buildTopLocationsSummary(context, theme),

          SizedBox(height: 3.h),

          // Location Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _locationInsights.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.w),
            itemBuilder: (context, index) {
              final insight = _locationInsights[index];
              return _buildLocationInsightCard(context, theme, insight);
            },
          ),

          SizedBox(height: 2.h),

          // AI Recommendation
          _buildAIRecommendation(context, theme),
        ],
      ),
    );
  }

  Widget _buildTopLocationsSummary(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Most Visited',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Karura Forest',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 4.h,
            width: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Mood Booster',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '+25% Happiness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 4.h,
            width: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Total Places',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '23',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInsightCard(BuildContext context, ThemeData theme, Map<String, dynamic> insight) {
    final moodImpact = insight['moodImpact'] as String;
    final isPositive = moodImpact.startsWith('+');

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight['location'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      insight['category'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Mood impact badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  moodImpact,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Stats Row
          Row(
            children: [
              _buildStatItem(
                context,
                theme,
                icon: 'repeat',
                label: '${insight['visitCount']} visits',
              ),
              SizedBox(width: 4.w),
              _buildStatItem(
                context,
                theme,
                icon: 'sentiment_satisfied',
                label: '${insight['averageMood']} avg mood',
              ),
              SizedBox(width: 4.w),
              _buildStatItem(
                context,
                theme,
                icon: 'schedule',
                label: insight['bestTime'] as String,
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Key Insights
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Insights',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              ...(insight['insights'] as List<String>).map((insight) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'fiber_manual_record',
                      color: theme.colorScheme.primary,
                      size: 8,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        insight,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),

          SizedBox(height: 2.h),

          // Recommendation
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    insight['recommendation'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
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

  Widget _buildStatItem(BuildContext context, ThemeData theme, {required String icon, required String label}) {
    return Expanded(
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendation(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'smart_toy',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'AI Recommendation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Based on your patterns, try visiting Uhuru Park during golden hour. It matches your preference for peaceful outdoor experiences and could boost your mood by up to 30%.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}