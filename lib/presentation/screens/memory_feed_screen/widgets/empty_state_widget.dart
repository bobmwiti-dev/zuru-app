import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:zuru_app/core/app_export.dart';

/// Empty state widget for when no memories exist
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateMemory;

  const EmptyStateWidget({
    super.key,
    required this.onCreateMemory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 30.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'auto_stories',
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  size: 80,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'Your Story Starts Here',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.5.h),

            // Description
            Text(
              'Capture your moments, emotions, and experiences.\nEvery memory matters.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // CTA Button
            ElevatedButton.icon(
              onPressed: onCreateMemory,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              label: Text('Create Your First Memory'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary action
            TextButton.icon(
              onPressed: () {
                // Show tips or tutorial
                _showTips(context);
              },
              icon: CustomIconWidget(
                iconName: 'lightbulb_outline',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: Text('Learn How It Works'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show tips dialog
  void _showTips(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'lightbulb',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Getting Started'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTipItem(
                theme,
                'Capture Moments',
                'Take photos or videos of your experiences',
                'camera_alt',
              ),
              SizedBox(height: 2.h),
              _buildTipItem(
                theme,
                'Express Emotions',
                'Tag your mood to track how you feel',
                'sentiment_satisfied',
              ),
              SizedBox(height: 2.h),
              _buildTipItem(
                theme,
                'Remember Places',
                'Auto-tag locations to map your memories',
                'location_on',
              ),
              SizedBox(height: 2.h),
              _buildTipItem(
                theme,
                'Reflect & Grow',
                'Review your journey and see patterns',
                'insights',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got It'),
          ),
        ],
      ),
    );
  }

  /// Build tip item
  Widget _buildTipItem(
      ThemeData theme, String title, String description, String iconName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
