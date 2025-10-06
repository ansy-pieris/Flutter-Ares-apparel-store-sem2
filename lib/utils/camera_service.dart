import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service class to handle camera and image picking functionality
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Check camera permission status
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Check storage permission status
  Future<PermissionStatus> checkStoragePermission() async {
    return await Permission.storage.status;
  }

  /// Request storage permission
  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  /// Take a photo from camera
  Future<File?> takePhoto({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      // Check camera permission
      PermissionStatus cameraPermission = await checkCameraPermission();
      if (cameraPermission.isDenied) {
        cameraPermission = await requestCameraPermission();
        if (cameraPermission.isDenied) {
          throw 'Camera permission denied';
        }
      }

      if (cameraPermission.isPermanentlyDenied) {
        throw 'Camera permission permanently denied. Please enable it in settings.';
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>?> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 85,
      );

      if (images.isNotEmpty) {
        return images.map((xFile) => File(xFile.path)).toList();
      }
      return null;
    } catch (e) {
      print('Error picking multiple images: $e');
      return null;
    }
  }

  /// Record video from camera
  Future<File?> recordVideo({Duration? maxDuration}) async {
    try {
      // Check camera permission
      PermissionStatus cameraPermission = await checkCameraPermission();
      if (cameraPermission.isDenied) {
        cameraPermission = await requestCameraPermission();
        if (cameraPermission.isDenied) {
          throw 'Camera permission denied';
        }
      }

      if (cameraPermission.isPermanentlyDenied) {
        throw 'Camera permission permanently denied. Please enable it in settings.';
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error recording video: $e');
      return null;
    }
  }

  /// Pick video from gallery
  Future<File?> pickVideoFromGallery({Duration? maxDuration}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video from gallery: $e');
      return null;
    }
  }

  /// Show image source selection dialog
  Future<File?> pickImageWithSourceSelection({
    required bool allowCamera,
    required bool allowGallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    // This method would typically show a dialog to let user choose
    // For simplicity, defaulting to camera if both are allowed
    if (allowCamera) {
      return await takePhoto(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } else if (allowGallery) {
      return await pickImageFromGallery(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    }
    return null;
  }

  /// Open app settings for camera permission
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Get image file size in bytes
  Future<int> getImageSize(File imageFile) async {
    try {
      return await imageFile.length();
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
