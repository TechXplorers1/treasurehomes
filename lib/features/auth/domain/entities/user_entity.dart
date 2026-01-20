import 'package:equatable/equatable.dart';

enum UserRole { customer, admin, provider }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.role = UserRole.customer,
  });

  @override
  List<Object?> get props => [id, email, name, phoneNumber, role];
}
