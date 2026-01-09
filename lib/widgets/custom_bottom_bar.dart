import 'package:flutter/material.dart';

/// Navigation item configuration for the bottom bar
class CustomBottomBarItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;

  const CustomBottomBarItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
  });
}

/// Custom bottom navigation bar widget for Zuru journaling app
/// Implements tab bar navigation with modal overlays pattern
/// Optimized for thumb zone with bottom-heavy design
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final Function(int index) onTap;

  /// Optional callback for center FAB action
  final VoidCallback? onCenterButtonTap;

  /// Whether to show the center floating action button
  final bool showCenterButton;

  /// Custom elevation for the bottom bar
  final double? elevation;

  /// Background color override
  final Color? backgroundColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterButtonTap,
    this.showCenterButton = true,
    this.elevation,
    this.backgroundColor,
  });

  /// Navigation items based on Mobile Navigation Hierarchy
  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      label: 'Feed',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      route: '/memory-feed-screen',
    ),
    CustomBottomBarItem(
      label: 'Friends',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: '/friends-screen',
    ),
    CustomBottomBarItem(
      label: 'Map',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      route: '/interactive-map-view',
    ),
    CustomBottomBarItem(
      label: 'Add',
      icon: Icons.add,
      route: '/add-journal-screen',
    ),
    CustomBottomBarItem(
      label: 'Analytics',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      route: '/mood-analytics-screen',
    ),
    CustomBottomBarItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: elevation ?? 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            children: [
              // Bottom navigation bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navigationItems.length,
                  (index) {
                    // Skip center item if showing FAB
                    if (showCenterButton && index == 2) {
                      return const Spacer();
                    }

                    return _buildNavigationItem(
                      context,
                      _navigationItems[index],
                      index,
                      currentIndex == index,
                    );
                  },
                ),
              ),

              // Center floating action button
              if (showCenterButton)
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 32,
                  top: -8,
                  child: _buildCenterButton(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual navigation item
  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on selection state
    final color = isSelected
        ? colorScheme.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
            colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => _handleNavigation(context, index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with smooth transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected && item.activeIcon != null
                      ? item.activeIcon
                      : item.icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(height: 4),

              // Label with fade transition
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: (isSelected
                        ? theme.bottomNavigationBarTheme.selectedLabelStyle
                        : theme
                            .bottomNavigationBarTheme.unselectedLabelStyle) ??
                    theme.textTheme.labelSmall!,
                child: Text(
                  item.label,
                  style: TextStyle(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build center floating action button for Add Journal
  Widget _buildCenterButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.primary,
      child: InkWell(
        onTap: () => _handleCenterButtonTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.surface,
              width: 4,
            ),
          ),
          child: Icon(
            Icons.add_rounded,
            color: colorScheme.onPrimary,
            size: 32,
          ),
        ),
      ),
    );
  }

  /// Handle navigation item tap
  void _handleNavigation(BuildContext context, int index) {
    // Skip if already on this tab
    if (index == currentIndex) return;

    // Skip center button in navigation items
    if (showCenterButton && index == 2) return;

    // Call the onTap callback
    onTap(index);

    // Navigate to the route
    final route = _navigationItems[index].route;
    Navigator.pushNamed(context, route);
  }

  /// Handle center button tap
  void _handleCenterButtonTap(BuildContext context) {
    if (onCenterButtonTap != null) {
      onCenterButtonTap!();
    } else {
      // Default behavior: navigate to Add Journal screen
      Navigator.pushNamed(context, '/add-journal-screen');
    }
  }
}

/// Variant of CustomBottomBar without center FAB
class CustomBottomBarSimple extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  final double? elevation;
  final Color? backgroundColor;

  const CustomBottomBarSimple({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.elevation,
    this.backgroundColor,
  });

  static const List<CustomBottomBarItem> _navigationItems = [
    CustomBottomBarItem(
      label: 'Feed',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      route: '/memory-feed-screen',
    ),
    CustomBottomBarItem(
      label: 'Friends',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: '/friends-screen',
    ),
    CustomBottomBarItem(
      label: 'Map',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      route: '/interactive-map-view',
    ),
    CustomBottomBarItem(
      label: 'Add',
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      route: '/add-journal-screen',
    ),
    CustomBottomBarItem(
      label: 'Analytics',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights,
      route: '/mood-analytics-screen',
    ),
    CustomBottomBarItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: elevation ?? 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavigationItem(
                context,
                _navigationItems[index],
                index,
                currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = isSelected
        ? colorScheme.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
            colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index != currentIndex) {
            onTap(index);
            Navigator.pushNamed(context, item.route);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected && item.activeIcon != null
                      ? item.activeIcon
                      : item.icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: (isSelected
                        ? theme.bottomNavigationBarTheme.selectedLabelStyle
                        : theme
                            .bottomNavigationBarTheme.unselectedLabelStyle) ??
                    theme.textTheme.labelSmall!,
                child: Text(
                  item.label,
                  style: TextStyle(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
