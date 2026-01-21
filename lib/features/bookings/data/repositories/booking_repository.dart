import '../../domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<String> createBooking(BookingEntity booking);
  Future<List<BookingEntity>> getUserBookings(String userId);
  Future<List<BookingEntity>> getAllBookings();
}
