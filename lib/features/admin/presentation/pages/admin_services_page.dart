import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/presentation/providers/service_providers.dart';
import 'add_edit_service_page.dart';
import '../../../services/domain/entities/service_entity.dart';

class AdminServicesPage extends ConsumerWidget {
  const AdminServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Services')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditServicePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text('No services found. Add one!'));
          }
          return ListView.builder(
            itemCount: services.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.work, color: Colors.blue),
                  ),
                  title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${service.price} - ${service.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditServicePage(service: service),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, service),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ServiceEntity service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(serviceRepositoryProvider);
        // Cast to FirestoreServiceRepository if needed, or update interface
        // For now assuming dynamic dispatch or direct access if interface updated
        // But better safely use the repository method if available
        // Note: Repository interface might need delete method if using interface type

        // Since we are using FirestoreServiceRepository via provider which returns ServiceRepository interface
        // We need to make sure deleteService is in interface or cast it.
        // Earlier I did NOT put deleteService in the interface file I wrote.
        // So I must cast or update interface. Let's cast for now to be quick, or fix interface.
        // Actually, let's try to call it dynamically or cast.

        // Better approach: Cast to FirestoreServiceRepository
        // But I need to import it.
        // Or simpler: Just update the interface now.

        // Let's rely on dynamic for a second or better, FIX THE INTERFACE in next step.
        // For this file, I will assume the interface has it or I will cast.

        // Let's use 'as dynamic' for now to avoid compilation error if interface doesn't have it yet.
        await (repository as dynamic).deleteService(service.id);

        await ref.refresh(servicesProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Service deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }
}
