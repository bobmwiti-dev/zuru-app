import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Camera preview widget with photo capture and gallery selection
class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final String? cameraError;
  final XFile? capturedImage;
  final VoidCallback onCapturePhoto;
  final VoidCallback onSelectFromGallery;
  final VoidCallback? onRetryCamera;
  final VoidCallback onRemoveImage;

  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.cameraError,
    required this.capturedImage,
    required this.onCapturePhoto,
    required this.onSelectFromGallery,
    required this.onRetryCamera,
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
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: capturedImage != null
            ? _buildCapturedImage(context, theme)
            : (cameraError != null
                ? _buildCameraError(context, theme)
                : _buildCameraPreview(context, theme)),
      ),
    );
  }

  Widget _buildCameraError(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'videocam_off',
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
            ),
            SizedBox(height: 1.8.h),
            Text(
              cameraError ?? 'Camera not available.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.2.h),
            Text(
              'You can still add a photo from your gallery.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.0.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Use Gallery',
                  size: CustomButtonSize.medium,
                  onPressed: () {
                    AnimationUtils.selectionClick();
                    onSelectFromGallery();
                  },
                ),
                SizedBox(width: 3.w),
                CustomButton(
                  text: 'Retry',
                  variant: CustomButtonVariant.tertiary,
                  size: CustomButtonSize.medium,
                  onPressed: onRetryCamera == null
                      ? null
                      : () {
                        AnimationUtils.selectionClick();
                        onRetryCamera!.call();
                      },
                ),
              ],
            ),
          ],
        ),
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
              onPressed: () {
                AnimationUtils.selectionClick();
                onRemoveImage();
              },
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
    return _PressScale(
      onPressed: () {
        AnimationUtils.mediumImpact();
        onCapturePhoto();
      },
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
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
    final borderRadius = BorderRadius.circular(24);

    return _PressScale(
      onPressed: () {
        AnimationUtils.selectionClick();
        onPressed();
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            AnimationUtils.selectionClick();
            onPressed();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
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
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _PressScale({required this.child, this.onPressed});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (!mounted) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AnimationUtils.fast,
        curve: AnimationUtils.easeInOut,
        child: widget.child,
      ),
    );
  }
}
