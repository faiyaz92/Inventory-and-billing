import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/admin_product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';

@RoutePage()
class AddStockPage extends StatefulWidget {
  const AddStockPage({Key? key}) : super(key: key);

  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStoreId;
  String? _selectedProductId;
  int _quantity = 0;
  late StockCubit _stockCubit;
  late AdminProductCubit _productCubit;

  @override
  void initState() {
    _stockCubit = sl<StockCubit>()..fetchStock('');
    _productCubit = sl<AdminProductCubit>()..loadProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _stockCubit),
        BlocProvider(create: (_) => _productCubit),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Add Stock'),
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
                      child: BlocConsumer<StockCubit, StockState>(
                        listener: (context, state) {
                          // if (state is StockLoaded) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('Stock added successfully')),
                          //   );
                          //   sl<Coordinator>().navigateBack(isUpdated: true);
                          // } else if (state is StockError) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(content: Text(state.error), backgroundColor: AppColors.red),
                          //   );
                          // }
                        },
                        builder: (context, state) {
                          return BlocBuilder<StockCubit, StockState>(
                            buildWhen: (previous, current) {
                              if (previous.runtimeType == current.runtimeType) {
                                if (previous is StockLoaded && current is StockLoaded) {
                                  return previous.stores != current.stores ||
                                      previous.stockItems != current.stockItems;
                                }
                                if (previous is StockError && current is StockError) {
                                  return previous.error != current.error;
                                }
                                return false;
                              }
                              return true;
                            },
                            builder: (context, state) {
                              if (state is StockLoading) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (state is StockError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => _stockCubit.fetchStock(''),
                                        child: const Text('Retry'),
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
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final stores = (state is StockLoaded) ? state.stores : [];
                              final products = context.read<AdminProductCubit>().state is ProductLoaded
                                  ? (context.read<AdminProductCubit>().state as ProductLoaded).products
                                  : [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Store Dropdown
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Store',
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        errorStyle: const TextStyle(color: Colors.red),
                                      ),
                                      value: _selectedStoreId,
                                      items: stores.map((store) => DropdownMenuItem<String>(
                                        value: store.storeId,
                                        child: Text(store.name),
                                      )).toList(),
                                      onChanged: (value) => setState(() => _selectedStoreId = value),
                                      validator: (value) => value == null ? 'Please select a store' : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Product Dropdown
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Product',
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        errorStyle: const TextStyle(color: Colors.red),
                                      ),
                                      value: _selectedProductId,
                                      items: products.map((product) => DropdownMenuItem<String>(
                                        value: product.id,
                                        child: Text(product.name),
                                      )).toList(),
                                      onChanged: (value) => setState(() => _selectedProductId = value),
                                      validator: (value) => value == null ? 'Please select a product' : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Quantity
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Quantity',
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        errorStyle: const TextStyle(color: Colors.red),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => setState(() => _quantity = int.tryParse(value) ?? 0),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter quantity';
                                        }
                                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                          return 'Please enter a valid quantity';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Save Button
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        final selectedProduct = products.firstWhere(
                                              (product) => product.id == _selectedProductId,
                                          orElse: () => Product(
                                            id: _selectedProductId ?? '',
                                            name: '',
                                            price: 0.0,
                                            stock: 0,
                                            category: '',
                                            categoryId: '',
                                            subcategoryId: '',
                                            subcategoryName: '',
                                            tax: 0.0,
                                          ),
                                        );

                                        final stock = StockModel(
                                          id: '${_selectedProductId}_${_selectedStoreId}',
                                          productId: _selectedProductId!,
                                          storeId: _selectedStoreId!,
                                          quantity: _quantity,
                                          lastUpdated: DateTime.now(),
                                          name: selectedProduct.name,
                                          price: selectedProduct.price,
                                          stock: null,
                                          category: selectedProduct.category,
                                          categoryId: selectedProduct.categoryId,
                                          subcategoryId: selectedProduct.subcategoryId,
                                          subcategoryName: selectedProduct.subcategoryName,
                                          tax: selectedProduct.tax,
                                        );
                                        _stockCubit.addStock(stock, product: selectedProduct);
                                      }
                                    },
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
                                    child: const Text(AppLabels.saveButtonText),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
}