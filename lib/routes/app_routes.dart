import 'package:flutter/material.dart';
import 'package:zuru_app/presentation/screens/memory_feed_screen/screen.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen.dart';
import 'package:zuru_app/presentation/screens/journal_detail_screen/screen.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/screen.dart';
import 'package:zuru_app/presentation/screens/interactive_map_view_screen/screen.dart';
import 'package:zuru_app/presentation/screens/add_journal_screen/screen.dart';

class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String memoryFeed = '/memory-feed-screen';
  static const String moodAnalytics = '/mood-analytics-screen';
  static const String journalDetail = '/journal-detail-screen';
  static const String authentication = '/authentication-screen';
  static const String interactiveMapView = '/interactive-map-view';
  static const String addJournal = '/add-journal-screen';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const MemoryFeedScreen());
      case memoryFeed:
        return MaterialPageRoute(builder: (_) => const MemoryFeedScreen());
      case moodAnalytics:
        return MaterialPageRoute(builder: (_) => const MoodAnalyticsScreen());
      case journalDetail:
        return MaterialPageRoute(
          builder: (_) => const JournalDetailScreen(),
        );
      case authentication:
        return MaterialPageRoute(builder: (_) => const AuthenticationScreen());
      case interactiveMapView:
        return MaterialPageRoute(builder: (_) => const InteractiveMapView());
      case addJournal:
        return MaterialPageRoute(builder: (_) => const AddJournalScreen());
      default:
        // Handle 404 - Page not found
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper method for navigation
  static void navigateTo(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method for navigation with replacement
  static void navigateToReplacement(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Helper method for navigation with removal of all previous routes
  static void navigateAndRemoveUntil(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false, // This removes all previous routes
      arguments: arguments,
    );
  }
}

/*
// In your main.dart
MaterialApp(
  initialRoute: AppRoutes.initial,
  onGenerateRoute: AppRoutes.generateRoute,
);

// Example usages:
// Navigate to journal detail with parameters
AppRoutes.navigateTo(context, AppRoutes.journalDetail, arguments: {'journalId': '123'});

// Replace current screen
AppRoutes.navigateToReplacement(context, AppRoutes.memoryFeed);

// Clear all previous screens (useful for login/logout)
AppRoutes.navigateAndRemoveUntil(context, AppRoutes.authentication);
*/
