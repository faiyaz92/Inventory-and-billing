import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';

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
    _categoryCubit.close();  // Close the cubit when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (_) => _categoryCubit,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is CategoryLoaded) {
            final categories = state.categories;

            if (categories.isEmpty) {
              // Show message if there are no categories
              return Scaffold(
                appBar: AppBar(
                  title: const Text("Categories and Subcategories"),
                ),
                body: const Center(
                  child: Text("Please add a category"),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    // Navigate to Add Category Page using Coordinator
                    sl<Coordinator>().navigateToAddEditCategoryPage();
                  },
                  child: const Icon(Icons.add),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text("Categories and Subcategories"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Navigate to Add Category Page using Coordinator
                      sl<Coordinator>().navigateToAddEditCategoryPage();
                    },
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  // Directly use subcategories from the category
                  final subcategories = category.subcategories;

                  return Card(
                    child: Column(
                      children: [
                        // Category Header
                        ListTile(
                          title: Text(category.name ?? 'Category'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Navigate to Edit Category Page using Coordinator
                                  sl<Coordinator>().navigateToAddEditCategoryPage(category: category);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Show delete confirmation
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Category'),
                                      content: const Text('Are you sure you want to delete this category?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            context.read<CategoryCubit>().deleteCategory( category.id ?? '');
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('No'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Subcategories List (Nested inside each Category)
                        if (subcategories != null && subcategories.isNotEmpty)
                          Column(
                            children: subcategories.map((sub) {
                              return ListTile(
                                title: Text(sub.name ?? ''),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Navigate to Edit Subcategory Page using Coordinator
                                        sl<Coordinator>().navigateToAddEditSubcategoryPage(
                                          subcategory: sub,
                                          category: category,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        context.read<CategoryCubit>().deleteSubcategory(
                                          category.id ?? '',
                                          sub.id ?? '',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        // Add Subcategory Button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Add Subcategory Page using Coordinator
                              sl<Coordinator>().navigateToAddEditSubcategoryPage(
                                category: category,
                              );
                            },
                            child: const Text('Add Subcategory'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: Text("Failed to load categories")),
            );
          }
        },
      ),
    );
  }
}

