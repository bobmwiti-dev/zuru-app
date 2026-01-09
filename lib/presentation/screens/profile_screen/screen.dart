import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/auth_user.dart';
import './widgets/profile_header_widget.dart';
import './widgets/stats_overview_widget.dart';
import './widgets/recent_memories_widget.dart';
import './widgets/profile_menu_widget.dart';

/// Profile Screen - User account management and overview
/// Displays user information, statistics, and account settings
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _currentBottomNavIndex = 4; // Profile tab active

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        style: CustomAppBarStyle.standard,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => _navigateToSettings(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _ProfileScreenContent(user: user),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings-screen');
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0: // Feed
        Navigator.pushNamed(context, '/memory-feed-screen');
        break;
      case 1: // Friends
        Navigator.pushNamed(context, '/friends-screen');
        break;
      case 2: // Map
        Navigator.pushNamed(context, '/interactive-map-view');
        break;
      case 3: // Add
        Navigator.pushNamed(context, '/add-journal-screen');
        break;
      case 4: // Analytics
        Navigator.pushNamed(context, '/mood-analytics-screen');
        break;
      case 5: // Profile - already here
        break;
    }
  }
}

class _ProfileScreenContent extends StatelessWidget {
  final AuthUser user;

  const _ProfileScreenContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              ProfileHeaderWidget(user: user),

              SizedBox(height: 3.h),

              // Stats Overview
              StatsOverviewWidget(),

              SizedBox(height: 3.h),

              // Recent Memories
              RecentMemoriesWidget(),

              SizedBox(height: 3.h),

              // Profile Menu
              ProfileMenuWidget(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
