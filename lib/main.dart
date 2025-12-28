import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:zuru_app/presentation/screens/authentication_screen/screen.dart';
import 'package:zuru_app/presentation/screens/memory_feed_screen/screen.dart';
import 'package:zuru_app/providers/auth_provider.dart';
import 'package:zuru_app/data/repositories/auth_repository.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the authRepositoryProvider with our implementation
        authRepositoryProvider.overrideWithValue(
          AuthRepository(sharedPreferences),
        ),
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
          title: 'Zuru App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: switch (authState) {
            AuthAuthenticated() => const MemoryFeedScreen(),
            AuthError(message: final message) => AuthenticationScreen(error: message),
            AuthLoading() || AuthInitial() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            _ => const AuthenticationScreen(),
          },
        );
      },
    );
  }
}