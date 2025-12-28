import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Content section displaying journal title, mood, location, and description
class ContentSection extends StatelessWidget {
  final Map<String, dynamic> journalEntry;

  const ContentSection({
    super.key,
    required this.journalEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = journalEntry['title'] as String? ?? 'Untitled Memory';
    final mood = journalEntry['mood'] as String? ?? 'Neutral';
    final location = journalEntry['location'] as String? ?? 'Unknown Location';
    final description = journalEntry['description'] as String? ?? '';
    final timestamp = journalEntry['timestamp'] as DateTime? ?? DateTime.now();
    final weather = journalEntry['weather'] as String?;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 16),

          // Mood badge and location
          Row(
            children: [
              _buildMoodBadge(theme, mood),
              SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Timestamp and weather
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 4),
              Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (weather != null) ...[
                SizedBox(width: 16),
                CustomIconWidget(
                  iconName: _getWeatherIcon(weather),
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 4),
                Text(
                  weather,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),

          if (description.isNotEmpty) ...[
            SizedBox(height: 24),

            // Description
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodBadge(ThemeData theme, String mood) {
    final moodColors = {
      'Happy': theme.colorScheme.tertiary,
      'Calm': theme.colorScheme.primary,
      'Excited': Color(0xFFE8B4B8),
      'Sad': Color(0xFFC67B7B),
      'Anxious': Color(0xFFD4A574),
      'Neutral': theme.colorScheme.onSurfaceVariant,
    };

    final moodIcons = {
      'Happy': 'sentiment_very_satisfied',
      'Calm': 'self_improvement',
      'Excited': 'celebration',
      'Sad': 'sentiment_dissatisfied',
      'Anxious': 'sentiment_neutral',
      'Neutral': 'sentiment_satisfied',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (moodColors[mood] ?? theme.colorScheme.onSurfaceVariant)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: moodIcons[mood] ?? 'sentiment_satisfied',
            size: 16,
            color: moodColors[mood] ?? theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 6),
          Text(
            mood,
            style: theme.textTheme.labelMedium?.copyWith(
              color: moodColors[mood] ?? theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _getWeatherIcon(String weather) {
    final weatherLower = weather.toLowerCase();
    if (weatherLower.contains('sun') || weatherLower.contains('clear')) {
      return 'wb_sunny';
    } else if (weatherLower.contains('cloud')) {
      return 'cloud';
    } else if (weatherLower.contains('rain')) {
      return 'water_drop';
    } else if (weatherLower.contains('storm')) {
      return 'thunderstorm';
    }
    return 'wb_cloudy';
  }
}
