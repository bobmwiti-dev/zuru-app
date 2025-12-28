import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Camera preview widget with photo capture and gallery selection
class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final XFile? capturedImage;
  final VoidCallback onCapturePhoto;
  final VoidCallback onSelectFromGallery;
  final VoidCallback onRemoveImage;

  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.capturedImage,
    required this.onCapturePhoto,
    required this.onSelectFromGallery,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: capturedImage != null
            ? _buildCapturedImage(context, theme)
            : _buildCameraPreview(context, theme),
      ),
    );
  }

  /// Build captured image view
  Widget _buildCapturedImage(BuildContext context, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        kIsWeb
            ? Image.network(
                capturedImage!.path,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(capturedImage!.path),
                fit: BoxFit.cover,
              ),
        Positioned(
          top: 2.h,
          right: 2.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 20,
              ),
              onPressed: onRemoveImage,
            ),
          ),
        ),
      ],
    );
  }

  /// Build camera preview
  Widget _buildCameraPreview(BuildContext context, ThemeData theme) {
    if (!isCameraInitialized || cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Initializing camera...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(cameraController!),
        Positioned(
          bottom: 2.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                theme,
                icon: 'photo_library',
                label: 'Gallery',
                onPressed: onSelectFromGallery,
              ),
              _buildCaptureButton(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  /// Build capture button
  Widget _buildCaptureButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: onCapturePhoto,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme, {
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
