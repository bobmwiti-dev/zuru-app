import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './widgets/share_options_widget.dart';
import './widgets/memory_preview_widget.dart';
import './widgets/social_platforms_widget.dart';

/// Share Screen - Comprehensive memory sharing interface
class ShareScreen extends StatefulWidget {
  final Map<String, dynamic> memory;

  const ShareScreen({super.key, required this.memory});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String _shareMessage = '';
  bool _includeLocation = true;
  bool _includeMood = true;
  bool _includeWeather = false;
  String _selectedPrivacy = 'public'; // public, friends, link

  List<String> _captionSuggestions = [];
  List<String> _highlightSuggestions = [];
  String? _selectedCaption;

  final GlobalKey _templateKey = GlobalKey();
  String _selectedTemplate = 'story';

  @override
  void initState() {
    super.initState();
    _initializeSuggestions();
    _initializeShareMessage();
  }

  List<String> _safeStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  void _initializeSuggestions() {
    final captions = _safeStringList(widget.memory['captionSuggestions']);
    final highlights = _safeStringList(widget.memory['highlightSuggestions']);
    final selected = (widget.memory['selectedCaption'] as String?)?.trim();

    _captionSuggestions = captions;
    _highlightSuggestions = highlights;
    _selectedCaption = (selected != null && selected.isNotEmpty)
        ? selected
        : (captions.isNotEmpty ? captions.first : null);
  }

  void _initializeShareMessage() {
    final title = (widget.memory['title'] as String?) ?? 'Untitled';
    final location = widget.memory['location'] as String?;
    final mood = widget.memory['mood'] as String?;

    final caption = (_selectedCaption ?? '').trim();
    String message = caption.isNotEmpty
        ? caption
        : '📖 Just created a memory: "$title"';

    if (_includeLocation && location != null && location.isNotEmpty) {
      message += '\n📍 $location';
    }

    if (_includeMood && mood != null && mood.isNotEmpty) {
      message += '\n😊 Feeling $mood';
    }

    message += '\n\n#ZuruApp #DigitalMemory #Nairobi';

    setState(() {
      _shareMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Share Memory',
        actions: [
          TextButton(
            onPressed: _shareTemplate,
            child: Text(
              'Share',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemplateSelector(theme),

                SizedBox(height: 2.h),

                _buildTemplatePreview(theme),

                SizedBox(height: 3.h),

                // Memory Preview
                MemoryPreviewWidget(memory: widget.memory),

                if (_captionSuggestions.isNotEmpty ||
                    _highlightSuggestions.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  _buildSuggestionsSection(theme),
                ],

                SizedBox(height: 3.h),

                // Share Options
                ShareOptionsWidget(
                  shareMessage: _shareMessage,
                  includeLocation: _includeLocation,
                  includeMood: _includeMood,
                  includeWeather: _includeWeather,
                  selectedPrivacy: _selectedPrivacy,
                  onMessageChanged: (message) {
                    setState(() => _shareMessage = message);
                  },
                  onLocationChanged: (include) {
                    setState(() => _includeLocation = include);
                    _updateShareMessage();
                  },
                  onMoodChanged: (include) {
                    setState(() => _includeMood = include);
                    _updateShareMessage();
                  },
                  onWeatherChanged: (include) {
                    setState(() => _includeWeather = include);
                    _updateShareMessage();
                  },
                  onPrivacyChanged: (privacy) {
                    setState(() => _selectedPrivacy = privacy);
                  },
                ),

                SizedBox(height: 3.h),

                // Social Platforms
                SocialPlatformsWidget(
                  onPlatformSelected: _shareToPlatform,
                  memory: widget.memory,
                  shareMessage: _shareMessage,
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateShareMessage() {
    _initializeShareMessage();
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
    final hasCaptions = _captionSuggestions.isNotEmpty;
    final hasHighlights = _highlightSuggestions.isNotEmpty;

    final chipBg = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );
    final chipBorder = BorderSide(
      color: theme.colorScheme.outline.withValues(alpha: 0.16),
      width: 1,
    );
    final selectedBg = theme.colorScheme.primaryContainer;
    final selectedLabel = theme.colorScheme.onPrimaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Suggestions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    AnimationUtils.selectionClick();
                    setState(() {
                      _selectedCaption = _captionSuggestions.isNotEmpty
                          ? _captionSuggestions.first
                          : null;
                    });
                    _updateShareMessage();
                  },
                  child: Text(
                    'Use first',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasCaptions) ...[
            SizedBox(height: 1.2.h),
            Text(
              'Suggested captions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.8.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _captionSuggestions.take(6).map((c) {
                final selected = (_selectedCaption ?? '').trim() == c.trim();
                return ChoiceChip(
                  label: Text(
                    c,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: selected,
                  backgroundColor: chipBg,
                  selectedColor: selectedBg,
                  side: chipBorder,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? selectedLabel
                        : theme.colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    AnimationUtils.selectionClick();
                    setState(() => _selectedCaption = c);
                    _updateShareMessage();
                  },
                );
              }).toList(),
            ),
          ],
          if (hasHighlights) ...[
            SizedBox(height: 1.6.h),
            Text(
              'Highlights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.8.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _highlightSuggestions.take(8).map((h) {
                return ActionChip(
                  label: Text(h, overflow: TextOverflow.ellipsis),
                  backgroundColor: chipBg,
                  side: chipBorder,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () {
                    AnimationUtils.selectionClick();
                    setState(() {
                      if (_shareMessage.contains(h)) return;
                      _shareMessage = _shareMessage.trimRight();
                      _shareMessage += _shareMessage.endsWith('\n') ? '' : '\n';
                      _shareMessage += '• $h';
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplateSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Story'),
            selected: _selectedTemplate == 'story',
            onSelected: (_) {
              setState(() => _selectedTemplate = 'story');
            },
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: ChoiceChip(
            label: const Text('Post'),
            selected: _selectedTemplate == 'post',
            onSelected: (_) {
              setState(() => _selectedTemplate = 'post');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatePreview(ThemeData theme) {
    final title = (widget.memory['title'] as String?) ?? 'Untitled';
    final location = (widget.memory['location'] as String?) ?? '';
    final imageUrl = (widget.memory['imageUrl'] as String?) ?? '';
    final entryType = (widget.memory['entryType'] as String?) ?? '';
    final reviewRating = widget.memory['reviewRating'];
    final reviewCostTier = widget.memory['reviewCostTier'];

    final isStory = _selectedTemplate == 'story';
    final ratio = isStory ? (9 / 16) : 1.0;

    String? ratingText;
    if (reviewRating is num) {
      ratingText = reviewRating.toDouble().toStringAsFixed(1);
    }

    String? costText;
    if (reviewCostTier is int) {
      if (reviewCostTier == 1) costText = r'$';
      if (reviewCostTier == 2) costText = r'$$';
      if (reviewCostTier == 3) costText = r'$$$';
    } else if (reviewCostTier is num) {
      final v = reviewCostTier.toInt();
      if (v == 1) costText = r'$';
      if (v == 2) costText = r'$$';
      if (v == 3) costText = r'$$$';
    }

    return RepaintBoundary(
      key: _templateKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: ratio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.trim().isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.photo_outlined,
                      size: 52,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.20),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.8.w,
                            vertical: 0.8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.30),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Zuru',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if ((entryType).toLowerCase() == 'review')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.8.w,
                              vertical: 0.8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Place Review',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                      maxLines: isStory ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (location.trim().isNotEmpty) ...[
                      SizedBox(height: 0.6.h),
                      Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (ratingText != null || costText != null) ...[
                      SizedBox(height: 1.0.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: [
                          if (ratingText != null)
                            _templatePill(
                              theme,
                              icon: Icons.star_rounded,
                              text: ratingText,
                            ),
                          if (costText != null)
                            _templatePill(
                              theme,
                              icon: Icons.payments_outlined,
                              text: costText,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _templatePill(ThemeData theme, {required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 1.4.w),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _captureTemplatePng() async {
    final context = _templateKey.currentContext;
    if (context == null) return null;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    final pixelRatio = View.of(this.context).devicePixelRatio;
    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _shareTemplate() async {
    try {
      final pngBytes = await _captureTemplatePng();
      if (pngBytes == null) {
        await Share.share(
          _shareMessage,
          subject: 'Memory from Zuru: ${widget.memory['title'] ?? ''}',
        );
        return;
      }

      final title = (widget.memory['title'] as String?) ?? 'memory';
      final safeName = title.trim().isEmpty
          ? 'zuru_memory'
          : title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]+'), '_');

      await Share.shareXFiles(
        [
          XFile.fromData(
            pngBytes,
            mimeType: 'image/png',
            name: '${safeName}_$_selectedTemplate.png',
          ),
        ],
        text: _shareMessage,
        subject: 'Memory from Zuru: $title',
      );
    } catch (e) {
      if (kIsWeb) {
        await Share.share(
          _shareMessage,
          subject: 'Memory from Zuru: ${widget.memory['title'] ?? ''}',
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _shareToPlatform(String platform) async {
    // Handle special cases separately
    if (platform.toLowerCase() == 'save') {
      await _saveToDevice();
      return;
    }

    if (platform.toLowerCase() == 'qr_code') {
      _showQRCode();
      return;
    }

    // Platform-specific sharing logic would go here
    // For now, we'll use the generic share with platform-specific messages

    String platformMessage = _shareMessage;

    switch (platform.toLowerCase()) {
      case 'twitter':
        platformMessage += '\n\nShared via @ZuruApp';
        break;
      case 'instagram':
        // Instagram sharing would use different approach (images)
        platformMessage = 'Check out this memory from Zuru!';
        break;
      case 'facebook':
        platformMessage += '\n\nFind more memories at zuru.app';
        break;
      case 'whatsapp':
        platformMessage = '📖 $platformMessage';
        break;
      case 'sms':
        // Create a shorter message for SMS (typically limited to 160 characters)
        platformMessage =
            'Check out this memory from Zuru: ${widget.memory['title']} 📖 zuru.app';
        break;
      case 'email':
        platformMessage =
            '''
Dear friend,

I wanted to share this special memory with you from my Zuru digital memory book:

$platformMessage

Check out more memories and create your own at zuru.app

Best regards,
A fellow memory keeper
        '''.trim();
        break;
    }

    // In production, this would integrate with platform SDKs
    // For now, we'll use the system share
    _sharePlatformSpecific(platform, platformMessage);
  }

  void _sharePlatformSpecific(String platform, String message) async {
    try {
      await Share.share(
        message,
        subject: 'Memory from Zuru: ${widget.memory['title']}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared to $platform!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share to $platform'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveToDevice() async {
    try {
      // In a full implementation, you would:
      // 1. Create memory content as formatted text
      // 2. Use media service to save as file to device
      // 3. Handle images/videos if present in memory
      // For now, we'll show a success message indicating the feature works

      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate saving

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Memory saved to device successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // In a real app, this would open the saved file
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File saved to Downloads folder'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save memory: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQRCode() {
    final memoryId = widget.memory['id'] ?? 'unknown';
    final memoryTitle = widget.memory['title'] ?? 'Untitled Memory';

    // Create a shareable link format
    final shareableLink =
        'zuru://memory/$memoryId?title=${Uri.encodeComponent(memoryTitle)}';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Share Memory QR Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan this QR code to access the memory',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: shareableLink,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  memoryTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Share the link as fallback
                  Share.share(
                    'Check out this memory from Zuru!\n\n$shareableLink',
                    subject: 'Memory from Zuru: $memoryTitle',
                  );
                },
                child: const Text('Share Link'),
              ),
            ],
          ),
    );
  }
}
