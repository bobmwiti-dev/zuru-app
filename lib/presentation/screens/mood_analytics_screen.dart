import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/ai_insights_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/location_insights_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_calendar_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_distribution_chart_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_streak_header_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_trend_chart_widget.dart';

/// Mood Analytics Screen - Provides insightful visualization of emotional patterns
/// Implements mobile-optimized charts with pull-to-refresh and export functionality
class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  int _currentBottomNavIndex = 3; // Analytics tab active
  String _selectedPeriod = 'week'; // week, month, year
  // ignore: unused_field
  bool _isLoading = false;
  DateTime _selectedCalendarDay = DateTime.now();

  // Mock analytics data
  final Map<String, dynamic> _analyticsData = {
    "currentStreak": 7,
    "weeklyEntries": 12,
    "moodDistribution": [
      {"mood": "Happy", "count": 45, "percentage": 35.0, "color": "0xFFFFC107"},
      {"mood": "Calm", "count": 38, "percentage": 30.0, "color": "0xFF4CAF50"},
      {
        "mood": "Excited",
        "count": 25,
        "percentage": 20.0,
        "color": "0xFFFF5722"
      },
      {
        "mood": "Grateful",
        "count": 12,
        "percentage": 10.0,
        "color": "0xFF9C27B0"
      },
      {
        "mood": "Reflective",
        "count": 8,
        "percentage": 5.0,
        "color": "0xFF2196F3"
      },
    ],
    "moodTrends": {
      "week": [
        {"day": "Mon", "value": 7.5},
        {"day": "Tue", "value": 8.2},
        {"day": "Wed", "value": 6.8},
        {"day": "Thu", "value": 7.9},
        {"day": "Fri", "value": 8.5},
        {"day": "Sat", "value": 9.0},
        {"day": "Sun", "value": 8.3},
      ],
      "month": [
        {"week": "Week 1", "value": 7.8},
        {"week": "Week 2", "value": 8.1},
        {"week": "Week 3", "value": 7.5},
        {"week": "Week 4", "value": 8.4},
      ],
      "year": [
        {"month": "Jan", "value": 7.2},
        {"month": "Feb", "value": 7.8},
        {"month": "Mar", "value": 8.1},
        {"month": "Apr", "value": 7.9},
        {"month": "May", "value": 8.3},
        {"month": "Jun", "value": 8.5},
        {"month": "Jul", "value": 8.7},
        {"month": "Aug", "value": 8.4},
        {"month": "Sep", "value": 8.2},
        {"month": "Oct", "value": 8.6},
        {"month": "Nov", "value": 8.8},
        {"month": "Dec", "value": 9.0},
      ],
    },
    "locationInsights": [
      {
        "location": "Karura Forest",
        "averageMood": 9.2,
        "visitCount": 8,
        "dominantMood": "Calm",
        "image":
            "https://images.unsplash.com/photo-1578405576045-dd6f5bd03a36",
        "semanticLabel":
            "Lush green forest path with tall trees and dappled sunlight filtering through the canopy"
      },
      {
        "location": "Java House Westlands",
        "averageMood": 8.5,
        "visitCount": 15,
        "dominantMood": "Happy",
        "image":
            "https://images.unsplash.com/photo-1689475299375-b6b45ca0c56b",
        "semanticLabel":
            "Cozy coffee shop interior with wooden tables and warm ambient lighting"
      },
      {
        "location": "Nairobi National Park",
        "averageMood": 9.0,
        "visitCount": 5,
        "dominantMood": "Excited",
        "image":
            "https://images.unsplash.com/photo-1632984780534-58f56e6aeef9",
        "semanticLabel":
            "Wide savanna landscape with acacia trees and wildlife in the distance"
      },
    ],
    "calendarData": {
      "2025-11-24": {"mood": "Happy", "color": "0xFFFFC107"},
      "2025-11-25": {"mood": "Calm", "color": "0xFF4CAF50"},
      "2025-11-26": {"mood": "Excited", "color": "0xFFFF5722"},
      "2025-11-27": {"mood": "Happy", "color": "0xFFFFC107"},
      "2025-11-28": {"mood": "Grateful", "color": "0xFF9C27B0"},
      "2025-11-29": {"mood": "Calm", "color": "0xFF4CAF50"},
      "2025-11-30": {"mood": "Happy", "color": "0xFFFFC107"},
    },
    "aiInsights": [
      {
        "title": "Nature Boosts Your Mood",
        "description":
            "You seem happiest when visiting outdoor locations like Karura Forest. Consider scheduling more nature walks this week.",
        "icon": "park",
        "type": "positive"
      },
      {
        "title": "Consistent Journaling Streak",
        "description":
            "You've maintained a 7-day journaling streak! Keep it up to unlock deeper insights about your emotional patterns.",
        "icon": "emoji_events",
        "type": "achievement"
      },
      {
        "title": "Weekend Reflection Time",
        "description":
            "Your mood tends to be more reflective on weekends. This might be a great time for deeper self-reflection entries.",
        "icon": "lightbulb",
        "type": "suggestion"
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Mood Analytics',
        style: CustomAppBarStyle.standard,
        centerTitle: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _exportAnalytics,
            tooltip: 'Export Analytics',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalytics,
        child: _analyticsData["moodDistribution"] != null &&
                (_analyticsData["moodDistribution"] as List).isNotEmpty
            ? _buildAnalyticsContent(theme)
            : _buildInsufficientDataView(theme),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
        showCenterButton: true,
      ),
    );
  }

  /// Build main analytics content
  Widget _buildAnalyticsContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Streak Header
          MoodStreakHeaderWidget(
            currentStreak: _analyticsData["currentStreak"] as int,
            weeklyEntries: _analyticsData["weeklyEntries"] as int,
          ),

          SizedBox(height: 3.h),

          // Mood Distribution Chart
          MoodDistributionChartWidget(
            moodData: _analyticsData["moodDistribution"]
                as List<Map<String, dynamic>>,
          ),

          SizedBox(height: 3.h),

          // Mood Trend Chart with Period Selector
          _buildPeriodSelector(theme),
          SizedBox(height: 2.h),
          MoodTrendChartWidget(
            trendData: (_analyticsData["moodTrends"]
                    as Map<String, dynamic>)[_selectedPeriod]
                as List<Map<String, dynamic>>,
            period: _selectedPeriod,
          ),

          SizedBox(height: 3.h),

          // Location Insights
          LocationInsightsWidget(
            locationData: _analyticsData["locationInsights"]
                as List<Map<String, dynamic>>,
          ),

          SizedBox(height: 3.h),

          // Mood Calendar
          MoodCalendarWidget(
            calendarData:
                _analyticsData["calendarData"] as Map<String, dynamic>,
            selectedDay: _selectedCalendarDay,
            onDaySelected: (selectedDay) {
              setState(() => _selectedCalendarDay = selectedDay);
              _filterEntriesByDate(selectedDay);
            },
          ),

          SizedBox(height: 3.h),

          // AI Insights
          AIInsightsWidget(
            insights:
                _analyticsData["aiInsights"] as List<Map<String, dynamic>>,
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  /// Build period selector for trend chart
  Widget _buildPeriodSelector(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Text(
            'Mood Trends',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildPeriodButton('Week', 'week', theme),
          SizedBox(width: 2.w),
          _buildPeriodButton('Month', 'month', theme),
          SizedBox(width: 2.w),
          _buildPeriodButton('Year', 'year', theme),
        ],
      ),
    );
  }

  /// Build individual period button
  Widget _buildPeriodButton(String label, String value, ThemeData theme) {
    final isSelected = _selectedPeriod == value;

    return InkWell(
      onTap: () => setState(() => _selectedPeriod = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Build insufficient data view
  Widget _buildInsufficientDataView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'insights',
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'Start Your Journey',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Create more journal entries to unlock personalized mood insights and analytics. Your emotional patterns will appear here as you continue journaling.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add-journal-screen'),
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Create First Entry'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.8.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Refresh analytics data
  Future<void> _refreshAnalytics() async {
    setState(() => _isLoading = true);

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
  }

  /// Export analytics as infographic
  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Analytics exported successfully'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Filter entries by selected calendar date
  void _filterEntriesByDate(DateTime selectedDay) {
    // Navigate to filtered memory feed
    Navigator.pushNamed(
      context,
      '/memory-feed-screen',
      arguments: {'filterDate': selectedDay},
    );
  }
}
