import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global app state that manages application-wide state
class AppState {
  final bool isLoading;
  final bool isOnline;
  final ConnectivityResult connectivityType;
  final String? loadingMessage;
  final AppError? currentError;
  final bool showErrorDialog;
  final Map<String, dynamic> userPreferences;
  final ThemeMode themeMode;
  final Locale locale;

  const AppState({
    this.isLoading = false,
    this.isOnline = true,
    this.connectivityType = ConnectivityResult.wifi,
    this.loadingMessage,
    this.currentError,
    this.showErrorDialog = false,
    this.userPreferences = const {},
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  AppState copyWith({
    bool? isLoading,
    bool? isOnline,
    ConnectivityResult? connectivityType,
    String? loadingMessage,
    AppError? currentError,
    bool? showErrorDialog,
    Map<String, dynamic>? userPreferences,
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      connectivityType: connectivityType ?? this.connectivityType,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      currentError: currentError ?? this.currentError,
      showErrorDialog: showErrorDialog ?? this.showErrorDialog,
      userPreferences: userPreferences ?? this.userPreferences,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  String toString() {
    return 'AppState(isLoading: $isLoading, isOnline: $isOnline, connectivityType: $connectivityType, loadingMessage: $loadingMessage, currentError: $currentError, showErrorDialog: $showErrorDialog, themeMode: $themeMode, locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppState &&
        other.isLoading == isLoading &&
        other.isOnline == isOnline &&
        other.connectivityType == connectivityType &&
        other.loadingMessage == loadingMessage &&
        other.currentError == currentError &&
        other.showErrorDialog == showErrorDialog &&
        other.themeMode == themeMode &&
        other.locale == locale;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isOnline.hashCode ^
        connectivityType.hashCode ^
        loadingMessage.hashCode ^
        currentError.hashCode ^
        showErrorDialog.hashCode ^
        themeMode.hashCode ^
        locale.hashCode;
  }
}

/// App error model for global error handling
class AppError {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? action;
  final bool isDismissible;
  final Duration autoHideDuration;

  const AppError({
    required this.title,
    required this.message,
    this.actionLabel,
    this.action,
    this.isDismissible = true,
    this.autoHideDuration = const Duration(seconds: 5),
  });

  @override
  String toString() {
    return 'AppError(title: $title, message: $message, actionLabel: $actionLabel, isDismissible: $isDismissible)';
  }
}

/// App events for event-driven architecture
abstract class AppEvent {
  const AppEvent();
}

class ShowLoadingEvent extends AppEvent {
  final String? message;

  const ShowLoadingEvent([this.message]);
}

class HideLoadingEvent extends AppEvent {
  const HideLoadingEvent();
}

class ShowErrorEvent extends AppEvent {
  final AppError error;

  const ShowErrorEvent(this.error);
}

class ClearErrorEvent extends AppEvent {
  const ClearErrorEvent();
}

class ConnectivityChangedEvent extends AppEvent {
  final bool isOnline;
  final ConnectivityResult type;

  const ConnectivityChangedEvent(this.isOnline, this.type);
}

class LogoutEvent extends AppEvent {
  const LogoutEvent();
}

class ThemeChangedEvent extends AppEvent {
  final ThemeMode themeMode;

  const ThemeChangedEvent(this.themeMode);
}

class LocaleChangedEvent extends AppEvent {
  final Locale locale;

  const LocaleChangedEvent(this.locale);
}

/// Global app state notifier
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _initializeConnectivity();
  }

  final Connectivity _connectivity = Connectivity();

  void _initializeConnectivity() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      state = state.copyWith(
        isOnline: isOnline,
        connectivityType: result,
      );

      // Show offline message if connection is lost
      if (!isOnline) {
        showError(AppError(
          title: 'Connection Lost',
          message: 'You appear to be offline. Some features may not be available.',
          isDismissible: true,
        ));
      }
    });

    // Check initial connectivity
    _connectivity.checkConnectivity().then((result) {
      final isOnline = result != ConnectivityResult.none;
      state = state.copyWith(
        isOnline: isOnline,
        connectivityType: result,
      );
    });
  }

  /// Show global loading indicator
  void showLoading([String? message]) {
    state = state.copyWith(
      isLoading: true,
      loadingMessage: message,
    );
  }

  /// Hide global loading indicator
  void hideLoading() {
    state = state.copyWith(
      isLoading: false,
      loadingMessage: null,
    );
  }

  /// Show global error
  void showError(AppError error) {
    state = state.copyWith(
      currentError: error,
      showErrorDialog: true,
    );
  }

  /// Clear current error
  void clearError() {
    state = state.copyWith(
      currentError: null,
      showErrorDialog: false,
    );
  }

  /// Update user preferences
  void updateUserPreferences(Map<String, dynamic> preferences) {
    state = state.copyWith(
      userPreferences: {...state.userPreferences, ...preferences},
    );
  }

  /// Update theme mode
  void updateThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }

  /// Update locale
  void updateLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  /// Handle app events
  void handleEvent(AppEvent event) {
    if (event is ShowLoadingEvent) {
      showLoading(event.message);
    } else if (event is HideLoadingEvent) {
      hideLoading();
    } else if (event is ShowErrorEvent) {
      showError(event.error);
    } else if (event is ClearErrorEvent) {
      clearError();
    } else if (event is ConnectivityChangedEvent) {
      state = state.copyWith(
        isOnline: event.isOnline,
        connectivityType: event.type,
      );
    } else if (event is ThemeChangedEvent) {
      updateThemeMode(event.themeMode);
    } else if (event is LocaleChangedEvent) {
      updateLocale(event.locale);
    }
  }

  /// Reset app state (useful for logout)
  void reset() {
    state = const AppState();
  }
}

/// Global app state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Convenience providers for specific state properties
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOnline;
});

final currentErrorProvider = Provider<AppError?>((ref) {
  return ref.watch(appStateProvider).currentError;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(appStateProvider).locale;
});

final userPreferencesProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(appStateProvider).userPreferences;
});

/// Event bus for cross-widget communication
class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  final StreamController<AppEvent> _eventController = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get events => _eventController.stream;

  void publish(AppEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

/// Global event bus instance
final appEventBus = AppEventBus();

/// Widget to listen to app events and update state
class AppEventListener extends ConsumerStatefulWidget {
  final Widget child;

  const AppEventListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppEventListener> createState() => _AppEventListenerState();
}

class _AppEventListenerState extends ConsumerState<AppEventListener> {
  StreamSubscription<AppEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = appEventBus.events.listen((event) {
      ref.read(appStateProvider.notifier).handleEvent(event);
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Global loading overlay widget
class GlobalLoadingOverlay extends ConsumerWidget {
  final Widget child;

  const GlobalLoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final loadingMessage = ref.watch(appStateProvider).loadingMessage;

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Global error dialog widget
class GlobalErrorDialog extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalErrorDialog({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlobalErrorDialog> createState() => _GlobalErrorDialogState();
}

class _GlobalErrorDialogState extends ConsumerState<GlobalErrorDialog> {
  Timer? _autoHideTimer;

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(currentErrorProvider);
    final showDialog = ref.watch(appStateProvider).showErrorDialog;

    // Auto-hide error after duration
    if (error != null && showDialog) {
      _autoHideTimer?.cancel();
      _autoHideTimer = Timer(error.autoHideDuration, () {
        if (mounted) {
          ref.read(appStateProvider.notifier).clearError();
        }
      });
    }

    // Show error dialog if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (error != null && showDialog && mounted) {
        _showErrorDialog(context, ref, error);
      }
    });

    return widget.child;
  }

  void _showErrorDialog(BuildContext context, WidgetRef ref, AppError error) {
    showDialog(
      context: context,
      barrierDismissible: error.isDismissible,
      builder: (context) => AlertDialog(
        title: Text(error.title),
        content: Text(error.message),
        actions: [
          if (error.actionLabel != null && error.action != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                error.action!();
              },
              child: Text(error.actionLabel!),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(appStateProvider.notifier).clearError();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      ref.read(appStateProvider.notifier).clearError();
    });
  }
}

/// Connectivity status widget
class ConnectivityStatus extends ConsumerWidget {
  final Widget child;

  const ConnectivityStatus({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    // Show offline banner if not connected
    if (!isOnline) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'You are currently offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Retry connectivity check
                    ref.read(appStateProvider.notifier);
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      );
    }

    return child;
  }
}