import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category; // If editing, category will be passed

  const AddEditCategoryPage({Key? key, this.category}) : super(key: key);

  @override
  _AddEditCategoryPageState createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final CategoryCubit _categoryCubit; // Declare _categoryCubit

  @override
  void initState() {
    super.initState();
    _categoryCubit = sl<CategoryCubit>();  // Initialize _categoryCubit using service locator

    if (widget.category != null) {
      _nameController.text = widget.category!.name ?? '';
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = Category(name: _nameController.text);

      if (widget.category == null) {
        // Adding new category
        _categoryCubit.addCategory(category);
      } else {
        // Updating existing category
        _categoryCubit.updateCategory(widget.category!.id ?? '', category);
      }
      Navigator.pop(context); // Navigate back
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (_) => _categoryCubit, // Provide _categoryCubit to this widget
      child: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                    validator: (value) => value!.isEmpty ? 'Enter category name' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: Text(widget.category == null ? 'Add Category' : 'Update Category'),
                  ),
                ],
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
    super.dispose();
  }
}
