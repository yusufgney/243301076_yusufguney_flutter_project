import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agency_model.dart';
import '../services/agency_service.dart';
import 'auth_provider.dart';

final agencyServiceProvider = Provider<AgencyService>((ref) {
  return AgencyService(ref.watch(firestoreProvider));
});

final agencyProfileProvider = StreamProvider<AgencyModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return ref.watch(agencyServiceProvider).getAgencyProfile(user.uid);
  }
  return Stream.value(null);
});

class AgencyProfileNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
  }

  Future<void> saveProfile(AgencyModel profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(agencyServiceProvider).saveAgencyProfile(profile);
    });
  }
}

final agencyProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<AgencyProfileNotifier, void>(() {
  return AgencyProfileNotifier();
});
