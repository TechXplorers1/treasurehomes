import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';

import 'package:home_services_app/features/bookings/presentation/providers/booking_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';

final bookingStateProvider = AsyncNotifierProvider<BookingNotifier, void>(() {
  return BookingNotifier();
});

class BookingNotifier extends AsyncNotifier<void> {
  late final _bookingRepository = ref.read(bookingRepositoryProvider);
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> build() async {}

  Future<void> createBooking({
    required String serviceId,
    required String serviceName,
    required DateTime bookingDate,
    required String address,
    required double price,
    String? notes,
  }) async {
    // Get current Firebase user
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('User not logged in');
    }

    // Fetch user data from Firestore using the UID
    late UserEntity user;
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        user = UserEntity(
          id: firebaseUser.uid,
          email: data['email'] ?? firebaseUser.email ?? '',
          name: data['name'] ?? firebaseUser.displayName ?? 'User',
          role: _parseRole(data['role'] ?? 'customer'),
        );
      } else {
        // User doc doesn't exist, create a basic user object from Firebase Auth - djhbhjbjhxcbjhbhb
        user = UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          role: UserRole.customer,
        );
      }
    } catch (e) {
      // Fallback: create user object from Firebase Auth data
      user = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'User',
        role: UserRole.customer,
      );
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final booking = BookingEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        serviceId: serviceId,
        serviceName: serviceName,
        bookingDate: bookingDate,
        address: address,
        notes: notes,
        status: BookingStatus.pending,
        totalPrice: price,
      );
      await _bookingRepository.createBooking(booking);
      // Refresh the list of bookings
      ref.invalidate(userBookingsProvider);
    });
  }

  UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'provider':
        return UserRole.provider;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}

final userBookingsProvider = FutureProvider<List<BookingEntity>>((ref) async {
  // Listen to Firebase auth changes to get current user
  final firebaseUser = ref.watch(firebaseAuthStateProvider).value;
  if (firebaseUser == null) return [];

  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getUserBookings(firebaseUser.uid);
});

final specificUserBookingsProviderFamily =
    FutureProvider.family<List<BookingEntity>, String>((ref, userId) async {
      final repo = ref.watch(bookingRepositoryProvider);
      return repo.getUserBookings(userId);
    });
