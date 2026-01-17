import 'package:camera/camera.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/companion_tag_widget.dart';
import './widgets/mood_selector_widget.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/datasources/remote/storage/firebase_storage_datasource.dart';
import '../../../data/repositories/journal_repository.dart';

/// Add Journal Screen - Enables users to capture and document experiences
/// with location-aware journaling optimized for mobile input
class AddJournalScreen extends StatefulWidget {
  const AddJournalScreen({super.key});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _collectionController = TextEditingController();
  final TextEditingController _reviewTipsController = TextEditingController();
  final TextEditingController _reviewHighlightController =
      TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _collectionFocusNode = FocusNode();
  final FocusNode _tagFocusNode = FocusNode();

  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  String? _cameraInitError;

  // Form state
  String? _selectedMood;
  List<String> _companions = [];
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  bool _isPublic = false; // Privacy setting: false = private, true = public
  String? _locationName;
  String? _locationCity;
  String? _locationCountry;
  String? _locationCountryCode;
  String? _locationAdminArea;
  String? _locationSubLocality;
  String? _locationAddress;
  String? _locationSource;
  Position? _currentPosition;
  JournalModel? _editingJournal;
  bool _isEditMode = false;
  bool _didInitFromArgs = false;
  List<String> _existingPhotoUrls = [];
  bool _isLoadingLocation = false;
  bool _isSaving = false;

  String _entryType = 'memory';
  double? _reviewRating;
  int? _reviewCostTier;
  bool? _reviewWouldReturn;
  final List<String> _reviewVibes = [];
  final List<String> _reviewHighlights = [];
  List<String> _collectionSuggestions = [];

  List<String> _captionSuggestions = [];
  List<String> _highlightSuggestions = [];
  String? _selectedCaption;
  bool _isGeneratingSuggestions = false;

  static const List<String> _reviewVibeOptions = [
    'Cozy',
    'Luxury',
    'Budget',
    'Romantic',
    'Family',
    'Party',
    'Quiet',
    'Cultural',
  ];

  // Character counter
  final int _maxDescriptionLength = 500;

  // Repository
  final JournalRepository _journalRepository = JournalRepository();
  final FirebaseStorageDataSource _firebaseStorageDataSource =
      FirebaseStorageDataSource();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchCurrentLocation();
    _titleFocusNode.addListener(_onFocusChanged);
    _descriptionFocusNode.addListener(_onFocusChanged);
    _locationFocusNode.addListener(_onFocusChanged);
    _collectionFocusNode.addListener(_onFocusChanged);
    _tagFocusNode.addListener(_onFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollectionSuggestions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromArgs) return;
    _didInitFromArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final mode = args['mode'];
      final journal = args['journal'];

      if (mode == 'edit' && journal is JournalModel) {
        _editingJournal = journal;
        _isEditMode = true;
        _existingPhotoUrls = List<String>.from(journal.photos);

        _titleController.text = journal.title;
        _descriptionController.text = journal.content ?? '';
        _selectedMood = journal.mood;
        _isPublic = journal.isPublic;

        _tags
          ..clear()
          ..addAll(journal.tags);

        _collectionController.text = journal.collection ?? '';
        _entryType = (journal.entryType ?? 'memory').trim().isNotEmpty
            ? (journal.entryType ?? 'memory')
            : 'memory';
        _reviewRating = journal.reviewRating;
        _reviewCostTier = journal.reviewCostTier;
        _reviewWouldReturn = journal.reviewWouldReturn;
        _reviewVibes
          ..clear()
          ..addAll(journal.reviewVibes);
        _reviewHighlights
          ..clear()
          ..addAll(journal.reviewHighlights);
        _reviewTipsController.text = journal.reviewTips ?? '';

        _captionSuggestions = List<String>.from(journal.captionSuggestions);
        _highlightSuggestions = List<String>.from(journal.highlightSuggestions);
        _selectedCaption = journal.selectedCaption;

        _locationName = journal.locationName;
        _locationController.text = journal.locationName ?? '';

        _locationCity = journal.locationCity;
        _locationCountry = journal.locationCountry;
        _locationCountryCode = journal.locationCountryCode;
        _locationAdminArea = journal.locationAdminArea;
        _locationSubLocality = journal.locationSubLocality;
        _locationAddress = journal.locationAddress;
        _locationSource = journal.locationSource;

        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  List<String> _generateCaptionSuggestions() {
    final title = _titleController.text.trim();
    final mood = (_selectedMood ?? '').trim();
    final location = (_locationName ?? _locationController.text).trim();
    final city = (_locationCity ?? '').trim();
    final country = (_locationCountry ?? '').trim();

    String locationShort = '';
    if (city.isNotEmpty && country.isNotEmpty) {
      locationShort = '$city, $country';
    } else if (location.isNotEmpty) {
      locationShort = location;
    } else if (city.isNotEmpty) {
      locationShort = city;
    } else if (country.isNotEmpty) {
      locationShort = country;
    }

    final vibes = _reviewVibes.take(2).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final out = <String>[];
    if (title.isNotEmpty && locationShort.isNotEmpty) {
      out.add('$title — $locationShort');
    }
    if (locationShort.isNotEmpty && mood.isNotEmpty) {
      out.add('${mood.toLowerCase() == mood ? mood[0].toUpperCase() + mood.substring(1) : mood} mood in $locationShort');
    }
    if (title.isNotEmpty && mood.isNotEmpty) {
      out.add('$title • Feeling $mood');
    }
    if (_entryType == 'review' && _reviewRating != null) {
      final rating = _reviewRating!.toStringAsFixed(1);
      if (locationShort.isNotEmpty) {
        out.add('$rating⭐ at $locationShort');
      }
      if (title.isNotEmpty) {
        out.add('$title — $rating⭐');
      }
    }
    if (_entryType == 'review' && vibes.isNotEmpty && locationShort.isNotEmpty) {
      out.add('${vibes.join(' • ')} vibes at $locationShort');
    }

    final cleaned = <String>[];
    for (final s in out) {
      final v = s.trim();
      if (v.isEmpty) continue;
      if (cleaned.contains(v)) continue;
      cleaned.add(v);
    }
    return cleaned.take(6).toList();
  }

  List<String> _generateHighlightSuggestions() {
    final out = <String>[];
    final description = _descriptionController.text.trim();

    if (_entryType == 'review') {
      if (_reviewRating != null && _reviewRating! >= 4.5) {
        out.add('Must-try spot');
      } else if (_reviewRating != null && _reviewRating! >= 4.0) {
        out.add('Worth it');
      }
      if (_reviewWouldReturn == true) {
        out.add('Would return');
      }
      for (final v in _reviewVibes.take(4)) {
        final vv = v.trim();
        if (vv.isNotEmpty) out.add(vv);
      }
    }

    if (description.isNotEmpty) {
      final parts = description
          .split(RegExp(r'[\n\.!?]+'))
          .map((e) => e.trim())
          .where((e) => e.length >= 12)
          .toList();
      for (final p in parts.take(3)) {
        out.add(p.length > 60 ? '${p.substring(0, 57)}...' : p);
      }
    }

    final cleaned = <String>[];
    for (final s in out) {
      final v = s.trim();
      if (v.isEmpty) continue;
      if (cleaned.contains(v)) continue;
      cleaned.add(v);
    }
    return cleaned.take(8).toList();
  }

  Future<void> _generateSuggestions() async {
    if (_isGeneratingSuggestions) return;
    setState(() => _isGeneratingSuggestions = true);

    try {
      final captions = _generateCaptionSuggestions();
      final highlights = _generateHighlightSuggestions();
      if (!mounted) return;

      setState(() {
        _captionSuggestions = captions;
        _highlightSuggestions = highlights;
        _selectedCaption ??= captions.isNotEmpty ? captions.first : null;
        _isGeneratingSuggestions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGeneratingSuggestions = false);
    }
  }

  Widget _buildSuggestionsSection(ThemeData theme) {
    final hasCaptions = _captionSuggestions.isNotEmpty;
    final hasHighlights = _highlightSuggestions.isNotEmpty;

    final chipBg = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );
    final chipBorder = BorderSide(
      color: theme.colorScheme.outline.withValues(alpha: 0.16),
      width: 1,
    );
    final selectedBg = theme.colorScheme.primaryContainer;
    final selectedLabel = theme.colorScheme.onPrimaryContainer;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Suggestions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: _isGeneratingSuggestions
                      ? null
                      : () {
                          AnimationUtils.selectionClick();
                          _generateSuggestions();
                        },
                  icon: _isGeneratingSuggestions
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'auto_awesome',
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                  label: Text(
                    _isGeneratingSuggestions ? 'Generating' : 'Generate',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasCaptions) ...[
            SizedBox(height: 1.2.h),
            Text(
              'Captions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.8.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _captionSuggestions.take(6).map((c) {
                final isSelected = (_selectedCaption ?? '').trim() == c.trim();
                return ChoiceChip(
                  label: Text(
                    c,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: isSelected,
                  backgroundColor: chipBg,
                  selectedColor: selectedBg,
                  side: chipBorder,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? selectedLabel
                        : theme.colorScheme.onSurface,
                  ),
                  onSelected: (_) {
                    AnimationUtils.selectionClick();
                    setState(() => _selectedCaption = c);
                  },
                );
              }).toList(),
            ),
          ],
          if (hasHighlights) ...[
            SizedBox(height: 1.8.h),
            Text(
              _entryType == 'review' ? 'Highlights (tap to add)' : 'Highlights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.8.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _highlightSuggestions.take(8).map((h) {
                return ActionChip(
                  label: Text(
                    h,
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: chipBg,
                  side: chipBorder,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: _entryType == 'review'
                      ? () {
                          AnimationUtils.selectionClick();
                          setState(() {
                            final v = h.trim();
                            if (v.isEmpty) return;
                            if (_reviewHighlights.contains(v)) return;
                            _reviewHighlights.add(v);
                          });
                        }
                      : null,
                );
              }).toList(),
            ),
          ],
          if (!hasCaptions && !hasHighlights)
            Padding(
              padding: EdgeInsets.only(top: 1.0.h),
              child: Text(
                'Generate captions and highlights from your entry details.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _collectionController.dispose();
    _tagController.dispose();
    _reviewTipsController.dispose();
    _reviewHighlightController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _locationFocusNode.dispose();
    _collectionFocusNode.dispose();
    _tagFocusNode.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadCollectionSuggestions() async {
    final userId = _journalRepository.currentUserId;
    if (userId == null) return;

    try {
      final journals = await _journalRepository.getUserJournals(
        userId: userId,
        limit: 50,
      );

      final unique = <String>{};
      for (final j in journals) {
        final c = (j.collection ?? '').trim();
        if (c.isNotEmpty) unique.add(c);
      }

      if (!mounted) return;
      setState(() {
        _collectionSuggestions = unique.toList()..sort();
      });
    } catch (_) {
      // Ignore suggestion load errors
    }
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  /// Initialize camera with platform detection
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            setState(() {
              _isCameraInitialized = false;
              _cameraInitError = 'Camera permission was denied.';
            });
          }
          _showPermissionDialog('Camera');
          return;
        }
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Select appropriate camera
      final camera =
          kIsWeb
              ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first,
              )
              : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first,
              );

      // Initialize controller
      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      // Apply platform-specific settings
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Focus mode not supported
      }

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash not supported
        }
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraInitError = null;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = false;
        _cameraInitError = 'Camera not available. Please allow camera access and retry.';
      });
    }
  }

  Future<void> _retryInitializeCamera() async {
    if (mounted) {
      setState(() {
        _cameraInitError = null;
        _isCameraInitialized = false;
      });
    }
    try {
      await _cameraController?.dispose();
    } catch (_) {}
    _cameraController = null;
    await _initializeCamera();
  }

  /// Fetch current location using GPS
  Future<void> _fetchCurrentLocation() async {
    if (mounted) {
      setState(() => _isLoadingLocation = true);
    }

    try {
      // Request location permission
      if (!kIsWeb) {
        final status = await Permission.location.request();
        if (!status.isGranted) {
          _showPermissionDialog('Location');
          if (mounted) {
            setState(() => _isLoadingLocation = false);
          }
          return;
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        if (mounted) {
          setState(() => _isLoadingLocation = false);
        }
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      debugPrint('Current position: \'$_currentPosition\'');

      await _reverseGeocodeAndApply(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        source: 'gps',
      );
    } catch (e) {
      debugPrint('Location fetch error: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _reverseGeocodeAndApply({
    required double latitude,
    required double longitude,
    required String source,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      if (!mounted) return;

      if (placemark == null) {
        setState(() {
          _isLoadingLocation = false;
          _locationSource = source;
        });
        return;
      }

      final placeName = (placemark.name ?? '').trim();
      final street = (placemark.street ?? '').trim();
      final subLocality = (placemark.subLocality ?? '').trim();
      final locality = (placemark.locality ?? '').trim();
      final admin = (placemark.administrativeArea ?? '').trim();
      final country = (placemark.country ?? '').trim();
      final countryCode = (placemark.isoCountryCode ?? '').trim();

      final addressParts = <String>[];
      if (placeName.isNotEmpty) addressParts.add(placeName);
      if (street.isNotEmpty && street.toLowerCase() != placeName.toLowerCase()) {
        addressParts.add(street);
      }
      if (subLocality.isNotEmpty) addressParts.add(subLocality);
      if (locality.isNotEmpty) addressParts.add(locality);
      if (admin.isNotEmpty) addressParts.add(admin);
      if (country.isNotEmpty) addressParts.add(country);
      final address = addressParts.join(', ');

      final displayName =
          placeName.isNotEmpty ? placeName : (street.isNotEmpty ? street : '');

      setState(() {
        _locationName = displayName.isNotEmpty ? displayName : _locationName;
        _locationCity = locality.isNotEmpty ? locality : _locationCity;
        _locationCountry = country.isNotEmpty ? country : _locationCountry;
        _locationCountryCode =
            countryCode.isNotEmpty ? countryCode : _locationCountryCode;
        _locationAdminArea = admin.isNotEmpty ? admin : _locationAdminArea;
        _locationSubLocality =
            subLocality.isNotEmpty ? subLocality : _locationSubLocality;
        _locationAddress = address.isNotEmpty ? address : _locationAddress;
        _locationSource = source;
        _isLoadingLocation = false;

        if (_locationController.text.trim().isEmpty && displayName.isNotEmpty) {
          _locationController.text = displayName;
        }
      });
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _locationSource = source;
      });
    }
  }

  /// Capture photo using camera
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (mounted) {
        setState(() => _capturedImage = photo);
      }
    } catch (e) {
      debugPrint('Photo capture error: $e');
      _showErrorSnackBar('Failed to capture photo');
    }
  }

  /// Select image from gallery
  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (mounted) {
          setState(() => _capturedImage = image);
        }
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
      _showErrorSnackBar('Failed to select image');
    }
  }

  /// Check if form is valid for saving
  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        (_capturedImage != null || _existingPhotoUrls.isNotEmpty ||
            _descriptionController.text.trim().isNotEmpty);
  }

  /// Save journal entry
  Future<void> _saveJournalEntry() async {
    if (!_isFormValid()) return;

    setState(() => _isSaving = true);

    try {
      // Get current user ID
      final userId = _journalRepository.currentUserId;
      if (userId == null) {
        _showErrorSnackBar('User not authenticated');
        if (mounted) {
          setState(() => _isSaving = false);
        }
        return;
      }

      // Prepare photos URLs
      List<String> photoUrls = List<String>.from(_existingPhotoUrls);
      bool photoUploadFailed = false;
      if (_capturedImage != null && !kIsWeb) {
        try {
          final bytes = await _capturedImage!.readAsBytes();
          final originalFileName = _capturedImage!.name;
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_$originalFileName';

          String? contentType;
          final extension = originalFileName.toLowerCase();
          if (extension.endsWith('.png')) {
            contentType = 'image/png';
          } else if (extension.endsWith('.jpg') || extension.endsWith('.jpeg')) {
            contentType = 'image/jpeg';
          }

          final downloadUrl = await _firebaseStorageDataSource
              .uploadData(
                path: 'journal_photos',
                data: bytes,
                userId: userId,
                fileName: fileName,
                contentType: contentType,
              )
              .timeout(const Duration(seconds: 25));

          photoUrls = [downloadUrl];
        } on TimeoutException catch (e) {
          photoUploadFailed = true;
          debugPrint('Image upload timeout: $e');
        } catch (e) {
          photoUploadFailed = true;
          debugPrint('Image upload error: $e');
        }
      } else if (_capturedImage != null && kIsWeb) {
        // Skip photo upload on web due to Storage billing/CORS
        photoUploadFailed = true;
        debugPrint('Photo upload skipped on web due to Storage configuration.');
      }

      final collection = _collectionController.text.trim().isNotEmpty
          ? _collectionController.text.trim()
          : null;

      final locationName =
          _locationName ??
          (_locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null);

      if (_isEditMode && _editingJournal?.id != null) {
        await _journalRepository.updateJournal(_editingJournal!.id!, {
          'title': _titleController.text.trim(),
          'content':
              _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
          'mood': _selectedMood,
          'latitude': _currentPosition?.latitude ?? _editingJournal?.latitude,
          'longitude': _currentPosition?.longitude ?? _editingJournal?.longitude,
          'locationName': locationName,
          'locationCity': _locationCity,
          'locationCountry': _locationCountry,
          'locationCountryCode': _locationCountryCode,
          'locationAdminArea': _locationAdminArea,
          'locationSubLocality': _locationSubLocality,
          'locationAddress': _locationAddress,
          'locationSource': _locationSource,
          'photos': photoUrls,
          'tags': _tags,
          'collection': collection,
          'entryType': _entryType,
          'reviewRating': _entryType == 'review' ? _reviewRating : null,
          'reviewCostTier': _entryType == 'review' ? _reviewCostTier : null,
          'reviewVibes':
              _entryType == 'review' ? List<String>.from(_reviewVibes) : <String>[],
          'reviewWouldReturn':
              _entryType == 'review' ? _reviewWouldReturn : null,
          'reviewHighlights':
              _entryType == 'review'
                  ? List<String>.from(_reviewHighlights)
                  : <String>[],
          'reviewTips':
              _entryType == 'review' &&
                      _reviewTipsController.text.trim().isNotEmpty
                  ? _reviewTipsController.text.trim()
                  : null,
          'captionSuggestions': List<String>.from(_captionSuggestions),
          'highlightSuggestions': List<String>.from(_highlightSuggestions),
          'selectedCaption': (_selectedCaption ?? '').trim().isNotEmpty
              ? _selectedCaption
              : null,
          'suggestionsGeneratedAt':
              _captionSuggestions.isNotEmpty || _highlightSuggestions.isNotEmpty
                  ? FieldValue.serverTimestamp()
                  : null,
          'suggestionsSource':
              _captionSuggestions.isNotEmpty || _highlightSuggestions.isNotEmpty
                  ? 'heuristic'
                  : null,
          'isPublic': _isPublic,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final journal = JournalModel(
          userId: userId,
          title: _titleController.text.trim(),
          content:
              _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
          mood: _selectedMood,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
          locationName: locationName,
          locationCity: _locationCity,
          locationCountry: _locationCountry,
          locationCountryCode: _locationCountryCode,
          locationAdminArea: _locationAdminArea,
          locationSubLocality: _locationSubLocality,
          locationAddress: _locationAddress,
          locationSource: _locationSource,
          photos: photoUrls,
          tags: _tags,
          collection: collection,
          entryType: _entryType,
          reviewRating: _entryType == 'review' ? _reviewRating : null,
          reviewCostTier: _entryType == 'review' ? _reviewCostTier : null,
          reviewVibes:
              _entryType == 'review' ? List<String>.from(_reviewVibes) : const [],
          reviewWouldReturn: _entryType == 'review' ? _reviewWouldReturn : null,
          reviewHighlights: _entryType == 'review'
              ? List<String>.from(_reviewHighlights)
              : const [],
          reviewTips:
              _entryType == 'review' &&
                      _reviewTipsController.text.trim().isNotEmpty
                  ? _reviewTipsController.text.trim()
                  : null,
          captionSuggestions: List<String>.from(_captionSuggestions),
          highlightSuggestions: List<String>.from(_highlightSuggestions),
          selectedCaption:
              (_selectedCaption ?? '').trim().isNotEmpty ? _selectedCaption : null,
          suggestionsGeneratedAt:
              _captionSuggestions.isNotEmpty || _highlightSuggestions.isNotEmpty
                  ? DateTime.now()
                  : null,
          suggestionsSource:
              _captionSuggestions.isNotEmpty || _highlightSuggestions.isNotEmpty
                  ? 'heuristic'
                  : null,
          isPublic: _isPublic,
          createdAt: DateTime.now(),
        );

        await _journalRepository.createJournal(journal);
      }

      if (mounted) {
        AnimationUtils.mediumImpact();
        if (photoUploadFailed) {
          _showErrorSnackBar(
            kIsWeb
                ? 'Photo upload failed (browser CORS). Saved entry without photo.'
                : 'Photo upload failed. Saved entry without photo.',
          );
        }
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Save error: $e');
      _showErrorSnackBar('Failed to save journal entry: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Show permission dialog
  void _showPermissionDialog(String permission) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$permission Permission Required'),
            content: Text(
              'Please grant $permission permission to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  Widget _buildEntryTypeAndCollectionSection(ThemeData theme) {
    final isFocused = _collectionFocusNode.hasFocus;
    final active = theme.colorScheme.primary;

    return _SectionCard(
      emphasized: isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'layers',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Entry Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              ChoiceChip(
                label: const Text('Memory'),
                selected: _entryType != 'review',
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() {
                    _entryType = 'memory';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('Place Review'),
                selected: _entryType == 'review',
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() {
                    _entryType = 'review';
                    _reviewRating ??= 4.0;
                    _reviewCostTier ??= 2;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'collections_bookmark',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Collection',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          TextField(
            focusNode: _collectionFocusNode,
            controller: _collectionController,
            decoration: InputDecoration(
              hintText: 'e.g. Nairobi Food Spots',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              suffixIcon: _collectionController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        AnimationUtils.selectionClick();
                        setState(() => _collectionController.clear());
                      },
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
            ),
            style: theme.textTheme.bodyMedium,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          if (_collectionSuggestions.isNotEmpty) ...[
            SizedBox(height: 1.2.h),
            Wrap(
              spacing: 1.w,
              runSpacing: 1.h,
              children: _collectionSuggestions.take(8).map((c) {
                final isSelected =
                    _collectionController.text.trim().toLowerCase() ==
                    c.trim().toLowerCase();
                return ChoiceChip(
                  label: Text(c),
                  selected: isSelected,
                  selectedColor: active.withValues(alpha: 0.18),
                  onSelected: (_) {
                    AnimationUtils.selectionClick();
                    setState(() {
                      _collectionController.text = c;
                      _collectionController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _collectionController.text.length),
                      );
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection(ThemeData theme) {
    final rating = (_reviewRating ?? 4.0).clamp(1.0, 5.0);
    final costTier = (_reviewCostTier ?? 2).clamp(1, 3);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Place Review',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Text(
            'Rating: ${rating.toStringAsFixed(1)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Slider(
            value: rating,
            min: 1,
            max: 5,
            divisions: 8,
            onChanged: (v) {
              setState(() => _reviewRating = v);
            },
          ),
          SizedBox(height: 1.h),
          Text(
            'Cost',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.8.h),
          Wrap(
            spacing: 2.w,
            children: [
              ChoiceChip(
                label: const Text('\$'),
                selected: costTier == 1,
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() => _reviewCostTier = 1);
                },
              ),
              ChoiceChip(
                label: const Text('\$\$'),
                selected: costTier == 2,
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() => _reviewCostTier = 2);
                },
              ),
              ChoiceChip(
                label: const Text('\$\$\$'),
                selected: costTier == 3,
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() => _reviewCostTier = 3);
                },
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              value: _reviewWouldReturn ?? true,
              onChanged: (v) {
                AnimationUtils.selectionClick();
                setState(() => _reviewWouldReturn = v);
              },
              title: Text(
                'Would return',
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                (_reviewWouldReturn ?? true) ? 'Yes' : 'No',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              activeColor: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.2.h),
          Text(
            'Vibes',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.8.h),
          Wrap(
            spacing: 1.w,
            runSpacing: 1.h,
            children: _reviewVibeOptions.map((v) {
              final selected = _reviewVibes.contains(v);
              return FilterChip(
                label: Text(v),
                selected: selected,
                onSelected: (_) {
                  AnimationUtils.selectionClick();
                  setState(() {
                    if (selected) {
                      _reviewVibes.remove(v);
                    } else {
                      _reviewVibes.add(v);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 1.4.h),
          Text(
            'Highlights',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.8.h),
          TextField(
            controller: _reviewHighlightController,
            decoration: InputDecoration(
              hintText: 'Add a highlight and tap +',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              suffixIcon: IconButton(
                onPressed: _addReviewHighlight,
                icon: Icon(
                  Icons.add,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            onSubmitted: (_) => _addReviewHighlight(),
          ),
          if (_reviewHighlights.isNotEmpty) ...[
            SizedBox(height: 1.2.h),
            Wrap(
              spacing: 1.w,
              runSpacing: 1.h,
              children: _reviewHighlights.map((h) {
                return Chip(
                  label: Text(h),
                  onDeleted: () {
                    AnimationUtils.selectionClick();
                    setState(() => _reviewHighlights.remove(h));
                  },
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 1.4.h),
          Text(
            'Tips',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.8.h),
          TextField(
            controller: _reviewTipsController,
            decoration: InputDecoration(
              hintText: 'Any tips for friends visiting?',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  void _addReviewHighlight() {
    final value = _reviewHighlightController.text.trim();
    if (value.isEmpty) return;
    if (_reviewHighlights.contains(value)) {
      _reviewHighlightController.clear();
      return;
    }

    AnimationUtils.selectionClick();
    setState(() {
      _reviewHighlights.add(value);
      _reviewHighlightController.clear();
    });
  }

  /// Show location service dialog
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text(
              'Please enable location services to automatically fetch your location.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditMode ? 'Edit Journal Entry' : 'Add Journal Entry',
        style: CustomAppBarStyle.standard,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: _buildBottomSaveBar(context, theme),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _PremiumBackground()),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),

                    _buildAnimatedSection(
                      index: 0,
                      child: CameraPreviewWidget(
                        cameraController: _cameraController,
                        isCameraInitialized: _isCameraInitialized,
                        cameraError: _cameraInitError,
                        capturedImage: _capturedImage,
                        onCapturePhoto: _capturePhoto,
                        onSelectFromGallery: _selectFromGallery,
                        onRetryCamera: _retryInitializeCamera,
                        onRemoveImage: () => setState(() => _capturedImage = null),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 1,
                      child: _buildLocationSection(theme),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 2,
                      child: _buildEntryTypeAndCollectionSection(theme),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 3,
                      child: _buildTitleInput(theme),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 4,
                      child: _buildDescriptionInput(theme),
                    ),

                    SizedBox(height: 2.h),

                    if (_entryType == 'review') ...[
                      _buildAnimatedSection(
                        index: 5,
                        child: _buildReviewSection(theme),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    _buildAnimatedSection(
                      index: 6,
                      child: _buildSuggestionsSection(theme),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 7,
                      child: _SectionCard(
                        child: MoodSelectorWidget(
                          selectedMood: _selectedMood,
                          onMoodSelected: (mood) {
                            setState(() => _selectedMood = mood);
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 8,
                      child: _SectionCard(
                        child: CompanionTagWidget(
                          companions: _companions,
                          onCompanionsChanged: (companions) {
                            setState(() => _companions = companions);
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 9,
                      child: _buildTagsSection(theme),
                    ),

                    SizedBox(height: 2.h),

                    _buildAnimatedSection(
                      index: 10,
                      child: _buildPrivacySection(theme),
                    ),

                    SizedBox(height: 14.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build location section
  Widget _buildLocationSection(ThemeData theme) {
    final isFocused = _locationFocusNode.hasFocus;
    final hasCity = (_locationCity ?? '').trim().isNotEmpty;
    final hasCountry = (_locationCountry ?? '').trim().isNotEmpty;
    final hasAddress = (_locationAddress ?? '').trim().isNotEmpty;
    return _SectionCard(
      emphasized: isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          TextField(
            focusNode: _locationFocusNode,
            controller: _locationController,
            decoration: InputDecoration(
              hintText: 'Add location manually',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              suffixIcon:
                  _isLoadingLocation
                      ? Padding(
                        padding: EdgeInsets.all(3.w),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                      : IconButton(
                        icon: CustomIconWidget(
                          iconName: 'my_location',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          AnimationUtils.selectionClick();
                          _fetchCurrentLocation();
                        },
                      ),
            ),
            style: theme.textTheme.bodyMedium,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              setState(() {
                _locationName = value.trim().isNotEmpty ? value.trim() : null;
                _locationSource = 'manual';
              });
            },
          ),
          if (hasCity || hasCountry)
            Padding(
              padding: EdgeInsets.only(top: 1.2.h),
              child: Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  if (hasCity)
                    Chip(
                      label: Text(_locationCity!.trim()),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.16),
                      ),
                    ),
                  if (hasCountry)
                    Chip(
                      label: Text(_locationCountry!.trim()),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.16),
                      ),
                    ),
                ],
              ),
            ),
          if (hasAddress)
            Padding(
              padding: EdgeInsets.only(top: 1.0.h),
              child: Text(
                _locationAddress!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// Build title input
  Widget _buildTitleInput(ThemeData theme) {
    final isFocused = _titleFocusNode.hasFocus;
    return _SectionCard(
      emphasized: isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Title',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.2.h),
          TextField(
            focusNode: _titleFocusNode,
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Give your memory a title...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            ),
            style: theme.textTheme.bodyLarge,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  /// Build description input
  Widget _buildDescriptionInput(ThemeData theme) {
    final currentLength = _descriptionController.text.length;
    final isFocused = _descriptionFocusNode.hasFocus;

    return _SectionCard(
      emphasized: isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: AnimationUtils.fast,
                style: theme.textTheme.bodySmall!.copyWith(
                  color:
                      currentLength > _maxDescriptionLength
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isFocused ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text('$currentLength/$_maxDescriptionLength'),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          TextField(
            focusNode: _descriptionFocusNode,
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Describe your experience...',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            ),
            style: theme.textTheme.bodyMedium,
            maxLines: 5,
            maxLength: _maxDescriptionLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
          ),
        ],
      ),
    );
  }

  /// Build tags section
  Widget _buildTagsSection(ThemeData theme) {
    final isFocused = _tagFocusNode.hasFocus;
    return _SectionCard(
      emphasized: isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'label',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          TextField(
            focusNode: _tagFocusNode,
            controller: _tagController,
            decoration: InputDecoration(
              hintText: 'Add tags (press Enter to add)',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              suffixIcon:
                  _tagController.text.isNotEmpty
                      ? IconButton(
                        icon: CustomIconWidget(
                          iconName: 'add',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: _addTag,
                      )
                      : null,
            ),
            style: theme.textTheme.bodyMedium,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addTag(),
            onChanged: (_) => setState(() {}),
          ),
          if (_tags.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            Wrap(
              spacing: 1.w,
              runSpacing: 1.h,
              children:
                  _tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () {
                        AnimationUtils.selectionClick();
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                      deleteIcon: Icon(
                        Icons.close,
                        size: 18,
                        color: theme.colorScheme.onSurface,
                      ),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Add a tag from the input field
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      AnimationUtils.selectionClick();
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  /// Build privacy section
  Widget _buildPrivacySection(ThemeData theme) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'privacy_tip',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Privacy',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              value: _isPublic,
              onChanged: (value) {
                AnimationUtils.selectionClick();
                setState(() {
                  _isPublic = value;
                });
              },
              title: Text(
                _isPublic ? 'Public' : 'Private',
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Text(
                _isPublic
                    ? 'Anyone can see this memory'
                    : 'Only you can see this memory',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              secondary: CustomIconWidget(
                iconName: _isPublic ? 'public' : 'lock',
                color:
                    _isPublic
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              activeColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSaveBar(BuildContext context, ThemeData theme) {
    final canSave = _isFormValid() && !_isSaving;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: AnimationUtils.medium,
      curve: AnimationUtils.easeInOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.0),
              theme.colorScheme.surface.withValues(alpha: 0.94),
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.30, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 2.h),
            child: IgnorePointer(
              ignoring: !canSave,
              child: Opacity(
                opacity: canSave ? 1.0 : 0.60,
                child: CustomButton(
                  text: _isEditMode ? 'Update' : 'Save',
                  isFullWidth: true,
                  size: CustomButtonSize.extraLarge,
                  isLoading: _isSaving,
                  onPressed: _saveJournalEntry,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    final delayMs = 40 * index;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.primary.withValues(alpha: 0.04),
            theme.colorScheme.tertiary.withValues(alpha: 0.03),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _GlowBlob(
              color: theme.colorScheme.primary,
              size: 220,
              opacity: 0.18,
            ),
          ),
          Positioned(
            top: 240,
            right: -90,
            child: _GlowBlob(
              color: theme.colorScheme.tertiary,
              size: 260,
              opacity: 0.14,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowBlob(
              color: theme.colorScheme.secondary,
              size: 320,
              opacity: 0.10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowBlob({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool emphasized;

  const _SectionCard({
    required this.child,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderColor = emphasized
        ? theme.colorScheme.primary.withValues(alpha: 0.45)
        : theme.colorScheme.outline.withValues(alpha: 0.16);

    return AnimatedContainer(
      duration: AnimationUtils.fast,
      curve: AnimationUtils.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: emphasized ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: emphasized ? 0.10 : 0.06),
            blurRadius: emphasized ? 22 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
