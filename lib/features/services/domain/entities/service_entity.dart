import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final double? rating;
  final String? imageUrl;
  final String? detailedDescription;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.rating,
    this.imageUrl,
    this.detailedDescription,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    rating,
    imageUrl,
    detailedDescription,
  ];
}
