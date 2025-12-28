import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:zuru_app/core/app_export.dart';
import 'package:zuru_app/widgets/custom_app_bar.dart';
import 'package:zuru_app/widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/memory_card_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/auth_user.dart';

/// Memory Feed Screen - Primary home screen displaying journal entries
/// Implements chronological feed with pull-to-refresh and infinite scroll
class MemoryFeedScreen extends ConsumerWidget {
  const MemoryFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Journal',
        actions: [
          // User profile button
          if (user != null)
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout(context, ref);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  enabled: false,
                  height: 1,
                  child: Divider(),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sign Out', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _MemoryFeedContent(
        user: user,
        onLogout: () => _handleLogout(context, ref),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authStateProvider.notifier).signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out')),
        );
      }
    }
  }
}

class _MemoryFeedContent extends StatefulWidget {
  final AuthUser? user;
  final VoidCallback onLogout;

  const _MemoryFeedContent({
    required this.user,
    required this.onLogout,
  });

  @override
  State<_MemoryFeedContent> createState() => _MemoryFeedContentState();
}

class _MemoryFeedContentState extends State<_MemoryFeedContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  String _searchQuery = '';

  // Mock data for journal entries
  List<Map<String, dynamic>> _journalEntries = [];
  List<Map<String, dynamic>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load mock journal entries
  void _loadMockData() {
    _journalEntries = [
      {
        "id": "1",
        "title": "Coffee at Java House",
        "description":
            "Amazing cappuccino and great ambiance. Perfect spot for morning journaling.",
        "mood": "Happy",
        "moodIcon": "sentiment_satisfied",
        "moodColor": 0xFFF4E4BC,
        "location": "Java House, Westlands",
        "coordinates": {"lat": -1.2674, "lng": 36.8108},
        "timestamp": DateTime.now().subtract(Duration(hours: 2)),
        "imageUrl":
            "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
        "semanticLabel":
            "Steaming cup of cappuccino with latte art on wooden table in cozy cafe setting",
        "companions": ["Sarah", "Mike"],
        "isOffline": false,
      },
      {
        "id": "2",
        "title": "Sunset at Karura Forest",
        "description":
            "Peaceful evening walk through the forest trails. Nature therapy at its finest.",
        "mood": "Calm",
        "moodIcon": "self_improvement",
        "moodColor": 0xFF2D7D7D,
        "location": "Karura Forest, Nairobi",
        "coordinates": {"lat": -1.2421, "lng": 36.8358},
        "timestamp": DateTime.now().subtract(Duration(days: 1)),
        "imageUrl":
            "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800",
        "semanticLabel":
            "Golden sunset filtering through tall trees in lush green forest with walking path",
        "companions": [],
        "isOffline": false,
      },
      {
        "id": "3",
        "title": "Rooftop Dinner at Tribe Hotel",
        "description":
            "Celebrated promotion with the team. Incredible city views and delicious food!",
        "mood": "Excited",
        "moodIcon": "celebration",
        "moodColor": 0xFFE8B4B8,
        "location": "Tribe Hotel, Gigiri",
        "coordinates": {"lat": -1.2357, "lng": 36.8076},
        "timestamp": DateTime.now().subtract(Duration(days: 2)),
        "imageUrl":
            "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
        "semanticLabel":
            "Elegant rooftop restaurant with city skyline view at dusk, tables with ambient lighting",
        "companions": ["Team"],
        "isOffline": false,
      },
      {
        "id": "4",
        "title": "Morning Yoga at Uhuru Park",
        "description":
            "Started the day with outdoor yoga session. Feeling refreshed and centered.",
        "mood": "Calm",
        "moodIcon": "self_improvement",
        "moodColor": 0xFF2D7D7D,
        "location": "Uhuru Park, CBD",
        "coordinates": {"lat": -1.2833, "lng": 36.8167},
        "timestamp": DateTime.now().subtract(Duration(days: 3)),
        "imageUrl":
            "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
        "semanticLabel":
            "Person in yoga pose on mat in green park with morning sunlight",
        "companions": [],
        "isOffline": false,
      },
      {
        "id": "5",
        "title": "Art Gallery Visit",
        "description":
            "Explored contemporary African art at Circle Art Gallery. So much inspiration!",
        "mood": "Inspired",
        "moodIcon": "lightbulb",
        "moodColor": 0xFFD4A574,
        "location": "Circle Art Gallery, Parklands",
        "coordinates": {"lat": -1.2667, "lng": 36.8167},
        "timestamp": DateTime.now().subtract(Duration(days: 4)),
        "imageUrl":
            "https://images.unsplash.com/photo-1536924940846-227afb31e2a5?w=800",
        "semanticLabel":
            "Modern art gallery interior with colorful abstract paintings on white walls",
        "companions": ["Alex"],
        "isOffline": false,
      },
      {
        "id": "6",
        "title": "Weekend Market at Village Market",
        "description":
            "Found amazing handcrafted items and enjoyed live music. Love supporting local artisans.",
        "mood": "Happy",
        "moodIcon": "sentiment_satisfied",
        "moodColor": 0xFFF4E4BC,
        "location": "Village Market, Gigiri",
        "coordinates": {"lat": -1.2357, "lng": 36.8076},
        "timestamp": DateTime.now().subtract(Duration(days: 5)),
        "imageUrl":
            "https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=800",
        "semanticLabel":
            "Colorful outdoor market stalls with handcrafted items and people browsing",
        "companions": ["Emma"],
        "isOffline": false,
      },
      {
        "id": "7",
        "title": "Late Night Coding Session",
        "description":
            "Finally cracked that bug! Sometimes the best solutions come at midnight.",
        "mood": "Accomplished",
        "moodIcon": "emoji_events",
        "moodColor": 0xFF4A9B8E,
        "location": "Home Office, Kilimani",
        "coordinates": {"lat": -1.2921, "lng": 36.7833},
        "timestamp": DateTime.now().subtract(Duration(days: 6)),
        "imageUrl":
            "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800",
        "semanticLabel":
            "Laptop with code on screen in dimly lit room with coffee cup nearby",
        "companions": [],
        "isOffline": false,
      },
      {
        "id": "8",
        "title": "Brunch at Artcaffe",
        "description":
            "Lazy Sunday brunch with friends. Good food, better conversations.",
        "mood": "Content",
        "moodIcon": "favorite",
        "moodColor": 0xFFE8B4B8,
        "location": "Artcaffe, The Junction",
        "coordinates": {"lat": -1.2921, "lng": 36.7833},
        "timestamp": DateTime.now().subtract(Duration(days: 7)),
        "imageUrl":
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800",
        "semanticLabel":
            "Colorful brunch spread with pancakes, fruits, and coffee on rustic wooden table",
        "companions": ["Lisa", "Tom", "Kate"],
        "isOffline": false,
      },
    ];

    _filteredEntries = List.from(_journalEntries);
  }

  /// Handle scroll for infinite loading
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _filteredEntries.length < 50) {
        _loadMoreEntries();
      }
    }
  }

  /// Simulate loading more entries
  Future<void> _loadMoreEntries() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    await Future.delayed(Duration(seconds: 1));

    // Add more mock entries
    final newEntries = List.generate(3, (index) {
      final baseIndex = _journalEntries.length + index;
      return {
        "id": "new_$baseIndex",
        "title": "Memory ${baseIndex + 1}",
        "description": "Another wonderful moment captured in time.",
        "mood": ["Happy", "Calm", "Excited"][index % 3],
        "moodIcon": [
          "sentiment_satisfied",
          "self_improvement",
          "celebration"
        ][index % 3],
        "moodColor": [0xFFF4E4BC, 0xFF2D7D7D, 0xFFE8B4B8][index % 3],
        "location": "Nairobi, Kenya",
        "coordinates": {"lat": -1.2921, "lng": 36.8219},
        "timestamp": DateTime.now().subtract(Duration(days: 8 + index)),
        "imageUrl":
            "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
        "semanticLabel":
            "Scenic landscape view with mountains and clear blue sky",
        "companions": [],
        "isOffline": false,
      };
    });

    setState(() {
      _journalEntries.addAll(newEntries);
      if (_searchQuery.isEmpty) {
        _filteredEntries.addAll(newEntries);
      }
      _isLoadingMore = false;
    });
  }

  /// Handle pull to refresh
  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _loadMockData();
      _isLoading = false;
    });
  }

  /// Handle search
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredEntries = List.from(_journalEntries);
      } else {
        _filteredEntries = _journalEntries.where((entry) {
          final title = (entry["title"] as String).toLowerCase();
          final location = (entry["location"] as String).toLowerCase();
          final mood = (entry["mood"] as String).toLowerCase();
          return title.contains(_searchQuery) ||
              location.contains(_searchQuery) ||
              mood.contains(_searchQuery);
        }).toList();
      }
    });
  }

  /// Handle bottom navigation
  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0: // Feed - already here
        break;
      case 1: // Map
        Navigator.pushNamed(context, '/interactive-map-view');
        break;
      case 2: // Add (handled by FAB)
        break;
      case 3: // Analytics
        Navigator.pushNamed(context, '/mood-analytics-screen');
        break;
      case 4: // Profile
        Navigator.pushNamed(context, '/authentication-screen');
        break;
    }
  }

  /// Navigate to journal detail
  void _navigateToDetail(Map<String, dynamic> entry) {
    Navigator.pushNamed(
      context,
      '/journal-detail-screen',
      arguments: entry,
    );
  }

  /// Navigate to add journal
  void _navigateToAddJournal() {
    Navigator.pushNamed(context, '/add-journal-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: _filteredEntries.isEmpty && !_isLoading
            ? EmptyStateWidget(onCreateMemory: _navigateToAddJournal)
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: theme.colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Greeting header
                    SliverToBoxAdapter(
                      child: GreetingHeaderWidget(
                        userName: widget.user?.name,
                        onSearchTap: () {
                          setState(() => _isSearching = !_isSearching);
                        },
                      ),
                    ),

                    // Search bar (when active)
                    if (_isSearching)
                      SliverToBoxAdapter(
                        child: _buildSearchBar(theme),
                      ),

                    // Memory cards list
                    SliverPadding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= _filteredEntries.length) {
                              return _isLoadingMore
                                  ? _buildLoadingCard(theme)
                                  : SizedBox.shrink();
                            }

                            final entry = _filteredEntries[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: MemoryCardWidget(
                                entry: entry,
                                onTap: () => _navigateToDetail(entry),
                                onEdit: () => _handleEdit(entry),
                                onShare: () => _handleShare(entry),
                                onDelete: () => _handleDelete(entry),
                              ),
                            );
                          },
                          childCount: _filteredEntries.length +
                              (_isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: _buildFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
        showCenterButton: true,
        onCenterButtonTap: _navigateToAddJournal,
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return CustomAppBar(
      title: 'Zuru',
      style: CustomAppBarStyle.standard,
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'search',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            setState(() => _isSearching = !_isSearching);
          },
          tooltip: 'Search',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  /// Build search bar
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: _handleSearch,
        decoration: InputDecoration(
          hintText: 'Search by title, location, or mood...',
          prefixIcon: CustomIconWidget(
            iconName: 'search',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  /// Build loading card skeleton
  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 25.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 1.5.h),
          Container(
            width: 60.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: 40.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget _buildFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddJournal,
      icon: CustomIconWidget(
        iconName: 'add',
        color: theme.colorScheme.onPrimary,
        size: 24,
      ),
      label: Text(
        'New Memory',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      elevation: 4,
    );
  }

  /// Handle edit action
  void _handleEdit(Map<String, dynamic> entry) {
    Navigator.pushNamed(
      context,
      '/add-journal-screen',
      arguments: {'mode': 'edit', 'entry': entry},
    );
  }

  /// Handle share action
  void _handleShare(Map<String, dynamic> entry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${entry["title"]}"...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle delete action
  void _handleDelete(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Memory?'),
        content: Text(
            'Are you sure you want to delete "${entry["title"]}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _journalEntries.removeWhere((e) => e["id"] == entry["id"]);
                _filteredEntries.removeWhere((e) => e["id"] == entry["id"]);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memory deleted'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
