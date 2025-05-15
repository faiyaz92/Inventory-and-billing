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

  List<Category> categoryList = []; // List of categories
  List<Subcategory> subcategoryList = []; // List of subcategories
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
      // Fetch categories
      final categories = await categoryService.fetchCategories();
      categoryList = categories;

      Category? selectedCategory;

      // Pre-select category if categoryId is provided (edit case)
      if (categoryId != null) {
        selectedCategory = categoryList.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => Category(id: null, name: null),
        );

        selectedCategoryId = selectedCategory.id;
        selectedCategoryName = selectedCategory.name;

        // Load subcategories for the selected category
        if (selectedCategory.id != null) {
          await loadSubcategories(selectedCategory.id!,
              subcategoryId: subCatId);
        }
      }

      emit(CategoriesLoaded(
          categories: categoryList, selectedCategory: selectedCategory));
    } catch (e) {
      emit(ProductError(message: 'Failed to load categories: $e'));
    }
  }

  Future<void> loadSubcategories(String categoryId,
      {String? subcategoryId}) async {
    emit(ProductLoading());
    try {
      // Fetch subcategories for the given category
      final subcategories =
          await categoryService.fetchSubcategories(categoryId);
      subcategoryList = subcategories;

      // If a subcategoryId is provided (edit case), set the selected subcategory
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
        emit(SubcategoriesLoaded(
          subcategories: subcategoryList,
        ));
      }
    } catch (e) {
      emit(ProductError(message: 'Failed to load subcategories: $e'));
    }
  }

  // Select category and reset subcategory
  void selectCategory(String categoryName) {
    // Find the category by matching the name
    final category = categoryList.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(
          id: null, name: categoryName), // Default to null if not found
    );

    // Update selected category ID and name
    selectedCategoryId = category.id;
    selectedCategoryName = category.name;

    // Reset subcategory when a new category is selected
    selectedSubcategoryId = null;
    selectedSubcategoryName = null;

    // Emit the new selected category state
    emit(CategorySelected(
      categoryId: category.id ?? '', // Send category ID, even if it's null
      categoryName: category.name ?? '', // Send category name
    ));
    Future.delayed(const Duration(microseconds: 100), () {
      if (category.id != null) {
        loadSubcategories(
            category.id!); // Load subcategories if category ID is valid
      }
    });
    // Load subcategories for the selected category
  }

  // Select subcategory by name
  void selectSubcategory(String subcategoryName) {
    // Find the subcategory by matching the name
    final subcategory = subcategoryList.firstWhere(
      (subcat) => subcat.name == subcategoryName,
      orElse: () => Subcategory(
          id: null, name: subcategoryName), // Default to null if not found
    );

    // Update selected subcategory ID and name
    selectedSubcategoryId = subcategory.id;
    selectedSubcategoryName = subcategory.name;

    // Emit the new selected subcategory state
    emit(SubcategorySelected(
      subcategoryId: subcategory.id ?? '',
      // Send subcategory ID, even if it's null
      subcategoryName: subcategory.name ?? '', // Send subcategory name
    ));
  }

  // Add product
  Future<void> addProduct(Product product) async {
    try {
      emit(ProductLoading());
      await productService.addNewProduct(product);
      emit(ProductAdded());
      await loadProducts(); // Refresh product list after adding
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      emit(ProductLoading());
      await productService.editProduct(product);
      emit(ProductUpdated());
      await loadProducts(); // Refresh product list after updating
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      emit(ProductLoading());
      await productService.removeProduct(productId);
      emit(ProductDeleted());
      await loadProducts(); // Refresh product list after deletion
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  // Fetch all products (optional based on your implementation)
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
