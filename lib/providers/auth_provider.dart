import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userModelProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user != null) {
    return ref.watch(authServiceProvider).getUserData(user.uid);
  } else {
    return Stream.value(null);
  }
});

class AuthStateNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signInWithEmailAndPassword(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }

  Future<void> register(String email, String password, UserRole role) async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).createUserWithEmailAndPassword(
        email: email,
        password: password,
        role: role,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthStateNotifier, void>(() {
  return AuthStateNotifier();
});
