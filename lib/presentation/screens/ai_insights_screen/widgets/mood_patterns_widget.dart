import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/app_export.dart';

/// Mood Patterns Widget - AI-analyzed mood trends and patterns
class MoodPatternsWidget extends StatefulWidget {
  const MoodPatternsWidget({super.key});

  @override
  State<MoodPatternsWidget> createState() => _MoodPatternsWidgetState();
}

class _MoodPatternsWidgetState extends State<MoodPatternsWidget> {
  // Mock AI-analyzed mood patterns
  final List<Map<String, dynamic>> _moodPatterns = [
    {
      'pattern': 'Weekend Elevation',
      'description': 'Your mood consistently improves by 35% on weekends',
      'confidence': 0.92,
      'icon': 'weekend',
      'trend': 'up',
    },
    {
      'pattern': 'Nature Boost',
      'description': 'Outdoor activities increase happiness by 28%',
      'confidence': 0.89,
      'icon': 'nature',
      'trend': 'up',
    },
    {
      'pattern': 'Evening Dip',
      'description': 'Energy levels decrease after 8 PM',
      'confidence': 0.76,
      'icon': 'nightlight',
      'trend': 'down',
    },
    {
      'pattern': 'Social Spark',
      'description': 'Time with friends boosts mood by 22%',
      'confidence': 0.84,
      'icon': 'people',
      'trend': 'up',
    },
  ];

  // Mock weekly mood data
  final List<double> _weeklyMoodData = [7.2, 7.8, 8.1, 6.9, 8.5, 8.8, 9.1];

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
                iconName: 'insights',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Mood Patterns',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI Analysis',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Weekly Trend Chart
          Container(
            height: 20.h,
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _weeklyMoodData
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                        .toList(),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // AI-Detected Patterns
          Text(
            'Detected Patterns',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _moodPatterns.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.w),
            itemBuilder: (context, index) {
              final pattern = _moodPatterns[index];
              return _buildPatternCard(context, theme, pattern);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(BuildContext context, ThemeData theme, Map<String, dynamic> pattern) {
    final confidence = pattern['confidence'] as double;
    final isPositive = pattern['trend'] == 'up';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pattern Icon
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: isPositive
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : theme.colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: pattern['icon'] as String,
              color: isPositive ? theme.colorScheme.primary : theme.colorScheme.secondary,
              size: 20,
            ),
          ),

          SizedBox(width: 3.w),

          // Pattern Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pattern['pattern'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Trend indicator
                    CustomIconWidget(
                      iconName: isPositive ? 'trending_up' : 'trending_down',
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                  ],
                ),

                SizedBox(height: 0.5.h),

                Text(
                  pattern['description'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 1.h),

                // Confidence indicator
                Row(
                  children: [
                    Text(
                      'Confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: confidence,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          confidence > 0.8
                              ? theme.colorScheme.primary
                              : confidence > 0.6
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${(confidence * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}