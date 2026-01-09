import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './widgets/settings_section_widget.dart';

/// Settings Screen - Comprehensive app settings and preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        style: CustomAppBarStyle.standard,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Settings
                SettingsSectionWidget(
                  title: 'Account',
                  items: [
                    SettingsItem(
                      title: 'Profile Information',
                      subtitle: 'Update your name, bio, and profile picture',
                      icon: 'person',
                      onTap: () => _navigateToProfileSettings(context),
                    ),
                    SettingsItem(
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      icon: 'lock',
                      onTap: () => _navigateToPasswordSettings(context),
                    ),
                    SettingsItem(
                      title: 'Privacy Settings',
                      subtitle: 'Control who can see your memories',
                      icon: 'privacy_tip',
                      onTap: () => _navigateToPrivacySettings(context),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // App Settings
                SettingsSectionWidget(
                  title: 'App Settings',
                  items: [
                    SettingsItem(
                      title: 'Notifications',
                      subtitle: 'Manage push notifications and reminders',
                      icon: 'notifications',
                      onTap: () => _navigateToNotificationSettings(context),
                    ),
                    SettingsItem(
                      title: 'Appearance',
                      subtitle: 'Theme, language, and display preferences',
                      icon: 'palette',
                      onTap: () => _navigateToAppearanceSettings(context),
                    ),
                    SettingsItem(
                      title: 'Location Services',
                      subtitle: 'Location permissions and preferences',
                      icon: 'location_on',
                      onTap: () => _navigateToLocationSettings(context),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Data & Storage
                SettingsSectionWidget(
                  title: 'Data & Storage',
                  items: [
                    SettingsItem(
                      title: 'Data Backup',
                      subtitle: 'Backup and restore your memories',
                      icon: 'backup',
                      onTap: () => _navigateToBackupSettings(context),
                    ),
                    SettingsItem(
                      title: 'Storage Usage',
                      subtitle: 'Manage storage and clear cache',
                      icon: 'storage',
                      onTap: () => _navigateToStorageSettings(context),
                    ),
                    SettingsItem(
                      title: 'Export Data',
                      subtitle: 'Download your memories as JSON or CSV',
                      icon: 'download',
                      onTap: () => _navigateToExportSettings(context),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Support & About
                SettingsSectionWidget(
                  title: 'Support & About',
                  items: [
                    SettingsItem(
                      title: 'Help Center',
                      subtitle: 'FAQs, tutorials, and guides',
                      icon: 'help',
                      onTap: () => _navigateToHelpCenter(context),
                    ),
                    SettingsItem(
                      title: 'Contact Support',
                      subtitle: 'Get help from our support team',
                      icon: 'support',
                      onTap: () => _navigateToSupport(context),
                    ),
                    SettingsItem(
                      title: 'About Zuru',
                      subtitle: 'Version 1.0.0 - Your Digital Memory Book',
                      icon: 'info',
                      onTap: () => _navigateToAbout(context),
                      showArrow: false,
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                // Sign Out Button
                _buildSignOutButton(context),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
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
      child: CustomButton(
        text: 'Sign Out',
        onPressed: () => _showSignOutDialog(context),
        variant: CustomButtonVariant.danger,
        size: CustomButtonSize.medium,
        leadingIcon: 'logout',
        isFullWidth: true,
      ),
    );
  }

  // Navigation methods - for now they show snackbars
  void _navigateToProfileSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile settings coming soon!')),
    );
  }

  void _navigateToPasswordSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password settings coming soon!')),
    );
  }

  void _navigateToPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy settings coming soon!')),
    );
  }

  void _navigateToNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _navigateToAppearanceSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appearance settings coming soon!')),
    );
  }

  void _navigateToLocationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location settings coming soon!')),
    );
  }

  void _navigateToBackupSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup settings coming soon!')),
    );
  }

  void _navigateToStorageSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage settings coming soon!')),
    );
  }

  void _navigateToExportSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export settings coming soon!')),
    );
  }

  void _navigateToHelpCenter(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Help center coming soon!')));
  }

  void _navigateToSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support contact coming soon!')),
    );
  }

  void _navigateToAbout(BuildContext context) {
    _showAboutDialog(context);
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Text(
                  'Zuru',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Digital Memory Book',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Zuru helps you document and cherish your experiences in Nairobi and beyond. Create lasting memories through text, photos, and reflections.',
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                Text(
                  '© 2025 Zuru App. All rights reserved.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Sign Out',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out? You can sign back in at any time.',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to authentication screen and clear stack
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/authentication-screen',
                    (route) => false,
                  );
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}

/// Settings item data class
class SettingsItem {
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;
  final bool showArrow;

  const SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.showArrow = true,
  });
}
