import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../providers/auth_provider.dart';

/// Profile Menu Widget - Settings and account management options
class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({super.key});

  static const _menuItems = [
    {
      'title': 'Account Settings',
      'subtitle': 'Update profile, password, and preferences',
      'icon': 'person',
      'route': '/account-settings',
      'color': Color(0xFF6366F1), // Primary
    },
    {
      'title': 'Privacy Settings',
      'subtitle': 'Control who can see your memories',
      'icon': 'privacy_tip',
      'route': '/privacy-settings',
      'color': Color(0xFF10B981), // Accent
    },
    {
      'title': 'Notification Settings',
      'subtitle': 'Manage push notifications and reminders',
      'icon': 'notifications',
      'route': '/notification-settings',
      'color': Color(0xFFF59E0B), // Warning
    },
    {
      'title': 'Data & Storage',
      'subtitle': 'Backup, export, and manage your data',
      'icon': 'storage',
      'route': '/data-settings',
      'color': Color(0xFF8B5CF6), // Violet
    },
    {
      'title': 'Help & Support',
      'subtitle': 'FAQ, contact support, and feedback',
      'icon': 'help',
      'route': '/help-support',
      'color': Color(0xFF06B6D4), // Cyan
    },
    {
      'title': 'About Zuru',
      'subtitle': 'Version info and app details',
      'icon': 'info',
      'route': '/about',
      'color': Color(0xFFEC4899), // Pink
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
            'Settings & Support',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Menu Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _buildMenuItem(context, item, index == _menuItems.length - 1);
            },
          ),

          SizedBox(height: 3.h),

          // Sign Out Button
          _buildSignOutButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item, bool isLast) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _onMenuItemTap(context, item['route'] as String),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isLast
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isLast
              ? Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(
                iconName: item['icon'] as String,
                color: item['color'] as Color,
                size: 20,
              ),
            ),

            SizedBox(width: 3.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    item['subtitle'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return CustomButton(
          text: 'Sign Out',
          onPressed: () => _signOut(context, ref),
          variant: CustomButtonVariant.danger,
          size: CustomButtonSize.medium,
          leadingIcon: 'logout',
          isFullWidth: true,
        );
      },
    );
  }

  void _onMenuItemTap(BuildContext context, String route) {
    // For now, show a snackbar indicating the feature is coming soon
    // In production, these would navigate to actual settings screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${route.replaceAll('/', '').replaceAll('-', ' ')} coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authStateProvider.notifier).signOut();

      if (context.mounted) {
        // Navigate back to authentication screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/authentication-screen',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}