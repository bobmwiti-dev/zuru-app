import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:zuru_app/core/app_export.dart';

/// Memory card widget displaying journal entry preview
/// Implements swipe actions and long-press context menu
class MemoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const MemoryCardWidget({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(entry["id"]),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onShare(),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: Icons.share,
            label: 'Share',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail
              _buildImageThumbnail(theme),

              // Content
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and mood badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry["title"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        _buildMoodBadge(theme),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Description
                    Text(
                      entry["description"] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.5.h),

                    // Location and timestamp
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            entry["location"] as String,
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

                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _formatTimestamp(entry["timestamp"] as DateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        // Companions indicator
                        if ((entry["companions"] as List).isNotEmpty) ...[
                          SizedBox(width: 3.w),
                          CustomIconWidget(
                            iconName: 'people',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${(entry["companions"] as List).length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        // Offline indicator
                        if (entry["isOffline"] == true) ...[
                          Spacer(),
                          CustomIconWidget(
                            iconName: 'cloud_off',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ],
                      ],
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

  /// Build image thumbnail
  Widget _buildImageThumbnail(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: Stack(
        children: [
          CustomImageWidget(
            imageUrl: entry["imageUrl"] as String,
            width: double.infinity,
            height: 25.h,
            fit: BoxFit.cover,
            semanticLabel: entry["semanticLabel"] as String,
          ),

          // Gradient overlay for better text visibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build mood badge
  Widget _buildMoodBadge(ThemeData theme) {
    final moodColor = Color(entry["moodColor"] as int);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: entry["moodIcon"] as String,
            color: moodColor,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            entry["mood"] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              color: moodColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  /// Show context menu
  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1.h),
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Edit Memory'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
              title: Text('Share Memory'),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Delete Memory',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
