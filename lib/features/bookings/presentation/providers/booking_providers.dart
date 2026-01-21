import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';
import '../../data/repositories/firebase_booking_repository.dart';
import '../../data/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return FirebaseBookingRepository();
});

final adminAllBookingsProvider = FutureProvider<List<BookingEntity>>((
  ref,
) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getAllBookings();
});
