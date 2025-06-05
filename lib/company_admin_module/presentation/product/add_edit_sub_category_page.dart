import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class AddEditSubcategoryPage extends StatefulWidget {
  final Subcategory? subcategory; // If editing, subcategory will be passed
  final Category
      category; // Pass the entire category object instead of just categoryId

  const AddEditSubcategoryPage({
    Key? key,
    this.subcategory,
    required this.category,
  }) : super(key: key);

  @override
  _AddEditSubcategoryPageState createState() => _AddEditSubcategoryPageState();
}

class _AddEditSubcategoryPageState extends State<AddEditSubcategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final CategoryCubit _categoryCubit; // Declare _categoryCubit

  @override
  void initState() {
    super.initState();
    _categoryCubit =
        sl<CategoryCubit>(); // Initialize _categoryCubit using service locator

    if (widget.subcategory != null) {
      _nameController.text = widget.subcategory!.name ?? '';
    }
  }

  void _saveSubcategory() {
    if (_formKey.currentState!.validate()) {
      final subcategory = Subcategory(name: _nameController.text);

      if (widget.subcategory == null) {
        // Adding new subcategory
        _categoryCubit.addSubcategory(widget.category.id ?? '',
            subcategory); // Use manually initialized cubit
      } else {
        // Updating existing subcategory
        _categoryCubit.updateSubcategory(widget.category.id ?? '',
            widget.subcategory!.id ?? '', subcategory);
      }
      Navigator.pop(context); // Navigate back
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (_) => _categoryCubit,
      // Provide the cubit for future children widgets
      child: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.subcategory == null
                ? 'Add Subcategory'
                : 'Edit Subcategory'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Category: ${widget.category.name}', // Display category name
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Make the text prominent
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Subcategory Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter subcategory name' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveSubcategory,
                    child: Text(widget.subcategory == null
                        ? 'Add Subcategory'
                        : 'Update Subcategory'),
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
