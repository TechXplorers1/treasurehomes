import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<String> createBooking(BookingEntity booking);
  Future<List<BookingEntity>> getUserBookings(String userId);
}

class MockBookingRepository implements BookingRepository {
  final List<BookingEntity> _bookings = [];

  @override
  Future<String> createBooking(BookingEntity booking) async {
    await Future.delayed(const Duration(seconds: 1));
    _bookings.add(booking);
    return booking.id;
  }

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((b) => b.userId == userId).toList();
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return MockBookingRepository();
});
