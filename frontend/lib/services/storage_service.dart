import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StorageService() {
    if (kDebugMode) {
      _storage.useStorageEmulator('localhost', 9292);
    }
  }

  // Upload marriage document
  Future<String> uploadMarriageDocument({
    required File file,
    required String applicationId,
    required String fileName,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      final path = 'marriage-documents/$userId/$applicationId/$fileName';
      final ref = _storage.ref().child(path);
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      rethrow;
    }
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(File file) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profile-pictures/$userId/$fileName';
      final ref = _storage.ref().child(path);
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  // Get download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting download URL: $e');
      rethrow;
    }
  }
}
