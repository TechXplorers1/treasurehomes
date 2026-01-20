import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../services/data/repositories/mock_service_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    // Categories Data
    final categories = [
      {'icon': Icons.plumbing, 'label': 'Plumbing'},
      {'icon': Icons.electrical_services, 'label': 'Electrical'},
      {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
      {'icon': Icons.construction, 'label': 'Remodeling'},
      {'icon': Icons.ac_unit, 'label': 'HVAC'},
      {'icon': Icons.more_horiz, 'label': 'More'},
    ];

    // Get services for search
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 35,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Text
                  Text(
                    'Hello, ${userState.value?.name ?? "Guest"}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for services...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : const Icon(Icons.tune),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Show search results if searching
                  if (_searchQuery.isNotEmpty)
                    servicesAsync.when(
                      data: (services) {
                        final filteredServices = services
                            .where((service) =>
                                service.name.toLowerCase().contains(_searchQuery) ||
                                service.description
                                    .toLowerCase()
                                    .contains(_searchQuery))
                            .toList();

                        if (filteredServices.isEmpty) {
                          return Column(
                            children: [
                              Text(
                                'Search Results',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text('No services found'),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search Results (${filteredServices.length})',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: filteredServices.length,
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];
                                  return _ServiceCard(
                                    service: service,
                                    onTap: () {
                                      context.push('/service/${service.id}');
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                      loading: () => Column(
                        children: [
                          Text(
                            'Search Results',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 24),
                        ],
                      ),
                      error: (error, stackTrace) => Column(
                        children: [
                          Text(
                            'Search Results',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(child: Text('Error: $error')),
                          const SizedBox(height: 24),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Services Section with All Services
                        Text(
                          'Services',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Categories Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return _CategoryCard(
                              icon: cat['icon'] as IconData,
                              label: cat['label'] as String,
                              onTap: () {
                                if (index == 5) {
                                  // More button - navigate to more services page
                                  context.push('/more-services');
                                } else if (index == 0) {
                                  context.push(
                                    '/service/2',
                                  ); // Plumbing -> Pipe Leakage Repair
                                } else if (index == 1) {
                                  context.push(
                                    '/service/4',
                                  ); // Electrical -> Switchboard Installation
                                } else if (index == 2) {
                                  context.push(
                                    '/service/3',
                                  ); // Cleaning -> Full House Cleaning
                                } else if (index == 3) {
                                  // Remodeling
                                  context
                                      .push('/service/5'); // Go to Home Remodeling
                                } else if (index == 4) {
                                  context.push('/service/1'); // HVAC -> AC Service
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // All Available Services Scrollable Grid
                        Text(
                          'All Services',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 320,
                          child: servicesAsync.when(
                            data: (services) {
                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: services.length,
                                itemBuilder: (context, index) {
                                  final service = services[index];
                                  return _ServiceCard(
                                    service: service,
                                    onTap: () {
                                      context.push('/service/${service.id}');
                                    },
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stackTrace) => Center(
                              child: Text('Error: $error'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Promotion/Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summer Maintenance Special',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Get 20% off on AC servicing this week only.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: theme.primaryColor,
                                ),
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recent Activity
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Card(
                          child: ListTile(
                            leading:
                                CircleAvatar(child: Icon(Icons.history)),
                            title: Text('Plumbing Repair'),
                            subtitle: Text('Completed on Jan 15'),
                            trailing: Text(
                              '\$45.00',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: theme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final dynamic service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image Placeholder
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${service.price.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        if (service.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                service.rating.toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
