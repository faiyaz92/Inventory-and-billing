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
  List<Map<String, dynamic>> _stockEntries = []; // {productId, quantity, product}
  final TextEditingController _productSearchController = TextEditingController();
  bool _useBatchMode = true; // Toggle between batch and single-item mode
  bool _isStockAdded = false; // Flag to track user-initiated stock addition
  late StockCubit _stockCubit;
  late AdminProductCubit _productCubit;

  @override
  void initState() {
    _stockCubit = sl<StockCubit>()..fetchStock('');
    _productCubit = sl<AdminProductCubit>()..loadProducts();
    _stockEntries = []; // Ensure stock entries are empty on init
    _isStockAdded = false; // Initialize flag
    super.initState();
  }

  void _addToStockEntries(Product product, int quantity) {
    setState(() {
      final existingEntry = _stockEntries.firstWhere(
            (entry) => entry['productId'] == product.id,
        orElse: () => {'productId': product.id, 'quantity': 0, 'product': product},
      );
      if (!_stockEntries.contains(existingEntry)) {
        _stockEntries.add({
          'productId': product.id,
          'quantity': quantity,
          'product': product,
        });
      } else {
        _stockEntries = _stockEntries.map((entry) {
          if (entry['productId'] == product.id) {
            return {
              ...entry,
              'quantity': entry['quantity'] + quantity,
            };
          }
          return entry;
        }).toList();
      }
      _stockEntries.removeWhere((entry) => entry['quantity'] == 0);
      _productSearchController.clear(); // Clear search after adding
    });
  }

  void _updateStockEntryQuantity(String productId, int change) {
    setState(() {
      _stockEntries = _stockEntries.map((entry) {
        if (entry['productId'] == productId) {
          final newQuantity = (entry['quantity'] + change).clamp(0, 9999999);
          return {...entry, 'quantity': newQuantity};
        }
        return entry;
      }).toList();
      _stockEntries.removeWhere((entry) => entry['quantity'] == 0);
    });
  }

  void _clearStockEntry(String productId) {
    setState(() {
      _stockEntries.removeWhere((entry) => entry['productId'] == productId);
    });
  }

  Future<void> _showQuantityInputDialog(String productId, {int initialQuantity = 1}) async {
    final product = _stockEntries
        .firstWhere((entry) => entry['productId'] == productId, orElse: () => {})
        .isNotEmpty
        ? _stockEntries.firstWhere((entry) => entry['productId'] == productId)['product'] as Product
        : null;
    if (product == null) return;

    final TextEditingController quantityController =
    TextEditingController(text: initialQuantity.toString());
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Set Quantity for ${product.name}'),
        content: Form(
          key: _dialogFormKey,
          child: TextFormField(
            controller: quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            keyboardType: TextInputType.number,
            maxLength: 7,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a quantity';
              }
              final parsedValue = int.tryParse(value);
              if (parsedValue == null || parsedValue <= 0) {
                return 'Please enter a valid quantity';
              }
              if (parsedValue > 9999999) {
                return 'Quantity cannot exceed 7 digits';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_dialogFormKey.currentState!.validate()) {
                final quantity = int.parse(quantityController.text);
                setState(() {
                  _stockEntries = _stockEntries.map((entry) {
                    if (entry['productId'] == product.id) {
                      return {
                        ...entry,
                        'quantity': quantity,
                      };
                    }
                    return entry;
                  }).toList();
                  _stockEntries.removeWhere((entry) => entry['quantity'] == 0);
                });
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProductSelectionDialog() async {
    _productSearchController.clear();
    debugPrint('Dialog: Opening product selection dialog');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext dialogContext) {
        final ValueNotifier<List<Product>> filteredProducts = ValueNotifier([]);
        bool isDialogInitialized = false;
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext dialogContext, ScrollController scrollController) {
            return BlocBuilder<AdminProductCubit, ProductState>(
              bloc: _productCubit,
              buildWhen: (previous, current) =>
              current is ProductLoading || current is ProductError || current is ProductLoaded,
              builder: (BuildContext context, ProductState productState) {
                if (productState is ProductLoading) {
                  debugPrint('Dialog: Loading products');
                  return const Center(child: CircularProgressIndicator());
                } else if (productState is ProductError) {
                  debugPrint('Dialog: Error - ${productState.message}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${productState.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint('Dialog: Retrying product load');
                            _productCubit.loadProducts();
                          },
                          child: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (productState is ProductLoaded) {
                  final List<Product> products = productState.products;
                  debugPrint('Dialog: Loaded ${products.length} products');
                  if (!isDialogInitialized && filteredProducts.value.isEmpty && products.isNotEmpty) {
                    filteredProducts.value = List.from(products);
                    isDialogInitialized = true;
                    debugPrint('Dialog: Initialized filteredProducts with ${filteredProducts.value.length} items');
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.primary),
                              onPressed: () {
                                debugPrint('Dialog: Closing dialog');
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TextField(
                          controller: _productSearchController,
                          decoration: InputDecoration(
                            hintText: 'Search Products',
                            hintStyle: const TextStyle(color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.textSecondary, width: 0.3),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.textSecondary, width: 0.3),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (value) {
                            // debugPrint('Dialog: Searching for "$value"');
                            filteredProducts.value = [];
                            if (value.isEmpty) {
                              filteredProducts.value = List.from(products);
                            } else {
                              filteredProducts.value = products
                                  .where((product) =>
                                  product.name.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            }
                            // debugPrint('Dialog: Filtered ${filteredProducts.value.length} products');
                          },
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<List<Product>>(
                          valueListenable: filteredProducts,
                          builder: (context, products, child) {
                            if (products.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No products found',
                                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                                ),
                              );
                            }
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: products.length,
                              itemBuilder: (BuildContext dialogContext, int index) {
                                final product = products[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Price: ₹${product.price.toStringAsFixed(2)} | Stock: ${product.stock}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.add, color: AppColors.primary),
                                      onPressed: () {
                                        _addToStockEntries(product, 1);
                                        setState(() {
                                          _productSearchController.clear();
                                          filteredProducts.value = List.from(products);
                                        });
                                        debugPrint('Dialog: Added product "${product.name}"');
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                debugPrint('Dialog: Unexpected state ${productState.runtimeType}');
                return const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                );
              },
            );
          },
        );
      },
    );
    debugPrint('Dialog: Dialog closed');
  }

  Future<void> _saveBatchStock() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isStockAdded = true); // Set flag before adding stock
      for (final entry in _stockEntries) {
        final product = entry['product'] as Product;
        final stock = StockModel(
          id: '${product.id}_$_selectedStoreId',
          productId: product.id,
          storeId: _selectedStoreId!,
          quantity: entry['quantity'],
          lastUpdated: DateTime.now(),
          name: product.name,
          price: product.price,
          stock: null,
          category: product.category,
          categoryId: product.categoryId,
          subcategoryId: product.subcategoryId,
          subcategoryName: product.subcategoryName,
          tax: product.tax,
        );
        await _stockCubit.addStock(stock, product: product);
      }
    }
  }

  Widget _buildStockEntries() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock Entries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_stockEntries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No products selected',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
              )
            else
              ..._stockEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final product = item['product'] as Product;
                final quantity = item['quantity'] as int;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Price: ₹${product.price.toStringAsFixed(2)} | Quantity: $quantity',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _showQuantityInputDialog(product.id, initialQuantity: quantity),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: const Size(80, 28),
                                ),
                                child: const Text(
                                  'Manual Entry',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                onPressed: () => _clearStockEntry(product.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: const Size(80, 28),
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppColors.textSecondary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: quantity > 0
                                      ? AppColors.red
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _updateStockEntryQuantity(product.id, -1),
                              ),
                              SizedBox(
                                width: 48,
                                child: Text(
                                  '$quantity',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _updateStockEntryQuantity(product.id, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _stockCubit),
        BlocProvider.value(value: _productCubit), // Provide the same _productCubit instance
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Add Stock',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(_useBatchMode ? Icons.list : Icons.add_box),
                      onPressed: () {
                        setState(() {
                          _useBatchMode = !_useBatchMode;
                          _stockEntries = []; // Clear entries when switching modes
                          _selectedProductId = null;
                          _quantity = 0;
                          _isStockAdded = false; // Reset flag when switching modes
                        });
                      },
                      tooltip: _useBatchMode ? 'Switch to Single Mode' : 'Switch to Batch Mode',
                    ),
                    if (_stockEntries.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${_stockEntries.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: BlocConsumer<StockCubit, StockState>(
                        listener: (context, state) {
                          if (state is StockLoaded && _isStockAdded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(_useBatchMode
                                      ? 'Stock batch added successfully'
                                      : 'Stock added successfully')),
                            );
                            sl<Coordinator>().navigateBack(isUpdated: true);
                          } else if (state is StockError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(state.error),
                                  backgroundColor: AppColors.red),
                            );
                            setState(() => _isStockAdded = false); // Reset on error
                          }
                        },
                        builder: (context, state) {
                          if (state is StockLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is StockError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Error: ${state.error}',
                                      style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _stockCubit.fetchStock(''),
                                    child: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final stores = (state is StockLoaded) ? state.stores : [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Store Dropdown
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Store',
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.black87),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                              ),
                              const SizedBox(height: 16),
                              if (_useBatchMode) ...[
                                // Add Product Button
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: InkWell(
                                    onTap: () => _showProductSelectionDialog(),
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inventory, color: AppColors.primary),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add Products',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Stock Entries List
                                _buildStockEntries(),
                                const SizedBox(height: 24),
                                // Save Button for Batch Mode
                                ElevatedButton(
                                  onPressed: _stockEntries.isEmpty || _selectedStoreId == null
                                      ? null
                                      : () => _saveBatchStock(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    textStyle: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Save All Stock'),
                                ),
                              ] else ...[
                                // Single Item Form
                                BlocBuilder<AdminProductCubit, ProductState>(
                                  bloc: _productCubit, // Use _productCubit directly
                                  builder: (context, productState) {
                                    final products = productState is ProductLoaded
                                        ? productState.products
                                        : [];
                                    return Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Product',
                                            labelStyle: const TextStyle(
                                                fontWeight: FontWeight.bold, color: Colors.black87),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            contentPadding:
                                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Quantity',
                                        labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold, color: Colors.black87),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide.none),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final products = _productCubit.state is ProductLoaded
                                          ? (_productCubit.state as ProductLoaded).products
                                          : []; // Use _productCubit directly
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
                                        id: '${_selectedProductId}_$_selectedStoreId',
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
                                      setState(() => _isStockAdded = true); // Set flag before adding
                                      _stockCubit.addStock(stock, product: selectedProduct);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    textStyle: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text(AppLabels.saveButtonText),
                                ),
                              ],
                            ],
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

  @override
  void dispose() {
    _productSearchController.dispose();
    super.dispose();
  }
}