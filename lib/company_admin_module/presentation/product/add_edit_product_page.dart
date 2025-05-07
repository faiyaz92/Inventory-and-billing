import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_drop_down_widget.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class AddEditProductPage extends StatefulWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  _AddEditProductPageState createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  late ProductCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ProductCubit>();
    // Load categories
    if (widget.product != null) {
      _cubit.loadCategories(
          categoryId: widget.product!.categoryId,
          subCatId: widget.product!.subcategoryId);
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
    } else {
      _cubit.loadCategories();
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _cubit.selectedCategoryName ?? '',
        categoryId: _cubit.selectedCategoryId ?? '',
        subcategoryId: _cubit.selectedSubcategoryId ?? '',
        subcategoryName: _cubit.selectedSubcategoryName ?? '',
      );

      if (widget.product == null) {
        await _cubit.addProduct(product);
      } else {
        await _cubit.updateProduct(product);
      }

      sl<Coordinator>()
          .navigateBack(isUpdated: true); // Use Coordinator to go back
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter product name' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter price' : null,
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter stock' : null,
                ),
                BlocBuilder<ProductCubit, ProductState>(
                  buildWhen: (previous, current) => current is CategoriesLoaded,
                  builder: (context, state) {
                    if (state is CategoriesLoaded) {
                      // Extract category names and ensure no null or empty values
                      final List<String> categoryNames = state.categories
                          .where((category) =>
                              category.name != null &&
                              category
                                  .name!.isNotEmpty) // Filter out invalid names
                          .map((category) => category.name!)
                          .toList();

                      return CustomDropdown<String>(
                        selectedValue: state
                                    .selectedCategory?.name?.isNotEmpty ==
                                true
                            ? state.selectedCategory!
                                .name // Use selected category name if available
                            : null,
                        // Default to no selection if not found (e.g., during product creation)
                        items: categoryNames,
                        labelText: 'Category',
                        onChanged: (value) {
                          if (value != null) {
                            _cubit.selectCategory(
                                value); // Update selected category
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Select a category'
                            : null,
                      );
                    }
                    return const SizedBox
                        .shrink(); // Return an empty widget if the state isn't CategoriesLoaded
                  },
                ),
                BlocBuilder<ProductCubit, ProductState>(
                  buildWhen: (previous, current) =>
                      current is SubcategoriesLoaded,
                  builder: (context, state) {
                    if (state is SubcategoriesLoaded) {
                      // Safely filter and process subcategories
                      final subcategoryItems = state.subcategories
                          .where((subcategory) =>
                              subcategory.name != null &&
                              subcategory
                                  .name!.isNotEmpty) // Filter valid names
                          .map((subcategory) => subcategory.name!)
                          .toSet() // Ensure uniqueness
                          .toList();

                      // Handle selected subcategory name safely
                      final selectedSubcategoryName = state
                                  .selectedSubcategory?.name?.isNotEmpty ==
                              true
                          ? state.selectedSubcategory!
                              .name // Use selected subcategory name if valid
                          : null; // Default to no selection for add flow

                      return CustomDropdown<String>(
                        selectedValue: selectedSubcategoryName,
                        items:
                            subcategoryItems.isNotEmpty ? subcategoryItems : [],
                        // Ensure dropdown has valid items
                        labelText: 'Subcategory',
                        onChanged: (value) {
                          if (value != null) {
                            _cubit.selectSubcategory(
                                value); // Update subcategory in cubit
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Select a subcategory'
                            : null,
                      );
                    }
                    // Graceful fallback for invalid state
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Save Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
