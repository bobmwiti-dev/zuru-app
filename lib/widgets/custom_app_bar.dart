import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar style variants
enum CustomAppBarStyle {
  /// Standard app bar with title and actions
  standard,

  /// Transparent app bar for overlaying content
  transparent,

  /// Large title app bar for main screens
  large,

  /// Search-focused app bar
  search,

  /// Minimal app bar with back button only
  minimal,
}

/// Custom app bar widget for Zuru journaling app
/// Implements clean, minimal design with contemplative warmth
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title
  final String? title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// App bar style variant
  final CustomAppBarStyle style;

  /// Background color override
  final Color? backgroundColor;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Center the title
  final bool centerTitle;

  /// Custom elevation
  final double? elevation;

  /// Bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  /// Flexible space widget for large style
  final Widget? flexibleSpace;

  /// System overlay style (status bar)
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.style = CustomAppBarStyle.standard,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.elevation,
    this.bottom,
    this.flexibleSpace,
    this.systemOverlayStyle,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine background color based on style
    final bgColor = _getBackgroundColor(context);

    // Determine if we should show back button
    final showBackButton =
        automaticallyImplyLeading && Navigator.of(context).canPop();

    switch (style) {
      case CustomAppBarStyle.transparent:
        return _buildTransparentAppBar(context, showBackButton);

      case CustomAppBarStyle.large:
        return _buildLargeAppBar(context, showBackButton);

      case CustomAppBarStyle.search:
        return _buildSearchAppBar(context, showBackButton);

      case CustomAppBarStyle.minimal:
        return _buildMinimalAppBar(context, showBackButton);

      case CustomAppBarStyle.standard:
        return _buildStandardAppBar(context, showBackButton, bgColor);
    }
  }

  /// Build standard app bar
  Widget _buildStandardAppBar(
    BuildContext context,
    bool showBackButton,
    Color bgColor,
  ) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions,
      backgroundColor: bgColor,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      systemOverlayStyle: systemOverlayStyle ?? _getSystemOverlayStyle(context),
      automaticallyImplyLeading: false,
    );
  }

  /// Build transparent app bar for overlaying content
  Widget _buildTransparentAppBar(BuildContext context, bool showBackButton) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      foregroundColor: Colors.white,
    );
  }

  /// Build large title app bar for main screens
  Widget _buildLargeAppBar(BuildContext context, bool showBackButton) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation ?? 0,
      systemOverlayStyle: _getSystemOverlayStyle(context),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: title != null
            ? Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              )
            : null,
        centerTitle: centerTitle,
        titlePadding: EdgeInsets.only(
          left: centerTitle ? 0 : 56,
          bottom: 16,
        ),
      ),
    );
  }

  /// Build search-focused app bar
  Widget _buildSearchAppBar(BuildContext context, bool showBackButton) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: title ?? 'Search journals...',
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation ?? 0,
      systemOverlayStyle: _getSystemOverlayStyle(context),
      automaticallyImplyLeading: false,
    );
  }

  /// Build minimal app bar with back button only
  Widget _buildMinimalAppBar(BuildContext context, bool showBackButton) {
    return AppBar(
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      systemOverlayStyle: _getSystemOverlayStyle(context),
      automaticallyImplyLeading: false,
    );
  }

  /// Build custom back button with proper styling
  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Back',
      color: style == CustomAppBarStyle.transparent
          ? Colors.white
          : colorScheme.onSurface,
    );
  }

  /// Get background color based on style and theme
  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    final colorScheme = Theme.of(context).colorScheme;

    switch (style) {
      case CustomAppBarStyle.transparent:
        return Colors.transparent;
      case CustomAppBarStyle.minimal:
        return Colors.transparent;
      default:
        return colorScheme.surface;
    }
  }

  /// Get system overlay style based on theme brightness
  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (style == CustomAppBarStyle.transparent) {
      return SystemUiOverlayStyle.light;
    }

    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;

    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }

    if (style == CustomAppBarStyle.large) {
      height = 120;
    }

    return Size.fromHeight(height);
  }
}

/// Custom app bar with search functionality
class CustomSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const CustomSearchAppBar({
    super.key,
    this.hintText,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.actions,
    this.backgroundColor,
  });

  @override
  State<CustomSearchAppBar> createState() => _CustomSearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomSearchAppBarState extends State<CustomSearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: widget.backgroundColor ?? colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(_isSearching ? Icons.arrow_back : Icons.search),
        onPressed: () {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          } else {
            setState(() => _isSearching = true);
          }
        },
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              style: theme.textTheme.bodyMedium,
              onChanged: widget.onSearchChanged,
              onSubmitted: (_) => widget.onSearchSubmitted?.call(),
            )
          : Text('Zuru'),
      actions: _isSearching
          ? [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged?.call('');
                  },
                ),
            ]
          : widget.actions,
    );
  }
}
