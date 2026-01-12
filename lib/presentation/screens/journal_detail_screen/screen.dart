import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_export.dart';
import './widgets/content_section.dart';
import './widgets/hero_media_section.dart';
import './widgets/location_map_section.dart';
import './widgets/related_memories_section.dart';

/// Journal Detail Screen - Immersive viewing experience for individual memory entries
class JournalDetailScreen extends StatefulWidget {
  const JournalDetailScreen({super.key});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;

  // Mock journal entry data
  final Map<String, dynamic> _journalEntry = {
    'id': 1,
    'title': 'Sunset at Karura Forest',
    'description':
        '''What an incredible evening! The golden hour light filtering through the trees created the most magical atmosphere. I spent two hours walking the trails, listening to the birds, and just being present in the moment.

The forest was alive with sounds - rustling leaves, distant laughter from other visitors, and the gentle flow of the stream. I found a quiet spot by the waterfall and sat there for what felt like both minutes and hours.

This place always reminds me why I love Nairobi. Despite being in the heart of the city, you can find these pockets of pure tranquility. It's my go-to spot when I need to reset and reconnect with myself.''',
    'mood': 'Calm',
    'location': 'Karura Forest, Nairobi',
    'latitude': -1.2527,
    'longitude': 36.8336,
    'mediaType': 'photo',
    'mediaUrl':
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    'semanticLabel':
        'Golden sunset light filtering through tall trees in a lush forest, creating dramatic rays of light through the canopy',
    'timestamp': DateTime.now().subtract(Duration(days: 2, hours: 5)),
    'weather': 'Sunny, 24°C',
    'companions': ['Sarah', 'Mike'],
  };

  // Mock related memories
  final List<Map<String, dynamic>> _relatedMemories = [
    {
      'id': 2,
      'title': 'Morning Jog at Karura',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1593103172216-910fa8a056ce',
      'semanticLabel':
          'Early morning forest trail with mist and sunlight breaking through trees',
      'location': 'Karura Forest',
      'timestamp': DateTime.now().subtract(Duration(days: 7)),
    },
    {
      'id': 3,
      'title': 'Picnic with Friends',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1513420901937-0b9c3ddb6b49',
      'semanticLabel':
          'Group of friends having a picnic on grass with food spread out',
      'location': 'Karura Forest',
      'timestamp': DateTime.now().subtract(Duration(days: 14)),
    },
    {
      'id': 4,
      'title': 'Waterfall Discovery',
      'thumbnailUrl':
          'https://images.unsplash.com/photo-1611183277210-a21e80e107e0',
      'semanticLabel':
          'Small waterfall cascading over rocks in a forest setting',
      'location': 'Karura Forest',
      'timestamp': DateTime.now().subtract(Duration(days: 21)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBarBackground) {
      setState(() => _showAppBarBackground = true);
    } else if (_scrollController.offset <= 200 && _showAppBarBackground) {
      setState(() => _showAppBarBackground = false);
    }
  }

  void _handleShare() async {
    final title = _journalEntry['title'] as String;
    final location = _journalEntry['location'] as String;
    final mood = _journalEntry['mood'] as String;

    final shareText = '''$title

📍 $location
😊 Feeling: $mood

Created with Zuru - Your moments matter''';

    try {
      await Share.share(
        shareText,
        subject: 'My Memory from Zuru',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to share at this moment'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleEdit() {
    Navigator.pushNamed(
      context,
      '/add-journal-screen',
      arguments: _journalEntry,
    );
  }

  void _handleMapTap() {
    Navigator.pushNamed(
      context,
      '/interactive-map-view',
      arguments: {
        'centerLatitude': _journalEntry['latitude'],
        'centerLongitude': _journalEntry['longitude'],
        'selectedEntryId': _journalEntry['id'],
      },
    );
  }

  void _handleRelatedMemoryTap(Map<String, dynamic> memory) {
    Navigator.pushReplacementNamed(
      context,
      '/journal-detail-screen',
      arguments: memory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        style: _showAppBarBackground
            ? CustomAppBarStyle.standard
            : CustomAppBarStyle.transparent,
        backgroundColor: _showAppBarBackground
            ? theme.colorScheme.surface.withValues(alpha: 0.95)
            : Colors.transparent,
        elevation: _showAppBarBackground ? 4 : 0,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              size: 24,
              color: _showAppBarBackground
                  ? theme.colorScheme.onSurface
                  : Colors.white,
            ),
            onPressed: _handleShare,
            tooltip: 'Share',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'edit',
              size: 24,
              color: _showAppBarBackground
                  ? theme.colorScheme.onSurface
                  : Colors.white,
            ),
            onPressed: _handleEdit,
            tooltip: 'Edit',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero media section
            HeroMediaSection(journalEntry: _journalEntry),

            // Content section
            ContentSection(journalEntry: _journalEntry),

            // Location map section
            LocationMapSection(
              journalEntry: _journalEntry,
              onMapTap: _handleMapTap,
            ),

            // Companions section (if available)
            if (_journalEntry['companions'] != null &&
                (_journalEntry['companions'] as List).isNotEmpty)
              _buildCompanionsSection(theme),

            // Related memories section
            RelatedMemoriesSection(
              relatedMemories: _relatedMemories,
              onMemoryTap: _handleRelatedMemoryTap,
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionsSection(ThemeData theme) {
    final companions = _journalEntry['companions'] as List<dynamic>;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'people',
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'With',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: companions.map((companion) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'person',
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(width: 6),
                    Text(
                      companion.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
