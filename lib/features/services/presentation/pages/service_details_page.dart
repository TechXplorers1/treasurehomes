import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/service_entity.dart';

import '../../data/repositories/mock_service_repository.dart';

class ServiceDetailsPage extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ideally use a FutureProviderFamily to fetch specific service, but we can filter from the list or fetch directly
    // For simplicity, let's just get everything and find it, or use a new provider.
    // Let's assume we pass the object or ID. Using ID is safer for deep links.
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: servicesAsync.when(
        data: (services) {
          final service = services.firstWhere(
            (s) => s.id == serviceId,
            orElse: () => const ServiceEntity(
              id: '0',
              name: 'Not Found',
              description: '',
              price: 0,
              category: '',
            ),
          );

          if (service.id == '0') {
            return const Center(child: Text('Service not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image (Placeholder)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '\$${service.price}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 20, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text('${service.rating ?? 0.0} (120 reviews)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(service.description),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/book_service',
                              extra: {
                                'serviceId': service.id,
                                'serviceName': service.name,
                                'price': service.price,
                              },
                            );
                          },
                          child: const Text('Book This Service'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
