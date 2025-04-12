import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/categoryDto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category_dto.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

abstract class CategoryRepository {
  Future<void> addCategory(String companyId, CategoryDTO category);
  Future<void> updateCategory(String companyId, String id, CategoryDTO category);
  Future<List<CategoryDTO>> getCategories(String companyId);
  Future<void> deleteCategory(String companyId, String categoryId);
  Future<void> addSubcategory(String companyId, String categoryId, SubcategoryDTO subcategoryDTO);
  Future<void> updateSubcategory(String companyId, String categoryId, String subcategoryId, SubcategoryDTO subcategoryDTO);
  Future<void> deleteSubcategory(String companyId, String categoryId, String subcategoryId);
  Future<List<SubcategoryDTO>> getSubcategories(String companyId, String categoryId);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final IFirestorePathProvider firestorePathProvider;

  CategoryRepositoryImpl({
    required this.firestorePathProvider,
  });

  @override
  Future<void> addCategory(String companyId, CategoryDTO category) {
    return firestorePathProvider
        .getCategoryCollectionRef(companyId)
        .add(category.toFirestore());
  }

  @override
  Future<void> updateCategory(String companyId, String id, CategoryDTO category) {
    return firestorePathProvider
        .getCategoryCollectionRef(companyId)
        .doc(id)
        .update(category.toFirestore());
  }

  @override
  Future<List<CategoryDTO>> getCategories(String companyId) async {
    final snapshot = await firestorePathProvider.getCategoryCollectionRef(companyId).get();
    return snapshot.docs.map((doc) => CategoryDTO.fromFirestore(doc)).toList();
  }

  @override
  Future<void> deleteCategory(String companyId, String categoryId) async {
    try {
      await firestorePathProvider
          .getCategoryCollectionRef(companyId)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<void> addSubcategory(String companyId, String categoryId, SubcategoryDTO subcategoryDTO) async {
    await firestorePathProvider
        .getSubcategoryCollectionRef(companyId)
        .add({
      ...subcategoryDTO.toFirestore(),
      'categoryId': categoryId,
    });
  }

  @override
  Future<void> updateSubcategory(String companyId, String categoryId, String subcategoryId, SubcategoryDTO subcategoryDTO) async {
    await firestorePathProvider
        .getSubcategoryCollectionRef(companyId)
        .doc(subcategoryId)
        .update({
      ...subcategoryDTO.toFirestore(),
      'categoryId': categoryId,
    });
  }

  @override
  Future<void> deleteSubcategory(String companyId, String categoryId, String subcategoryId) async {
    await firestorePathProvider
        .getSubcategoryCollectionRef(companyId)
        .doc(subcategoryId)
        .delete();
  }

  @override
  Future<List<SubcategoryDTO>> getSubcategories(String companyId, String categoryId) async {
    final snapshot = await firestorePathProvider
        .getSubcategoryCollectionRef(companyId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => SubcategoryDTO.fromFirestore(doc)).toList();
  }
}