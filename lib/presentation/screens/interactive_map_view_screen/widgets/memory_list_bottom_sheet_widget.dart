import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../screen.dart';

/// Bottom sheet displaying list of memories
class MemoryListBottomSheetWidget extends StatelessWidget {
  final List<MemoryData> memories;
  final Function(MemoryData) onMemoryTap;

  const MemoryListBottomSheetWidget({
    super.key,
    required this.memories,
    required this.onMemoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Your Memories',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Text(
                  '${memories.length} places',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Memory list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: memories.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final memory = memories[index];
                return _buildMemoryItem(context, memory, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryItem(
    BuildContext context,
    MemoryData memory,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => onMemoryTap(memory),
      child: Container(
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: CustomImageWidget(
                imageUrl: memory.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                semanticLabel: memory.semanticLabel,
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and mood
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            memory.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: memory.moodColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            memory.mood,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: memory.moodColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            memory.locationName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2),

                    // Date
                    Text(
                      DateFormat('MMM dd, yyyy').format(memory.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
