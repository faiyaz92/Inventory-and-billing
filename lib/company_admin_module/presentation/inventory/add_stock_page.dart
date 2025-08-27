import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/admin_product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/purchase/purchase_order_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';

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
  final TextEditingController _supplierSearchController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _finalAmountController = TextEditingController();
  final TextEditingController _billNumberController = TextEditingController();
  final TextEditingController _amountReceivedController = TextEditingController();
  bool _useBatchMode = true; // Toggle between batch and single-item mode
  bool _isStockAdded = false; // Flag to track user-initiated stock addition
  bool _isLoading = false;
  UserInfo? _selectedSupplier;
  String? _selectedPurchaseType = 'Cash';
  late StockCubit _stockCubit;
  late AdminProductCubit _productCubit;
  late AdminPurchaseCubit _purchaseCubit;
  late UserLedgerCubit _ledgerCubit;
  final UserServices _userServices = sl<UserServices>();
  final AccountRepository _accountRepository = sl<AccountRepository>();

  @override
  void initState() {
    _stockCubit = sl<StockCubit>()..fetchStock('');
    _productCubit = sl<AdminProductCubit>()..loadProducts();
    _purchaseCubit = sl<AdminPurchaseCubit>();
    _ledgerCubit = sl<UserLedgerCubit>();
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
          'taxRate': product.tax,
          'taxAmount': product.price * quantity * (product.tax / 100),
        });
      } else {
        _stockEntries = _stockEntries.map((entry) {
          if (entry['productId'] == product.id) {
            final newQuantity = entry['quantity'] + quantity;
            return {
              ...entry,
              'quantity': newQuantity,
              'taxAmount': product.price * newQuantity * (product.tax / 100),
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
          final product = entry['product'] as Product;
          final newQuantity = (entry['quantity'] + change).clamp(0, 9999999);
          return {
            ...entry,
            'quantity': newQuantity,
            'taxAmount': product.price * newQuantity * (product.tax / 100),
          };
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

    final TextEditingController quantityController = TextEditingController(text: initialQuantity.toString());
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
                        'taxAmount': product.price * quantity * (product.tax / 100),
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

  Future<void> _showSupplierSelectionDialog() async {
    List<UserInfo> suppliers = [];
    List<UserInfo> _filteredSuppliers = [];
    bool _isLoadingDialog = false;

    print('DEBUG: Entering _showSupplierSelectionDialog');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) {
          print('DEBUG: Building supplier selection dialog, suppliers.length: ${suppliers.length}, _isLoadingDialog: $_isLoadingDialog');

          if (suppliers.isEmpty && !_isLoadingDialog) {
            print('DEBUG: Suppliers empty and not loading, initiating fetch');
            setStateDialog(() => _isLoadingDialog = true);
            _userServices.getUsersFromTenantCompany().then((users) {
              print('DEBUG: Fetched users from tenant company, total users: ${users.length}');
              suppliers = users.where((u) => u.userType == UserType.Supplier).toList();
              print('DEBUG: Filtered suppliers, count: ${suppliers.length}');
              _filteredSuppliers = suppliers;
              print('DEBUG: Updated _filteredSuppliers, count: ${_filteredSuppliers.length}');
              setStateDialog(() {
                _isLoadingDialog = false;
                print('DEBUG: Set _isLoadingDialog to false');
              });
            }).catchError((error) {
              print('DEBUG: Error fetching users: $error');
              setStateDialog(() {
                _isLoadingDialog = false;
                print('DEBUG: Set _isLoadingDialog to false after error');
              });
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (BuildContext dialogContext, ScrollController scrollController) {
              print('DEBUG: Building DraggableScrollableSheet, _isLoadingDialog: $_isLoadingDialog, _filteredSuppliers.length: ${_filteredSuppliers.length}');
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Supplier',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.primary),
                          onPressed: () {
                            print('DEBUG: Close button pressed');
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_isLoadingDialog)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _supplierSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search Suppliers',
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
                          print('DEBUG: Search query changed: $value');
                          setStateDialog(() {
                            _filteredSuppliers = suppliers
                                .where((supplier) =>
                                supplier.userName!.toLowerCase().contains(value.toLowerCase()))
                                .toList();
                            print('DEBUG: Filtered suppliers after search, count: ${_filteredSuppliers.length}');
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredSuppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = _filteredSuppliers[index];
                          print('DEBUG: Building ListTile for supplier: ${supplier.userName}, index: $index');
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              title: Text(
                                supplier.name ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                print('DEBUG: Selected supplier: ${supplier.userName}');
                                setState(() {
                                  _selectedSupplier = supplier;
                                });
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _supplierNameController,
                            decoration: InputDecoration(
                              labelText: 'New Supplier Name',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (_supplierNameController.text.isNotEmpty) {
                                print('DEBUG: Add New Supplier button pressed, name: ${_supplierNameController.text}');
                                final userInfo = await _accountRepository.getUserInfo();
                                print('DEBUG: Fetched userInfo, companyId: ${userInfo?.companyId}');
                                final newSupplier = UserInfo(
                                  userName: _supplierNameController.text,
                                  userType: UserType.Supplier,
                                  companyId: userInfo?.companyId,
                                  userId: DateTime.now().millisecondsSinceEpoch.toString(),
                                );
                                await _userServices.addUserToCompany(newSupplier, '');
                                print('DEBUG: Added new supplier: ${newSupplier.userName}');
                                suppliers = await _userServices.getUsersFromTenantCompany();
                                print('DEBUG: Refetched suppliers, count: ${suppliers.length}');
                                _filteredSuppliers = suppliers.where((u) => u.userType == UserType.Supplier).toList();
                                print('DEBUG: Updated _filteredSuppliers, count: ${_filteredSuppliers.length}');
                                setStateDialog(() {});
                                _supplierNameController.clear();
                                print('DEBUG: Cleared supplierNameController');
                              } else {
                                print('DEBUG: Add New Supplier button pressed, but supplier name is empty');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Add New Supplier'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
    print('DEBUG: Supplier selection dialog closed');
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
                            filteredProducts.value = [];
                            if (value.isEmpty) {
                              filteredProducts.value = List.from(products);
                            } else {
                              filteredProducts.value = products
                                  .where((product) => product.name.toLowerCase().contains(value.toLowerCase()))
                                  .toList();
                            }
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Price: ₹${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                        ),
                                        Text(
                                          'Tax: ${product.tax.toStringAsFixed(0)}%',
                                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                        ),
                                        if (product.category.isNotEmpty)
                                          Text(
                                            'Category: ${product.category}',
                                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                          ),
                                        if (product.subcategoryName.isNotEmpty)
                                          Text(
                                            'Subcategory: ${product.subcategoryName}',
                                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                          ),
                                      ],
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

  Future<bool> _showReviewDialog() async {
    double subtotal = 0.0;
    double totalTax = 0.0;
    _stockEntries.forEach((entry) {
      final product = entry['product'] as Product;
      final quantity = entry['quantity'] as int;
      subtotal += product.price * quantity;
      totalTax += (product.price * quantity) * (product.tax / 100);
    });
    final calculatedTotal = subtotal + totalTax;
    _finalAmountController.text = calculatedTotal.toStringAsFixed(2);
    _billNumberController.text = 'BILL-${DateTime.now().millisecondsSinceEpoch}';
    _amountReceivedController.text = _selectedPurchaseType == 'Cash' ? calculatedTotal.toStringAsFixed(2) : '0.0';

    final _dialogFormKey = GlobalKey<FormState>();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 800 ? 600 : MediaQuery.of(context).size.width * 0.9,
            minWidth: 300,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.white,
            contentPadding: const EdgeInsets.all(0),
            title: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Review Purchase',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.pop(dialogContext, false),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _dialogFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow('Supplier', _selectedSupplier?.name ?? 'None'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Store', _selectedStoreId ?? 'None'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Purchase Type', _selectedPurchaseType ?? 'None'),
                        ],
                      ),
                    ),
                    // Stock Entries Table
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          border: TableBorder(
                            verticalInside: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                            horizontalInside: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                          ),
                          children: [
                            // Table Header
                            TableRow(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                              ),
                              children: [
                                _buildTableCell('Product', isHeader: true),
                                _buildTableCell('Qty', isHeader: true, align: TextAlign.center),
                                _buildTableCell('Subtotal', isHeader: true, align: TextAlign.right),
                                _buildTableCell('Tax', isHeader: true, align: TextAlign.right),
                              ],
                            ),
                            // Table Rows for Stock Entries
                            ..._stockEntries.map((entry) {
                              final product = entry['product'] as Product;
                              final quantity = entry['quantity'] as int;
                              final itemSubtotal = product.price * quantity;
                              final itemTax = itemSubtotal * (product.tax / 100);
                              return TableRow(
                                children: [
                                  _buildTableCell(product.name),
                                  _buildTableCell(quantity.toString(), align: TextAlign.center),
                                  _buildTableCell('₹${itemSubtotal.toStringAsFixed(2)}', align: TextAlign.right),
                                  _buildTableCell('₹${itemTax.toStringAsFixed(2)}', align: TextAlign.right),
                                ],
                              );
                            }).toList(),
                            // Total Row
                            TableRow(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              ),
                              children: [
                                _buildTableCell('Total', isHeader: true),
                                _buildTableCell('', align: TextAlign.center),
                                _buildTableCell('₹${subtotal.toStringAsFixed(2)}', isHeader: true, align: TextAlign.right),
                                _buildTableCell('₹${totalTax.toStringAsFixed(2)}', isHeader: true, align: TextAlign.right),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Form Fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _finalAmountController,
                            decoration: _buildInputDecoration('Final Amount'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter final amount';
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) return 'Please enter a valid amount';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _billNumberController,
                            decoration: _buildInputDecoration('Bill Number'),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter bill number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_selectedPurchaseType == 'Cash') ...[
                            TextFormField(
                              controller: _amountReceivedController,
                              decoration: _buildInputDecoration('Initial Payment (Fixed)'),
                              keyboardType: TextInputType.number,
                              enabled: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter a valid amount';
                                final parsed = double.tryParse(value);
                                if (parsed == null || parsed <= 0) return 'Please enter a valid amount';
                                return null;
                              },
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _amountReceivedController,
                              decoration: _buildInputDecoration('Initial Payment (Optional)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                final parsed = double.tryParse(value);
                                if (parsed == null || parsed < 0) return 'Please enter a valid amount';
                                if (parsed > double.parse(_finalAmountController.text)) {
                                  return 'Initial payment cannot exceed final amount';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final amountReceived = double.tryParse(_amountReceivedController.text) ?? 0.0;
                              final payableAmount = double.parse(_finalAmountController.text) - amountReceived;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Payable Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '₹${payableAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_dialogFormKey.currentState!.validate()) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

// Helper method to build summary row
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

// Helper method to build table cell
  Widget _buildTableCell(String text, {bool isHeader = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: isHeader ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

// Helper method to build input decoration
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _saveStock() async {
    if (_formKey.currentState!.validate() && _selectedSupplier != null && _selectedPurchaseType != null) {
      print('DEBUG: _saveStock called, mode: ${_useBatchMode ? "Batch" : "Single"}, purchaseType: $_selectedPurchaseType');

      // Validate and set _stockEntries for single-entry mode
      if (!_useBatchMode) {
        final products = _productCubit.state is ProductLoaded
            ? (_productCubit.state as ProductLoaded).products
            : [];
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
        if (selectedProduct.id.isEmpty) {
          print('DEBUG: Invalid product selected in single mode');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid product selected')),
          );
          return;
        }
        _stockEntries = [
          {
            'productId': selectedProduct.id,
            'quantity': _quantity,
            'product': selectedProduct,
            'taxRate': selectedProduct.tax,
            'taxAmount': selectedProduct.price * _quantity * (selectedProduct.tax / 100),
          }
        ];
        print('DEBUG: Single mode _stockEntries set, product: ${selectedProduct.name}, quantity: $_quantity');
      }

      if (_stockEntries.isEmpty) {
        print('DEBUG: No stock entries to save');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products selected')),
        );
        return;
      }

      final confirmed = await _showReviewDialog();
      if (!confirmed) {
        print('DEBUG: Review dialog cancelled');
        return;
      }

      setState(() => _isLoading = true);
      print('DEBUG: Set _isLoading to true');

      try {
        final userInfo = await _accountRepository.getUserInfo();
        final companyId = userInfo?.companyId ?? '';
        final userId = userInfo?.userId ?? '';
        final billNumber = _billNumberController.text;
        final finalAmount = double.parse(_finalAmountController.text);
        final amountReceived = double.tryParse(_amountReceivedController.text) ?? 0.0;

        print('DEBUG: userInfo.companyId: $companyId, userId: $userId, billNumber: $billNumber, finalAmount: $finalAmount, amountReceived: $amountReceived');

        final paymentStatus = amountReceived >= finalAmount
            ? 'Paid'
            : amountReceived > 0
            ? 'Partial Paid'
            : 'Not Paid';
        final paymentDetails = amountReceived > 0
            ? [
          {
            'date': DateTime.now(),
            'amount': amountReceived,
            'method': 'Cash',
          }
        ]
            : null;

        print('DEBUG: paymentStatus: $paymentStatus, paymentDetails: $paymentDetails');

        // Ensure ledgers
        final supplierLedgerId = _selectedSupplier!.accountLedgerId ??
            await _ledgerCubit.ensureLedger(_selectedSupplier!.userId!, UserType.Supplier, _selectedSupplier!);
        final store = (await sl<StockRepository>().getStores(companyId))
            .firstWhere((s) => s.storeId == _selectedStoreId, orElse: () => StoreDto(storeId: '', name: '', createdBy: '', createdAt: DateTime.now()));
        final storeLedgerId = store.accountLedgerId ??
            await _ledgerCubit.ensureLedgerForStore(_selectedStoreId!, store);


        // Create purchase items
        final purchaseItems = _stockEntries.map((entry) {
          final product = entry['product'] as Product;
          final quantity = entry['quantity'] as int;
          return PurchaseItem(
            productId: product.id,
            productName: product.name,
            price: product.price,
            quantity: quantity,
            taxRate: product.tax,
            taxAmount: (product.price * quantity) * (product.tax / 100),
          );
        }).toList();

        print('DEBUG: Created ${purchaseItems.length} purchase items');

        // Create purchase order
        final purchaseOrder = AdminPurchaseOrder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          supplierId: _selectedSupplier!.userId!,
          supplierName: _selectedSupplier!.userName ?? 'Unknown',
          items: purchaseItems,
          totalAmount: finalAmount,
          discount: 0.0,
          status: 'pending',
          orderDate: DateTime.now(),
          storeId: _selectedStoreId,
          billNumber: billNumber,
          invoiceLastUpdatedBy: userId,
          invoiceGeneratedDate: DateTime.now(),
          purchaseType: _selectedPurchaseType,
          paymentStatus: paymentStatus,
          amountReceived: amountReceived,
          paymentDetails: paymentDetails,
          supplierLedgerId: supplierLedgerId as String,
          storeLedgerId: storeLedgerId as String,
        );

        print('DEBUG: Saving purchase order: ${purchaseOrder.id}');
        await _purchaseCubit.createPurchaseOrder(purchaseOrder);
        print('DEBUG: Purchase order saved');

        // Add stock
        for (var entry in _stockEntries) {
          final product = entry['product'] as Product;
          final quantity = entry['quantity'] as int;
          final stock = StockModel(
            id: '${product.id}_$_selectedStoreId',
            productId: product.id,
            storeId: _selectedStoreId!,
            quantity: quantity,
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
          print('DEBUG: Added stock for product: ${product.name}, quantity: $quantity');
        }

        // Ledger entries for supplier
        // Always add Credit for purchase
        await _ledgerCubit.addTransaction(
          ledgerId: supplierLedgerId,
          amount: finalAmount,
          type: 'Credit',
          billNumber: billNumber,
          purpose: 'Purchase stock',
          typeOfPurpose: _selectedPurchaseType,
          remarks: 'Purchase order ${purchaseOrder.id}',
          userType: UserType.Supplier,
        );
        print('DEBUG: Added Credit transaction to supplier ledger: $finalAmount, purpose: Purchase stock, billNumber: $billNumber');

        if (_selectedPurchaseType == 'Cash' && amountReceived > 0) {
          // For cash payments, add Debit for payment
          await _ledgerCubit.addTransaction(
            ledgerId: supplierLedgerId,
            amount: amountReceived,
            type: 'Debit',
            billNumber: billNumber,
            purpose: 'Cash payment for purchased stock',
            typeOfPurpose: 'Cash',
            remarks: 'Purchase order ${purchaseOrder.id}',
            userType: UserType.Supplier,
          );
          print('DEBUG: Added Debit transaction to supplier ledger: $amountReceived, purpose: Cash payment for purchased stock, billNumber: $billNumber');
        }

        // Ledger entries for store (mirror entries)
        // Always add Debit for purchase
        await _ledgerCubit.addTransaction(
          ledgerId: storeLedgerId,
          amount: finalAmount,
          type: 'Debit',
          billNumber: billNumber,
          purpose: 'Purchase stock',
          typeOfPurpose: _selectedPurchaseType,
          remarks: 'Purchase order ${purchaseOrder.id}',
          userType: UserType.Store,
        );
        print('DEBUG: Added Debit transaction to store ledger: $finalAmount, purpose: Purchase stock, billNumber: $billNumber');

        if (_selectedPurchaseType == 'Cash' && amountReceived > 0) {
          // For cash payments, add Credit for payment
          await _ledgerCubit.addTransaction(
            ledgerId: storeLedgerId,
            amount: amountReceived,
            type: 'Credit',
            billNumber: billNumber,
            purpose: 'Cash payment for purchased stock',
            typeOfPurpose: 'Cash',
            remarks: 'Purchase order ${purchaseOrder.id}',
            userType: UserType.Store,
          );
          print('DEBUG: Added Credit transaction to store ledger: $amountReceived, purpose: Cash payment for purchased stock, billNumber: $billNumber');
        }

        // Verify ledger balance for debugging
        if (_selectedPurchaseType == 'Cash' && amountReceived >= finalAmount) {
          print('DEBUG: Cash payment fully paid, expected supplier ledger balance: 0');
          print('DEBUG: Cash payment fully paid, expected store ledger balance: 0');
        } else if (_selectedPurchaseType == 'Cash' && amountReceived > 0) {
          print('DEBUG: Partial cash payment, expected supplier ledger balance: ${finalAmount - amountReceived}');
          print('DEBUG: Partial cash payment, expected store ledger balance: ${finalAmount - amountReceived}');
        } else if (_selectedPurchaseType == 'Credit') {
          print('DEBUG: Credit payment, expected supplier ledger balance: $finalAmount');
          print('DEBUG: Credit payment, expected store ledger balance: $finalAmount');
        }

        setState(() => _isStockAdded = true);
        print('DEBUG: Set _isStockAdded to true');
      } catch (e) {
        print('DEBUG: Error in _saveStock: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      } finally {
        setState(() => _isLoading = false);
        print('DEBUG: Set _isLoading to false');
      }
    } else {
      print('DEBUG: Validation failed or missing supplier/purchase type');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }
  Widget _buildStockEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Stock Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_stockEntries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            final subtotal = product.price * quantity;
            final taxAmount = item['taxAmount'] as double;
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Price: ₹${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                              Text(
                                'Tax Rate: ${product.tax.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      color: quantity > 0 ? AppColors.red : AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => _updateStockEntryQuantity(product.id, -1),
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
                                    icon: const Icon(Icons.add, color: AppColors.green, size: 20),
                                    onPressed: () => _updateStockEntryQuantity(product.id, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showQuantityInputDialog(product.id, initialQuantity: quantity),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: const Text(
                                    'Enter Manual Qty',
                                    style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _clearStockEntry(product.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (quantity > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Table(
                          border: TableBorder(
                            verticalInside: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                            horizontalInside: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    'Subtotal (₹${product.price.toStringAsFixed(2)} x $quantity)',
                                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    '₹${subtotal.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    'Tax (${product.tax.toStringAsFixed(0)}%)',
                                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    '₹${taxAmount.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    'Total',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    '₹${(subtotal + taxAmount).toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _stockCubit),
        BlocProvider.value(value: _productCubit),
        BlocProvider.value(value: _purchaseCubit),
        BlocProvider.value(value: _ledgerCubit),
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
                          _stockEntries = [];
                          _selectedProductId = null;
                          _quantity = 0;
                          _isStockAdded = false;
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
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
        body: _isLoading
            ? const CustomLoadingDialog(message: 'Saving...')
            : Container(
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
                                    : 'Stock added successfully'),
                              ),
                            );
                            sl<Coordinator>().navigateBack(isUpdated: true);
                          } else if (state is StockError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error), backgroundColor: AppColors.red),
                            );
                            setState(() => _isStockAdded = false);
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
                                  Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _stockCubit.fetchStock(''),
                                    child: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              // Supplier Selection
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: _showSupplierSelectionDialog,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedSupplier?.name ?? 'Select Supplier',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Store Dropdown
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Store',
                                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    errorStyle: const TextStyle(color: Colors.red),
                                  ),
                                  value: _selectedStoreId,
                                  items: stores
                                      .map((store) => DropdownMenuItem<String>(
                                    value: store.storeId,
                                    child: Text(store.name),
                                  ))
                                      .toList(),
                                  onChanged: (value) => setState(() => _selectedStoreId = value),
                                  validator: (value) => value == null ? 'Please select a store' : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Purchase Type Dropdown
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Purchase Type',
                                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    errorStyle: const TextStyle(color: Colors.red),
                                  ),
                                  value: _selectedPurchaseType,
                                  items: const [
                                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                                    DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                                  ],
                                  onChanged: (value) => setState(() => _selectedPurchaseType = value),
                                  validator: (value) => value == null ? 'Please select a purchase type' : null,
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
                                  onPressed: _stockEntries.isEmpty || _selectedStoreId == null || _selectedSupplier == null
                                      ? null
                                      : () => _saveStock(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Save All Stock'),
                                ),
                              ] else ...[
                                // Single Item Form
                                BlocBuilder<AdminProductCubit, ProductState>(
                                  bloc: _productCubit,
                                  builder: (context, productState) {
                                    final products = productState is ProductLoaded ? productState.products : [];
                                    return Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Product',
                                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          errorStyle: const TextStyle(color: Colors.red),
                                        ),
                                        value: _selectedProductId,
                                        items: products
                                            .map((product) => DropdownMenuItem<String>(
                                          value: product.id,
                                          child: Text(product.name),
                                        ))
                                            .toList(),
                                        onChanged: (value) => setState(() => _selectedProductId = value),
                                        validator: (value) => value == null ? 'Please select a product' : null,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
                                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: Colors.grey[50],
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
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate() && _selectedSupplier != null) {
                                      final products = _productCubit.state is ProductLoaded
                                          ? (_productCubit.state as ProductLoaded).products
                                          : [];
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
                                      _stockEntries = [
                                        {
                                          'productId': selectedProduct.id,
                                          'quantity': _quantity,
                                          'product': selectedProduct,
                                          'taxRate': selectedProduct.tax,
                                          'taxAmount': selectedProduct.price * _quantity * (selectedProduct.tax / 100),
                                        }
                                      ];
                                      _saveStock();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    _supplierSearchController.dispose();
    _supplierNameController.dispose();
    _finalAmountController.dispose();
    _billNumberController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }
}