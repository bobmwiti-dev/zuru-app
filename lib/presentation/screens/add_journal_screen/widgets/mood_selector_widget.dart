import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Mood selector widget with colorful emotion badges
class MoodSelectorWidget extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const List<Map<String, dynamic>> _moods = [
    {
      'name': 'Happy',
      'icon': 'sentiment_very_satisfied',
      'color': Color(0xFFFFC107),
    },
    {
      'name': 'Calm',
      'icon': 'self_improvement',
      'color': Color(0xFF4A9B8E),
    },
    {
      'name': 'Excited',
      'icon': 'celebration',
      'color': Color(0xFFE8B4B8),
    },
    {
      'name': 'Thoughtful',
      'icon': 'psychology',
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Adventurous',
      'icon': 'explore',
      'color': Color(0xFF2D7D7D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = selectedMood == mood['name'];

              return _buildMoodBadge(
                context,
                theme,
                name: mood['name'] as String,
                icon: mood['icon'] as String,
                color: mood['color'] as Color,
                isSelected: isSelected,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build mood badge
  Widget _buildMoodBadge(
    BuildContext context,
    ThemeData theme, {
    required String name,
    required String icon,
    required Color color,
    required bool isSelected,
  }) {
    final borderRadius = BorderRadius.circular(16);

    return _PressScale(
      onPressed: () {
        AnimationUtils.selectionClick();
        onMoodSelected(name);
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            AnimationUtils.selectionClick();
            onMoodSelected(name);
          },
          child: AnimatedContainer(
            duration: AnimationUtils.fast,
            curve: AnimationUtils.easeInOut,
            width: 20.w,
            padding: EdgeInsets.symmetric(vertical: 1.0.h),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? color.withValues(alpha: 0.18)
                      : theme.colorScheme.surface,
              borderRadius: borderRadius,
              border: Border.all(
                color:
                    isSelected
                        ? color
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: icon,
                      color:
                          isSelected
                              ? color
                              : theme.colorScheme.onSurfaceVariant,
                      size: 32,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            isSelected
                                ? color
                                : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _PressScale({required this.child, this.onPressed});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (!mounted) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AnimationUtils.fast,
        curve: AnimationUtils.easeInOut,
        child: widget.child,
      ),
    );
  }
}
