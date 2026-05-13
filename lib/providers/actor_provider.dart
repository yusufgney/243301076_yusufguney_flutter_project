import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/actor_model.dart';
import '../services/actor_service.dart';
import 'auth_provider.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final actorServiceProvider = Provider<ActorService>((ref) {
  return ActorService(
    ref.watch(firestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

final actorProfileProvider = StreamProvider<ActorModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return ref.watch(actorServiceProvider).getActorProfile(user.uid);
  }
  return Stream.value(null);
});

/// Live actor profile stream by uid (e.g. agency viewing an applicant).
final actorProfileStreamByIdProvider = StreamProvider.family<ActorModel?, String>((ref, uid) {
  return ref.watch(actorServiceProvider).getActorProfile(uid);
});

/// One-shot actor public profile by uid (e.g. agency viewing an applicant).
final actorByIdProvider = FutureProvider.family<ActorModel?, String>((ref, uid) async {
  final doc = await ref.read(firestoreProvider).collection('actors').doc(uid).get();
  if (!doc.exists || doc.data() == null) return null;
  return ActorModel.fromMap(doc.data()!, doc.id);
});

class ActorProfileNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // nothing to build
  }

  Future<void> saveProfile({
    required ActorModel profile,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      String? imageUrl = profile.profileImageUrl;
      
      if (imageBytes != null && imageExtension != null) {
        imageUrl = await ref
            .read(actorServiceProvider)
            .uploadProfileImage(profile.uid, imageBytes, imageExtension);
      }

      final updatedProfile = profile.copyWith(profileImageUrl: imageUrl);
      await ref.read(actorServiceProvider).saveActorProfile(updatedProfile);
    });
  }
}

final actorProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<ActorProfileNotifier, void>(() {
  return ActorProfileNotifier();
});
