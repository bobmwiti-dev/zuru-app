import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_export.dart';

/// Hero section displaying full-width photo/video with interactive controls
class HeroMediaSection extends StatefulWidget {
  final Map<String, dynamic> journalEntry;

  const HeroMediaSection({
    super.key,
    required this.journalEntry,
  });

  @override
  State<HeroMediaSection> createState() => _HeroMediaSectionState();
}

class _HeroMediaSectionState extends State<HeroMediaSection> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    final mediaType = widget.journalEntry['mediaType'] as String? ?? 'photo';

    if (mediaType == 'video') {
      final videoUrl = widget.journalEntry['mediaUrl'] as String?;
      if (videoUrl != null && videoUrl.isNotEmpty) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        try {
          await _videoController!.initialize();
          setState(() => _isVideoInitialized = true);
        } catch (e) {
          debugPrint('Video initialization error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;

    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaType = widget.journalEntry['mediaType'] as String? ?? 'photo';
    final mediaUrl = widget.journalEntry['mediaUrl'] as String? ?? '';
    final semanticLabel = widget.journalEntry['semanticLabel'] as String? ??
        'Journal entry media';

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media content
          if (mediaType == 'video' &&
              _isVideoInitialized &&
              _videoController != null)
            _buildVideoPlayer(theme)
          else if (mediaType == 'photo' && mediaUrl.isNotEmpty)
            _buildPhotoViewer(mediaUrl, semanticLabel)
          else
            _buildPlaceholder(theme),

          // Video controls overlay
          if (mediaType == 'video' && _isVideoInitialized)
            _buildVideoControls(theme),

          // Gradient overlay for better text visibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(ThemeData theme) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildPhotoViewer(String imageUrl, String semanticLabel) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: CustomImageWidget(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        semanticLabel: semanticLabel,
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'image_not_supported',
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              'Media not available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls(ThemeData theme) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: _isPlaying ? 'pause' : 'play_arrow',
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
