import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_state.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';

@RoutePage()
class AddEditCategoryPage extends StatefulWidget {
  final Category? category;

  const AddEditCategoryPage({Key? key, this.category}) : super(key: key);

  @override
  _AddEditCategoryPageState createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final CategoryCubit _categoryCubit;

  @override
  void initState() {
    super.initState();
    _categoryCubit = sl<CategoryCubit>();
    if (widget.category != null) {
      _nameController.text = widget.category!.name ?? '';
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      // Show custom loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CustomLoadingDialog(message: 'Wait...'),
      );

      final category = Category(name: _nameController.text);
      if (widget.category == null) {
        _categoryCubit.addCategory(category);
      } else {
        _categoryCubit.updateCategory(widget.category!.id ?? '', category);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryCubit>(
      create: (_) => _categoryCubit,
      child: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          // Close loading dialog if open
          if (state is CategoryLoading) return; // Keep dialog open during loading
          Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state is CategoryLoaded) {
            // Show success SnackBar and clear controller
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.category == null
                      ? 'Category added successfully'
                      : 'Category updated successfully',
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
            if (widget.category == null) {
              _nameController.clear(); // Clear controller only for add operation
            }
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: widget.category == null ? 'Add Category' : 'Edit Category',
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
                            // Category Name
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextFormField(
                                textCapitalization: TextCapitalization.words,
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Category Name',
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
                                value!.isEmpty ? 'Enter category name' : null,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Save Button
                            ElevatedButton(
                              onPressed: _saveCategory,
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
                              child: Text(widget.category == null
                                  ? 'Add Category'
                                  : 'Update Category'),
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}