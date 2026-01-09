import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Find Friends Widget - Discover and connect with new friends
class FindFriendsWidget extends StatefulWidget {
  const FindFriendsWidget({super.key});

  @override
  State<FindFriendsWidget> createState() => _FindFriendsWidgetState();
}

class _FindFriendsWidgetState extends State<FindFriendsWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, nearby, interests, mutual

  // Mock discoverable users
  final List<Map<String, dynamic>> _discoverableUsers = [
    {
      'id': '1',
      'name': 'Maria Garcia',
      'username': 'mariag',
      'avatar': 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150',
      'mutualFriends': 2,
      'memoriesCount': 15,
      'distance': '2.3 km away',
      'commonInterests': ['Coffee Shops', 'Art Galleries'],
      'recentMemory': 'Visited a new café in Koinange Street',
      'isRequested': false,
    },
    {
      'id': '2',
      'name': 'James Mitchell',
      'username': 'jamesm',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      'mutualFriends': 0,
      'memoriesCount': 22,
      'distance': '5.1 km away',
      'commonInterests': ['Hiking', 'Nature', 'Photography'],
      'recentMemory': 'Hiked up Ngong Hills this morning',
      'isRequested': true,
    },
    {
      'id': '3',
      'name': 'Sophie Chen',
      'username': 'sophiec',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'mutualFriends': 4,
      'memoriesCount': 18,
      'distance': '1.8 km away',
      'commonInterests': ['Food', 'Markets', 'Culture'],
      'recentMemory': 'Found amazing street food in River Road',
      'isRequested': false,
    },
    {
      'id': '4',
      'name': 'Ahmed Hassan',
      'username': 'ahmedh',
      'avatar': 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=150',
      'mutualFriends': 1,
      'memoriesCount': 9,
      'distance': '3.7 km away',
      'commonInterests': ['History', 'Museums', 'Architecture'],
      'recentMemory': 'Explored the National Archives',
      'isRequested': false,
    },
    {
      'id': '5',
      'name': 'Grace Oduya',
      'username': 'graceo',
      'avatar': 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=150',
      'mutualFriends': 3,
      'memoriesCount': 11,
      'distance': '4.2 km away',
      'commonInterests': ['Music', 'Events', 'Nightlife'],
      'recentMemory': 'Amazing jazz night at Alliance Française',
      'isRequested': false,
    },
  ];

  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = List.from(_discoverableUsers);
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
        _filteredUsers = List.from(_discoverableUsers);
      } else {
        _filteredUsers = _discoverableUsers.where((user) {
          final name = (user['name'] as String).toLowerCase();
          final username = (user['username'] as String).toLowerCase();
          final interests = (user['commonInterests'] as List<String>).join(' ').toLowerCase();
          return name.contains(query) || username.contains(query) || interests.contains(query);
        }).toList();
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      // TODO: Implement actual filtering logic
      _filteredUsers = List.from(_discoverableUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Search and Filter
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, interests...',
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

                SizedBox(height: 2.h),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, theme, 'All', 'all'),
                      SizedBox(width: 2.w),
                      _buildFilterChip(context, theme, 'Nearby', 'nearby'),
                      SizedBox(width: 2.w),
                      _buildFilterChip(context, theme, 'Mutual Friends', 'mutual'),
                      SizedBox(width: 2.w),
                      _buildFilterChip(context, theme, 'Interests', 'interests'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _filteredUsers.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.w),
                        child: _buildUserCard(context, theme, user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, ThemeData theme, String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _onFilterChanged(value),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No users found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, ThemeData theme, Map<String, dynamic> user) {
    final isRequested = user['isRequested'] as bool;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and basic info
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  image: DecorationImage(
                    image: NetworkImage(user['avatar'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${user['username']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'auto_stories',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${user['memoriesCount']} memories',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.secondary,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          user['distance'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (user['mutualFriends'] > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${user['mutualFriends']} mutual',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Common interests
          if (user['commonInterests'] != null && (user['commonInterests'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Common Interests',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Wrap(
                  spacing: 1.w,
                  runSpacing: 0.5.h,
                  children: (user['commonInterests'] as List<String>).map((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        interest,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 1.h),
              ],
            ),

          // Recent activity
          if (user['recentMemory'] != null)
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      user['recentMemory'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 2.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: isRequested ? 'Request Sent' : 'Add Friend',
                  onPressed: isRequested ? null : () => _sendFriendRequest(context, user),
                  variant: isRequested ? CustomButtonVariant.tertiary : CustomButtonVariant.primary,
                  size: CustomButtonSize.small,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: CustomButton(
                  text: 'View Profile',
                  onPressed: () => _viewProfile(context, user),
                  variant: CustomButtonVariant.tertiary,
                  size: CustomButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendFriendRequest(BuildContext context, Map<String, dynamic> user) {
    setState(() {
      user['isRequested'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${user['name']}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewProfile(BuildContext context, Map<String, dynamic> user) {
    // TODO: Navigate to user profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${user['name']}\'s profile...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}