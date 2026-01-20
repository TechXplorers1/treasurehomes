import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<String> createBooking(BookingEntity booking);
  Future<List<BookingEntity>> getUserBookings(String userId);
}

class FirebaseBookingRepository implements BookingRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<String> createBooking(BookingEntity booking) async {
    try {
      await _firestore.collection('bookings').doc(booking.id).set({
        'id': booking.id,
        'userId': booking.userId,
        'serviceId': booking.serviceId,
        'serviceName': booking.serviceName,
        'bookingDate': booking.bookingDate.toIso8601String(),
        'address': booking.address,
        'status': booking.status.toString().split('.').last,
        'totalPrice': booking.totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return booking.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final bookings = <BookingEntity>[];

      for (final doc in snapshot.docs) {
        try {
          final bookingData = doc.data();
          bookings.add(
            BookingEntity(
              id: bookingData['id'] as String,
              userId: bookingData['userId'] as String,
              serviceId: bookingData['serviceId'] as String,
              serviceName: bookingData['serviceName'] as String,
              bookingDate: DateTime.parse(bookingData['bookingDate'] as String),
              address: bookingData['address'] as String,
              status: _parseStatus(bookingData['status'] as String),
              totalPrice: (bookingData['totalPrice'] as num).toDouble(),
            ),
          );
        } catch (e) {
          print('Error parsing booking: $e');
        }
      }

      return bookings;
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }
}

// Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return FirebaseBookingRepository();
});
