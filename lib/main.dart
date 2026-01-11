import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zuru_app/app/theme/app_theme.dart';
import 'package:zuru_app/app/config/environment.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/screen.dart';
import 'package:zuru_app/presentation/screens/memory_feed_screen/screen.dart';
import 'package:zuru_app/providers/auth_provider.dart';
import 'package:zuru_app/data/repositories/auth_repository.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await Environment.initialize();

  // Initialize Firebase with platform-specific configuration
  if (kIsWeb) {
    // For web, use the Firebase configuration from environment
    await Firebase.initializeApp(
      options: EnvironmentConstants.firebaseConfig.toFirebaseOptions(),
    );
  } else {
    // For mobile platforms, Firebase can auto-configure
    await Firebase.initializeApp();
  }

  runApp(
    ProviderScope(
      overrides: [
        // Override the authRepositoryProvider with our implementation
        authRepositoryProvider.overrideWithValue(AuthRepositoryImpl()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Zuru',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: switch (authState) {
            AuthAuthenticated() => const MemoryFeedScreen(),
            AuthError() || AuthLoading() || AuthInitial() => const AuthenticationScreen(
              key: ValueKey('auth_screen'),
            ),
            _ => const AuthenticationScreen(
              key: ValueKey('auth_screen'),
            ),
          },
        );
      },
    );
  }
}
