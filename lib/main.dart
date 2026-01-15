import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zuru_app/app/theme/app_theme.dart';
import 'package:zuru_app/app/config/environment.dart';
import 'package:zuru_app/routes/app_routes.dart';
import 'package:zuru_app/providers/auth_provider.dart';
import 'package:zuru_app/data/repositories/auth_repository.dart';

FirebaseOptions _firebaseOptionsForWeb() {
  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  if (apiKey.isEmpty || appId.isEmpty || messagingSenderId.isEmpty || projectId.isEmpty) {
    throw FlutterError(
      'Missing Firebase Web configuration. Run the web app with --dart-define values for: '
      'FIREBASE_API_KEY, FIREBASE_APP_ID, FIREBASE_MESSAGING_SENDER_ID, FIREBASE_PROJECT_ID '
      '(and optionally FIREBASE_AUTH_DOMAIN, FIREBASE_STORAGE_BUCKET, FIREBASE_MEASUREMENT_ID).',
    );
  }

  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain.isEmpty ? null : authDomain,
    storageBucket: storageBucket.isEmpty ? null : storageBucket,
    measurementId: measurementId.isEmpty ? null : measurementId,
  );
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await Environment.initialize();

  // Initialize Firebase with platform-specific configuration
  if (kIsWeb) {
    // For web, supply Firebase configuration via --dart-define
    await Firebase.initializeApp(
      options: _firebaseOptionsForWeb(),
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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Zuru',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.initial,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
