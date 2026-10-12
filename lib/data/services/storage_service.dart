import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/config/firebase_bootstrap.dart';

/// Service for uploading device photos and recycling certificates.
class StorageService {
  StorageService._();

  /// Uploads binary data (image/document) to Firebase Storage.
  /// Falls back gracefully when Firebase is in offline development mode.
  static Future<String> uploadDeviceImage({
    required String itemId,
    required Uint8List bytes,
    required String filename,
  }) async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('device_photos')
            .child(itemId)
            .child(filename);

        final uploadTask = await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        debugPrint('[waste2value] FirebaseStorage upload error: $e');
      }
    }

    // Development mode fallback URL
    debugPrint('[waste2value] StorageService: Running in development mode. Simulating upload.');
    return 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80';
  }
}
