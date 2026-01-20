import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration; // e.g., 'Monthly', 'Yearly'
  final List<String> features;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
  });

  @override
  List<Object?> get props => [id, name, description, price, duration, features];
}
