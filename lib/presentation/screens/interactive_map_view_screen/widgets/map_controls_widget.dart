import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Map controls widget for map type toggle and current location
class MapControlsWidget extends StatelessWidget {
  final MapType currentMapType;
  final VoidCallback onMapTypeToggle;
  final VoidCallback onCurrentLocationTap;

  const MapControlsWidget({
    super.key,
    required this.currentMapType,
    required this.onMapTypeToggle,
    required this.onCurrentLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Map type toggle
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onMapTypeToggle,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: _getMapTypeIcon(),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getMapTypeLabel(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        // Current location button
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCurrentLocationTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'my_location',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMapTypeIcon() {
    switch (currentMapType) {
      case MapType.normal:
        return 'map';
      case MapType.satellite:
        return 'satellite_alt';
      case MapType.terrain:
        return 'terrain';
      default:
        return 'map';
    }
  }

  String _getMapTypeLabel() {
    switch (currentMapType) {
      case MapType.normal:
        return 'Normal';
      case MapType.satellite:
        return 'Satellite';
      case MapType.terrain:
        return 'Terrain';
      default:
        return 'Map';
    }
  }
}
