import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../data/repositories/mock_booking_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final bookingStateProvider = AsyncNotifierProvider<BookingNotifier, void>(() {
  return BookingNotifier();
});

class BookingNotifier extends AsyncNotifier<void> {
  late final _bookingRepository = ref.read(bookingRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> createBooking({
    required String serviceId,
    required String serviceName,
    required DateTime bookingDate,
    required String address,
    required double price,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final booking = BookingEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        serviceId: serviceId,
        serviceName: serviceName,
        bookingDate: bookingDate,
        address: address,
        status: BookingStatus.pending,
        totalPrice: price,
      );
      await _bookingRepository.createBooking(booking);
      // Refresh the list of bookings
      ref.invalidate(userBookingsProvider);
    });
  }
}

final userBookingsProvider = FutureProvider<List<BookingEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getUserBookings(user.id);
});
