import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Data Source for file uploads
class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource() : _storage = FirebaseStorage.instance;

  /// Upload file to Firebase Storage
  Future<String> uploadFile({
    required String path,
    required File file,
    required String userId,
    String? contentType,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final storageRef = _storage.ref().child('$path/$userId/$fileName');

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'userId': userId},
    );

    final uploadTask = storageRef.putFile(file, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  /// Upload data (bytes) to Firebase Storage
  Future<String> uploadData({
    required String path,
    required List<int> data,
    required String userId,
    required String fileName,
    String? contentType,
  }) async {
    final storageRef = _storage.ref().child('$path/$userId/$fileName');

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'userId': userId},
    );

    final uploadTask = storageRef.putData(
      Uint8List.fromList(data),
      metadata,
    );
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  /// Delete file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    final ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String downloadUrl) async {
    final ref = _storage.refFromURL(downloadUrl);
    return await ref.getMetadata();
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// List files in a directory
  Future<ListResult> listFiles({
    required String path,
    required String userId,
  }) async {
    final ref = _storage.ref().child('$path/$userId');
    return await ref.listAll();
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  /// Monitor upload progress
  Stream<TaskSnapshot> uploadFileWithProgress({
    required String path,
    required File file,
    required String userId,
    String? contentType,
  }) {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final storageRef = _storage.ref().child('$path/$userId/$fileName');

    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'userId': userId},
    );

    final uploadTask = storageRef.putFile(file, metadata);
    return uploadTask.snapshotEvents;
  }
}