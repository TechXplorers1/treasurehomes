import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'firebase_auth_repository.dart';

// Use Firebase Auth Repository for production
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Keep MockAuthRepository for testing if needed
class MockAuthRepository implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'admin@home.com' && password == 'password') {
      _currentUser = const UserEntity(
        id: 'admin_123',
        email: 'admin@home.com',
        name: 'Admin User',
        role: UserRole.admin,
      );
      return _currentUser!;
    }

    // Default customer login
    if (password == 'password') {
      _currentUser = UserEntity(
        id: 'user_${email.hashCode}',
        email: email,
        name: 'John Doe',
        role: UserRole.customer,
      );
      return _currentUser!;
    }

    throw Exception('Invalid credentials');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserEntity> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final newUser = UserEntity(
      id: 'user_${email.hashCode}',
      email: email,
      name: name,
      role: UserRole.customer,
    );
    _currentUser = newUser;
    return newUser;
  }
}
