import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/mock_auth_repository.dart';

// Provider for the AuthController (Notifier)
final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(() {
  return AuthNotifier();
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
}
