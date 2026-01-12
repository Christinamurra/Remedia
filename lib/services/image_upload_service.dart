import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a meal post image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadMealPostImage(File imageFile, String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(imageFile.path);
    final fileName = '$timestamp$extension';
    final storagePath = 'meal_posts/$userId/$fileName';

    final ref = _storage.ref().child(storagePath);

    // Upload with metadata
    final metadata = SettableMetadata(
      contentType: _getContentType(extension),
      customMetadata: {
        'uploadedBy': userId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    final uploadTask = ref.putFile(imageFile, metadata);

    // Wait for upload to complete
    final snapshot = await uploadTask;

    // Get download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Delete a meal post image from Firebase Storage
  Future<void> deleteMealPostImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image may not exist or already deleted
      // Log but don't throw
      print('Failed to delete image: $e');
    }
  }

  /// Get content type from file extension
  String _getContentType(String extension) {
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
      case '.heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
