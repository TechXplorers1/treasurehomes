import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import 'firestore_subscription_repository.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanEntity>> getPlans();
}

class MockSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<List<SubscriptionPlanEntity>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      SubscriptionPlanEntity(
        id: '1',
        name: 'Basic Home Care (Mock)',
        description: 'Essential maintenance for your home.',
        price: 29.99,
        duration: 'Monthly',
        features: [
          '1 Plumbing Check',
          '1 Electrical Check',
          '5% Discount on Services',
        ],
      ),
    ];
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return ref.watch(firestoreSubscriptionRepositoryProvider);
});

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlanEntity>>((
  ref,
) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getPlans();
});
