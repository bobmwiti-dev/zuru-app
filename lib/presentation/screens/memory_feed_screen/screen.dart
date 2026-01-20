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

    return _MemoryFeedContent(
      user: user,
      onLogout: () => _handleLogout(context, ref),
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

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.primary.withValues(alpha: 0.04),
            theme.colorScheme.tertiary.withValues(alpha: 0.03),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _GlowBlob(
              color: theme.colorScheme.primary,
              size: 220,
              opacity: 0.18,
            ),
          ),
          Positioned(
            top: 220,
            right: -90,
            child: _GlowBlob(
              color: theme.colorScheme.tertiary,
              size: 260,
              opacity: 0.16,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowBlob(
              color: theme.colorScheme.primary,
              size: 280,
              opacity: 0.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowBlob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _PressScale({required this.child, this.onPressed});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (!mounted) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.translucent,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AnimationUtils.fast,
          curve: AnimationUtils.easeInOut,
          child: widget.child,
        ),
      ),
    );
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
  String? _selectedCollection;

  String? _filterEntryType;
  double? _filterMinRating;
  int? _filterCostTier;
  bool? _filterWouldReturn;
  bool _filterHasPhotoOnly = false;
  DateTimeRange? _filterDateRange;

  // Real journal data from Firestore
  List<JournalModel> _journalEntries = [];
  List<JournalModel> _filteredEntries = [];
  final JournalRepository _journalRepository = JournalRepository();

  List<String> _availableCollections = [];

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
          _availableCollections = _deriveCollections(journals);
          _isLoading = false;
        });

        _applyFilters();

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
          _availableCollections = _deriveCollections(_journalEntries);
          _isLoadingMore = false;
        });

        _applyFilters();

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
    });

    _applyFilters();
  }

  List<String> _deriveCollections(List<JournalModel> journals) {
    final set = <String>{};
    for (final j in journals) {
      final c = (j.collection ?? '').trim();
      if (c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  bool _collectionMatches(JournalModel entry) {
    final selected = (_selectedCollection ?? '').trim();
    if (selected.isEmpty) return true;
    final entryCollection = (entry.collection ?? '').trim();
    return entryCollection.toLowerCase() == selected.toLowerCase();
  }

  void _applyFilters() {
    if (!mounted) return;

    final query = _searchQuery.trim();
    final entries = _journalEntries.where(_collectionMatches).where((entry) {
      if (!_passesAdvancedFilters(entry)) return false;
      if (query.isEmpty) return true;
      final title = entry.title.toLowerCase();
      final location = entry.locationName?.toLowerCase() ?? '';
      final city = entry.locationCity?.toLowerCase() ?? '';
      final country = entry.locationCountry?.toLowerCase() ?? '';
      final address = entry.locationAddress?.toLowerCase() ?? '';
      final mood = entry.mood?.toLowerCase() ?? '';
      final description = entry.content?.toLowerCase() ?? '';
      final collection = entry.collection?.toLowerCase() ?? '';
      final vibes = entry.reviewVibes.join(' ').toLowerCase();
      return title.contains(query) ||
          location.contains(query) ||
          city.contains(query) ||
          country.contains(query) ||
          address.contains(query) ||
          mood.contains(query) ||
          description.contains(query) ||
          collection.contains(query) ||
          vibes.contains(query);
    }).toList();

    setState(() {
      _filteredEntries = entries;
    });
  }

  bool _passesAdvancedFilters(JournalModel entry) {
    final type = (entry.entryType ?? 'memory').toLowerCase().trim();
    if (_filterEntryType != null && _filterEntryType!.trim().isNotEmpty) {
      final expected = _filterEntryType!.toLowerCase().trim();
      if (type != expected) return false;
    }

    if (_filterHasPhotoOnly) {
      if (entry.photos.isEmpty || entry.photos.first.trim().isEmpty) {
        return false;
      }
    }

    if (_filterDateRange != null) {
      final start = _filterDateRange!.start;
      final end = _filterDateRange!.end;
      final d = entry.createdAt;
      if (d.isBefore(DateTime(start.year, start.month, start.day))) return false;
      if (d.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59))) {
        return false;
      }
    }

    if (_filterMinRating != null) {
      final rating = entry.reviewRating;
      if (rating == null) return false;
      if (rating < _filterMinRating!) return false;
    }

    if (_filterCostTier != null) {
      final cost = entry.reviewCostTier;
      if (cost == null) return false;
      if (cost != _filterCostTier) return false;
    }

    if (_filterWouldReturn != null) {
      final wr = entry.reviewWouldReturn;
      if (wr == null) return false;
      if (wr != _filterWouldReturn) return false;
    }

    return true;
  }

  int _activeAdvancedFilterCount() {
    var count = 0;
    if ((_filterEntryType ?? '').trim().isNotEmpty) count++;
    if (_filterMinRating != null) count++;
    if (_filterCostTier != null) count++;
    if (_filterWouldReturn != null) count++;
    if (_filterHasPhotoOnly) count++;
    if (_filterDateRange != null) count++;
    return count;
  }

  Future<void> _openAdvancedFilters() async {
    final theme = Theme.of(context);

    String? entryType = _filterEntryType;
    double? minRating = _filterMinRating;
    int? costTier = _filterCostTier;
    bool? wouldReturn = _filterWouldReturn;
    bool hasPhotoOnly = _filterHasPhotoOnly;
    DateTimeRange? dateRange = _filterDateRange;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDateRange() async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDateRange: dateRange,
              );
              if (picked == null) return;
              setModalState(() => dateRange = picked);
            }

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                left: 4.w,
                right: 4.w,
                top: 2.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Filters',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                entryType = null;
                                minRating = null;
                                costTier = null;
                                wouldReturn = null;
                                hasPhotoOnly = false;
                                dateRange = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Entry type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Wrap(
                        spacing: 2.w,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: (entryType ?? '').trim().isEmpty,
                            onSelected: (_) {
                              setModalState(() => entryType = null);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Memory'),
                            selected: (entryType ?? '') == 'memory',
                            onSelected: (_) {
                              setModalState(() => entryType = 'memory');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Place Review'),
                            selected: (entryType ?? '') == 'review',
                            onSelected: (_) {
                              setModalState(() => entryType = 'review');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: SwitchListTile(
                          value: hasPhotoOnly,
                          onChanged: (v) {
                            setModalState(() => hasPhotoOnly = v);
                          },
                          title: Text(
                            'Photos only',
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Show entries that have at least one photo',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Rating (reviews)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: (minRating ?? 0).clamp(0.0, 5.0),
                              min: 0,
                              max: 5,
                              divisions: 10,
                              onChanged: (v) {
                                setModalState(() {
                                  minRating = v <= 0 ? null : v;
                                  entryType ??= 'review';
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.7.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              (minRating ?? 0) <= 0
                                  ? 'Any'
                                  : '${(minRating ?? 0).toStringAsFixed(1)}+',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Cost (reviews)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Wrap(
                        spacing: 2.w,
                        children: [
                          ChoiceChip(
                            label: const Text('Any'),
                            selected: costTier == null,
                            onSelected: (_) {
                              setModalState(() => costTier = null);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('\$'),
                            selected: costTier == 1,
                            onSelected: (_) {
                              setModalState(() {
                                costTier = 1;
                                entryType ??= 'review';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('\$\$'),
                            selected: costTier == 2,
                            onSelected: (_) {
                              setModalState(() {
                                costTier = 2;
                                entryType ??= 'review';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('\$\$\$'),
                            selected: costTier == 3,
                            onSelected: (_) {
                              setModalState(() {
                                costTier = 3;
                                entryType ??= 'review';
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Would return (reviews)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Wrap(
                        spacing: 2.w,
                        children: [
                          ChoiceChip(
                            label: const Text('Any'),
                            selected: wouldReturn == null,
                            onSelected: (_) {
                              setModalState(() => wouldReturn = null);
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Yes'),
                            selected: wouldReturn == true,
                            onSelected: (_) {
                              setModalState(() {
                                wouldReturn = true;
                                entryType ??= 'review';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: const Text('No'),
                            selected: wouldReturn == false,
                            onSelected: (_) {
                              setModalState(() {
                                wouldReturn = false;
                                entryType ??= 'review';
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Date range',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: pickDateRange,
                              child: Text(
                                dateRange == null
                                    ? 'Any time'
                                    : '${dateRange!.start.year}-${dateRange!.start.month.toString().padLeft(2, '0')}-${dateRange!.start.day.toString().padLeft(2, '0')}  →  ${dateRange!.end.year}-${dateRange!.end.month.toString().padLeft(2, '0')}-${dateRange!.end.day.toString().padLeft(2, '0')}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (dateRange != null) ...[
                            SizedBox(width: 2.w),
                            IconButton(
                              onPressed: () {
                                setModalState(() => dateRange = null);
                              },
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _filterEntryType = entryType;
                                  _filterMinRating = minRating;
                                  _filterCostTier = costTier;
                                  _filterWouldReturn = wouldReturn;
                                  _filterHasPhotoOnly = hasPhotoOnly;
                                  _filterDateRange = dateRange;
                                });
                                _applyFilters();
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionFilters(ThemeData theme) {
    if (_availableCollections.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 5.2.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        children: [
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: ChoiceChip(
              label: const Text('All'),
              selected: (_selectedCollection ?? '').trim().isEmpty,
              onSelected: (_) {
                AnimationUtils.selectionClick();
                setState(() => _selectedCollection = null);
                _applyFilters();
              },
            ),
          ),
          ..._availableCollections.map((c) {
            final isSelected =
                (_selectedCollection ?? '').trim().toLowerCase() ==
                c.trim().toLowerCase();
            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: ChoiceChip(
                label: Text(c),
                selected: isSelected,
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() => _selectedCollection = c);
                  _applyFilters();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, dynamic> _journalToShareMap(JournalModel journal) {
    final imageUrl =
        journal.photos.isNotEmpty && journal.photos.first.trim().isNotEmpty
            ? journal.photos.first
            : '';

    return {
      'id': journal.id ?? '',
      'title': journal.title,
      'location': journal.locationName ?? '',
      'mood': journal.mood ?? '',
      'moodColor': Colors.blue.toARGB32(),
      'imageUrl': imageUrl,
      'collection': journal.collection,
      'entryType': journal.entryType,
      'reviewRating': journal.reviewRating,
      'reviewCostTier': journal.reviewCostTier,
      'reviewVibes': journal.reviewVibes,
      'reviewWouldReturn': journal.reviewWouldReturn,
      'reviewHighlights': journal.reviewHighlights,
      'reviewTips': journal.reviewTips,
      'captionSuggestions': journal.captionSuggestions,
      'highlightSuggestions': journal.highlightSuggestions,
      'selectedCaption': journal.selectedCaption,
      'suggestionsGeneratedAt': journal.suggestionsGeneratedAt?.toIso8601String(),
      'suggestionsSource': journal.suggestionsSource,
      'createdAt': journal.createdAt.toIso8601String(),
    };
  }

  /// Handle bottom navigation
  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
  }

  /// Navigate to journal detail
  void _navigateToDetail(JournalModel journal) {
    Navigator.pushNamed(context, '/journal-detail-screen', arguments: journal);
  }

  /// Navigate to add journal
  Future<void> _navigateToAddJournal() async {
    final result = await Navigator.pushNamed(context, '/add-journal-screen');
    if (result == true) {
      await _loadJournals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBackground()),
          SafeArea(
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
                        SliverToBoxAdapter(child: SizedBox(height: 14.h)),
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
                              SliverToBoxAdapter(
                                child: GreetingHeaderWidget(
                                  userName: widget.user?.name,
                                  onSearchTap: () {
                                    setState(
                                      () => _isSearching = !_isSearching,
                                    );
                                  },
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: AnimatedSwitcher(
                                  duration: AnimationUtils.medium,
                                  switchInCurve: AnimationUtils.easeInOut,
                                  switchOutCurve: AnimationUtils.easeInOut,
                                  child:
                                      _isSearching
                                          ? _buildSearchBar(theme)
                                          : const SizedBox.shrink(),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 1.h),
                                  child: _buildCollectionFilters(theme),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index >= _filteredEntries.length) {
                                      return _isLoadingMore
                                          ? _buildShimmerPost(theme)
                                          : const SizedBox.shrink();
                                    }

                                    final entry = _filteredEntries[index];
                                    final isLiked = entry.id != null &&
                                        _likedJournalIds.contains(entry.id);
                                    final isSaved = entry.id != null &&
                                        _savedJournalIds.contains(entry.id);
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
                              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                            ],
                          ),
                        ),
          ),
        ],
      ),
      floatingActionButton:
          (_isLoading || _filteredEntries.isEmpty) ? null : _buildFAB(theme),
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
    final activeCount = _activeAdvancedFilterCount();
    return CustomAppBar(
      title: 'Zuru',
      style: CustomAppBarStyle.standard,
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.tune,
                color: theme.colorScheme.onSurface,
              ),
              if (activeCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        activeCount > 9 ? '9+' : '$activeCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            AnimationUtils.selectionClick();
            _openAdvancedFilters();
          },
          tooltip: 'Filters',
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'search',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            AnimationUtils.selectionClick();
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
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

  Widget _buildShimmerPost(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    final neonCyan = const Color(0xFF00E5FF);
    final neonPurple = const Color(0xFFB000FF);
    final borderColor = Color.lerp(neonCyan, neonPurple, 0.55)!.withValues(
      alpha: 0.22,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withValues(alpha: 0.10),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: neonPurple.withValues(alpha: 0.08),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ShimmerContainer(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
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
      ),
    );
  }

  /// Build floating action button
  Widget _buildFAB(ThemeData theme) {
    return _PressScale(
      onPressed: () {
        AnimationUtils.selectionClick();
        _navigateToAddJournal();
      },
      child: FloatingActionButton.extended(
        onPressed: () {
          AnimationUtils.selectionClick();
          _navigateToAddJournal();
        },
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
      ),
    );
  }

  /// Handle edit action
  Future<void> _handleEdit(JournalModel journal) async {
    final result = await Navigator.pushNamed(
      context,
      '/add-journal-screen',
      arguments: {'mode': 'edit', 'journal': journal},
    );
    if (result == true) {
      await _loadJournals();
    }
  }

  /// Handle share action
  void _handleShare(JournalModel journal) {
    Navigator.pushNamed(
      context,
      '/share-screen',
      arguments: {'memory': _journalToShareMap(journal)},
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
