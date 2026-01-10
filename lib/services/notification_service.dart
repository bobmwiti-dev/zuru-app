import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/logging/logger.dart';

/// Notification service for push notifications and local notifications
class NotificationService {
  final Logger _logger;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._logger);

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      _logger.info('FCM Token: $token');

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _localNotificationsPlugin.initialize(settings);

      // Set up message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessageStatic);

      _logger.info('Notification service initialized');
    } catch (e) {
      _logger.error('Failed to initialize notification service', e);
      rethrow;
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      // TODO: Request notification permission
      // For now, return true
      _logger.info('Notification permission requested');
      return true;
    } catch (e) {
      _logger.error('Failed to request notification permission', e);
      return false;
    }
  }

  /// Check notification permission status
  Future<bool> hasPermission() async {
    try {
      // TODO: Check notification permission
      // For now, return true
      return true;
    } catch (e) {
      _logger.error('Failed to check notification permission', e);
      return false;
    }
  }

  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      // TODO: Show local notification
      _logger.info('Showing notification: $title - $body');
    } catch (e) {
      _logger.error('Failed to show notification', e);
    }
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    int? id,
  }) async {
    try {
      // TODO: Schedule notification
      _logger.info('Scheduled notification for: $scheduledTime');
    } catch (e) {
      _logger.error('Failed to schedule notification', e);
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      // TODO: Cancel notification
      _logger.info('Cancelled notification with id: $id');
    } catch (e) {
      _logger.error('Failed to cancel notification', e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      // Cancel all local notifications
      // If using flutter_local_notifications:
      // await _localNotificationsPlugin.cancelAll();

      // Cancel all scheduled notifications
      // If using flutter_local_notifications:
      // await _localNotificationsPlugin.cancelAll();

      // For Firebase Cloud Messaging, clear any pending messages
      // Note: FCM doesn't have a direct "cancel all" but we can clear local state

      _logger.info('Cancelled all notifications');
    } catch (e) {
      _logger.error('Failed to cancel all notifications', e);
      rethrow;
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      // TODO: Get FCM token
      // For now, return a mock token
      return 'mock_fcm_token_${Random().nextInt(10000)}';
    } catch (e) {
      _logger.error('Failed to get FCM token', e);
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      // TODO: Subscribe to FCM topic
      _logger.info('Subscribed to topic: $topic');
    } catch (e) {
      _logger.error('Failed to subscribe to topic: $topic', e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // TODO: Unsubscribe from FCM topic
      _logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.error('Failed to unsubscribe from topic: $topic', e);
    }
  }

  /// Handle incoming message
  void handleIncomingMessage(Map<String, dynamic> message) {
    try {
      _logger.info('Handling incoming message: $message');

      final notification = message['notification'] as Map<String, dynamic>?;
      final data = message['data'] as Map<String, dynamic>?;

      if (notification != null) {
        final title = notification['title'] as String?;
        final body = notification['body'] as String?;

        if (title != null && body != null) {
          showNotification(
            title: title,
            body: body,
            payload: data != null ? json.encode(data) : null,
          );
        }
      }
    } catch (e) {
      _logger.error('Failed to handle incoming message', e);
    }
  }

  /// Create reminder notifications for journaling
  Future<void> scheduleJournalReminders() async {
    try {
      // Schedule daily reminder at 8 PM
      await scheduleNotification(
        title: 'Time to Journal',
        body: 'Don\'t forget to capture today\'s memories!',
        scheduledTime: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          20, // 8 PM
          0,
        ).add(const Duration(days: 1)), // Tomorrow
        id: 1001,
      );

      // Schedule weekly summary on Sunday
      await scheduleNotification(
        title: 'Weekly Memory Summary',
        body: 'Check out your memory insights this week!',
        scheduledTime: _getNextSunday(),
        id: 1002,
      );

      _logger.info('Journal reminders scheduled');
    } catch (e) {
      _logger.error('Failed to schedule journal reminders', e);
    }
  }

  /// Create social notifications
  Future<void> notifyFriendActivity({
    required String friendName,
    required String activity,
  }) async {
    try {
      await showNotification(
        title: 'Friend Activity',
        body: '$friendName $activity',
        id: Random().nextInt(9999) + 2000,
      );
    } catch (e) {
      _logger.error('Failed to show friend activity notification', e);
    }
  }

  /// Create achievement notifications
  Future<void> notifyAchievement({
    required String achievement,
    required String description,
  }) async {
    try {
      await showNotification(
        title: '🎉 Achievement Unlocked!',
        body: '$achievement: $description',
        id: Random().nextInt(9999) + 3000,
      );
    } catch (e) {
      _logger.error('Failed to show achievement notification', e);
    }
  }

  /// Get next Sunday
  DateTime _getNextSunday() {
    final now = DateTime.now();
    final daysUntilSunday = 7 - now.weekday; // Sunday is 7
    return DateTime(
      now.year,
      now.month,
      now.day + (daysUntilSunday == 7 ? 7 : daysUntilSunday),
      10, // 10 AM
      0,
    );
  }

  /// Dispose of resources
  void dispose() {
    // TODO: Clean up notification resources
    _logger.info('Notification service disposed');
  }
}

/// Notification types
enum NotificationType {
  journalReminder,
  friendActivity,
  achievement,
  systemUpdate,
  marketing,
}

/// Notification channels for Android
class NotificationChannels {
  static const String journalReminders = 'journal_reminders';
  static const String friendActivity = 'friend_activity';
  static const String achievements = 'achievements';
  static const String systemUpdates = 'system_updates';
  static const String marketing = 'marketing';

  static Map<String, NotificationChannelInfo> get channels => {
    journalReminders: const NotificationChannelInfo(
      id: journalReminders,
      name: 'Journal Reminders',
      description: 'Daily reminders to journal your experiences',
      importance: NotificationImportance.high,
    ),
    friendActivity: const NotificationChannelInfo(
      id: friendActivity,
      name: 'Friend Activity',
      description: 'Updates about your friends\' activities',
      importance: NotificationImportance.default_,
    ),
    achievements: const NotificationChannelInfo(
      id: achievements,
      name: 'Achievements',
      description: 'Celebrate your journaling milestones',
      importance: NotificationImportance.high,
    ),
    systemUpdates: const NotificationChannelInfo(
      id: systemUpdates,
      name: 'System Updates',
      description: 'Important updates about the app',
      importance: NotificationImportance.default_,
    ),
    marketing: const NotificationChannelInfo(
      id: marketing,
      name: 'Updates & Tips',
      description: 'Tips and updates about journaling',
      importance: NotificationImportance.low,
    ),
  };
}

/// Notification channel information
class NotificationChannelInfo {
  final String id;
  final String name;
  final String description;
  final NotificationImportance importance;

  const NotificationChannelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
  });
}

/// Notification importance levels
enum NotificationImportance { low, default_, high, max }

// TODO: Add message handlers when firebase_messaging is integrated:
/// Handle foreground messages
void _handleForegroundMessage(RemoteMessage message) {
  ConsoleLogger(
    name: 'NotificationService',
  ).info('Received foreground message: ${message.notification?.title}');

  if (message.notification != null) {
    // Show local notification for foreground messages
    // TODO: Implement local notification display when FlutterLocalNotificationsPlugin is available

    // Note: This would need the FlutterLocalNotificationsPlugin instance
    // For now, just log the message
    ConsoleLogger(
      name: 'NotificationService',
    ).info('Would show local notification: ${message.notification?.title}');
  }
}

/// Handle messages when app is opened from background
void _handleBackgroundMessage(RemoteMessage message) {
  ConsoleLogger(
    name: 'NotificationService',
  ).info('App opened from background message: ${message.notification?.title}');
  // Handle navigation or other actions based on message data
}

/// Static method for background message handling (required by FCM)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessageStatic(RemoteMessage message) async {
  // This method must be static and top-level for FCM background handling
  // Use debugPrint instead of print for better production logging
  debugPrint('Received background message: ${message.notification?.title}');
}

/// Notification utilities
class NotificationUtils {
  /// Format notification time
  static String formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.month}/${time.day}/${time.year}';
    }
  }

  /// Check if notifications are enabled for a specific type
  static Future<bool> areNotificationsEnabled(NotificationType type) async {
    // TODO: Check notification settings
    // For now, return true
    return true;
  }

  /// Get notification preferences
  static Map<NotificationType, bool> getDefaultPreferences() {
    return {
      NotificationType.journalReminder: true,
      NotificationType.friendActivity: true,
      NotificationType.achievement: true,
      NotificationType.systemUpdate: true,
      NotificationType.marketing: false,
    };
  }
}
