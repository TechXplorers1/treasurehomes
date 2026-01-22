import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}

class FirestoreCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore;

  FirestoreCategoryRepository(this._firestore);

  @override
  Stream<List<CategoryEntity>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryEntity.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    await _firestore
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await _firestore
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }
}
