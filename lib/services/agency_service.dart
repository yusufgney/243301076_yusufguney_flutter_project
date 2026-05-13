import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agency_model.dart';

class AgencyService {
  final FirebaseFirestore _firestore;

  AgencyService(this._firestore);

  Stream<AgencyModel?> getAgencyProfile(String uid) {
    return _firestore.collection('agencies').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AgencyModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> saveAgencyProfile(AgencyModel profile) async {
    await _firestore
        .collection('agencies')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
