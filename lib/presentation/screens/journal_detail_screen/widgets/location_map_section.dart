import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Interactive location section with map preview
class LocationMapSection extends StatefulWidget {
  final Map<String, dynamic> journalEntry;
  final VoidCallback onMapTap;

  const LocationMapSection({
    super.key,
    required this.journalEntry,
    required this.onMapTap,
  });

  @override
  State<LocationMapSection> createState() => _LocationMapSectionState();
}

class _LocationMapSectionState extends State<LocationMapSection> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location =
        widget.journalEntry['location'] as String? ?? 'Unknown Location';
    final latitude = widget.journalEntry['latitude'] as double? ?? -1.2921;
    final longitude = widget.journalEntry['longitude'] as double? ?? 36.8219;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onMapTap,
                child: Text('View Full Map'),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Location name
          Text(
            location,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 16),

          // Map preview
          GestureDetector(
            onTap: widget.onMapTap,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('journal_location'),
                        position: LatLng(latitude, longitude),
                        infoWindow: InfoWindow(title: location),
                      ),
                    },
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                  ),

                  // Tap overlay
                  Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'touch_app',
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap to open full map',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
