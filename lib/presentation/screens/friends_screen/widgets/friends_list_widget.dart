import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../app/di/injector.dart';

/// Friends List Widget - Shows current friends and their activity
class FriendsListWidget extends StatefulWidget {
  const FriendsListWidget({super.key});

  @override
  State<FriendsListWidget> createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget> {
  final TextEditingController _searchController = TextEditingController();

  // Mock friends data
  late List<Map<String, dynamic>> _friends;
  late List<Map<String, dynamic>> _filteredFriends;

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = List.from(_friends);
      } else {
        _filteredFriends =
            _friends.where((friend) {
              final name = (friend['name'] as String).toLowerCase();
              final username = (friend['username'] as String).toLowerCase();
              return name.contains(query) || username.contains(query);
            }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _friends = [
      {
        'id': '1',
        'name': 'Sarah Johnson',
        'username': 'sarahj',
        'avatar':
            'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
        'isOnline': true,
        'lastActive': '2h ago',
        'memoriesShared': 12,
        'mutualFriends': 8,
        'recentMemory': {
          'title': 'Coffee at Java House',
          'location': 'Westlands',
          'timeAgo': '3h ago',
        },
      },
      {
        'id': '2',
        'name': 'Mike Chen',
        'username': 'mikec',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'isOnline': false,
        'lastActive': '1d ago',
        'memoriesShared': 8,
        'mutualFriends': 5,
        'recentMemory': {
          'title': 'Weekend Hike',
          'location': 'Karura Forest',
          'timeAgo': '1d ago',
        },
      },
      {
        'id': '3',
        'name': 'Emma Wilson',
        'username': 'emmaw',
        'avatar':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        'isOnline': true,
        'lastActive': '30m ago',
        'memoriesShared': 15,
        'mutualFriends': 12,
        'recentMemory': {
          'title': 'Art Gallery Visit',
          'location': 'National Museum',
          'timeAgo': '1h ago',
        },
      },
      {
        'id': '4',
        'name': 'Alex Rodriguez',
        'username': 'alexr',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        'isOnline': false,
        'lastActive': '3d ago',
        'memoriesShared': 6,
        'mutualFriends': 3,
        'recentMemory': {
          'title': 'Beach Day',
          'location': 'Mombasa',
          'timeAgo': '5d ago',
        },
      },
    ];

    _filteredFriends = List.from(_friends);
    _searchController.addListener(_onSearchChanged);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'people_outline',
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No friends found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchController.text.isEmpty
                ? 'Add friends to see their memories and connect!'
                : 'Try a different search term',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          CustomButton(
            text: 'Find Friends',
            onPressed: () {
              // Switch to discover tab
              DefaultTabController.of(context).animateTo(2);
            },
            variant: CustomButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
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
            ),
          ),

          // Friends List
          Expanded(
            child:
                _filteredFriends.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = _filteredFriends[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.w),
                          child: _buildFriendCard(context, theme, friend),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> friend,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openFriendProfile(context, friend),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    image: DecorationImage(
                      image: NetworkImage(friend['avatar'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (friend['isOnline'] as bool)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 3.w),

            // Friend Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and online status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          friend['name'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (friend['isOnline'] as bool)
                        Container(
                          margin: EdgeInsets.only(left: 1.w),
                          width: 1.w,
                          height: 1.w,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 0.3.h),

                  // Username
                  Text(
                    '@${friend['username']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  // Stats
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'auto_stories',
                        color: theme.colorScheme.primary,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${friend['memoriesShared']} memories',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'people',
                        color: theme.colorScheme.secondary,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${friend['mutualFriends']} mutual',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 0.5.h),

                  // Recent activity
                  if (friend['recentMemory'] != null)
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'history',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            'Posted "${(friend['recentMemory'] as Map)['title']}" ${(friend['recentMemory'] as Map)['timeAgo']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Active ${friend['lastActive']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),

            // Menu button
            IconButton(
              icon: CustomIconWidget(
                iconName: 'more_vert',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: () => _showFriendMenu(context, friend),
            ),
          ],
        ),
      ),
    );
  }

  void _openFriendProfile(BuildContext context, Map<String, dynamic> friend) {
    // Navigate to profile screen (currently shows current user's profile)
    // Future enhancement: Implement viewing other users' profiles when user profile system is expanded
    // - Modify ProfileScreen to accept an optional user parameter (e.g., ProfileScreen(userId: friend['id']))
    // - Create a dedicated UserProfileScreen for viewing other users' profiles
    // - Update AppRoutes to pass the friend data (e.g., arguments: {'userId': friend['id']})
    // - Implement privacy controls and permissions for viewing other users' data
    // - Add user profile API endpoints to fetch other users' data
    Navigator.pushNamed(context, '/profile-screen');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Viewing ${friend['name']}\'s profile coming soon! Currently showing your profile.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFriendMenu(BuildContext context, Map<String, dynamic> friend) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 1.h),
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'person',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: const Text('View Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    _openFriendProfile(context, friend);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'chat',
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                  title: const Text('Send Message'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendMessage(context, friend);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'remove_circle_outline',
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                  title: const Text('Remove Friend'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRemoveFriendDialog(context, friend);
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }

  void _sendMessage(BuildContext context, Map<String, dynamic> friend) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(friend['avatar']),
                radius: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Message ${friend['name']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.all(3.w),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                return CustomButton(
                  text: 'Send',
                  onPressed: () async {
                    final message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      try {
                        // Get current user ID from auth state
                        final authState = ref.watch(authStateProvider);
                        final currentUserId = authState.user?.id;

                        if (currentUserId == null) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You must be logged in to send messages',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // Send the message using the use case
                        final sendMessageUseCase = ref.read(
                          sendMessageUseCaseProvider,
                        );
                        await sendMessageUseCase(
                          currentUserId,
                          friend['id'],
                          message,
                        );

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Message sent to ${friend['name']}!',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to send message: ${e.toString()}',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a message'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  variant: CustomButtonVariant.primary,
                  size: CustomButtonSize.small,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRemoveFriendDialog(
    BuildContext context,
    Map<String, dynamic> friend,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Friend?'),
            content: Text(
              'Are you sure you want to remove ${friend['name']} from your friends list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeFriend(friend);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _removeFriend(Map<String, dynamic> friend) {
    setState(() {
      _friends.removeWhere((f) => f['id'] == friend['id']);
      _filteredFriends.removeWhere((f) => f['id'] == friend['id']);
    });

    // In a real app, this would call a repository to remove the friend
    // For now, show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${friend['name']} removed from friends'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
