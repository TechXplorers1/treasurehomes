import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final DateTime bookingDate;
  final String address;
  final String? notes;
  final BookingStatus status;
  final double totalPrice;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.bookingDate,
    required this.address,
    this.notes,
    required this.status,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    serviceId,
    serviceName,
    bookingDate,
    address,
    notes,
    status,
    totalPrice,
  ];
}
