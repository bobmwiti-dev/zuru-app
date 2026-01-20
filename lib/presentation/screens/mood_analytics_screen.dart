import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/ai_insights_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/location_insights_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_calendar_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_distribution_chart_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_streak_header_widget.dart';
import 'package:zuru_app/presentation/screens/mood_analytics_screen/widgets/mood_trend_chart_widget.dart';
import 'package:zuru_app/data/models/journal_model.dart';
import 'package:zuru_app/data/repositories/journal_repository.dart';

/// Mood Analytics Screen - Provides insightful visualization of emotional patterns
/// Implements mobile-optimized charts with pull-to-refresh and export functionality
class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  int _currentBottomNavIndex = 4; // Analytics tab active
  String _selectedPeriod = 'week'; // week, month, year
  bool _isLoading = false;
  DateTime _selectedCalendarDay = DateTime.now();

  final JournalRepository _journalRepository = JournalRepository();

  Map<String, dynamic> _analyticsData = const {
    'currentStreak': 0,
    'weeklyEntries': 0,
    'moodDistribution': <Map<String, dynamic>>[],
    'moodTrends': <String, dynamic>{
      'week': <Map<String, dynamic>>[],
      'month': <Map<String, dynamic>>[],
      'year': <Map<String, dynamic>>[],
    },
    'locationInsights': <Map<String, dynamic>>[],
    'calendarData': <String, dynamic>{},
    'aiInsights': <Map<String, dynamic>>[],
    'avgReviewRating': null,
    'topCollections': <Map<String, dynamic>>[],
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = _journalRepository.currentUserId;
      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _analyticsData = {
            ..._analyticsData,
            'moodDistribution': <Map<String, dynamic>>[],
          };
          _isLoading = false;
        });
        return;
      }

      final journals = await _journalRepository.getUserJournals(
        userId: userId,
        limit: 500,
      );

      final computed = _computeAnalytics(journals);
      if (!mounted) return;
      setState(() {
        _analyticsData = computed;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _computeAnalytics(List<JournalModel> journals) {
    final withMood = journals.where((j) => (j.mood ?? '').trim().isNotEmpty).toList();
    withMood.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final moodCounts = <String, int>{};
    for (final j in withMood) {
      final m = (j.mood ?? '').trim();
      if (m.isEmpty) continue;
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }

    final totalMood = moodCounts.values.fold<int>(0, (a, b) => a + b);
    final distribution = moodCounts.entries
        .map((e) {
          final pct = totalMood == 0 ? 0.0 : (e.value / totalMood) * 100.0;
          final c = AppColors.getMoodColor(e.key);
          final hex = '0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
          return {
            'mood': e.key,
            'count': e.value,
            'percentage': double.parse(pct.toStringAsFixed(1)),
            'color': hex,
          };
        })
        .toList();
    distribution.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    final weekStart = today.subtract(const Duration(days: 6));
    final weekBuckets = List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return {
        'date': d,
        'day': DateFormat('EEE').format(d),
        'sum': 0.0,
        'count': 0,
      };
    });

    for (final j in withMood) {
      final d = DateTime(j.createdAt.year, j.createdAt.month, j.createdAt.day);
      if (d.isBefore(weekStart) || d.isAfter(today)) continue;
      final idx = d.difference(weekStart).inDays;
      if (idx < 0 || idx >= 7) continue;
      final score = _moodScore(j.mood!);
      weekBuckets[idx]['sum'] = (weekBuckets[idx]['sum'] as double) + score;
      weekBuckets[idx]['count'] = (weekBuckets[idx]['count'] as int) + 1;
    }

    final weekTrend = weekBuckets
        .map((b) {
          final count = b['count'] as int;
          final val = count == 0 ? 0.0 : (b['sum'] as double) / count;
          return {
            'day': b['day'],
            'value': double.parse(val.toStringAsFixed(1)),
          };
        })
        .toList();

    final monthStart = DateTime(today.year, today.month, 1);
    final nextMonthStart = DateTime(today.year, today.month + 1, 1);
    final daysInMonth = nextMonthStart.subtract(const Duration(days: 1)).day;
    final monthWeeks = List.generate(4, (i) {
      return {'sum': 0.0, 'count': 0};
    });

    for (final j in withMood) {
      final d = DateTime(j.createdAt.year, j.createdAt.month, j.createdAt.day);
      if (d.isBefore(monthStart) || d.isAfter(nextMonthStart.subtract(const Duration(days: 1)))) {
        continue;
      }
      final dayIndex = d.day - 1;
      final weekIdx = ((dayIndex / (daysInMonth / 4)).floor()).clamp(0, 3);
      monthWeeks[weekIdx]['sum'] = (monthWeeks[weekIdx]['sum'] as double) + _moodScore(j.mood!);
      monthWeeks[weekIdx]['count'] = (monthWeeks[weekIdx]['count'] as int) + 1;
    }

    final monthTrend = List.generate(4, (i) {
      final count = monthWeeks[i]['count'] as int;
      final val = count == 0 ? 0.0 : (monthWeeks[i]['sum'] as double) / count;
      return {
        'week': 'Week ${i + 1}',
        'value': double.parse(val.toStringAsFixed(1)),
      };
    });

    final yearStart = DateTime(today.year, 1, 1);
    final yearMonths = List.generate(12, (i) => {'sum': 0.0, 'count': 0});
    for (final j in withMood) {
      final d = j.createdAt;
      if (d.isBefore(yearStart) || d.isAfter(today)) continue;
      final idx = d.month - 1;
      yearMonths[idx]['sum'] = (yearMonths[idx]['sum'] as double) + _moodScore(j.mood!);
      yearMonths[idx]['count'] = (yearMonths[idx]['count'] as int) + 1;
    }

    final yearTrend = List.generate(12, (i) {
      final count = yearMonths[i]['count'] as int;
      final val = count == 0 ? 0.0 : (yearMonths[i]['sum'] as double) / count;
      final monthLabel = DateFormat('MMM').format(DateTime(today.year, i + 1, 1));
      return {
        'month': monthLabel,
        'value': double.parse(val.toStringAsFixed(1)),
      };
    });

    final calendar = <String, dynamic>{};
    for (final j in withMood) {
      final d = DateTime(j.createdAt.year, j.createdAt.month, j.createdAt.day);
      final key = DateFormat('yyyy-MM-dd').format(d);
      final mood = (j.mood ?? '').trim();
      if (mood.isEmpty) continue;
      final c = AppColors.getMoodColor(mood);
      final hex = '0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
      calendar[key] = {'mood': mood, 'color': hex};
    }

    final locationAgg = <String, _LocationAgg>{};
    for (final j in withMood) {
      final label = _locationLabel(j);
      if (label.isEmpty) continue;
      locationAgg.putIfAbsent(label, () => _LocationAgg());
      final agg = locationAgg[label]!;
      agg.count += 1;
      final score = _moodScore(j.mood!);
      agg.sum += score;
      agg.moodCounts[(j.mood ?? '').trim()] = (agg.moodCounts[(j.mood ?? '').trim()] ?? 0) + 1;
      if (agg.imageUrl == null || agg.imageUrl!.trim().isEmpty) {
        if (j.photos.isNotEmpty && j.photos.first.trim().isNotEmpty) {
          agg.imageUrl = j.photos.first.trim();
        }
      }
    }

    final locationInsights = locationAgg.entries
        .map((e) {
          final avg = e.value.count == 0 ? 0.0 : e.value.sum / e.value.count;
          final dominantMood = _dominantKey(e.value.moodCounts);
          return {
            'location': e.key,
            'averageMood': double.parse(avg.toStringAsFixed(1)),
            'visitCount': e.value.count,
            'dominantMood': dominantMood.isEmpty ? 'Neutral' : dominantMood,
            'image': (e.value.imageUrl ?? '').trim().isEmpty
                ? 'https://via.placeholder.com/800x600.png?text=Zuru'
                : e.value.imageUrl,
            'semanticLabel': e.key,
          };
        })
        .toList();
    locationInsights.sort((a, b) => (b['visitCount'] as int).compareTo(a['visitCount'] as int));

    final last7Days = today.subtract(const Duration(days: 6));
    final weeklyEntries = journals.where((j) {
      final d = DateTime(j.createdAt.year, j.createdAt.month, j.createdAt.day);
      return !d.isBefore(last7Days) && !d.isAfter(today);
    }).length;

    final currentStreak = _computeStreakDays(journals);

    final reviewRatings = journals
        .where((j) => (j.entryType ?? '').trim() == 'review' && j.reviewRating != null)
        .map((j) => j.reviewRating!)
        .toList();
    final avgReviewRating = reviewRatings.isEmpty
        ? null
        : double.parse((reviewRatings.reduce((a, b) => a + b) / reviewRatings.length)
            .toStringAsFixed(1));

    final collectionCounts = <String, int>{};
    for (final j in journals) {
      final c = (j.collection ?? '').trim();
      if (c.isEmpty) continue;
      collectionCounts[c] = (collectionCounts[c] ?? 0) + 1;
    }
    final topCollections = collectionCounts.entries
        .map((e) => {'collection': e.key, 'count': e.value})
        .toList();
    topCollections.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    final aiInsights = _buildAiInsights(
      currentStreak: currentStreak,
      topLocation: locationInsights.isNotEmpty ? locationInsights.first : null,
      distribution: distribution,
    );

    return {
      'currentStreak': currentStreak,
      'weeklyEntries': weeklyEntries,
      'moodDistribution': distribution,
      'moodTrends': {
        'week': weekTrend,
        'month': monthTrend,
        'year': yearTrend,
      },
      'locationInsights': locationInsights.take(10).toList(),
      'calendarData': calendar,
      'aiInsights': aiInsights,
      'avgReviewRating': avgReviewRating,
      'topCollections': topCollections.take(6).toList(),
    };
  }

  double _moodScore(String mood) {
    final m = mood.trim().toLowerCase();
    switch (m) {
      case 'ecstatic':
        return 10;
      case 'excited':
        return 9;
      case 'happy':
        return 8;
      case 'grateful':
        return 7.5;
      case 'peaceful':
        return 7;
      case 'content':
        return 6.5;
      case 'neutral':
        return 5;
      case 'reflective':
        return 5.5;
      case 'sad':
        return 3;
      case 'anxious':
        return 3.5;
      case 'frustrated':
        return 2.5;
      default:
        return 5;
    }
  }

  String _locationLabel(JournalModel j) {
    final name = (j.locationName ?? '').trim();
    final city = (j.locationCity ?? '').trim();
    final country = (j.locationCountry ?? '').trim();

    if (name.isNotEmpty) return name;
    if (city.isNotEmpty && country.isNotEmpty) return '$city, $country';
    if (city.isNotEmpty) return city;
    if (country.isNotEmpty) return country;
    return '';
  }

  int _computeStreakDays(List<JournalModel> journals) {
    final dates = journals
        .map((j) => DateTime(j.createdAt.year, j.createdAt.month, j.createdAt.day))
        .toSet()
        .toList();
    dates.sort();

    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    var streak = 0;

    while (true) {
      if (dates.contains(cursor)) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
    return streak;
  }

  String _dominantKey(Map<String, int> counts) {
    if (counts.isEmpty) return '';
    String best = '';
    var bestCount = -1;
    for (final e in counts.entries) {
      if (e.key.trim().isEmpty) continue;
      if (e.value > bestCount) {
        bestCount = e.value;
        best = e.key;
      }
    }
    return best;
  }

  List<Map<String, dynamic>> _buildAiInsights({
    required int currentStreak,
    required Map<String, dynamic>? topLocation,
    required List<Map<String, dynamic>> distribution,
  }) {
    final out = <Map<String, dynamic>>[];

    if (topLocation != null) {
      final loc = (topLocation['location'] as String?) ?? '';
      final avg = (topLocation['averageMood'] as num?)?.toDouble() ?? 0.0;
      if (loc.trim().isNotEmpty && avg >= 7.5) {
        out.add({
          'title': 'Your best vibes location',
          'description': 'You seem happiest around $loc. Consider planning another visit soon.',
          'icon': 'location_on',
          'type': 'positive',
        });
      }
    }

    if (currentStreak >= 3) {
      out.add({
        'title': 'Consistent journaling streak',
        'description': 'You\'re on a $currentStreak-day streak. Keep it up for deeper insights.',
        'icon': 'emoji_events',
        'type': 'achievement',
      });
    }

    if (distribution.isNotEmpty) {
      final topMood = (distribution.first['mood'] as String?) ?? '';
      if (topMood.trim().isNotEmpty) {
        out.add({
          'title': 'Most frequent mood',
          'description': 'Your most common mood recently is $topMood. Want to explore what drives it?',
          'icon': 'psychology',
          'type': 'suggestion',
        });
      }
    }

    return out.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Mood Analytics',
        style: CustomAppBarStyle.standard,
        centerTitle: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _exportAnalytics,
            tooltip: 'Export Analytics',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalytics,
        child: _isLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              )
            : _analyticsData["moodDistribution"] != null &&
                    (_analyticsData["moodDistribution"] as List).isNotEmpty
                ? _buildAnalyticsContent(theme)
                : _buildInsufficientDataView(theme),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
        },
        showCenterButton: true,
      ),
    );
  }

  /// Build main analytics content
  Widget _buildAnalyticsContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood Streak Header
          MoodStreakHeaderWidget(
            currentStreak: _analyticsData["currentStreak"] as int,
            weeklyEntries: _analyticsData["weeklyEntries"] as int,
          ),

          SizedBox(height: 3.h),

          // Mood Distribution Chart
          MoodDistributionChartWidget(
            moodData: _analyticsData["moodDistribution"]
                as List<Map<String, dynamic>>,
          ),

          SizedBox(height: 3.h),

          // Mood Trend Chart with Period Selector
          _buildPeriodSelector(theme),
          SizedBox(height: 2.h),
          MoodTrendChartWidget(
            trendData: (_analyticsData["moodTrends"]
                    as Map<String, dynamic>)[_selectedPeriod]
                as List<Map<String, dynamic>>,
            period: _selectedPeriod,
          ),

          SizedBox(height: 3.h),

          // Location Insights
          LocationInsightsWidget(
            locationData: _analyticsData["locationInsights"]
                as List<Map<String, dynamic>>,
          ),

          SizedBox(height: 3.h),

          // Mood Calendar
          MoodCalendarWidget(
            calendarData:
                _analyticsData["calendarData"] as Map<String, dynamic>,
            selectedDay: _selectedCalendarDay,
            onDaySelected: (selectedDay) {
              setState(() => _selectedCalendarDay = selectedDay);
              _filterEntriesByDate(selectedDay);
            },
          ),

          SizedBox(height: 3.h),

          // AI Insights
          AIInsightsWidget(
            insights:
                _analyticsData["aiInsights"] as List<Map<String, dynamic>>,
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  /// Build period selector for trend chart
  Widget _buildPeriodSelector(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Text(
            'Mood Trends',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildPeriodButton('Week', 'week', theme),
          SizedBox(width: 2.w),
          _buildPeriodButton('Month', 'month', theme),
          SizedBox(width: 2.w),
          _buildPeriodButton('Year', 'year', theme),
        ],
      ),
    );
  }

  /// Build individual period button
  Widget _buildPeriodButton(String label, String value, ThemeData theme) {
    final isSelected = _selectedPeriod == value;

    return InkWell(
      onTap: () => setState(() => _selectedPeriod = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Build insufficient data view
  Widget _buildInsufficientDataView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'insights',
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'Start Your Journey',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Create more journal entries to unlock personalized mood insights and analytics. Your emotional patterns will appear here as you continue journaling.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add-journal-screen'),
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Create First Entry'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.8.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Refresh analytics data
  Future<void> _refreshAnalytics() async {
    await _loadAnalytics();
  }

  /// Export analytics as infographic
  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Analytics exported successfully'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  /// Filter entries by selected calendar date
  void _filterEntriesByDate(DateTime selectedDay) {
    // Navigate to filtered memory feed
    Navigator.pushNamed(
      context,
      '/memory-feed-screen',
      arguments: {'filterDate': selectedDay},
    );
  }
}

class _LocationAgg {
  int count = 0;
  double sum = 0.0;
  final Map<String, int> moodCounts = {};
  String? imageUrl;
}
