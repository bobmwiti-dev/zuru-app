import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Share Options Widget - Customize sharing preferences and message
class ShareOptionsWidget extends StatelessWidget {
  final String shareMessage;
  final bool includeLocation;
  final bool includeMood;
  final bool includeWeather;
  final String selectedPrivacy;
  final ValueChanged<String> onMessageChanged;
  final ValueChanged<bool> onLocationChanged;
  final ValueChanged<bool> onMoodChanged;
  final ValueChanged<bool> onWeatherChanged;
  final ValueChanged<String> onPrivacyChanged;

  const ShareOptionsWidget({
    super.key,
    required this.shareMessage,
    required this.includeLocation,
    required this.includeMood,
    required this.includeWeather,
    required this.selectedPrivacy,
    required this.onMessageChanged,
    required this.onLocationChanged,
    required this.onMoodChanged,
    required this.onWeatherChanged,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Share Options',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Message Editor
          _buildMessageEditor(context, theme),

          SizedBox(height: 3.h),

          // Include Options
          _buildIncludeOptions(context, theme),

          SizedBox(height: 3.h),

          // Privacy Settings
          _buildPrivacySettings(context, theme),
        ],
      ),
    );
  }

  Widget _buildMessageEditor(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: TextEditingController(text: shareMessage),
          maxLines: 4,
          maxLength: 280,
          decoration: InputDecoration(
            hintText: 'Add a personal message...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          style: theme.textTheme.bodyMedium,
          onChanged: onMessageChanged,
        ),
      ],
    );
  }

  Widget _buildIncludeOptions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Include in Share',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildSwitchOption(
          context,
          theme,
          title: 'Location',
          subtitle: 'Show where this memory was created',
          value: includeLocation,
          onChanged: onLocationChanged,
          icon: 'location_on',
        ),
        _buildSwitchOption(
          context,
          theme,
          title: 'Mood',
          subtitle: 'Include your emotional state',
          value: includeMood,
          onChanged: onMoodChanged,
          icon: 'sentiment_satisfied',
        ),
        _buildSwitchOption(
          context,
          theme,
          title: 'Weather',
          subtitle: 'Add weather conditions',
          value: includeWeather,
          onChanged: onWeatherChanged,
          icon: 'cloud',
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildPrivacyOption(
          context,
          theme,
          title: 'Public',
          subtitle: 'Anyone can discover and view',
          value: 'public',
          icon: 'public',
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: 1.h),
        _buildPrivacyOption(
          context,
          theme,
          title: 'Friends Only',
          subtitle: 'Only your friends can see',
          value: 'friends',
          icon: 'people',
          color: theme.colorScheme.secondary,
        ),
        SizedBox(height: 1.h),
        _buildPrivacyOption(
          context,
          theme,
          title: 'Link Only',
          subtitle: 'Only people with the link can view',
          value: 'link',
          icon: 'link',
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildSwitchOption(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required String value,
    required String icon,
    required Color color,
  }) {
    final isSelected = selectedPrivacy == value;

    return InkWell(
      onTap: () => onPrivacyChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}