import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  XFile? _capturedImage;
  bool _isCameraInitialized = false;

  // Form state
  String? _selectedMood;
  List<String> _companions = [];
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();
  bool _isPublic = false; // Privacy setting: false = private, true = public
  String? _locationName;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSaving = false;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Initialize camera with platform detection
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
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
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  /// Fetch current location using GPS
  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Request location permission
      if (!kIsWeb) {
        final status = await Permission.location.request();
        if (!status.isGranted) {
          _showPermissionDialog('Location');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      debugPrint('Current position: \'$_currentPosition\'');

      // Mock location name (in production, use reverse geocoding)
      _locationName = 'Nairobi, Kenya';
      _locationController.text = _locationName ?? '';

      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    } catch (e) {
      debugPrint('Location fetch error: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  /// Capture photo using camera
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() => _capturedImage = photo);
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
        setState(() => _capturedImage = image);
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
      _showErrorSnackBar('Failed to select image');
    }
  }

  /// Check if form is valid for saving
  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        (_capturedImage != null ||
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
        return;
      }

      // Prepare photos URLs (for now, we'll use empty array since we don't have file upload implemented yet)
      List<String> photoUrls = [];
      if (_capturedImage != null) {
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

          final downloadUrl = await _firebaseStorageDataSource.uploadData(
            path: 'journal_photos',
            data: bytes,
            userId: userId,
            fileName: fileName,
            contentType: contentType,
          );

          photoUrls = [downloadUrl];
        } catch (e) {
          debugPrint('Image upload error: $e');
        }
      }

      // Create journal model
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
        locationName:
            _locationName ??
            (_locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null),
        photos: photoUrls,
        tags: _tags,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _journalRepository.createJournal(journal);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/memory-feed-screen');
        _showSuccessSnackBar('Journal entry saved successfully!');
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

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Journal Entry',
        style: CustomAppBarStyle.standard,
        automaticallyImplyLeading: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveJournalEntry,
            child:
                _isSaving
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                    : Text(
                      'Save',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color:
                            _isFormValid()
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                      ),
                    ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Camera Preview Section
                CameraPreviewWidget(
                  cameraController: _cameraController,
                  isCameraInitialized: _isCameraInitialized,
                  capturedImage: _capturedImage,
                  onCapturePhoto: _capturePhoto,
                  onSelectFromGallery: _selectFromGallery,
                  onRemoveImage: () => setState(() => _capturedImage = null),
                ),

                SizedBox(height: 3.h),

                // Location Section
                _buildLocationSection(theme),

                SizedBox(height: 3.h),

                // Title Input
                _buildTitleInput(theme),

                SizedBox(height: 2.h),

                // Description Input
                _buildDescriptionInput(theme),

                SizedBox(height: 3.h),

                // Mood Selector
                MoodSelectorWidget(
                  selectedMood: _selectedMood,
                  onMoodSelected:
                      (mood) => setState(() => _selectedMood = mood),
                ),

                SizedBox(height: 3.h),

                // Companion Tagging
                CompanionTagWidget(
                  companions: _companions,
                  onCompanionsChanged:
                      (companions) => setState(() => _companions = companions),
                ),

                SizedBox(height: 3.h),

                // Tags Section
                _buildTagsSection(theme),

                SizedBox(height: 3.h),

                // Privacy Toggle
                _buildPrivacySection(theme),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build location section
  Widget _buildLocationSection(ThemeData theme) {
    return Column(
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
        SizedBox(height: 1.h),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Add location manually',
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
                      onPressed: _fetchCurrentLocation,
                    ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Build title input
  Widget _buildTitleInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Give your memory a title...',
          ),
          style: theme.textTheme.bodyLarge,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  /// Build description input
  Widget _buildDescriptionInput(ThemeData theme) {
    final currentLength = _descriptionController.text.length;

    return Column(
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
            Text(
              '$currentLength/$_maxDescriptionLength',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    currentLength > _maxDescriptionLength
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Describe your experience...',
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
    );
  }

  /// Build tags section
  Widget _buildTagsSection(ThemeData theme) {
    return Column(
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
        SizedBox(height: 1.h),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Add tags (press Enter to add)',
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
    );
  }

  /// Add a tag from the input field
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  /// Build privacy section
  Widget _buildPrivacySection(ThemeData theme) {
    return Column(
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
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: SwitchListTile(
            value: _isPublic,
            onChanged: (value) {
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
    );
  }
}
