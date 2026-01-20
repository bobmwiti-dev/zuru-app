import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../app/di/injector.dart' show journalRepositoryProvider;
import '../../../app/di/injector.dart' show userRepositoryProvider;
import '../../../providers/auth_provider.dart';
import '../../../domain/models/auth_user.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/models/user_model.dart';
import './widgets/profile_menu_widget.dart';

/// Instagram-Style Profile Screen
/// Enhanced with modern UI patterns, smooth animations, and Instagram-like interactions
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 5;
  late TabController _tabController;

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
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
              SizedBox(height: 2.h),
              Text('User not found', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: _PremiumBackground()),
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  elevation: 0,
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.72),
                  surfaceTintColor: Colors.transparent,
                  title: AnimatedOpacity(
                    opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      (user.name ?? 'Profile').trim().isEmpty
                          ? 'Profile'
                          : (user.name ?? 'Profile'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.add_box_outlined,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.addJournal),
                      tooltip: 'New memory',
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                      onPressed: () => _showProfileMenu(context),
                      tooltip: 'Menu',
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _ProfileHeader(user: user),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: theme.colorScheme.primary,
                      indicatorWeight: 1,
                      labelColor: theme.colorScheme.onSurface,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      dividerColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on, size: 24)),
                        Tab(icon: Icon(Icons.bookmark_border, size: 24)),
                        Tab(icon: Icon(Icons.insights_outlined, size: 24)),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: const [
                _ProfileJournalsGridTab(saved: false),
                _ProfileJournalsGridTab(saved: true),
                _ProfileInsightsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileMenuSheet(),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);
  }
}

class _ProfileHeader extends ConsumerWidget {
  final AuthUser user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userRepository = ref.watch(userRepositoryProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        userRepository.getUserProfile(user.id),
        userRepository.getUserStats(user.id),
      ]),
      builder: (context, snapshot) {
        final profile = snapshot.data != null ? snapshot.data![0] as UserModel? : null;
        final stats = snapshot.data != null ? snapshot.data![1] as UserStats : UserStats.empty();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ProfileAvatar(user: user),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatColumn(label: 'Memories', value: stats.journalsCount),
                              _StatColumn(label: 'Friends', value: stats.friendsCount),
                              _StatColumn(label: 'Following', value: stats.followingCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.2.h),
                    Text(
                      (user.name ?? user.email).trim().isEmpty
                          ? 'User'
                          : (user.name ?? user.email),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if ((profile?.bio ?? '').trim().isNotEmpty) ...[
                      SizedBox(height: 0.6.h),
                      Text(
                        profile!.bio!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.25,
                        ),
                      ),
                    ],
                    SizedBox(height: 1.4.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _ActionButton(
                            text: 'Edit profile',
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          flex: 3,
                          child: _ActionButton(
                            text: 'New memory',
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.addJournal),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        _ActionIconButton(
                          icon: Icons.share_outlined,
                          onPressed: () {
                            final name = (user.name ?? user.email).trim();
                            Share.share('Check out my Zuru profile: $name');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final AuthUser user;

  const _ProfileAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = (user.avatarUrl ?? '').trim();
    final initials = _getInitials((user.name ?? user.email).trim());

    return Container(
      width: 22.w,
      height: 22.w,
      margin: EdgeInsets.only(right: 4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.85),
            theme.colorScheme.tertiary.withValues(alpha: 0.80),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? CustomImageWidget(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    semanticLabel: user.name,
                  )
                : Center(
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    final safe = name.trim();
    if (safe.isEmpty) return 'U';
    final parts = safe.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return safe[0].toUpperCase();
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatCount(value),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  static String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _ActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 3.w),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

class _ProfileJournalsGridTab extends ConsumerWidget {
  final bool saved;

  const _ProfileJournalsGridTab({required this.saved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final journalRepository = ref.watch(journalRepositoryProvider);
    final uid = journalRepository.currentUserId;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<JournalModel>>(
      future: saved
          ? journalRepository.getSavedJournals(limit: 60)
          : journalRepository.getUserJournals(userId: uid, limit: 60),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildGridLoading(theme);
        }

        final journals = snapshot.data ?? <JournalModel>[];

        if (journals.isEmpty) {
          return _buildEmptyState(context, theme, saved);
        }

        return GridView.builder(
          key: PageStorageKey<String>(saved ? 'saved_grid' : 'posts_grid'),
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: journals.length,
          itemBuilder: (context, index) => _JournalGridTile(journal: journals[index]),
        );
      },
    );
  }

  Widget _buildGridLoading(ThemeData theme) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: 18,
      itemBuilder: (context, index) {
        return Container(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool saved) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(8.w),
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onSurface,
                width: 2,
              ),
            ),
            child: Icon(
              saved ? Icons.bookmark_border : Icons.grid_on_outlined,
              size: 36,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          saved ? 'No saved memories yet' : 'No memories yet',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          saved
              ? 'Save meaningful memories from your feed to revisit later.'
              : 'Start journaling to build your personal memory library.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (!saved) ...[
          SizedBox(height: 2.h),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addJournal),
              child: Text(
                'Write your first memory',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _JournalGridTile extends StatelessWidget {
  final JournalModel journal;

  const _JournalGridTile({required this.journal});

  @override
  Widget build(BuildContext context) {
    final imageUrl = journal.photos.isNotEmpty && journal.photos.first.trim().isNotEmpty
        ? journal.photos.first
        : null;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/journal-detail-screen',
        arguments: journal,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            semanticLabel: journal.title,
          ),
          if (journal.photos.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 20,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileInsightsTab extends StatelessWidget {
  const _ProfileInsightsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Understand your patterns and celebrate your progress.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          _InsightCard(
            icon: Icons.insights_outlined,
            title: 'Mood analytics',
            subtitle: 'Trends, mood balance, and your emotional journey.',
            cta: 'View analytics',
            onTap: () => Navigator.pushNamed(context, AppRoutes.moodAnalytics),
          ),
          SizedBox(height: 1.4.h),
          _InsightCard(
            icon: Icons.auto_awesome,
            title: 'AI insights',
            subtitle: 'Personalized reflections generated from your memories.',
            cta: 'Open AI insights',
            onTap: () => Navigator.pushNamed(context, AppRoutes.aiInsights),
          ),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        cta,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1.h),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const ProfileMenuWidget(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
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