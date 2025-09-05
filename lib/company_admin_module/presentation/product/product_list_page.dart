import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/admin_product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final Coordinator _coordinator = sl<Coordinator>();
  final TextEditingController _searchController = TextEditingController();
  final AdminProductCubit _cubit = sl<AdminProductCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminProductCubit>(
      create: (_) => _cubit..loadProducts(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Product List'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      // Search bar row
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _cubit.setSearchQuery('');
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        onChanged: (value) {
                          print('Search input: $value');
                          _cubit.setSearchQuery(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Filter row (Category and Subcategory)
                      Row(
                        children: [
                          Expanded(
                            child: BlocBuilder<AdminProductCubit, ProductState>(
                              bloc: _cubit,
                              buildWhen: (previous, current) =>
                              current is CategoriesLoaded || current is CategorySelected,
                              builder: (context, state) {
                                List<String> categoryNames = ['Select'];
                                if (state is CategoriesLoaded) {
                                  categoryNames.addAll(
                                    state.categories
                                        .where((cat) => cat.name != null)
                                        .map((cat) => cat.name!)
                                        .toSet()
                                        .toList(),
                                  );
                                } else if (state is CategorySelected) {
                                  categoryNames.addAll(
                                    state.categories
                                        .where((cat) => cat.name != null)
                                        .map((cat) => cat.name!)
                                        .toSet()
                                        .toList(),
                                  );
                                }
                                String? selectedCategory = _cubit.selectedCategoryName;
                                if (selectedCategory == null || !categoryNames.contains(selectedCategory)) {
                                  selectedCategory = 'Select';
                                }
                                print('Category Dropdown: items=$categoryNames, selected=$selectedCategory');
                                return DropdownButtonFormField<String>(
                                  value: selectedCategory,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10.0),
                                  ),
                                  items: categoryNames.map((name) {
                                    return DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontSize: 14.0),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    print('Category selected: $value');
                                    _cubit.selectCategory(value);
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BlocBuilder<AdminProductCubit, ProductState>(
                              buildWhen: (previous, current) =>
                              current is SubcategoriesLoaded || current is SubcategorySelected,
                              builder: (context, state) {
                                List<String> subcategoryNames = ['Select'];
                                if (state is SubcategoriesLoaded) {
                                  subcategoryNames.addAll(
                                    state.subcategories
                                        .where((subcat) => subcat.name != null)
                                        .map((subcat) => subcat.name!)
                                        .toSet()
                                        .toList(),
                                  );
                                } else if (state is SubcategorySelected) {
                                  subcategoryNames.addAll(
                                    state.subcategories
                                        .where((subcat) => subcat.name != null)
                                        .map((subcat) => subcat.name!)
                                        .toSet()
                                        .toList(),
                                  );
                                }
                                String? selectedSubcategory = _cubit.selectedSubcategoryName;
                                if (selectedSubcategory == null || !subcategoryNames.contains(selectedSubcategory)) {
                                  selectedSubcategory = 'Select';
                                }
                                print('Subcategory Dropdown: items=$subcategoryNames, selected=$selectedSubcategory');
                                return DropdownButtonFormField<String>(
                                  value: selectedSubcategory,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10.0),
                                  ),
                                  items: subcategoryNames.map((name) {
                                    return DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontSize: 14.0),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    print('Subcategory selected: $value');
                                    _cubit.selectSubcategory(value);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<AdminProductCubit, ProductState>(
                      buildWhen: (previous, current) =>
                      current is ProductLoading ||
                          current is ProductError ||
                          current is ProductLoaded,
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (state is ProductError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Error: ${state.message}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (state is ProductLoaded) {
                          if (state.products.isEmpty) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    _cubit.searchQuery.isNotEmpty ||
                                        _cubit.selectedCategoryId != null ||
                                        _cubit.selectedSubcategoryId != null
                                        ? 'No Products Match Your Search'
                                        : 'No Products Available',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: state.products.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: ListTile(
                                      title: Text(
                                        product.name ?? 'Unnamed Product',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'IQD ${product.price ?? 0}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _coordinator
                                                  .navigateToAddEditProductPage(
                                                  product: product)
                                                  .then((value) {
                                                if (value) {
                                                  _cubit.loadProducts();
                                                }
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _cubit.deleteProduct(product.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No Products Available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
          onPressed: () {
            _coordinator.navigateToAddEditProductPage();
          },
        ),
      ),
    );
  }
}