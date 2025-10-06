import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  ProductLoaded({required this.products});
}

class ProductError extends ProductState {
  final String message;
  ProductError({required this.message});
}

class ProductAdded extends ProductState {}

class ProductUpdated extends ProductState {}

class ProductDeleted extends ProductState {}

class CategoriesLoaded extends ProductState {
  final List<Category> categories;
  final Category? selectedCategory;
  CategoriesLoaded({required this.categories, this.selectedCategory});
}

class SubcategoriesLoaded extends ProductState {
  final List<Subcategory> subcategories;
  final Subcategory? selectedSubcategory;
  SubcategoriesLoaded({required this.subcategories, this.selectedSubcategory});
}

class CategorySelected extends ProductState {
  final String categoryId;
  final String categoryName;
  final List<Category> categories;
  CategorySelected({
    required this.categoryId,
    required this.categoryName,
    this.categories = const [],
  });
}

class SubcategorySelected extends ProductState {
  final String subcategoryId;
  final String subcategoryName;
  final List<Subcategory> subcategories;
  SubcategorySelected({
    required this.subcategoryId,
    required this.subcategoryName,
    this.subcategories = const [],
  });
}