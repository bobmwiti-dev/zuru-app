import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

/// Mood Distribution Chart Widget - Displays colorful donut chart
class MoodDistributionChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> moodData;

  const MoodDistributionChartWidget({
    super.key,
    required this.moodData,
  });

  @override
  State<MoodDistributionChartWidget> createState() =>
      _MoodDistributionChartWidgetState();
}

class _MoodDistributionChartWidgetState
    extends State<MoodDistributionChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
          Text(
            'Mood Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 30.h,
            child: Semantics(
              label: 'Mood Distribution Pie Chart',
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 12.w,
                        sections: _buildPieChartSections(theme),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 2,
                    child: _buildLegend(theme),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(ThemeData theme) {
    return List.generate(widget.moodData.length, (index) {
      final isTouched = index == _touchedIndex;
      final mood = widget.moodData[index];
      final radius = isTouched ? 15.w : 12.w;

      return PieChartSectionData(
        color: Color(int.parse(mood["color"] as String)),
        value: (mood["percentage"] as num).toDouble(),
        title: isTouched ? '${mood["percentage"]}%' : '',
        radius: radius,
        titleStyle: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      );
    });
  }

  Widget _buildLegend(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.moodData.map((mood) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 0.8.h),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: Color(int.parse(mood["color"] as String)),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood["mood"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${mood["count"]} entries',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
