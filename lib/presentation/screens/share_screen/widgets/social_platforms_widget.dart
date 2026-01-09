import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Social Platforms Widget - Share to different social media platforms
class SocialPlatformsWidget extends StatelessWidget {
  final Function(String) onPlatformSelected;
  final Map<String, dynamic> memory;
  final String shareMessage;

  const SocialPlatformsWidget({
    super.key,
    required this.onPlatformSelected,
    required this.memory,
    required this.shareMessage,
  });

  static const List<Map<String, dynamic>> _platforms = [
    {
      'name': 'WhatsApp',
      'icon': 'chat',
      'color': Color(0xFF25D366),
      'available': true,
    },
    {
      'name': 'Facebook',
      'icon': 'facebook',
      'color': Color(0xFF1877F2),
      'available': true,
    },
    {
      'name': 'Twitter',
      'icon': 'twitter',
      'color': Color(0xFF1DA1F2),
      'available': true,
    },
    {
      'name': 'Instagram',
      'icon': 'instagram',
      'color': Color(0xFFE4405F),
      'available': true,
    },
    {
      'name': 'Copy Link',
      'icon': 'link',
      'color': Color(0xFF6366F1),
      'available': true,
    },
    {
      'name': 'More',
      'icon': 'more_horiz',
      'color': Color(0xFF6B7280),
      'available': true,
    },
  ];

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
            'Share to',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Platform Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.w,
              childAspectRatio: 1,
            ),
            itemCount: _platforms.length,
            itemBuilder: (context, index) {
              final platform = _platforms[index];
              return _buildPlatformButton(context, theme, platform);
            },
          ),

          SizedBox(height: 2.h),

          // Additional Actions
          _buildAdditionalActions(context, theme),
        ],
      ),
    );
  }

  Widget _buildPlatformButton(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> platform,
  ) {
    final color = platform['color'] as Color;
    final isAvailable = platform['available'] as bool;

    return InkWell(
      onTap: isAvailable ? () => _handlePlatformTap(platform['name'] as String) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isAvailable
              ? color.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable
                ? color.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Platform Icon
            Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: isAvailable ? color : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: platform['icon'] as String,
                color: isAvailable ? Colors.white : theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),

            SizedBox(height: 0.5.h),

            // Platform Name
            Text(
              platform['name'] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isAvailable ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Divider(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          thickness: 1,
        ),

        SizedBox(height: 1.h),

        // Quick Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickAction(
              context,
              theme,
              icon: 'qr_code',
              label: 'QR Code',
              onTap: _generateQRCode,
            ),
            _buildQuickAction(
              context,
              theme,
              icon: 'email',
              label: 'Email',
              onTap: _shareViaEmail,
            ),
            _buildQuickAction(
              context,
              theme,
              icon: 'sms',
              label: 'SMS',
              onTap: _shareViaSMS,
            ),
            _buildQuickAction(
              context,
              theme,
              icon: 'save',
              label: 'Save',
              onTap: _saveToDevice,
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Privacy Note
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'privacy_tip',
                color: theme.colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Your privacy settings will be respected when sharing publicly.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    ThemeData theme, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlatformTap(String platformName) {
    onPlatformSelected(platformName);
  }

  void _generateQRCode() {
    // TODO: Implement QR code generation for memory link
    onPlatformSelected('qr_code');
  }

  void _shareViaEmail() {
    // TODO: Implement email sharing
    onPlatformSelected('email');
  }

  void _shareViaSMS() {
    // TODO: Implement SMS sharing
    onPlatformSelected('sms');
  }

  void _saveToDevice() {
    // TODO: Implement save to device functionality
    onPlatformSelected('save');
  }
}