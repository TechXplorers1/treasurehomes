import '../../domain/entities/booking_entity.dart';
import 'booking_repository.dart';

// Keep MockBookingRepository for testing if needed
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

  @override
  Future<List<BookingEntity>> getAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings;
  }
}
