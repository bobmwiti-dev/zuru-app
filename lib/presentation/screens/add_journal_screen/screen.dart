import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/companion_tag_widget.dart';
import './widgets/mood_selector_widget.dart';

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
  String? _locationName;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSaving = false;

  // Character counter
  final int _maxDescriptionLength = 500;

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
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

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
      // Simulate save operation (in production, save to Firebase)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/memory-feed-screen');
        _showSuccessSnackBar('Journal entry saved successfully');
      }
    } catch (e) {
      debugPrint('Save error: $e');
      _showErrorSnackBar('Failed to save journal entry');
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
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content:
            Text('Please grant $permission permission to use this feature.'),
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
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
            'Please enable location services to automatically fetch your location.'),
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
            child: _isSaving
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
                      color: _isFormValid()
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
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
                  onMoodSelected: (mood) =>
                      setState(() => _selectedMood = mood),
                ),

                SizedBox(height: 3.h),

                // Companion Tagging
                CompanionTagWidget(
                  companions: _companions,
                  onCompanionsChanged: (companions) =>
                      setState(() => _companions = companions),
                ),

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
            suffixIcon: _isLoadingLocation
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
                color: currentLength > _maxDescriptionLength
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
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              null,
        ),
      ],
    );
  }
}
