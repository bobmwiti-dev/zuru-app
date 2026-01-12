import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:zuru_app/core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/memory_card_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/models/auth_user.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/repositories/journal_repository.dart';

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
                  user.name?.isNotEmpty == true
                      ? user.name![0].toUpperCase()
                      : 'U',
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
              itemBuilder:
                  (context) => [
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
                    PopupMenuItem(enabled: false, height: 1, child: Divider()),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to sign out')));
      }
    }
  }
}

class _MemoryFeedContent extends StatefulWidget {
  final AuthUser? user;
  final VoidCallback onLogout;

  const _MemoryFeedContent({required this.user, required this.onLogout});

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

  // Real journal data from Firestore
  List<JournalModel> _journalEntries = [];
  List<JournalModel> _filteredEntries = [];
  final JournalRepository _journalRepository = JournalRepository();

  @override
  void initState() {
    super.initState();
    _loadJournals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Load real journal entries from Firestore
  Future<void> _loadJournals() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      final userId = _journalRepository.currentUserId;
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load user's journals from Firestore
      final journals = await _journalRepository.getUserJournals(
        userId: userId,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _journalEntries = journals;
          _filteredEntries = List.from(journals);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load journals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  /// Load more journal entries from Firestore
  Future<void> _loadMoreEntries() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // Get current user ID
      final userId = _journalRepository.currentUserId;
      if (userId == null) {
        setState(() => _isLoadingMore = false);
        return;
      }

      // Load more journals from Firestore
      // Note: For pagination, we'd need to track the last document snapshot
      // For now, we'll just reload with a higher limit
      final moreJournals = await _journalRepository.getUserJournals(
        userId: userId,
        limit: _journalEntries.length + 10,
      );

      if (mounted) {
        setState(() {
          _journalEntries.addAll(moreJournals);
          _filteredEntries = List.from(_journalEntries);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more journals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle pull to refresh
  Future<void> _handleRefresh() async {
    await _loadJournals();
  }

  /// Handle search
  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredEntries = List.from(_journalEntries);
      } else {
        _filteredEntries =
            _journalEntries.where((entry) {
              final title = entry.title.toLowerCase();
              final location = entry.locationName?.toLowerCase() ?? '';
              final mood = entry.mood?.toLowerCase() ?? '';
              final description = entry.content?.toLowerCase() ?? '';
              return title.contains(_searchQuery) ||
                  location.contains(_searchQuery) ||
                  mood.contains(_searchQuery) ||
                  description.contains(_searchQuery);
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
      case 1: // Friends
        Navigator.pushNamed(context, '/friends-screen');
        break;
      case 2: // Map
        Navigator.pushNamed(context, '/interactive-map-view');
        break;
      case 3: // Add (handled by FAB)
        break;
      case 4: // Analytics
        Navigator.pushNamed(context, '/mood-analytics-screen');
        break;
      case 5: // Profile
        Navigator.pushNamed(context, '/profile-screen');
        break;
    }
  }

  /// Navigate to journal detail
  void _navigateToDetail(JournalModel journal) {
    Navigator.pushNamed(context, '/journal-detail-screen', arguments: journal);
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
        child:
            _filteredEntries.isEmpty && !_isLoading
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
                        SliverToBoxAdapter(child: _buildSearchBar(theme)),

                      // Memory cards list
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
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
                                  journal: entry,
                                  onTap: () => _navigateToDetail(entry),
                                  onEdit: () => _handleEdit(entry),
                                  onShare: () => _handleShare(entry),
                                  onDelete: () => _handleDelete(entry),
                                ),
                              );
                            },
                            childCount:
                                _filteredEntries.length +
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
          suffixIcon:
              _searchQuery.isNotEmpty
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 1.5.h),
          Container(
            width: 60.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: 40.w,
            height: 1.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
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
  void _handleEdit(JournalModel journal) {
    Navigator.pushNamed(
      context,
      '/add-journal-screen',
      arguments: {'mode': 'edit', 'journal': journal},
    );
  }

  /// Handle share action
  void _handleShare(JournalModel journal) {
    Navigator.pushNamed(
      context,
      '/share-screen',
      arguments: {'memory': journal},
    );
  }

  /// Handle delete action
  Future<void> _handleDelete(JournalModel journal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Memory?'),
            content: Text(
              'Are you sure you want to delete "${journal.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && journal.id != null) {
      try {
        await _journalRepository.deleteJournal(journal.id!);

        if (!mounted) return;

        // Remove from local lists
        setState(() {
          _journalEntries.removeWhere((j) => j.id == journal.id);
          _filteredEntries.removeWhere((j) => j.id == journal.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memory deleted'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete memory: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
