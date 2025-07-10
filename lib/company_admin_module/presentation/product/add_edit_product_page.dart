import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/admin_product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
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
  final TextEditingController _taxController = TextEditingController();

  late AdminProductCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<AdminProductCubit>();
    if (widget.product != null) {
      _cubit.loadCategories(
          categoryId: widget.product!.categoryId,
          subCatId: widget.product!.subcategoryId);
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _taxController.text = widget.product!.tax.toString();
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
        tax: double.parse(_taxController.text),
      );

      if (widget.product == null) {
        await _cubit.addProduct(product);
      } else {
        await _cubit.updateProduct(product);
      }

      sl<Coordinator>().navigateBack(isUpdated: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.product == null ? 'Add Product' : 'Edit Product',
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Product Name
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Product Name',
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              validator: (value) =>
                              value!.isEmpty ? 'Enter product name' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Price
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Price',
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Enter price'
                                  : double.tryParse(value) == null ||
                                  double.parse(value) < 0
                                  ? 'Enter a valid price'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Stock
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _stockController,
                              decoration: InputDecoration(
                                labelText: 'Stock',
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Enter stock'
                                  : int.tryParse(value) == null ||
                                  int.parse(value) < 0
                                  ? 'Enter a valid stock'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tax
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _taxController,
                              decoration: InputDecoration(
                                labelText: 'Tax (%)',
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty
                                  ? 'Enter tax'
                                  : double.tryParse(value) == null ||
                                  double.parse(value) < 0
                                  ? 'Enter a valid tax percentage'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Category Dropdown
                          BlocBuilder<AdminProductCubit, ProductState>(
                            buildWhen: (previous, current) =>
                            current is CategoriesLoaded,
                            builder: (context, state) {
                              if (state is CategoriesLoaded) {
                                final List<String> categoryNames = state.categories
                                    .where((category) =>
                                category.name != null &&
                                    category.name!.isNotEmpty)
                                    .map((category) => category.name!)
                                    .toList();

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Category',
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      errorStyle: const TextStyle(color: Colors.red),
                                    ),
                                    value: state.selectedCategory?.name?.isNotEmpty == true
                                        ? state.selectedCategory!.name
                                        : null,
                                    items: categoryNames.map((name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    )).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        _cubit.selectCategory(value);
                                      }
                                    },
                                    validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Select a category'
                                        : null,
                                  ),
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                          const SizedBox(height: 16),
                          // Subcategory Dropdown
                          BlocBuilder<AdminProductCubit, ProductState>(
                            buildWhen: (previous, current) =>
                            current is SubcategoriesLoaded,
                            builder: (context, state) {
                              if (state is SubcategoriesLoaded) {
                                final subcategoryItems = state.subcategories
                                    .where((subcategory) =>
                                subcategory.name != null &&
                                    subcategory.name!.isNotEmpty)
                                    .map((subcategory) => subcategory.name!)
                                    .toSet()
                                    .toList();

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Subcategory',
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      errorStyle: const TextStyle(color: Colors.red),
                                    ),
                                    value: state.selectedSubcategory?.name?.isNotEmpty == true
                                        ? state.selectedSubcategory!.name
                                        : null,
                                    items: subcategoryItems.isNotEmpty
                                        ? subcategoryItems
                                        .map((name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    ))
                                        .toList()
                                        : [],
                                    onChanged: (value) {
                                      if (value != null) {
                                        _cubit.selectSubcategory(value);
                                      }
                                    },
                                    validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Select a subcategory'
                                        : null,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),
                          // Save Button
                          ElevatedButton(
                            onPressed: _saveProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Save Product'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
    _taxController.dispose();
    super.dispose();
  }
}