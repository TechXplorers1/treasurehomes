import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../subscriptions/data/repositories/firestore_subscription_repository.dart';
import '../../../subscriptions/data/repositories/mock_subscription_repository.dart';
import '../../../subscriptions/domain/entities/subscription_plan_entity.dart';
import 'add_edit_subscription_page.dart';

class AdminSubscriptionsPage extends ConsumerWidget {
  const AdminSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background uyghjgjhgf
      appBar: AppBar(
        title: const Text('Manage Subscriptions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(subscriptionPlansProvider),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'seed') {
                _seedDefaultPlans(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'seed',
                child: Text('Add Default Plans'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const AddEditSubscriptionPage(),
                ),
              )
              .then((_) => ref.invalidate(subscriptionPlansProvider));
        },
        label: const Text('Add Plan'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF1E2A47), // Dark blue
      ),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subscription plans found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + or use menu to add default plans',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    plan.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '\$${plan.price.toStringAsFixed(2)} / ${plan.duration}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFD4AF37), // Goldish
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditSubscriptionPage(plan: plan),
                                ),
                              )
                              .then(
                                (_) =>
                                    ref.invalidate(subscriptionPlansProvider),
                              );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, ref, plan);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _seedDefaultPlans(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(firestoreSubscriptionRepositoryProvider);

      final defaultPlans = [
        const SubscriptionPlanEntity(
          id: '', // Will be ignored by addPlan
          name: 'Basic Home Care',
          description:
              'Essential maintenance for your home. Perfect for apartments.',
          price: 29.99,
          duration: 'Monthly',
          features: [
            '1 Plumbing Check',
            '1 Electrical Check',
            '5% Discount on Services',
            'Basic Support',
          ],
        ),
        const SubscriptionPlanEntity(
          id: '',
          name: 'Premium Home Shield',
          description:
              'Complete peace of mind for your household. Most popular choice.',
          price: 49.99,
          duration: 'Monthly',
          features: [
            'Unlimited Checks',
            'Priority Booking',
            '15% Discount on Services',
            'Free Minor Repairs',
            '24/7 Emergency Support',
          ],
        ),
        const SubscriptionPlanEntity(
          id: '',
          name: 'Annual Value',
          description:
              'Best value for year-round protection. Get 2 months free!',
          price: 499.99,
          duration: 'Yearly',
          features: [
            'All Premium Features',
            '2 Months Free',
            'Dedicated Manager',
            'Free Annual Inspection',
          ],
        ),
      ];

      for (var plan in defaultPlans) {
        await repo.addPlan(plan);
      }

      ref.invalidate(subscriptionPlansProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default plans added successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding plans: $e')));
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlanEntity plan,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                final repo = ref.read(firestoreSubscriptionRepositoryProvider);
                await repo.deletePlan(plan.id);
                ref.invalidate(subscriptionPlansProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting plan: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
