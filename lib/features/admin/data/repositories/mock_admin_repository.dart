import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../bookings/domain/entities/booking_entity.dart';

// Simple Admin Repo to fetch lists
class MockAdminRepository {
  Future<List<UserEntity>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const UserEntity(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: UserRole.customer,
      ),
      const UserEntity(
        id: '2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        role: UserRole.customer,
      ),
      const UserEntity(
        id: '3',
        name: 'Bob Wilson',
        email: 'bob@example.com',
        role: UserRole.customer,
      ),
    ];
  }

  Future<List<BookingEntity>> getAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return some mock bookings
    return [
      BookingEntity(
        id: '101',
        userId: '1',
        serviceId: '1',
        serviceName: 'AC Service',
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
        address: '123 Main St',
        status: BookingStatus.completed,
        totalPrice: 50.0,
      ),
      BookingEntity(
        id: '102',
        userId: '2',
        serviceId: '2',
        serviceName: 'Pipe Repair',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        address: '456 Oak Ave',
        status: BookingStatus.confirmed,
        totalPrice: 40.0,
      ),
    ];
  }
}

final adminRepositoryProvider = Provider((ref) => MockAdminRepository());

final adminUsersProvider = FutureProvider((ref) async {
  return ref.watch(adminRepositoryProvider).getAllUsers();
});

final adminBookingsProvider = FutureProvider((ref) async {
  return ref.watch(adminRepositoryProvider).getAllBookings();
});
