import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../screen.dart';

/// Memory preview card widget shown when marker is tapped
class MemoryPreviewCardWidget extends StatelessWidget {
  final MemoryData memory;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const MemoryPreviewCardWidget({
    super.key,
    required this.memory,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image and close button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: CustomImageWidget(
                    imageUrl: memory.imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    semanticLabel: memory.semanticLabel,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and mood
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          memory.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: memory.moodColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          memory.mood,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: memory.moodColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          memory.locationName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(memory.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  if (memory.companions.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'people',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'With ${memory.companions.join(', ')}',
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

                  SizedBox(height: 12),

                  // Tap to view full entry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Tap to view full entry',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
