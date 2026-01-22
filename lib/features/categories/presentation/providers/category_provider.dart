import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository.dart';
import '../../domain/entities/category_entity.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return FirestoreCategoryRepository(FirebaseFirestore.instance);
});

final categoriesProvider = StreamProvider<List<CategoryEntity>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories();
});

// Logic to check and seed defaults if empty
final checkAndSeedCategoriesProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  final currentCategories = await ref.read(categoriesProvider.future);

  if (currentCategories.isEmpty) {
    final defaultCategories = [
      const CategoryEntity(
        id: 'plumbing',
        name: 'Plumbing',
        iconName: 'plumbing',
        color: 0xFFE3F2FD,
      ),
      const CategoryEntity(
        id: 'electrical',
        name: 'Electrical',
        iconName: 'electrical_services',
        color: 0xFFFFF8E1,
      ),
      const CategoryEntity(
        id: 'cleaning',
        name: 'Cleaning',
        iconName: 'cleaning_services',
        color: 0xFFE8F5E9,
      ),
      const CategoryEntity(
        id: 'repair',
        name: 'Repair',
        iconName: 'construction',
        color: 0xFFFCE4EC,
      ),
      const CategoryEntity(
        id: 'ac',
        name: 'AC',
        iconName: 'ac_unit',
        color: 0xFFE0F7FA,
      ),
      const CategoryEntity(
        id: 'painting',
        name: 'Painting',
        iconName: 'format_paint',
        color: 0xFFF3E5F5,
      ),
    ];

    for (var cat in defaultCategories) {
      await repository.addCategory(cat);
    }
  }
});
