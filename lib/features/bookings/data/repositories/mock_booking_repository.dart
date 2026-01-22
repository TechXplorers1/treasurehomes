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

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final oldBooking = _bookings[index];
      _bookings[index] = BookingEntity(
        id: oldBooking.id,
        userId: oldBooking.userId,
        serviceId: oldBooking.serviceId,
        serviceName: oldBooking.serviceName,
        bookingDate: oldBooking.bookingDate,
        address: oldBooking.address,
        notes: oldBooking.notes,
        status: status,
        totalPrice: oldBooking.totalPrice,
      );
    }
  }
}
