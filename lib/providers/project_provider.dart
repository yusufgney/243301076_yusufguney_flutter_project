import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project_model.dart';
import '../services/project_service.dart';
import 'auth_provider.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService(ref.watch(firestoreProvider));
});

/// All casting projects – for actors browsing.
final allProjectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  return ref.watch(projectServiceProvider).getAllProjects();
});

/// Projects created by the signed-in agency.
final agencyProjectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(projectServiceProvider).getAgencyProjects(uid);
});

class DeleteProjectNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String projectId) async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(projectServiceProvider).deleteCastingProjectIfOwner(
            projectId: projectId,
            ownerUid: uid,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}

final deleteProjectProvider = AsyncNotifierProvider<DeleteProjectNotifier, void>(
  DeleteProjectNotifier.new,
);
