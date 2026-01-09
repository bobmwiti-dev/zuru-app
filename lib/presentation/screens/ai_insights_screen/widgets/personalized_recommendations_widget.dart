import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Personalized Recommendations Widget - AI-generated suggestions based on user patterns
class PersonalizedRecommendationsWidget extends StatelessWidget {
  const PersonalizedRecommendationsWidget({super.key});

  // Mock personalized recommendations
  static const _recommendations = [
    {
      'type': 'location',
      'title': 'Try Uhuru Park',
      'description': 'Based on your love for Karura Forest, you might enjoy this nearby park',
      'reason': 'Similar nature experience, 2.3km from your location',
      'confidence': 0.89,
      'action': 'Navigate',
      'icon': 'park',
    },
    {
      'type': 'activity',
      'title': 'Morning Coffee Ritual',
      'description': 'Try visiting a café before 10 AM for optimal mood boost',
      'reason': 'Your morning visits to Java House show 35% higher happiness',
      'confidence': 0.92,
      'action': 'Find Cafes',
      'icon': 'local_cafe',
    },
    {
      'type': 'social',
      'title': 'Connect with Nature Lovers',
      'description': 'Users who enjoy outdoor activities like you',
      'reason': 'You have 3 mutual friends with similar interests',
      'confidence': 0.76,
      'action': 'Discover Friends',
      'icon': 'people',
    },
    {
      'type': 'timing',
      'title': 'Weekend Forest Walks',
      'description': 'Schedule outdoor activities for Saturday mornings',
      'reason': 'Your weekend mood improves by 28% after nature time',
      'confidence': 0.85,
      'action': 'Set Reminder',
      'icon': 'schedule',
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
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'recommend',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Personalized for You',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI Powered',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Recommendations List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recommendations.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.w),
            itemBuilder: (context, index) {
              final recommendation = _recommendations[index];
              return _buildRecommendationCard(context, theme, recommendation);
            },
          ),

          SizedBox(height: 2.h),

          // Learn More Section
          _buildLearnMoreSection(context, theme),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, ThemeData theme, Map<String, dynamic> recommendation) {
    final confidence = recommendation['confidence'] as double;
    final type = recommendation['type'] as String;

    Color typeColor;
    switch (type) {
      case 'location':
        typeColor = Colors.green;
        break;
      case 'activity':
        typeColor = Colors.blue;
        break;
      case 'social':
        typeColor = Colors.purple;
        break;
      case 'timing':
        typeColor = Colors.orange;
        break;
      default:
        typeColor = theme.colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type indicator
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              // Confidence indicator
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'verified',
                    color: confidence > 0.8
                        ? Colors.green
                        : confidence > 0.6
                            ? Colors.yellow
                            : Colors.grey,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${(confidence * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Title and description
          Text(
            recommendation['title'] as String,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            recommendation['description'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 1.5.h),

          // Reason
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    recommendation['reason'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Action button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: recommendation['action'] as String,
              onPressed: () => _handleRecommendationAction(context, recommendation),
              variant: CustomButtonVariant.primary,
              size: CustomButtonSize.small,
              leadingIcon: recommendation['icon'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnMoreSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'school',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'How AI Works',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Our AI analyzes your memory patterns, location preferences, mood trends, and social connections to provide personalized insights. The more you use Zuru, the better our recommendations become.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          CustomButton(
            text: 'Learn More About AI',
            onPressed: () => _showAIInfoDialog(context),
            variant: CustomButtonVariant.tertiary,
            size: CustomButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _handleRecommendationAction(BuildContext context, Map<String, dynamic> recommendation) {
    final action = recommendation['action'] as String;

    // Handle different action types
    switch (action) {
      case 'Navigate':
        // Navigate to map with location
        Navigator.pushNamed(context, '/interactive-map-view');
        break;
      case 'Find Cafes':
        // Search for cafes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Finding nearby cafes...')),
        );
        break;
      case 'Discover Friends':
        // Go to friends screen
        Navigator.pushNamed(context, '/friends-screen');
        break;
      case 'Set Reminder':
        // Set a reminder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder set for weekend activities!')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action action triggered')),
        );
    }
  }

  void _showAIInfoDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'smart_toy',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('How AI Insights Work'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAIInfoItem(
                theme,
                icon: 'analytics',
                title: 'Pattern Recognition',
                description: 'Analyzes your mood, location, and activity patterns over time.',
              ),
              SizedBox(height: 2.h),
              _buildAIInfoItem(
                theme,
                icon: 'psychology',
                title: 'Behavioral Insights',
                description: 'Identifies what activities and locations boost your happiness.',
              ),
              SizedBox(height: 2.h),
              _buildAIInfoItem(
                theme,
                icon: 'recommend',
                title: 'Personalized Recommendations',
                description: 'Suggests new experiences based on your preferences and past behavior.',
              ),
              SizedBox(height: 2.h),
              _buildAIInfoItem(
                theme,
                icon: 'security',
                title: 'Privacy First',
                description: 'All analysis happens on your device. Your data never leaves your phone.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInfoItem(ThemeData theme, {required String icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 16,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}