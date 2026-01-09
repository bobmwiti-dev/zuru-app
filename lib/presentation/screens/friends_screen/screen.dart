import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import './widgets/friends_list_widget.dart';
import './widgets/friend_requests_widget.dart';
import './widgets/find_friends_widget.dart';

/// Friends Screen - Social connections and friend management
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 1; // Friends tab (assuming it's index 1)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Friends',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Discover'),
          ],
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.titleSmall,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FriendsListWidget(),
          FriendRequestsWidget(),
          FindFriendsWidget(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inviteFriends,
        backgroundColor: theme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'person_add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0: // Feed
        Navigator.pushNamed(context, '/memory-feed-screen');
        break;
      case 1: // Friends (current)
        break;
      case 2: // Map
        Navigator.pushNamed(context, '/interactive-map-view');
        break;
      case 3: // Add
        Navigator.pushNamed(context, '/add-journal-screen');
        break;
      case 4: // Profile
        Navigator.pushNamed(context, '/profile-screen');
        break;
    }
  }

  void _inviteFriends() {
    // TODO: Implement friend invitation functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite friends coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}