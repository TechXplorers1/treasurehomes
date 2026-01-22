import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../presentation/widgets/premium_card.dart';

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger seed if needed
    ref.watch(checkAndSeedCategoriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/categories/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: theme.disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return PremiumCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(category.color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(category.color).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getIconData(category.iconName),
                      color: Color(category.color),
                      size: 28,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'ID: ${category.id.substring(0, 8)}...',
                    style: TextStyle(color: theme.disabledColor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          context.push(
                            '/admin/categories/edit/${category.id}',
                            extra: category,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, ref, category.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
      'plumbing': Icons.plumbing,
      'electrical_services': Icons.electrical_services,
      'cleaning_services': Icons.cleaning_services,
      'construction': Icons.construction,
      'ac_unit': Icons.ac_unit,
      'format_paint': Icons.format_paint,
      'pest_control': Icons.pest_control,
      'yard': Icons.yard,
      'move_to_inbox': Icons.move_to_inbox,
      'home_repair_service': Icons.home_repair_service,
      'build': Icons.build,
      'brush': Icons.brush,
      'bug_report': Icons.bug_report,
      'grass': Icons.grass,
      'local_shipping': Icons.local_shipping,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
        ),
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

    if (confirm == true) {
      ref.read(categoryRepositoryProvider).deleteCategory(id);
    }
  }
}
