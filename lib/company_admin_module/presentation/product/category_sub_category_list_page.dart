import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class CategoriesWithSubcategoriesPage extends StatefulWidget {
  const CategoriesWithSubcategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesWithSubcategoriesPageState createState() =>
      _CategoriesWithSubcategoriesPageState();
}

class _CategoriesWithSubcategoriesPageState
    extends State<CategoriesWithSubcategoriesPage> {
  late CategoryCubit _categoryCubit;

  @override
  void initState() {
    super.initState();
    _categoryCubit = sl<CategoryCubit>();
    _categoryCubit.fetchCategories();
  }

  @override
  void dispose() {
    _categoryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (_) => _categoryCubit,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Categories and Subcategories',
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    sl<Coordinator>().navigateToAddEditCategoryPage();
                  },
                  tooltip: 'Add Category',
                ),
              ],
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
                child: _buildBody(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CategoryState state) {
    if (state is CategoryLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is CategoryLoaded) {
      final categories = state.categories;

      if (categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No categories available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  sl<Coordinator>().navigateToAddEditCategoryPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Add Category'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final subcategories = category.subcategories ?? [];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Header
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Semantics(
                    label: 'Category: ${category.name}',
                    child: Text(
                      category.name ?? 'Category',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54),
                        onPressed: () {
                          sl<Coordinator>().navigateToAddEditCategoryPage(category: category);
                        },
                        tooltip: 'Edit Category',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, category, true);
                        },
                        tooltip: 'Delete Category',
                      ),
                    ],
                  ),
                ),
                // Subcategories List
                if (subcategories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: subcategories.map((sub) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Semantics(
                            label: 'Subcategory: ${sub.name}',
                            child: Text(
                              sub.name ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.black54),
                                onPressed: () {
                                  sl<Coordinator>().navigateToAddEditSubcategoryPage(
                                    subcategory: sub,
                                    category: category,
                                  );
                                },
                                tooltip: 'Edit Subcategory',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(context, sub, false, categoryId: category.id ?? '');
                                },
                                tooltip: 'Delete Subcategory',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Add Subcategory Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      sl<Coordinator>().navigateToAddEditSubcategoryPage(category: category);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Add Subcategory'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _categoryCubit.fetchCategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic item, bool isCategory, {String? categoryId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          isCategory ? 'Delete Category' : 'Delete Subcategory',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${isCategory ? 'category' : 'subcategory'} "${item.name}"?',
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isCategory) {
                _categoryCubit.deleteCategory(item.id ?? '');
              } else {
                _categoryCubit.deleteSubcategory(categoryId!, item.id ?? '');
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}