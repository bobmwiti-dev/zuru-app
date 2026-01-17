import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/app_export.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/repositories/journal_repository.dart';
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

  final JournalRepository _journalRepository = JournalRepository();
  bool _didInitArgs = false;
  LatLng? _initialCenter;
  String? _initialSelectedEntryId;

  // Nairobi coordinates as default center
  static const LatLng _nairobiCenter = LatLng(-1.2921, 36.8219);

  final List<MemoryData> _memories = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitArgs) return;
    _didInitArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final lat = (args['centerLatitude'] as num?)?.toDouble();
      final lng = (args['centerLongitude'] as num?)?.toDouble();
      final selectedId = args['selectedEntryId']?.toString();
      if (lat != null && lng != null) {
        _initialCenter = LatLng(lat, lng);
      }
      if (selectedId != null && selectedId.trim().isNotEmpty) {
        _initialSelectedEntryId = selectedId;
      }
    }
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

      await _loadMemoriesFromFirestore();

      // Create markers for memories
      _createMarkers();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMemoriesFromFirestore() async {
    final uid = _journalRepository.currentUserId;
    if (uid == null) return;

    try {
      final journals = await _journalRepository.getUserJournals(
        userId: uid,
        limit: 250,
      );

      final mapped = <MemoryData>[];
      for (final j in journals) {
        if (j.latitude == null || j.longitude == null) continue;

        final id = (j.id ?? '').trim();
        if (id.isEmpty) continue;

        final imageUrl =
            j.photos.isNotEmpty && j.photos.first.trim().isNotEmpty
                ? j.photos.first
                : 'assets/images/no-image.jpg';

        mapped.add(
          MemoryData(
            id: id,
            title: j.title,
            description: j.content ?? '',
            mood: (j.mood ?? '').trim().isNotEmpty ? j.mood!.trim() : 'Memory',
            moodColor: _moodColorFor(j.mood),
            location: LatLng(j.latitude!, j.longitude!),
            locationName: _formatLocationForMemory(j),
            date: j.createdAt,
            imageUrl: imageUrl,
            semanticLabel: j.title,
            companions: const [],
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _memories
          ..clear()
          ..addAll(mapped);

        if (_initialSelectedEntryId != null) {
          final match = _memories
              .where((m) => m.id == _initialSelectedEntryId)
              .cast<MemoryData?>()
              .firstOrNull;
          _selectedMemory = match;
        }
      });
    } catch (_) {
      // Ignore map load errors - UI still should show map
    }
  }

  String _formatLocationForMemory(JournalModel j) {
    final name = (j.locationName ?? '').trim();
    if (name.isNotEmpty) return name;

    final city = (j.locationCity ?? '').trim();
    final country = (j.locationCountry ?? '').trim();
    if (city.isNotEmpty && country.isNotEmpty) return '$city, $country';
    if (city.isNotEmpty) return city;
    if (country.isNotEmpty) return country;
    return 'Unknown location';
  }

  Color _moodColorFor(String? mood) {
    final m = (mood ?? '').toLowerCase();
    if (m.contains('happy')) return const Color(0xFFF4E4BC);
    if (m.contains('calm')) return const Color(0xFF2D7D7D);
    if (m.contains('excited')) return const Color(0xFFE8B4B8);
    if (m.contains('sad')) return const Color(0xFF6C7A89);
    if (m.contains('angry')) return const Color(0xFFE57373);
    return Colors.blueGrey;
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
    _tryCenterOnSelected();
  }

  Future<void> _tryCenterOnSelected() async {
    if (_mapController == null) return;
    if (_selectedMemory == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedMemory!.location, zoom: 16.0),
      ),
    );
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
                    target:
                        _initialCenter ??
                        (_currentPosition != null
                            ? LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              )
                            : _nairobiCenter),
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
                          arguments: {'memoryId': _selectedMemory!.id},
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
