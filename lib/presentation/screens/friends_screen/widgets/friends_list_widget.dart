import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Friends List Widget - Shows current friends and their activity
class FriendsListWidget extends StatefulWidget {
  const FriendsListWidget({super.key});

  @override
  State<FriendsListWidget> createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget> {
  final TextEditingController _searchController = TextEditingController();

  // Mock friends data
  final List<Map<String, dynamic>> _friends = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'username': 'sarahj',
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
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
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
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
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
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
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
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

  List<Map<String, dynamic>> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = List.from(_friends);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = List.from(_friends);
      } else {
        _filteredFriends = _friends.where((friend) {
          final name = (friend['name'] as String).toLowerCase();
          final username = (friend['username'] as String).toLowerCase();
          return name.contains(query) || username.contains(query);
        }).toList();
      }
    });
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
                suffixIcon: _searchController.text.isNotEmpty
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
            child: _filteredFriends.isEmpty
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

  Widget _buildFriendCard(BuildContext context, ThemeData theme, Map<String, dynamic> friend) {
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
    // TODO: Navigate to friend profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${friend['name']}\'s profile...'),
        behavior: SnackBarBehavior.floating,
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1.h),
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                _removeFriend(context, friend);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context, Map<String, dynamic> friend) {
    // TODO: Implement messaging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Messaging ${friend['name']} coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFriend(BuildContext context, Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend?'),
        content: Text('Are you sure you want to remove ${friend['name']} from your friends list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement friend removal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${friend['name']} removed from friends'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
}