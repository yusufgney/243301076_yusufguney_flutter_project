import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/actor_model.dart';

class ActorService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ActorService(this._firestore, this._storage);

  Stream<ActorModel?> getActorProfile(String uid) {
    return _firestore.collection('actors').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ActorModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> saveActorProfile(ActorModel profile) async {
    await _firestore
        .collection('actors')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<String> uploadProfileImage(String uid, Uint8List imageBytes, String extension) async {
    final ref = _storage.ref().child('actor_profiles').child('$uid.$extension');
    final uploadTask = await ref.putData(imageBytes);
    return await uploadTask.ref.getDownloadURL();
  }
}
