import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application_model.dart';
import '../services/application_service.dart';
import 'auth_provider.dart';

final applicationServiceProvider = Provider<ApplicationService>((ref) {
  return ApplicationService(ref.watch(firestoreProvider));
});

final actorApplicationForProjectProvider =
    StreamProvider.family<ApplicationModel?, String>((ref, projectId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(applicationServiceProvider).watchApplication(
        actorId: user.uid,
        projectId: projectId,
      );
});

final projectApplicationCountProvider = StreamProvider.family<int, String>((ref, projectId) {
  return ref.watch(applicationServiceProvider).watchApplicationsForProject(projectId).map((list) => list.length);
});

final applicationsForProjectProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, projectId) {
  return ref.watch(applicationServiceProvider).watchApplicationsForProject(projectId);
});

final actorApplicationsListProvider = StreamProvider<List<ApplicationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(applicationServiceProvider).watchActorApplications(user.uid);
});

class ApplyToProjectNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> apply(String projectId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    try {
      await ref.read(applicationServiceProvider).applyToProject(
            actorId: user.uid,
            projectId: projectId,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}

final applyToProjectControllerProvider =
    AsyncNotifierProvider.autoDispose<ApplyToProjectNotifier, void>(
  ApplyToProjectNotifier.new,
);
