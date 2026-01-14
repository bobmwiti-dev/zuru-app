import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zuru_app/presentation/screens/memory_feed_screen/screen.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen.dart';
import 'package:zuru_app/presentation/screens/journal_detail_screen/screen.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/sign_in_screen.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/sign_up_screen.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/forgot_password_screen.dart';
import 'package:zuru_app/presentation/screens/interactive_map_view_screen/screen.dart';
import 'package:zuru_app/presentation/screens/add_journal_screen/screen.dart';
import 'package:zuru_app/presentation/screens/profile_screen/screen.dart';
import 'package:zuru_app/presentation/screens/settings_screen/screen.dart';
import 'package:zuru_app/presentation/screens/share_screen/screen.dart';
import 'package:zuru_app/presentation/screens/friends_screen/screen.dart';
import 'package:zuru_app/presentation/screens/ai_insights_screen/screen.dart';
import 'package:zuru_app/providers/auth_provider.dart';

class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String memoryFeed = '/memory-feed-screen';
  static const String moodAnalytics = '/mood-analytics-screen';
  static const String journalDetail = '/journal-detail-screen';
  static const String authentication = '/authentication-screen';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String interactiveMapView = '/interactive-map-view';
  static const String addJournal = '/add-journal-screen';
  static const String profile = '/profile-screen';
  static const String settings = '/settings-screen';
  static const String share = '/share-screen';
  static const String friends = '/friends-screen';
  static const String aiInsights = '/ai-insights-screen';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case initial:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: MemoryFeedScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case memoryFeed:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: MemoryFeedScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case moodAnalytics:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: MoodAnalyticsScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case journalDetail:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: JournalDetailScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case authentication:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case interactiveMapView:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: InteractiveMapView(),
                unauthenticated: SignInScreen(),
              ),
        );
      case addJournal:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: AddJournalScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case profile:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: ProfileScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case settings:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: SettingsScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case share:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => AuthGateScreen(
                authenticated: ShareScreen(memory: args?['memory'] ?? {}),
                unauthenticated: const SignInScreen(),
              ),
        );
      case friends:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: FriendsScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      case aiInsights:
        return MaterialPageRoute(
          builder:
              (_) => const AuthGateScreen(
                authenticated: AIInsightsScreen(),
                unauthenticated: SignInScreen(),
              ),
        );
      default:
        // Handle 404 - Page not found
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
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

class AuthGateScreen extends ConsumerWidget {
  final Widget authenticated;
  final Widget unauthenticated;

  const AuthGateScreen({
    super.key,
    required this.authenticated,
    required this.unauthenticated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return switch (authState) {
      AuthAuthenticated() => authenticated,
      AuthUnauthenticated() => unauthenticated,
      AuthError(message: final message) => SignInScreen(error: message),
      AuthLoading() || AuthInitial() =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
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
