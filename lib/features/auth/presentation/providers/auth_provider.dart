import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/mock_auth_repository.dart';

// Provider for the AuthController (Notifier)
final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(() {
  return AuthNotifier();
});

// Listen to Firebase Auth state changes
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  late final _authRepository = ref.read(authRepositoryProvider);

  @override
  Future<UserEntity?> build() async {
    // Check current user on initialization
    return _authRepository.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _authRepository.login(email, password);
    });
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _authRepository.signUp(name, email, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.logout();
      return null;
    });
  }

  Future<void> resetPassword(String email) async {
    // We don't necessarily need to set global loading state for this,
    // as it might clear the user session if we use AsyncValue.loading().
    // Instead, we can just return the future and let UI handle loading.
    // However, to keep it consistent via provider if we wanted,
    // but usually forgot password is separate flow.
    // Let's just return the Future and NOT update the main auth state (user).

    await _authRepository.resetPassword(email);
  }
}
