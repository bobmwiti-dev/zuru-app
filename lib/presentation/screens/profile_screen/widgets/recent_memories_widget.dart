import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Recent Memories Widget - Shows user's latest journal entries
class RecentMemoriesWidget extends StatelessWidget {
  const RecentMemoriesWidget({super.key});

  // Mock recent memories data
  static const _recentMemories = [
    {
      'id': '1',
      'title': 'Coffee at Java House',
      'location': 'Westlands',
      'timestamp': '2h ago',
      'mood': 'Happy',
      'moodColor': Color(0xFFFFC107),
      'imageUrl': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
    },
    {
      'id': '2',
      'title': 'Sunset at Karura Forest',
      'location': 'Karura Forest',
      'timestamp': '1d ago',
      'mood': 'Calm',
      'moodColor': Color(0xFF4A9B8E),
      'imageUrl': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400',
    },
    {
      'id': '3',
      'title': 'Art Exhibition Visit',
      'location': 'National Museum',
      'timestamp': '3d ago',
      'mood': 'Inspired',
      'moodColor': Color(0xFF9C27B0),
      'imageUrl': 'https://images.unsplash.com/photo-1577083552431-6e5fd01988ec?w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
          // Header with View All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Memories',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => _viewAllMemories(context),
                child: Text(
                  'View All',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Recent memories list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentMemories.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final memory = _recentMemories[index];
              return _buildMemoryItem(context, memory);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryItem(BuildContext context, Map<String, dynamic> memory) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openMemoryDetail(context, memory['id'] as String),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Memory Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: memory['imageUrl'] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
                semanticLabel: memory['title'] as String,
              ),
            ),

            SizedBox(width: 3.w),

            // Memory Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    memory['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 0.5.h),

                  // Location
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.primary,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          memory['location'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 0.5.h),

                  // Timestamp and Mood
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        memory['timestamp'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Mood badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: (memory['moodColor'] as Color).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          memory['mood'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: memory['moodColor'] as Color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _viewAllMemories(BuildContext context) {
    // Navigate to memory feed with filter for user's memories
    Navigator.pushNamed(context, '/memory-feed-screen');
  }

  void _openMemoryDetail(BuildContext context, String memoryId) {
    // Navigate to journal detail screen
    Navigator.pushNamed(
      context,
      '/journal-detail-screen',
      arguments: {'memoryId': memoryId},
    );
  }
}