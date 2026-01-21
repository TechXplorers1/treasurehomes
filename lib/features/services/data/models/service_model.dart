import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    super.rating,
    super.imageUrl,
    super.detailedDescription,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      detailedDescription: json['detailedDescription'] as String?,
    );
  }

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Service',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'General',
      rating: (data['rating'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'] as String?,
      detailedDescription: data['detailedDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'rating': rating,
      'imageUrl': imageUrl,
      'detailedDescription': detailedDescription,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'rating': rating,
      'imageUrl': imageUrl,
      'detailedDescription': detailedDescription,
      // id is document ID, not stored in data Usually
    };
  }
}
