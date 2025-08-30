import 'dart:async';
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
  Timer? _debounce;

  List<Category> categoryList = [];
  List<Subcategory> subcategoryList = [];
  String? selectedCategoryId;
  String? selectedSubcategoryId;
  String? selectedCategoryName;
  String? selectedSubcategoryName;
  String searchQuery = '';
  List<Product> allProducts = [];

  AdminProductCubit({
    required this.productService,
    required this.categoryService,
  }) : super(ProductInitial());

  Future<void> loadCategories({String? categoryId, String? subCatId}) async {
    try {
      final categories = await categoryService.fetchCategories();
      categoryList = categories;
      print('loadCategories: Fetched ${categories.length} categories: ${categories.map((c) => c.name).toList()}');

      // Check for duplicate category names
      final nameCounts = <String, int>{};
      for (var cat in categories) {
        if (cat.name != null) {
          nameCounts[cat.name!] = (nameCounts[cat.name!] ?? 0) + 1;
        }
      }
      nameCounts.forEach((name, count) {
        if (count > 1) print('Duplicate category name: $name ($count occurrences)');
      });

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

      emit(CategoriesLoaded(categories: categoryList, selectedCategory: selectedCategory));
    } catch (e) {
      print('loadCategories error: $e');
      emit(ProductError(message: 'Failed to load categories: $e'));
    }
  }

  Future<void> loadSubcategories(String categoryId, {String? subcategoryId}) async {
    try {
      final subcategories = await categoryService.fetchSubcategories(categoryId);
      subcategoryList = subcategories;
      print('loadSubcategories: Fetched ${subcategories.length} subcategories for category $categoryId: ${subcategories.map((s) => s.name).toList()}');

      if (subcategoryId != null) {
        final subcategory = subcategoryList.firstWhere(
              (subcat) => subcat.id == subcategoryId,
          orElse: () => Subcategory(id: null, name: null),
        );

        selectedSubcategoryId = subcategory.id;
        selectedSubcategoryName = subcategory.name;
        emit(SubcategoriesLoaded(subcategories: subcategoryList, selectedSubcategory: subcategory));
      } else {
        emit(SubcategoriesLoaded(subcategories: subcategoryList));
      }
    } catch (e) {
      print('loadSubcategories error: $e');
      emit(ProductError(message: 'Failed to load subcategories: $e'));
    }
  }

  void selectCategory(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty || categoryName == 'Select') {
      selectedCategoryId = null;
      selectedCategoryName = null;
      selectedSubcategoryId = null;
      selectedSubcategoryName = null;
      subcategoryList = [];
      print('selectCategory: Reset to Select (null/empty/Select)');
      emit(CategorySelected(categoryId: '', categoryName: 'Select', categories: categoryList));
      filterProducts();
      return;
    }

    final category = categoryList.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => Category(id: null, name: null),
    );

    if (category.id == null || category.name == null) {
      selectedCategoryId = null;
      selectedCategoryName = null;
      selectedSubcategoryId = null;
      selectedSubcategoryName = null;
      subcategoryList = [];
      print('selectCategory: Invalid category "$categoryName", reset to Select');
      emit(CategorySelected(categoryId: '', categoryName: 'Select', categories: categoryList));
    } else {
      selectedCategoryId = category.id;
      selectedCategoryName = category.name;
      selectedSubcategoryId = null;
      selectedSubcategoryName = null;
      subcategoryList = [];
      print('selectCategory: Selected "$categoryName" (ID: ${category.id})');
      emit(CategorySelected(categoryId: category.id!, categoryName: category.name!, categories: categoryList));
      loadSubcategories(category.id!);
    }

    filterProducts();
  }

  void selectSubcategory(String? subcategoryName) {
    if (subcategoryName == null || subcategoryName.isEmpty || subcategoryName == 'Select') {
      selectedSubcategoryId = null;
      selectedSubcategoryName = null;
      print('selectSubcategory: Reset to Select (null/empty/Select)');
      emit(SubcategorySelected(subcategoryId: '', subcategoryName: 'Select', subcategories: subcategoryList));
      filterProducts();
      return;
    }

    final subcategory = subcategoryList.firstWhere(
          (subcat) => subcat.name == subcategoryName,
      orElse: () => Subcategory(id: null, name: null),
    );

    if (subcategory.id == null || subcategory.name == null) {
      selectedSubcategoryId = null;
      selectedSubcategoryName = null;
      print('selectSubcategory: Invalid subcategory "$subcategoryName", reset to Select');
      emit(SubcategorySelected(subcategoryId: '', subcategoryName: 'Select', subcategories: subcategoryList));
    } else {
      selectedSubcategoryId = subcategory.id;
      selectedSubcategoryName = subcategory.name;
      print('selectSubcategory: Selected "$subcategoryName" (ID: ${subcategory.id})');
      emit(SubcategorySelected(subcategoryId: subcategory.id!, subcategoryName: subcategory.name!, subcategories: subcategoryList));
    }

    filterProducts();
  }

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery = query.toLowerCase(); // Store query in lowercase for case-insensitive search
      print('setSearchQuery: Search query set to "$searchQuery"');
      emit(ProductInitial());
      filterProducts();
    });
  }

  void filterProducts() {
    print('filterProducts: Starting with allProducts.length=${allProducts.length}, '
        'searchQuery="$searchQuery", categoryId=$selectedCategoryId, subcategoryId=$selectedSubcategoryId');

    // Log product and category ID alignment
    print('Product categoryIds: ${allProducts.map((p) => p.categoryId).toSet()}');
    print('Category IDs: ${categoryList.map((c) => c.id).toSet()}');

    final filteredProducts = allProducts.where((product) {
      final matchesName = product.name != null && product.name!.toLowerCase().contains(searchQuery);
      final matchesCategory = selectedCategoryId == null || (product.categoryId != null && product.categoryId == selectedCategoryId);
      final matchesSubcategory = selectedSubcategoryId == null || (product.subcategoryId != null && product.subcategoryId == selectedSubcategoryId);
      print('filterProducts: Product "${product.name}" - matchesName: $matchesName, '
          'matchesCategory: $matchesCategory, matchesSubcategory: $matchesSubcategory');
      return matchesName && matchesCategory && matchesSubcategory;
    }).toList();

    print('filterProducts: Filtered ${filteredProducts.length} products: ${filteredProducts.map((p) => p.name).toList()}');
    emit(ProductLoaded(products: filteredProducts));
  }

  Future<void> addProduct(Product product) async {
    try {
      emit(ProductLoading());
      await productService.addNewProduct(product);
      emit(ProductAdded());
      await loadProducts();
    } catch (e) {
      print('addProduct error: $e');
      emit(ProductError(message: 'Failed to add product: $e'));
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      emit(ProductLoading());
      await productService.editProduct(product);
      emit(ProductUpdated());
      await loadProducts();
    } catch (e) {
      print('updateProduct error: $e');
      emit(ProductError(message: 'Failed to update product: $e'));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      emit(ProductLoading());
      await productService.removeProduct(productId);
      emit(ProductDeleted());
      await loadProducts();
    } catch (e) {
      print('deleteProduct error: $e');
      emit(ProductError(message: 'Failed to delete product: $e'));
    }
  }

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      allProducts = await productService.fetchProducts();
      print('loadProducts: Fetched ${allProducts.length} products: ${allProducts.map((p) => p.name).toList()}');
      if (allProducts.isEmpty) {
        print('loadProducts: Warning - No products returned from productService.fetchProducts()');
      }
      await loadCategories();
      filterProducts();
    } catch (e) {
      print('loadProducts error: $e');
      emit(ProductError(message: 'Failed to load products: $e'));
    }
  }

  void resetSelections() {
    selectedCategoryId = null;
    selectedCategoryName = null;
    selectedSubcategoryId = null;
    selectedSubcategoryName = null;
    subcategoryList = []; // Clear subcategory list to ensure dropdown is empty
    emit(CategoriesLoaded(categories: categoryList, selectedCategory: null));
  }
}