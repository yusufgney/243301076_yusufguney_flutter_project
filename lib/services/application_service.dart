import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application_model.dart';

class DuplicateApplicationException implements Exception {
  @override
  String toString() => 'You have already applied to this project.';
}

class ApplicationService {
  final FirebaseFirestore _firestore;

  ApplicationService(this._firestore);

  static String applicationDocId(String actorId, String projectId) =>
      '${actorId}_$projectId';

  DocumentReference<Map<String, dynamic>> _ref(String actorId, String projectId) {
    return _firestore
        .collection('applications')
        .doc(applicationDocId(actorId, projectId));
  }

  Future<void> applyToProject({
    required String actorId,
    required String projectId,
  }) async {
    final ref = _ref(actorId, projectId);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (snap.exists) throw DuplicateApplicationException();
      final model = ApplicationModel(
        id: ref.id,
        actorId: actorId,
        projectId: projectId,
        createdAt: DateTime.now(),
        status: ApplicationStatus.pending,
      );
      transaction.set(ref, model.toMap());
    });
  }

  Stream<ApplicationModel?> watchApplication({
    required String actorId,
    required String projectId,
  }) {
    return _ref(actorId, projectId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ApplicationModel.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<ApplicationModel>> watchApplicationsForProject(String projectId) {
    return _firestore
        .collection('applications')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((d) => ApplicationModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ApplicationModel>> watchActorApplications(String actorId) {
    return _firestore
        .collection('applications')
        .where('actorId', isEqualTo: actorId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((d) => ApplicationModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateApplicationStatus({
    required String actorId,
    required String projectId,
    required ApplicationStatus status,
  }) async {
    await _ref(actorId, projectId).update({
      'status': ApplicationModel.statusToString(status),
    });
  }
}
