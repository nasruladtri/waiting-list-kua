import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/marriage_application_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirestoreService() {
    if (kDebugMode) {
      _firestore.useFirestoreEmulator('localhost', 8282);
    }
  }

  // Create marriage application
  Future<String> createMarriageApplication(MarriageApplication application) async {
    try {
      final docRef = await _firestore.collection('marriageApplications').add(application.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating marriage application: $e');
      rethrow;
    }
  }

  // Get marriage applications for current user
  Stream<List<MarriageApplication>> getUserApplications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('marriageApplications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarriageApplication.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get all marriage applications (for admins)
  Stream<List<MarriageApplication>> getAllApplications() {
    return _firestore
        .collection('marriageApplications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarriageApplication.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get applications by status
  Stream<List<MarriageApplication>> getApplicationsByStatus(String status) {
    return _firestore
        .collection('marriageApplications')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarriageApplication.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get single application
  Future<MarriageApplication?> getApplication(String applicationId) async {
    try {
      final doc = await _firestore.collection('marriageApplications').doc(applicationId).get();
      if (!doc.exists) return null;
      return MarriageApplication.fromMap(doc.id, doc.data()!);
    } catch (e) {
      debugPrint('Error getting application: $e');
      return null;
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(
    String applicationId,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await _firestore.collection('marriageApplications').doc(applicationId).update(updateData);
    } catch (e) {
      debugPrint('Error updating application status: $e');
      rethrow;
    }
  }

  // Update application
  Future<void> updateApplication(String applicationId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('marriageApplications').doc(applicationId).update(data);
    } catch (e) {
      debugPrint('Error updating application: $e');
      rethrow;
    }
  }

  // Delete application
  Future<void> deleteApplication(String applicationId) async {
    try {
      await _firestore.collection('marriageApplications').doc(applicationId).delete();
    } catch (e) {
      debugPrint('Error deleting application: $e');
      rethrow;
    }
  }

  // Get logs for application
  Stream<List<Map<String, dynamic>>> getApplicationLogs(String applicationId) {
    return _firestore
        .collection('logs')
        .where('applicationId', isEqualTo: applicationId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
