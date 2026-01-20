import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_plan_entity.dart';

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
        name: 'Basic Home Care',
        description: 'Essential maintenance for your home.',
        price: 29.99,
        duration: 'Monthly',
        features: [
          '1 Plumbing Check',
          '1 Electrical Check',
          '5% Discount on Services',
        ],
      ),
      SubscriptionPlanEntity(
        id: '2',
        name: 'Premium Home Shield',
        description: 'Complete peace of mind for your household.',
        price: 49.99,
        duration: 'Monthly',
        features: [
          'Unlimited Checks',
          'Priority Booking',
          '15% Discount on Services',
          'Free Minor Repairs',
        ],
      ),
      SubscriptionPlanEntity(
        id: '3',
        name: 'Annual Value',
        description: 'Best value for year-round protection.',
        price: 499.99,
        duration: 'Yearly',
        features: [
          'All Premium Features',
          '2 Months Free',
          'Dedicated Manager',
        ],
      ),
    ];
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return MockSubscriptionRepository();
});

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlanEntity>>((
  ref,
) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getPlans();
});
