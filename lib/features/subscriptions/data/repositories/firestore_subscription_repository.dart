import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import 'mock_subscription_repository.dart';

class FirestoreSubscriptionRepository implements SubscriptionRepository {
  final FirebaseFirestore _firestore;

  FirestoreSubscriptionRepository(this._firestore);

  @override
  Future<List<SubscriptionPlanEntity>> getPlans() async {
    final snapshot = await _firestore.collection('subscription_plans').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SubscriptionPlanEntity(
        id: doc.id,
        name: data['name'] as String,
        description: data['description'] as String,
        price: (data['price'] as num).toDouble(),
        duration: data['duration'] as String,
        features: List<String>.from(data['features'] as List),
      );
    }).toList();
  }

  Future<void> addPlan(SubscriptionPlanEntity plan) async {
    await _firestore.collection('subscription_plans').add({
      'name': plan.name,
      'description': plan.description,
      'price': plan.price,
      'duration': plan.duration,
      'features': plan.features,
    });
  }

  Future<void> updatePlan(SubscriptionPlanEntity plan) async {
    await _firestore.collection('subscription_plans').doc(plan.id).update({
      'name': plan.name,
      'description': plan.description,
      'price': plan.price,
      'duration': plan.duration,
      'features': plan.features,
    });
  }

  Future<void> deletePlan(String id) async {
    await _firestore.collection('subscription_plans').doc(id).delete();
  }
}

final firestoreSubscriptionRepositoryProvider =
    Provider<FirestoreSubscriptionRepository>((ref) {
      return FirestoreSubscriptionRepository(FirebaseFirestore.instance);
    });
