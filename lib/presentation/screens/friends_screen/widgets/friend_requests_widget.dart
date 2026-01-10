import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Friend Requests Widget - Shows incoming and outgoing friend requests
class FriendRequestsWidget extends StatefulWidget {
  const FriendRequestsWidget({super.key});

  @override
  State<FriendRequestsWidget> createState() => _FriendRequestsWidgetState();
}

class _FriendRequestsWidgetState extends State<FriendRequestsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Sub-tabs
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Received'), Tab(text: 'Sent')],
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.titleSmall,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [ReceivedRequestsTab(), SentRequestsTab()],
          ),
        ),
      ],
    );
  }
}

class ReceivedRequestsTab extends StatefulWidget {
  const ReceivedRequestsTab({super.key});

  @override
  State<ReceivedRequestsTab> createState() => _ReceivedRequestsTabState();
}

class _ReceivedRequestsTabState extends State<ReceivedRequestsTab> {
  // Mock received requests - in a real app, this would come from a repository
  final List<Map<String, dynamic>> _receivedRequests = [
    {
      'id': '1',
      'name': 'David Kim',
      'username': 'davidk',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      'mutualFriends': 3,
    },
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'username': 'sarahj',
      'avatar':
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      'mutualFriends': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _receivedRequests.isEmpty
        ? _buildEmptyState(
          context,
          theme,
          'No friend requests',
          'When someone sends you a friend request, it will appear here.',
        )
        : ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          itemCount: _receivedRequests.length,
          itemBuilder: (context, index) {
            final request = _receivedRequests[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 2.w),
              child: _buildRequestCard(context, theme, request, true),
            );
          },
        );
  }

  Widget _buildRequestCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> request,
    bool isReceived,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 6.w,
            backgroundImage: NetworkImage(request['avatar']),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['name'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${request['username']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (request['mutualFriends'] != null) ...[
                  SizedBox(height: 1.w),
                  Text(
                    '${request['mutualFriends']} mutual friends',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 2.w),
          if (isReceived) ...[
            CustomButton(
              text: 'Accept',
              onPressed: () => _acceptRequest(context, request),
              variant: CustomButtonVariant.primary,
              size: CustomButtonSize.small,
            ),
            SizedBox(width: 2.w),
            CustomButton(
              text: 'Decline',
              onPressed: () => _declineRequest(context, request),
              variant: CustomButtonVariant.secondary,
              size: CustomButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }

  void _acceptRequest(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Accept Request?'),
            content: Text(
              'Are you sure you want to accept ${request['name']}\'s friend request?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _acceptFriendRequest(request);
                },
                child: const Text('Accept'),
              ),
            ],
          ),
    );
  }

  void _acceptFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _receivedRequests.removeWhere((r) => r['id'] == request['id']);
    });

    // In a real app, this would call a repository to accept the friend request
    // For now, show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now friends with ${request['name']}!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _declineFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _receivedRequests.removeWhere((r) => r['id'] == request['id']);
    });

    // In a real app, this would call a repository to decline the friend request
    // For now, show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request from ${request['name']} declined'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _declineRequest(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Decline Request?'),
            content: Text(
              'Are you sure you want to decline ${request['name']}\'s friend request?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _declineFriendRequest(request);
                },
                child: const Text(
                  'Decline',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _viewProfile(BuildContext context, Map<String, dynamic> request) {
    // Navigate to profile screen (currently shows current user's profile)
    // Future Enhancement: Implement viewing other users' profiles by:
    // 1. Modifying ProfileScreen to accept optional user parameter
    // 2. Creating UserProfileScreen for viewing other users
    // 3. Updating routes to pass user data (request['userId'])
    // 4. Implementing privacy controls and permissions
    // 5. Adding user profile API endpoints
    Navigator.pushNamed(context, '/profile-screen');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Viewing user profiles coming soon! Currently showing your profile.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class SentRequestsTab extends StatefulWidget {
  const SentRequestsTab({super.key});

  @override
  State<SentRequestsTab> createState() => _SentRequestsTabState();
}

class _SentRequestsTabState extends State<SentRequestsTab> {
  // Mock sent requests - in a real app, this would come from a repository
  final List<Map<String, dynamic>> _sentRequests = [
    {
      'id': '1',
      'name': 'Anna Davis',
      'username': 'annad',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _sentRequests.isEmpty
        ? _buildEmptyState(
          context,
          theme,
          'No sent requests',
          'Friend requests you\'ve sent will appear here.',
        )
        : ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          itemCount: _sentRequests.length,
          itemBuilder: (context, index) {
            final request = _sentRequests[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 2.w),
              child: _buildRequestCard(context, theme, request, false),
            );
          },
        );
  }

  Widget _buildRequestCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> request,
    bool isReceived,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 6.w,
            backgroundImage: NetworkImage(request['avatar']),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['name'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${request['username']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (request['mutualFriends'] != null) ...[
                  SizedBox(height: 1.w),
                  Text(
                    '${request['mutualFriends']} mutual friends',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 2.w),
          CustomButton(
            text: 'Cancel Request',
            onPressed: () => _cancelRequest(context, request),
            variant: CustomButtonVariant.secondary,
            size: CustomButtonSize.small,
          ),
          SizedBox(width: 2.w),
          IconButton(
            onPressed: () => _viewProfile(context, request),
            icon: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelRequest(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Request?'),
            content: Text(
              'Are you sure you want to cancel your friend request to ${request['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep Request'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _cancelFriendRequest(request);
                },
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _cancelFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _sentRequests.removeWhere((r) => r['id'] == request['id']);
    });

    // In a real app, this would call a repository to cancel the friend request
    // For now, show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend request to ${request['name']} cancelled'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _viewProfile(BuildContext context, Map<String, dynamic> request) {
    // Navigate to profile screen (currently shows current user's profile)
    // Future Enhancement: Implement viewing other users' profiles by:
    // 1. Modifying ProfileScreen to accept optional user parameter
    // 2. Creating UserProfileScreen for viewing other users
    // 3. Updating routes to pass user data (request['userId'])
    // 4. Implementing privacy controls and permissions
    // 5. Adding user profile API endpoints
    Navigator.pushNamed(context, '/profile-screen');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Viewing user profiles coming soon! Currently showing your profile.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Common empty state widget
Widget _buildEmptyState(
  BuildContext context,
  ThemeData theme,
  String title,
  String subtitle,
) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'person_add_alt_1',
          color: theme.colorScheme.onSurfaceVariant,
          size: 48,
        ),
        SizedBox(height: 2.h),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
