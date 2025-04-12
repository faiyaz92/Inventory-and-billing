import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

// ✅ Initial State
class ProductInitial extends ProductState {}

// ✅ Loading State
class ProductLoading extends ProductState {}

// ✅ Success State (Data Loaded)
class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

// ✅ Error State
class ProductError extends ProductState {
  final String message;
  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ✅ CRUD Operation Success States
class ProductAdded extends ProductState {}

class ProductUpdated extends ProductState {}

class ProductDeleted extends ProductState {}
class CategoriesLoaded extends ProductState {
  final List<Category> categories; // List of all categories
  final Category? selectedCategory; // Selected category object for edit

  const CategoriesLoaded({
    required this.categories,
    this.selectedCategory,
  });
}

class SubcategoriesLoaded extends ProductState {
  final List<Subcategory> subcategories; // List of all subcategories
  final Subcategory? selectedSubcategory; // Selected subcategory object for edit

  const SubcategoriesLoaded({
    required this.subcategories,
    this.selectedSubcategory,
  });
}
class CategorySelected extends ProductState {
  final String categoryId;
  final String categoryName;
  const CategorySelected({required this.categoryId, required this.categoryName});
}

class SubcategorySelected extends ProductState {
  final String subcategoryId;
  final String subcategoryName;
  const SubcategorySelected({required this.subcategoryId, required this.subcategoryName});
}