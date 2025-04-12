import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/category_service.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryService categoryService;

  CategoryCubit({required this.categoryService}) : super(CategoryInitial());

  // Fetch Categories
  // Fetch Categories
  Future<void> fetchCategories() async {
    try {
      emit(CategoryLoading());
      final categories = await categoryService.fetchCategories();

      // Fetch subcategories for each category
      for (var category in categories) {
        final subcategories = await categoryService.fetchSubcategories( category.id ?? '');
        category.subcategories = subcategories;  // Assign fetched subcategories to the category
      }

      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to fetch categories: $e'));
    }
  }

  // Add Category
  Future<void> addCategory(Category category) async {
    try {
      emit(CategoryLoading());
      await categoryService.addCategory( category);
      emit(CategoryAdded(category: category));  // Category successfully added
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to add category: $e'));
    }
  }

  // Update Category
  Future<void> updateCategory( String id, Category category) async {
    try {
      emit(CategoryLoading());
      await categoryService.updateCategory(id, category);
      emit(CategoryUpdated(updatedCategory: category));  // Category successfully updated
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to update category: $e'));
    }
  }

  // Add Subcategory
  Future<void> addSubcategory( String categoryId, Subcategory subcategory) async {
    try {
      emit(CategoryLoading());
      await categoryService.addSubcategory( categoryId, subcategory);
      emit(SubcategoryAdded(subcategory: subcategory));  // Subcategory successfully added
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to add subcategory: $e'));
    }
  }

  // Delete Subcategory
  Future<void> deleteSubcategory( String categoryId, String subcategoryId) async {
    try {
      emit(CategoryLoading());
      await categoryService.deleteSubcategory( categoryId, subcategoryId);
      emit(SubcategoryDeleted(subcategoryId: subcategoryId));  // Subcategory successfully deleted
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to delete subcategory: $e'));
    }
  }

  // Update Subcategory
  Future<void> updateSubcategory( String categoryId, String subcategoryId, Subcategory subcategory) async {
    try {
      emit(CategoryLoading());
      await categoryService.updateSubcategory( categoryId, subcategoryId, subcategory);
      emit(SubcategoryUpdated(updatedSubcategory: subcategory));  // Subcategory successfully updated
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to update subcategory: $e'));
    }
  }
  Future<void> fetchSubcategories( String categoryId) async {
    try {
      emit(CategoryLoading());
      final subcategories = await categoryService.fetchSubcategories( categoryId);
      emit(SubcategoryLoaded(subcategories: subcategories));
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to fetch subcategories: $e'));
    }
  }
  Future<void> deleteCategory( String categoryId) async {
    try {
      emit(CategoryLoading());
      await categoryService.deleteCategory( categoryId);
      emit(CategoryDeleted(categoryId: categoryId));  // Category successfully deleted
    } catch (e) {
      emit(CategoryError(errorMessage: 'Failed to delete category: $e'));
    }
  }
}
