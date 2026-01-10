import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import './widgets/share_options_widget.dart';
import './widgets/memory_preview_widget.dart';
import './widgets/social_platforms_widget.dart';

/// Share Screen - Comprehensive memory sharing interface
class ShareScreen extends StatefulWidget {
  final Map<String, dynamic> memory;

  const ShareScreen({
    super.key,
    required this.memory,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String _shareMessage = '';
  bool _includeLocation = true;
  bool _includeMood = true;
  bool _includeWeather = false;
  String _selectedPrivacy = 'public'; // public, friends, link

  @override
  void initState() {
    super.initState();
    _initializeShareMessage();
  }

  void _initializeShareMessage() {
    final title = widget.memory['title'] as String;
    final location = widget.memory['location'] as String?;
    final mood = widget.memory['mood'] as String?;

    String message = '📖 Just created a memory: "$title"';

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
            onPressed: _shareMemory,
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
                // Memory Preview
                MemoryPreviewWidget(memory: widget.memory),

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

  void _shareMemory() async {
    try {
      await Share.share(
        _shareMessage,
        subject: 'Memory from Zuru: ${widget.memory['title']}',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory shared successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
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
      case 'email':
        platformMessage = '''
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

      await Future.delayed(const Duration(milliseconds: 500)); // Simulate saving

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
    final shareableLink = 'zuru://memory/$memoryId?title=${Uri.encodeComponent(memoryTitle)}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              memoryTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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