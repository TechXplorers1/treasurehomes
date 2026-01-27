import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/entities/service_entity.dart';
import '../models/service_model.dart';

class FirestoreServiceRepository implements ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'services';

  @override
  Future<List<ServiceEntity>> getServices() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map<ServiceEntity>((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  @override
  Future<ServiceEntity> getServiceById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(doc);
      } else {
        throw Exception('Service not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }

  @override
  Future<void> addService(ServiceEntity service) async {
    try {
      // Use toFirestore from ServiceModel
      final serviceModel = ServiceModel(
        id: '', // ID will be auto-generated
        name: service.name,
        description: service.description,
        price: service.price,
        category: service.category,
        rating: service.rating,
        imageUrl: service.imageUrl,
        detailedDescription: service.detailedDescription,
      );

      await _firestore.collection(_collection).add(serviceModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  @override
  Future<void> updateService(ServiceEntity service) async {
    try {
      final serviceModel = ServiceModel(
        id: service.id,
        name: service.name,
        description: service.description,
        price: service.price,
        category: service.category,
        rating: service.rating,
        imageUrl: service.imageUrl,
        detailedDescription: service.detailedDescription,
      );

      await _firestore
          .collection(_collection)
          .doc(service.id)
          .update(serviceModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }
}
