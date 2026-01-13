import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:zuru_app/core/app_export.dart';
import '../../../../data/models/journal_model.dart';

/// Memory card widget displaying journal entry preview
/// Implements swipe actions and long-press context menu
class MemoryCardWidget extends StatefulWidget {
  final JournalModel journal;
  final bool isLiked;
  final bool isSaved;
  final ValueChanged<bool>? onLikeChanged;
  final ValueChanged<bool>? onSaveChanged;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const MemoryCardWidget({
    super.key,
    required this.journal,
    required this.isLiked,
    required this.isSaved,
    this.onLikeChanged,
    this.onSaveChanged,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
 }

 class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;
  int _likesCount = 0;
  bool _showHeart = false;
  late final AnimationController _heartController;
  late final Animation<double> _heartScale;
  Timer? _heartHideTimer;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isSaved = widget.isSaved;
    _likesCount = widget.journal.likesCount;

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _heartScale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextLiked = widget.isLiked;
    final nextSaved = widget.isSaved;
    final nextLikesCount = widget.journal.likesCount;

    if (nextLiked != _isLiked) {
      _isLiked = nextLiked;
    }
    if (nextSaved != _isSaved) {
      _isSaved = nextSaved;
    }
    if (nextLikesCount != _likesCount) {
      _likesCount = nextLikesCount;
    }
  }

  @override
  void dispose() {
    _heartHideTimer?.cancel();
    _heartController.dispose();
    super.dispose();
  }

  String get _heroTag {
    final id = widget.journal.id;
    if (id != null && id.toString().trim().isNotEmpty) {
      return 'journal-media-$id';
    }
    return 'journal-media-${widget.journal.createdAt.millisecondsSinceEpoch}';
  }

  void _toggleLike({required bool showHeartOverlay}) {
    final next = !_isLiked;
    setState(() {
      _isLiked = next;
      _likesCount = next
          ? _likesCount + 1
          : (_likesCount > 0 ? _likesCount - 1 : 0);
      if (showHeartOverlay) {
        _showHeart = true;
      }
    });

    widget.onLikeChanged?.call(next);

    if (showHeartOverlay) {
      _heartHideTimer?.cancel();
      _heartController.forward(from: 0);
      _heartHideTimer = Timer(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() => _showHeart = false);
      });
    }
  }

  void _openMediaViewer() {
    if (widget.journal.photos.isEmpty || widget.journal.photos.first.trim().isEmpty) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _MediaViewerScreen(
              imageUrl: widget.journal.photos.first,
              heroTag: _heroTag,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final captionText = widget.journal.content;

    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildMedia(theme),
              _buildActionsRow(context),
              if (_likesCount > 0)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    '$_likesCount likes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              _buildCaption(theme, captionText),
              _buildMeta(theme),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleInitial = widget.journal.title.isNotEmpty
        ? widget.journal.title[0].toUpperCase()
        : 'M';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Text(
              titleInitial,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.journal.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((widget.journal.locationName ?? '').trim().isNotEmpty)
                  Text(
                    widget.journal.locationName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showContextMenu(context),
            icon: Icon(
              Icons.more_horiz,
              color: colorScheme.onSurface,
            ),
            tooltip: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final hasMedia =
        widget.journal.photos.isNotEmpty &&
        widget.journal.photos.first.trim().isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasMedia)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openMediaViewer,
              onDoubleTap: () => _toggleLike(showHeartOverlay: true),
              child: Hero(
                tag: _heroTag,
                child: CustomImageWidget(
                  imageUrl: widget.journal.photos.first,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: 'Journal entry image',
                ),
              ),
            )
          else
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
            ),
          if (_showHeart)
            Center(
              child: ScaleTransition(
                scale: _heartScale,
                child: Icon(
                  Icons.favorite,
                  size: 96,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _toggleLike(showHeartOverlay: false),
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? AppColors.secondary : colorScheme.onSurface,
            ),
            tooltip: 'Like',
          ),
          IconButton(
            onPressed: widget.onTap,
            icon: Icon(
              Icons.mode_comment_outlined,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Comment',
          ),
          IconButton(
            onPressed: widget.onShare,
            icon: Icon(
              Icons.send_outlined,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Share',
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              final next = !_isSaved;
              setState(() => _isSaved = next);
              widget.onSaveChanged?.call(next);
            },
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Save',
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(ThemeData theme, String? captionText) {
    final colorScheme = theme.colorScheme;
    final hasCaption = (captionText ?? '').trim().isNotEmpty;

    if (!hasCaption) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        captionText!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMeta(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 0.75.h),
      child: Row(
        children: [
          Text(
            _formatTimestamp(widget.journal.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if ((widget.journal.mood ?? '').trim().isNotEmpty) ...[
            Text(
              '  ·  ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            _buildMoodBadge(theme),
          ],
        ],
      ),
    );
    
  }

  /// Build mood badge
  Widget _buildMoodBadge(ThemeData theme) {
    final moodColor = _getMoodColor(widget.journal.mood);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: moodColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getMoodIcon(widget.journal.mood),
            color: moodColor,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            widget.journal.mood ?? 'Unknown',
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
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 1.h),
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
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
                    widget.onEdit();
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
                    widget.onShare();
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
                    widget.onDelete();
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }

  /// Get mood color based on mood string
  Color _getMoodColor(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'happy':
        return const Color(0xFFF4E4BC);
      case 'calm':
        return const Color(0xFF2D7D7D);
      case 'excited':
        return const Color(0xFFE8B4B8);
      case 'sad':
        return const Color(0xFF7986CB);
      case 'angry':
        return const Color(0xFFE57373);
      case 'anxious':
        return const Color(0xFFFFB74D);
      case 'grateful':
        return const Color(0xFF81C784);
      case 'focused':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Get mood icon based on mood string
  String _getMoodIcon(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'happy':
        return 'sentiment_satisfied';
      case 'calm':
        return 'self_improvement';
      case 'excited':
        return 'celebration';
      case 'sad':
        return 'sentiment_dissatisfied';
      case 'angry':
        return 'sentiment_very_dissatisfied';
      case 'anxious':
        return 'warning';
      case 'grateful':
        return 'favorite';
      case 'focused':
        return 'visibility';
      default:
        return 'sentiment_neutral';
    }
  }
}

class _MediaViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const _MediaViewerScreen({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<_MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<_MediaViewerScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late final AnimationController _resetController;

  double _resetStartDy = 0;
  double _resetStartOpacity = 1;

  double _dragDy = 0;
  double _backgroundOpacity = 1;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _resetController.addListener(() {
      final t = Curves.easeOut.transform(_resetController.value);
      setState(() {
        _dragDy = _resetStartDy * (1 - t);
        _backgroundOpacity = _resetStartOpacity + (1 - _resetStartOpacity) * t;
      });
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  double get _currentScale {
    return _transformationController.value.getMaxScaleOnAxis();
  }

  void _resetDrag() {
    _resetStartDy = _dragDy;
    _resetStartOpacity = _backgroundOpacity;
    _resetController.stop();
    _resetController.reset();
    _resetController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _backgroundOpacity),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              onVerticalDragUpdate: (details) {
                if (_currentScale > 1.01) return;

                setState(() {
                  _dragDy += details.delta.dy;
                  final t = (_dragDy.abs() / (mq.size.height * 0.35))
                      .clamp(0.0, 1.0);
                  _backgroundOpacity = (1 - t).clamp(0.0, 1.0);
                });
              },
              onVerticalDragEnd: (details) {
                if (_currentScale > 1.01) return;

                if (_dragDy.abs() > 120) {
                  Navigator.of(context).maybePop();
                } else {
                  _resetDrag();
                }
              },
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, _dragDy),
                  child: Hero(
                    tag: widget.heroTag,
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1,
                      maxScale: 4,
                      clipBehavior: Clip.none,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain,
                        width: mq.size.width,
                        height: mq.size.height,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
