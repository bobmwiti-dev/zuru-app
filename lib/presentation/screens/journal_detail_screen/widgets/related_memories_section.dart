import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// Related memories section showing other entries from same location or timeframe
class RelatedMemoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> relatedMemories;
  final Function(Map<String, dynamic>) onMemoryTap;

  const RelatedMemoriesSection({
    super.key,
    required this.relatedMemories,
    required this.onMemoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (relatedMemories.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Related Memories',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: relatedMemories.length,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildRelatedMemoryCard(
                  context,
                  theme,
                  relatedMemories[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedMemoryCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> memory,
  ) {
    final title = memory['title'] as String? ?? 'Untitled';
    final imageUrl = memory['thumbnailUrl'] as String? ?? '';
    final semanticLabel =
        memory['semanticLabel'] as String? ?? 'Related memory thumbnail';
    final location = memory['location'] as String? ?? '';

    return GestureDetector(
      onTap: () => onMemoryTap(memory),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.isNotEmpty
                  ? CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: semanticLabel,
                    )
                  : Center(
                      child: CustomIconWidget(
                        iconName: 'image',
                        size: 32,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
