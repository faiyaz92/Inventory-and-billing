import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String errorMessage;

  const CategoryError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class CategoryAdded extends CategoryState {
  final Category category;

  const CategoryAdded({required this.category});

  @override
  List<Object?> get props => [category];
}

class CategoryUpdated extends CategoryState {
  final Category updatedCategory;

  const CategoryUpdated({required this.updatedCategory});

  @override
  List<Object?> get props => [updatedCategory];
}

class SubcategoryAdded extends CategoryState {
  final Subcategory subcategory;

  const SubcategoryAdded({required this.subcategory});
}

class SubcategoryUpdated extends CategoryState {
  final Subcategory updatedSubcategory;

  const SubcategoryUpdated({required this.updatedSubcategory});
}

class SubcategoryDeleted extends CategoryState {
  final String subcategoryId;

  const SubcategoryDeleted({required this.subcategoryId});
}

class SubcategoryLoaded extends CategoryState {
  final List<Subcategory> subcategories;

  const SubcategoryLoaded({required this.subcategories});
}

class CategoryDeleted extends CategoryState {
  final String categoryId;

  CategoryDeleted({required this.categoryId});
}
