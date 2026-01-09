import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../core/logging/logger.dart';
import '../core/exceptions/app_exception.dart';

/// Media service for handling photos and videos
class MediaService {
  final Logger _logger;
  final ImagePicker _imagePicker;

  MediaService(this._logger) : _imagePicker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        _logger.info('Image picked from gallery: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      _logger.error('Failed to pick image from gallery', e);
      throw PermissionException(message: 'Failed to access gallery');
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        _logger.info('Image captured from camera: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      _logger.error('Failed to capture image from camera', e);
      throw PermissionException(message: 'Failed to access camera');
    }
  }

  /// Pick video from gallery
  Future<XFile?> pickVideoFromGallery({
    Duration? maxDuration,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (pickedFile != null) {
        _logger.info('Video picked from gallery: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      _logger.error('Failed to pick video from gallery', e);
      throw PermissionException(message: 'Failed to access gallery');
    }
  }

  /// Record video from camera
  Future<XFile?> recordVideoFromCamera({
    Duration? maxDuration,
    int? preferredCameraDevice = 0,
  }) async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCameraDevice == 0
            ? CameraDevice.rear
            : CameraDevice.front,
      );

      if (pickedFile != null) {
        _logger.info('Video recorded from camera: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      _logger.error('Failed to record video from camera', e);
      throw PermissionException(message: 'Failed to access camera');
    }
  }

  /// Get media info
  Future<MediaInfo> getMediaInfo(XFile file) async {
    try {
      final fileSize = await file.length();
      final fileName = path.basename(file.name);
      final fileExtension = path.extension(file.name).toLowerCase();
      final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(fileExtension);
      final isVideo = ['.mp4', '.mov', '.avi', '.mkv'].contains(fileExtension);

      return MediaInfo(
        file: file,
        fileName: fileName,
        fileSize: fileSize,
        fileExtension: fileExtension,
        isImage: isImage,
        isVideo: isVideo,
        mimeType: _getMimeType(fileExtension),
      );
    } catch (e) {
      _logger.error('Failed to get media info', e);
      throw DataException(message: 'Failed to read media file');
    }
  }

  /// Compress image
  Future<XFile?> compressImage(
    XFile imageFile, {
    int quality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      // Note: In production, use flutter_image_compress package
      // For now, return original file
      _logger.info('Image compression not implemented - returning original');
      return imageFile;
    } catch (e) {
      _logger.error('Failed to compress image', e);
      return imageFile; // Return original on failure
    }
  }

  /// Create video thumbnail
  Future<XFile?> createVideoThumbnail(XFile videoFile) async {
    try {
      // Note: In production, use video_thumbnail package
      // For now, return null
      _logger.info('Video thumbnail generation not implemented');
      return null;
    } catch (e) {
      _logger.error('Failed to create video thumbnail', e);
      return null;
    }
  }

  /// Save file to app directory
  Future<String> saveFileToAppDirectory(XFile file, {String? customName}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = customName ?? path.basename(file.name);
      final savedPath = path.join(appDir.path, fileName);

      await file.saveTo(savedPath);
      _logger.info('File saved to app directory: $savedPath');

      return savedPath;
    } catch (e) {
      _logger.error('Failed to save file to app directory', e);
      throw DataException(message: 'Failed to save file');
    }
  }

  /// Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.info('File deleted: $filePath');
      }
    } catch (e) {
      _logger.error('Failed to delete file: $filePath', e);
    }
  }

  /// Get file size in human readable format
  String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Validate file size
  bool isValidFileSize(int fileSizeBytes, {int maxSizeMB = 10}) {
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB default
    return fileSizeBytes <= maxSizeBytes;
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mkv':
        return 'video/x-matroska';
      default:
        return 'application/octet-stream';
    }
  }

  /// Clean up temporary files
  Future<void> cleanUpTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = tempDir.listSync();

      for (final file in tempFiles) {
        if (file is File) {
          try {
            await file.delete();
          } catch (e) {
            // Ignore deletion errors for temp files
          }
        }
      }

      _logger.info('Cleaned up temporary files');
    } catch (e) {
      _logger.error('Failed to clean up temp files', e);
    }
  }
}

/// Media information class
class MediaInfo {
  final XFile file;
  final String fileName;
  final int fileSize;
  final String fileExtension;
  final bool isImage;
  final bool isVideo;
  final String mimeType;

  MediaInfo({
    required this.file,
    required this.fileName,
    required this.fileSize,
    required this.fileExtension,
    required this.isImage,
    required this.isVideo,
    required this.mimeType,
  });

  /// Get file size in human readable format
  String get formattedSize => MediaService(LoggerFactory.createLogger()).formatFileSize(fileSize);

  /// Check if file is valid for upload
  bool get isValidForUpload {
    return (isImage || isVideo) &&
           MediaService(LoggerFactory.createLogger()).isValidFileSize(fileSize);
  }

  @override
  String toString() {
    return 'MediaInfo(fileName: $fileName, size: $formattedSize, type: $mimeType)';
  }
}

/// Media utilities
class MediaUtils {
  /// Get supported image formats
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'gif', 'webp'
  ];

  /// Get supported video formats
  static const List<String> supportedVideoFormats = [
    'mp4', 'mov', 'avi', 'mkv'
  ];

  /// Check if file extension is supported
  static bool isSupportedFormat(String extension, {bool forImages = true, bool forVideos = true}) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    final imageSupported = forImages && supportedImageFormats.contains(ext);
    final videoSupported = forVideos && supportedVideoFormats.contains(ext);
    return imageSupported || videoSupported;
  }

  /// Get aspect ratio from dimensions
  static double getAspectRatio(double width, double height) {
    return width / height;
  }

  /// Check if aspect ratio is valid for social media
  static bool isValidAspectRatio(double aspectRatio) {
    // Most social media accept 1:1 to 16:9 ratios
    return aspectRatio >= 1.0 && aspectRatio <= 16.0;
  }
}