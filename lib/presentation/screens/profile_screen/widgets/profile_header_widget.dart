import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../app/di/injector.dart' show userRepositoryProvider;
import '../../../../data/models/user_model.dart';
import '../../../../domain/models/auth_user.dart';

/// Profile Header Widget - Displays user avatar, name, and basic info
class ProfileHeaderWidget extends ConsumerWidget {
  final AuthUser user;

  const ProfileHeaderWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userRepository = ref.watch(userRepositoryProvider);

    return FutureBuilder<UserModel?>(
      future: userRepository.getUserProfile(user.id),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final bio = (profile?.bio ?? '').trim();

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
              Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(user.name ?? user.email),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name ?? 'User',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'verified',
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          'Member since ${_formatJoinDate(user.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editProfile(context),
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                Padding(
                  padding: EdgeInsets.only(top: 1.4.h),
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              else if (bio.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 1.4.h),
                  child: Text(
                    bio,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(height: 1.8.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Edit Profile',
                      onPressed: () => _editProfile(context),
                      variant: CustomButtonVariant.secondary,
                      size: CustomButtonSize.small,
                      leadingIcon: 'edit',
                      isFullWidth: true,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: CustomButton(
                      text: 'New Memory',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.addJournal,
                      ),
                      variant: CustomButtonVariant.secondary,
                      size: CustomButtonSize.small,
                      leadingIcon: 'add',
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _formatJoinDate(DateTime? date) {
    if (date == null) return 'recently';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round();
      return '$months months ago';
    } else {
      final years = (difference.inDays / 365).round();
      return '$years years ago';
    }
  }

  void _editProfile(BuildContext context) {
    // Navigate to settings screen for profile editing
    Navigator.pushNamed(context, AppRoutes.settings);
  }
}
