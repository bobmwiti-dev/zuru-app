import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import './widgets/map_controls_widget.dart';
import './widgets/memory_list_bottom_sheet_widget.dart';
import './widgets/memory_preview_card_widget.dart';

/// Interactive Map View screen for Zuru journaling app
/// Displays user's memories as location pins on Google Maps
class InteractiveMapView extends StatefulWidget {
  const InteractiveMapView({super.key});

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends State<InteractiveMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  MemoryData? _selectedMemory;
  MapType _currentMapType = MapType.normal;
  Position? _currentPosition;
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Nairobi coordinates as default center
  static const LatLng _nairobiCenter = LatLng(-1.2921, 36.8219);

  // Mock memory data with locations in Nairobi
  final List<MemoryData> _memories = [
    MemoryData(
      id: '1',
      title: 'Coffee at Java House',
      description: 'Amazing cappuccino and great ambiance for journaling',
      mood: 'Happy',
      moodColor: Color(0xFFF4E4BC),
      location: LatLng(-1.2864, 36.8172),
      locationName: 'Java House, Westlands',
      date: DateTime(2025, 11, 28),
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      semanticLabel:
          'Steaming cup of cappuccino with latte art on wooden table in cozy cafe',
      companions: ['Sarah', 'Mike'],
    ),
    MemoryData(
      id: '2',
      title: 'Sunset at Karura Forest',
      description: 'Peaceful evening walk through the forest trails',
      mood: 'Calm',
      moodColor: Color(0xFF2D7D7D),
      location: LatLng(-1.2421, 36.8370),
      locationName: 'Karura Forest',
      date: DateTime(2025, 11, 27),
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      semanticLabel:
          'Golden sunset filtering through tall trees in lush green forest',
      companions: [],
    ),
    MemoryData(
      id: '3',
      title: 'Art Exhibition at National Museum',
      description: 'Inspiring contemporary African art showcase',
      mood: 'Excited',
      moodColor: Color(0xFFE8B4B8),
      location: LatLng(-1.2674, 36.8172),
      locationName: 'National Museum of Kenya',
      date: DateTime(2025, 11, 26),
      imageUrl:
          'https://images.unsplash.com/photo-1577083552431-6e5fd01988ec?w=800',
      semanticLabel:
          'Colorful abstract paintings displayed on white gallery walls with spotlights',
      companions: ['Alex'],
    ),
    MemoryData(
      id: '4',
      title: 'Lunch at Mama Oliech',
      description: 'Delicious traditional fish and ugali',
      mood: 'Happy',
      moodColor: Color(0xFFF4E4BC),
      location: LatLng(-1.2921, 36.8219),
      locationName: 'Mama Oliech Restaurant',
      date: DateTime(2025, 11, 25),
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
      semanticLabel:
          'Traditional African meal with grilled fish and white ugali on ceramic plate',
      companions: ['Family'],
    ),
    MemoryData(
      id: '5',
      title: 'Morning Jog at Uhuru Park',
      description: 'Refreshing start to the day with city views',
      mood: 'Excited',
      moodColor: Color(0xFFE8B4B8),
      location: LatLng(-1.2833, 36.8167),
      locationName: 'Uhuru Park',
      date: DateTime(2025, 11, 24),
      imageUrl:
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      semanticLabel:
          'Early morning view of park with joggers on path and city skyline in background',
      companions: [],
    ),
    MemoryData(
      id: '6',
      title: 'Shopping at Sarit Centre',
      description: 'Found some great books and had ice cream',
      mood: 'Happy',
      moodColor: Color(0xFFF4E4BC),
      location: LatLng(-1.2615, 36.7879),
      locationName: 'Sarit Centre',
      date: DateTime(2025, 11, 23),
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
      semanticLabel:
          'Modern shopping mall interior with bright lighting and retail stores',
      companions: ['Emma'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Get current location
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
      }

      // Create markers for memories
      _createMarkers();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _createMarkers() {
    _markers.clear();
    for (var memory in _memories) {
      _markers.add(
        Marker(
          markerId: MarkerId(memory.id),
          position: memory.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMoodHue(memory.mood),
          ),
          onTap: () => _onMarkerTapped(memory),
          infoWindow: InfoWindow(
            title: memory.title,
            snippet: memory.locationName,
          ),
        ),
      );
    }
  }

  double _getMoodHue(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return BitmapDescriptor.hueYellow;
      case 'calm':
        return BitmapDescriptor.hueCyan;
      case 'excited':
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _onMarkerTapped(MemoryData memory) {
    setState(() => _selectedMemory = memory);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.terrain
              : MapType.normal;
    });
  }

  void _showMemoryListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemoryListBottomSheetWidget(
        memories: _filteredMemories,
        onMemoryTap: (memory) {
          Navigator.pop(context);
          _onMarkerTapped(memory);
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: memory.location,
                zoom: 16.0,
              ),
            ),
          );
        },
      ),
    );
  }

  void _filterMemories(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  List<MemoryData> get _filteredMemories {
    if (_searchQuery.isEmpty) return _memories;
    return _memories.where((memory) {
      return memory.title.toLowerCase().contains(_searchQuery) ||
          memory.locationName.toLowerCase().contains(_searchQuery) ||
          memory.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Memory Map',
        style: CustomAppBarStyle.standard,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : _nairobiCenter,
                    zoom: 12.0,
                  ),
                  markers: _markers,
                  mapType: _currentMapType,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Search bar
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterMemories,
                      decoration: InputDecoration(
                        hintText: 'Search memories...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterMemories('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Map controls
                Positioned(
                  top: 80,
                  right: 16,
                  child: MapControlsWidget(
                    currentMapType: _currentMapType,
                    onMapTypeToggle: _toggleMapType,
                    onCurrentLocationTap: _goToCurrentLocation,
                  ),
                ),

                // Memory list button
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _showMemoryListBottomSheet,
                    backgroundColor: theme.colorScheme.primary,
                    child: CustomIconWidget(
                      iconName: 'list',
                      color: theme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),

                // Memory preview card
                if (_selectedMemory != null)
                  Positioned(
                    bottom: 100,
                    left: 16,
                    right: 16,
                    child: MemoryPreviewCardWidget(
                      memory: _selectedMemory!,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/journal-detail-screen',
                          arguments: _selectedMemory,
                        );
                      },
                      onClose: () {
                        setState(() => _selectedMemory = null);
                      },
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

/// Memory data model
class MemoryData {
  final String id;
  final String title;
  final String description;
  final String mood;
  final Color moodColor;
  final LatLng location;
  final String locationName;
  final DateTime date;
  final String imageUrl;
  final String semanticLabel;
  final List<String> companions;

  MemoryData({
    required this.id,
    required this.title,
    required this.description,
    required this.mood,
    required this.moodColor,
    required this.location,
    required this.locationName,
    required this.date,
    required this.imageUrl,
    required this.semanticLabel,
    required this.companions,
  });
}
