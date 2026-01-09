// This file is used to export all the necessary files and packages for the app

// Constants
export 'constants/app_colors.dart';
export 'constants/app_strings.dart';
export 'constants/app_sizes.dart';

// Utilities
export 'utils/animation_utils.dart';

// Routes
export '../routes/app_routes.dart';

// Widgets
export '../widgets/custom_app_bar.dart';
export '../widgets/custom_bottom_bar.dart';
export '../widgets/custom_button.dart';
export '../widgets/custom_icon_widget.dart';
export '../widgets/custom_image_widget.dart';
export '../widgets/custom_loading_indicator.dart';
export '../widgets/shimmer_widget.dart';

// Re-export shimmer classes for convenience
export '../widgets/shimmer_widget.dart' show ShimmerContainer, ShimmerText, ShimmerListItem;

// Theme
export '../theme/app_theme.dart';

// External packages
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:google_fonts/google_fonts.dart';
