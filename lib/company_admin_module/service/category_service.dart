import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';

abstract class CategoryService {
  Future<void> addCategory(Category category); // Removed companyId
  Future<void> updateCategory(String id, Category category); // Removed companyId
  Future<List<Category>> fetchCategories(); // Removed companyId
  Future<void> addSubcategory(String categoryId, Subcategory subcategory); // Removed companyId
  Future<void> deleteSubcategory(String categoryId, String subcategoryId); // Removed companyId
  Future<void> updateSubcategory(String categoryId, String subcategoryId, Subcategory subcategory); // Removed companyId
  Future<List<Subcategory>> fetchSubcategories(String categoryId); // Removed companyId
  Future<void> deleteCategory(String categoryId); // Removed companyId
}
