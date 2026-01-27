import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> signUp(String name, String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> resetPassword(String email);
  Future<UserEntity> createUserByAdmin(
    String name,
    String email,
    String password,
    String phoneNumber,
    UserRole role,
  );
}
