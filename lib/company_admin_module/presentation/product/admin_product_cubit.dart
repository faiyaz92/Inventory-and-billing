import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/category_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/product_service.dart';

class AdminProductCubit extends Cubit<ProductState> {
  final ProductService productService;
  final CategoryService categoryService;

  List<Category> categoryList = [];
  List<Subcategory> subcategoryList = [];
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? selectedCategoryName;
  String? selectedSubcategoryName;

  AdminProductCubit({
    required this.productService,
    required this.categoryService,
  }) : super(ProductInitial());

  Future<void> loadCategories({String? categoryId, String? subCatId}) async {
    emit(ProductLoading());
    try {
      final categories = await categoryService.fetchCategories();
      categoryList = categories;

      Category? selectedCategory;

      if (categoryId != null) {
        selectedCategory = categoryList.firstWhere(
              (cat) => cat.id == categoryId,
          orElse: () => Category(id: null, name: null),
        );

        selectedCategoryId = selectedCategory.id;
        selectedCategoryName = selectedCategory.name;

        if (selectedCategory.id != null) {
          await loadSubcategories(selectedCategory.id!, subcategoryId: subCatId);
        }
      }

      emit(CategoriesLoaded(
          categories: categoryList, selectedCategory: selectedCategory));
    } catch (e) {
      emit(ProductError(message: 'Failed to load categories: $e'));
    }
  }

  Future<void> loadSubcategories(String categoryId, {String? subcategoryId}) async {
    emit(ProductLoading());
    try {
      final subcategories = await categoryService.fetchSubcategories(categoryId);
      subcategoryList = subcategories;

      if (subcategoryId != null) {
        final subcategory = subcategoryList.firstWhere(
              (subcat) => subcat.id == subcategoryId,
          orElse: () => Subcategory(id: null, name: null),
        );

        selectedSubcategoryId = subcategory.id;
        selectedSubcategoryName = subcategory.name;
        emit(ProductInitial());
        emit(SubcategoriesLoaded(
            subcategories: subcategoryList, selectedSubcategory: subcategory));
      } else {
        emit(SubcategoriesLoaded(subcategories: subcategoryList));
      }
    } catch (e) {
      emit(ProductError(message: 'Failed to load subcategories: $e'));
    }
  }

  void selectCategory(String categoryName) {
    final category = categoryList.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => Category(id: null, name: categoryName),
    );

    selectedCategoryId = category.id;
    selectedCategoryName = category.name;

    selectedSubcategoryId = null;
    selectedSubcategoryName = null;

    emit(CategorySelected(
      categoryId: category.id ?? '',
      categoryName: category.name ?? '',
    ));
    Future.delayed(const Duration(microseconds: 100), () {
      if (category.id != null) {
        loadSubcategories(category.id!);
      }
    });
  }

  void selectSubcategory(String subcategoryName) {
    final subcategory = subcategoryList.firstWhere(
          (subcat) => subcat.name == subcategoryName,
      orElse: () => Subcategory(id: null, name: subcategoryName),
    );

    selectedSubcategoryId = subcategory.id;
    selectedSubcategoryName = subcategory.name;

    emit(SubcategorySelected(
      subcategoryId: subcategory.id ?? '',
      subcategoryName: subcategory.name ?? '',
    ));
  }

  Future<void> addProduct(Product product) async {
    try {
      emit(ProductLoading());
      await productService.addNewProduct(product);
      emit(ProductAdded());
      await loadProducts();
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      emit(ProductLoading());
      await productService.editProduct(product);
      emit(ProductUpdated());
      await loadProducts();
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      emit(ProductLoading());
      await productService.removeProduct(productId);
      emit(ProductDeleted());
      await loadProducts();
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await productService.fetchProducts();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }
}