import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import './widgets/insights_header_widget.dart';
import './widgets/mood_patterns_widget.dart';
import './widgets/location_insights_widget.dart';
import './widgets/personalized_recommendations_widget.dart';
import './widgets/memory_streak_widget.dart';

/// AI Insights Screen - Personalized insights and recommendations based on memory patterns
class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  int _currentBottomNavIndex = 4; // Analytics tab active

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Insights',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _refreshInsights,
            tooltip: 'Refresh Insights',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Insights Header
                const InsightsHeaderWidget(),

                SizedBox(height: 3.h),

                // Memory Streak
                const MemoryStreakWidget(),

                SizedBox(height: 3.h),

                // Mood Patterns
                const MoodPatternsWidget(),

                SizedBox(height: 3.h),

                // Location Insights
                const LocationInsightsWidget(),

                SizedBox(height: 3.h),

                // Personalized Recommendations
                const PersonalizedRecommendationsWidget(),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0: // Feed
        Navigator.pushNamed(context, '/memory-feed-screen');
        break;
      case 1: // Friends
        Navigator.pushNamed(context, '/friends-screen');
        break;
      case 2: // Map
        Navigator.pushNamed(context, '/interactive-map-view');
        break;
      case 3: // Add
        Navigator.pushNamed(context, '/add-journal-screen');
        break;
      case 4: // Analytics (current)
        break;
      case 5: // Profile
        Navigator.pushNamed(context, '/profile-screen');
        break;
    }
  }

  void _refreshInsights() {
    // TODO: Implement insights refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing your AI insights...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}