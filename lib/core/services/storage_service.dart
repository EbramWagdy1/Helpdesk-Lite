import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpdesk/core/services/firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseService.storage;

  /// Uploads file bytes (compatible with Web, Mobile, Desktop)
  Future<String> uploadAttachment({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Deletes a file by its full storage path or URL
  Future<void> deleteFile(String pathOrUrl) async {
    try {
      if (pathOrUrl.startsWith('http')) {
        final ref = _storage.refFromURL(pathOrUrl);
        await ref.delete();
      } else {
        final ref = _storage.ref().child(pathOrUrl);
        await ref.delete();
      }
    } catch (_) {
      // Ignore if not found
    }
  }
}
