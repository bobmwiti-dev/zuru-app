import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_export.dart';
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
  }

  void _inviteFriends() async {
    const String invitationMessage = '''
🌟 Join me on Zuru - Your Digital Memory Book! 🌟

I'm documenting my experiences and creating amazing memories with Zuru. Join me and let's discover and share our favorite places together!

📱 Download Zuru and use invitation code: ZURU2024

#ZuruApp #DigitalMemories #TravelDiary
    ''';

    try {
      await Share.share(
        invitationMessage.trim(),
        subject: 'Join me on Zuru - Digital Memory Book',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open share dialog: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
