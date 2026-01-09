import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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

  void _shareToPlatform(String platform) {
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
}