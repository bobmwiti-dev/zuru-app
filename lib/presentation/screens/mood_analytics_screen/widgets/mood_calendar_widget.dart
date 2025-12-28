import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Mood Calendar Widget - Displays color-coded calendar with mood patterns
class MoodCalendarWidget extends StatelessWidget {
  final Map<String, dynamic> calendarData;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const MoodCalendarWidget({
    super.key,
    required this.calendarData,
    required this.selectedDay,
    required this.onDaySelected,
  });

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
            'Mood Calendar',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: selectedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: CustomIconWidget(
                iconName: 'chevron_left',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              rightChevronIcon: CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              weekendStyle: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: theme.textTheme.bodyMedium!,
              weekendTextStyle: theme.textTheme.bodyMedium!,
              outsideTextStyle: theme.textTheme.bodyMedium!.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildCalendarDay(day, theme, false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildCalendarDay(day, theme, true);
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              onDaySelected(selectedDay);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, ThemeData theme, bool isToday) {
    final dateKey =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final moodData = calendarData[dateKey] as Map<String, dynamic>?;

    if (moodData != null) {
      return Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Color(int.parse(moodData["color"] as String))
              .withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Text(
        '${day.day}',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
