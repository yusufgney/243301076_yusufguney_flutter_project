import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project_model.dart';

class ProjectDeleteUnauthorizedException implements Exception {
  @override
  String toString() => 'You can only delete your own projects.';
}

class ProjectService {
  final FirebaseFirestore _firestore;

  ProjectService(this._firestore);

  Stream<List<ProjectModel>> getAllProjects() {
    return _firestore
        .collection('casting_projects')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ProjectModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<ProjectModel>> getAgencyProjects(String uid) {
    return _firestore
        .collection('casting_projects')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ProjectModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> deleteCastingProjectIfOwner({
    required String projectId,
    required String ownerUid,
  }) async {
    final projectRef = _firestore.collection('casting_projects').doc(projectId);
    final snap = await projectRef.get();
    if (!snap.exists || snap.data() == null) return;

    final project = ProjectModel.fromMap(snap.data()!, snap.id);
    if (project.createdBy != ownerUid) throw ProjectDeleteUnauthorizedException();

    final appsSnap = await _firestore
        .collection('applications')
        .where('projectId', isEqualTo: projectId)
        .get();

    const chunk = 450;
    for (var i = 0; i < appsSnap.docs.length; i += chunk) {
      final batch = _firestore.batch();
      final end = i + chunk < appsSnap.docs.length ? i + chunk : appsSnap.docs.length;
      for (var j = i; j < end; j++) {
        batch.delete(appsSnap.docs[j].reference);
      }
      await batch.commit();
    }
    await projectRef.delete();
  }
}
