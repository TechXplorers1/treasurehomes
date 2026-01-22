import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_repository.dart';

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
        'notes': booking.notes,
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
      return _mapQuerySnapshotToBookings(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  @override
  Future<List<BookingEntity>> getAllBookings() async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .orderBy('bookingDate', descending: true)
          .get();
      return _mapQuerySnapshotToBookings(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch all bookings: $e');
    }
  }

  List<BookingEntity> _mapQuerySnapshotToBookings(QuerySnapshot snapshot) {
    final bookings = <BookingEntity>[];
    for (final doc in snapshot.docs) {
      try {
        final bookingData = doc.data() as Map<String, dynamic>;
        bookings.add(
          BookingEntity(
            id: bookingData['id'] as String,
            userId: bookingData['userId'] as String? ?? '',
            serviceId: bookingData['serviceId'] as String? ?? '',
            serviceName:
                bookingData['serviceName'] as String? ?? 'Unknown Service',
            bookingDate: DateTime.parse(bookingData['bookingDate'] as String),
            address: bookingData['address'] as String? ?? '',
            notes: bookingData['notes'] as String?,
            status: _parseStatus(bookingData['status'] as String? ?? 'pending'),
            totalPrice: (bookingData['totalPrice'] as num?)?.toDouble() ?? 0.0,
          ),
        );
      } catch (e) {
        print('Error parsing booking ${doc.id}: $e');
      }
    }
    return bookings;
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'workinprogress':
      case 'work in progress':
        return BookingStatus.workInProgress;
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
