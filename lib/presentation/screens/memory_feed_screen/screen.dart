import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Set<String> _likedJournalIds = {};
  Set<String> _savedJournalIds = {};

  Future<void> _loadReactionStateForJournals(
    List<JournalModel> journals, {
    required bool merge,
  }) async {
    final uid = _journalRepository.currentUserId;
    if (uid == null) return;

    final ids = journals
        .map((j) => j.id)
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toList();
    if (ids.isEmpty) return;

    try {
      final liked = await _journalRepository.getLikedJournalIds(ids);
      final saved = await _journalRepository.getSavedJournalIds(ids);

      if (!mounted) return;
      setState(() {
        if (merge) {
          _likedJournalIds = {..._likedJournalIds, ...liked};
          _savedJournalIds = {..._savedJournalIds, ...saved};
        } else {
          _likedJournalIds = liked;
          _savedJournalIds = saved;
        }
      });
    } catch (_) {
      // Ignore reaction state fetch errors; feed should still render.
    }
  }

  Future<void> _toggleLikeForEntry(JournalModel entry, bool nextIsLiked) async {
    final id = entry.id;
    final uid = _journalRepository.currentUserId;
    if (id == null || uid == null) return;

    final previous = entry;
    final nextCount = nextIsLiked
        ? entry.likesCount + 1
        : (entry.likesCount > 0 ? entry.likesCount - 1 : 0);
    final updated = entry.copyWith(likesCount: nextCount);

    final prevLikedIds = _likedJournalIds;
    final nextLikedIds = Set<String>.from(_likedJournalIds);
    if (nextIsLiked) {
      nextLikedIds.add(id);
    } else {
      nextLikedIds.remove(id);
    }

    setState(() {
      _journalEntries = _journalEntries
          .map((j) => j.id == id ? updated : j)
          .toList();
      _filteredEntries = _filteredEntries
          .map((j) => j.id == id ? updated : j)
          .toList();
      _likedJournalIds = nextLikedIds;
    });

    try {
      await _journalRepository.toggleLike(id, isLiked: nextIsLiked);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _journalEntries = _journalEntries
            .map((j) => j.id == id ? previous : j)
            .toList();
        _filteredEntries = _filteredEntries
            .map((j) => j.id == id ? previous : j)
            .toList();
        _likedJournalIds = prevLikedIds;
      });
    }
  }

  Future<void> _toggleSaveForEntry(JournalModel entry, bool nextIsSaved) async {
    final id = entry.id;
    final uid = _journalRepository.currentUserId;
    if (id == null || uid == null) return;

    final previous = entry;
    final nextCount = nextIsSaved
        ? entry.savesCount + 1
        : (entry.savesCount > 0 ? entry.savesCount - 1 : 0);
    final updated = entry.copyWith(savesCount: nextCount);

    final prevSavedIds = _savedJournalIds;
    final nextSavedIds = Set<String>.from(_savedJournalIds);
    if (nextIsSaved) {
      nextSavedIds.add(id);
    } else {
      nextSavedIds.remove(id);
    }

    setState(() {
      _journalEntries = _journalEntries
          .map((j) => j.id == id ? updated : j)
          .toList();
      _filteredEntries = _filteredEntries
          .map((j) => j.id == id ? updated : j)
          .toList();
      _savedJournalIds = nextSavedIds;
    });

    try {
      await _journalRepository.toggleSave(id, isSaved: nextIsSaved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _journalEntries = _journalEntries
            .map((j) => j.id == id ? previous : j)
            .toList();
        _filteredEntries = _filteredEntries
            .map((j) => j.id == id ? previous : j)
            .toList();
        _savedJournalIds = prevSavedIds;
      });
    }
  }

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

  void _prefetchFeedImages(List<JournalModel> journals) {
    if (!mounted) return;

    final urls = <String>[];
    for (final j in journals) {
      if (j.photos.isNotEmpty && j.photos.first.trim().isNotEmpty) {
        urls.add(j.photos.first);
      }
      if (urls.length >= 6) break;
    }

    for (final url in urls) {
      precacheImage(CachedNetworkImageProvider(url), context);
    }
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

        _prefetchFeedImages(journals);
        await _loadReactionStateForJournals(journals, merge: false);
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

        _prefetchFeedImages(moreJournals);
        await _loadReactionStateForJournals(moreJournals, merge: true);
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
            _isLoading
                ? CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: GreetingHeaderWidget(
                        userName: widget.user?.name,
                        onSearchTap: () {
                          setState(() => _isSearching = !_isSearching);
                        },
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildShimmerPost(theme);
                        },
                        childCount: 4,
                      ),
                    ),
                  ],
                )
                : _filteredEntries.isEmpty
                    ? EmptyStateWidget(onCreateMemory: _navigateToAddJournal)
                    : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: theme.colorScheme.primary,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
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

                          // Feed list (edge-to-edge)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= _filteredEntries.length) {
                                  return _isLoadingMore
                                      ? _buildShimmerPost(theme)
                                      : const SizedBox.shrink();
                                }

                                final entry = _filteredEntries[index];
                                final isLiked =
                                    entry.id != null && _likedJournalIds.contains(entry.id);
                                final isSaved =
                                    entry.id != null && _savedJournalIds.contains(entry.id);
                                return MemoryCardWidget(
                                  journal: entry,
                                  isLiked: isLiked,
                                  isSaved: isSaved,
                                  onLikeChanged: (isLiked) {
                                    _toggleLikeForEntry(entry, isLiked);
                                  },
                                  onSaveChanged: (isSaved) {
                                    _toggleSaveForEntry(entry, isSaved);
                                  },
                                  onTap: () => _navigateToDetail(entry),
                                  onEdit: () => _handleEdit(entry),
                                  onShare: () => _handleShare(entry),
                                  onDelete: () => _handleDelete(entry),
                                );
                              },
                              childCount:
                                  _filteredEntries.length +
                                  (_isLoadingMore ? 1 : 0),
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
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 0.5,
        ),
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

  Widget _buildShimmerPost(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Row(
                children: [
                  ShimmerContainer(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerContainer(
                          width: 40.w,
                          height: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        SizedBox(height: 0.6.h),
                        ShimmerContainer(
                          width: 28.w,
                          height: 10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                  ShimmerContainer(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: ShimmerContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.25.h),
              child: Row(
                children: [
                  ShimmerContainer(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  SizedBox(width: 3.w),
                  ShimmerContainer(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  SizedBox(width: 3.w),
                  ShimmerContainer(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const Spacer(),
                  ShimmerContainer(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerContainer(
                    width: double.infinity,
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  SizedBox(height: 0.8.h),
                  ShimmerContainer(
                    width: 70.w,
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
          ],
        ),
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
