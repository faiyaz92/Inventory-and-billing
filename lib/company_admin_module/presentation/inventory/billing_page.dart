import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_user_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';

@RoutePage()
class BillingPage extends StatefulWidget {
  final String? orderId;

  const BillingPage({super.key, this.orderId});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _productSearchController =
      TextEditingController();
  List<StockModel> _filteredProducts = [];
  List<CartItem> _cartItems = [];
  String? _selectedStoreId;
  String _selectedStatus = 'pending';
  UserInfo? _selectedCustomer;
  String? _newCustomerLedgerId;
  final List<String> _statuses = [
    'pending',
    'processing',
    'shipped',
    'completed'
  ];
  bool _isLoading = false;
  String? _selectedBillType = 'Cash';
  String? _existingBillNumber;

  final StockCubit _stockCubit = sl<StockCubit>();
  final AdminOrderCubit _adminOrderCubit = sl<AdminOrderCubit>();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    final userServices = sl<UserServices>();

    await _stockCubit.fetchStock('');

    final loggedInUserStoreId = await _getLoggedInUserStoreId(userServices);

    setState(() {
      _selectedStoreId = loggedInUserStoreId;
      _isLoading = false;
    });

    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No store assigned to user. Please select a store.')),
      );
    } else {
      _stockCubit.fetchStock(_selectedStoreId!);
      if (widget.orderId != null) {
        _adminOrderCubit.fetchOrderById(widget.orderId!);
      }
    }
  }

  Future<String?> _getLoggedInUserStoreId(UserServices userServices) async {
    try {
      final users = await userServices.getUsersFromTenantCompany();
      final userId = (await sl<AccountRepository>().getUserInfo())?.userId;
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final user = users.firstWhere(
        (u) => u.userId == userId,
        orElse: () => UserInfo(userId: userId, userName: 'Unknown'),
      );
      return user.storeId;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user store: $e')),
      );
      return null;
    }
  }

  void _searchProducts(String query, List<StockModel> products) {
    setState(() {
      _filteredProducts = query.isEmpty
          ? products
          : products.where((product) {
              final name = product.name?.toLowerCase() ?? '';
              return name.contains(query.toLowerCase());
            }).toList();
    });
  }

  void _addToCart(StockModel product) {
    if (_existingBillNumber != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot add new items to an existing bill')),
      );
      return;
    }
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.productId == product.productId,
        orElse: () => CartItem(
          productId: product.productId!,
          productName: product.name!,
          price: product.price!,
          quantity: 0,
          taxRate: product.tax ?? 0.05,
          taxAmount: 0.0,
        ),
      );
      if (!_cartItems.contains(existingItem)) {
        _cartItems.add(existingItem.copyWith(
          quantity: 1,
          taxAmount: product.price! * 1 * (product.tax ?? 0.05) / 100,
        ));
      } else {
        _cartItems = _cartItems.map((item) {
          if (item.productId == product.productId) {
            final newQuantity = item.quantity + 1;
            return item.copyWith(
              quantity: newQuantity,
              taxAmount: item.price * newQuantity * item.taxRate / 100,
            );
          }
          return item;
        }).toList();
      }
    });
  }

  void _updateQuantity(String productId, int change) {
    print('Updating quantity for productId: $productId, change: $change, existingBillNumber: $_existingBillNumber');
    setState(() {
      _cartItems = _cartItems.map((item) {
        if (item.productId == productId) {
          final newQuantity = (item.quantity + change).clamp(0, 9999999); // Max 7 digits
          if (change > 0 && _existingBillNumber != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cannot increase quantity for existing bill')),
            );
            return item; // Return unchanged item if increasing quantity for existing bill
          }
          return item.copyWith(
            quantity: newQuantity,
            taxAmount: item.price * newQuantity * item.taxRate / 100,
          );
        }
        return item;
      }).toList();
      _cartItems.removeWhere((item) => item.quantity == 0);
    });
  }
  Future<void> _showQuantityInputDialog(String productId) async {
    int quantity = 0;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Set Quantity'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter Quantity',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.number,
              maxLength: 7,
              onChanged: (value) => quantity = int.tryParse(value) ?? 0,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                final parsedValue = int.tryParse(value);
                if (parsedValue == null || parsedValue < 0) {
                  return 'Please enter a valid quantity';
                }
                if (parsedValue > 9999999) {
                  return 'Quantity cannot exceed 7 digits';
                }
                if (_existingBillNumber != null &&
                    parsedValue >
                        _cartItems
                            .firstWhere((item) => item.productId == productId)
                            .quantity) {
                  return 'Cannot increase quantity for existing bill';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _cartItems = _cartItems.map((item) {
                      if (item.productId == productId) {
                        return item.copyWith(
                          quantity: quantity,
                          taxAmount: item.price * quantity * item.taxRate / 100,
                        );
                      }
                      return item;
                    }).toList();
                    _cartItems.removeWhere((item) => item.quantity == 0);
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionButtons(
      List<StockModel> products, List<StoreDto> stores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSelectionButton(
          icon: Icons.person,
          label: _selectedCustomer?.name ??
              _selectedCustomer?.userName ??
              'Select Customer',
          onPressed: _showCustomerSelectionDialog,
          hasError: _selectedCustomer == null,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildSelectionButton(
                icon: Icons.store,
                label: _selectedStoreId != null
                    ? stores
                        .firstWhere(
                            (store) => store.storeId == _selectedStoreId,
                            orElse: () => StoreDto(
                                name: 'Unknown',
                                storeId: '',
                                createdBy: '',
                                createdAt: DateTime.now()))
                        .name
                    : 'Select Store',
                onPressed: () => _showStoreSelectionDialog(stores),
                hasError: _selectedStoreId == null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectionButton(
                icon: Icons.inventory,
                label: 'Add Products',
                onPressed: () => _showProductSelectionDialog(products),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Bill Type',
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              value: _selectedBillType,
              items: ['Cash', 'Credit'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBillType = value ?? 'Cash';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCustomerSelectionDialog() async {
    final userServices = sl<UserServices>();
    final addUserCubit = sl<AddUserCubit>();
    final TextEditingController searchController = TextEditingController();
    List<UserInfo> filteredCustomers = [];
    List<UserInfo> allCustomers = [];

    try {
      final users = await userServices.getUsersFromTenantCompany();
      allCustomers =
          users.where((u) => u.userType == UserType.Customer).toList();
      filteredCustomers = allCustomers;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: addUserCubit),
          ],
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select or Add Customer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.close, color: AppColors.primary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Customers',
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            filteredCustomers = allCustomers;
                          } else {
                            filteredCustomers = allCustomers
                                .where((customer) =>
                                    (customer.name
                                            ?.toLowerCase()
                                            .contains(value.toLowerCase()) ??
                                        false) ||
                                    (customer.userName
                                            ?.toLowerCase()
                                            .contains(value.toLowerCase()) ??
                                        false))
                                .toList();
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _customerNameController,
                      decoration: InputDecoration(
                        labelText: 'New Customer Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorText: _customerNameController.text.isEmpty &&
                                filteredCustomers.isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                    ),
                  ),
                  BlocListener<AddUserCubit, AddUserState>(
                    listener: (context, state) {
                      if (state is AddUserSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Customer added successfully')),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                      } else if (state is AddUserFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_customerNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Customer name is required')),
                            );
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            final companyId =
                                (await sl<AccountRepository>().getUserInfo())
                                    ?.companyId;
                            final userInfo = UserInfo(
                              name: _customerNameController.text.trim(),
                              userType: UserType.Customer,
                              companyId: companyId,
                            );
                            await addUserCubit.addUser(userInfo, '');
                            final users =
                                await userServices.getUsersFromTenantCompany();
                            final newCustomer = users.firstWhere(
                              (u) => u.name == userInfo.name,
                              orElse: () => userInfo.copyWith(
                                userId: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                              ),
                            );
                            setState(() {
                              _selectedCustomer = newCustomer;
                              _newCustomerLedgerId =
                                  newCustomer.accountLedgerId;
                              _customerNameController.clear();
                            });
                            allCustomers = users
                                .where((u) => u.userType == UserType.Customer)
                                .toList();
                            filteredCustomers = allCustomers;
                            searchController.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to add customer: $e')),
                            );
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Add New Customer',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredCustomers.isEmpty
                        ? const Center(child: Text('No customers available'))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final user = filteredCustomers[index];
                              return ListTile(
                                title: Text(
                                  user.name ?? user.userName ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('ID: ${user.userId}'),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = user;
                                    _newCustomerLedgerId = user.accountLedgerId;
                                  });
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error')),
      );
    }
  }

  Future<void> _generateBill() async {
    if (_cartItems.isEmpty && _existingBillNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }
    if (_selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a store')),
      );
      return;
    }
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_selectedBillType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bill type')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderService = sl<IOrderService>();
      final ledgerCubit = sl<UserLedgerCubit>();
      final userId = (await sl<AccountRepository>().getUserInfo())?.userId;
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final stockState = _stockCubit.state;
      final totalAmount = _cartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity) + item.taxAmount,
      );
      final billNumber = _existingBillNumber ??
          'BILL-${DateTime.now().millisecondsSinceEpoch}';
      Order order;

      print(
          'Processing bill: existingBillNumber=$_existingBillNumber, cartItems=${_cartItems.length}, totalAmount=$totalAmount');

      if (_existingBillNumber == null) {
        for (var item in _cartItems) {
          final stock = stockState is StockLoaded
              ? stockState.stockItems.firstWhere(
                  (stock) =>
                      stock.productId == item.productId &&
                      stock.storeId == _selectedStoreId,
                  orElse: () => StockModel(
                    id: '${item.productId}_$_selectedStoreId',
                    productId: item.productId,
                    storeId: _selectedStoreId!,
                    quantity: 0,
                    lastUpdated: DateTime.now(),
                  ),
                )
              : null;
          if (stock == null || stock.quantity < item.quantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Insufficient stock for ${item.productName}')),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        for (var item in _cartItems) {
          final stock = stockState is StockLoaded
              ? stockState.stockItems.firstWhere(
                  (stock) =>
                      stock.productId == item.productId &&
                      stock.storeId == _selectedStoreId,
                )
              : null;
          if (stock != null) {
            await _stockCubit.generateBill(
              stock,
              item.quantity,
              _selectedCustomer!.userId!,
              remarks:
                  'Bill generated for $_selectedBillType sale (Order: ${widget.orderId ?? 'New'})',
            );
          }
        }

        order = Order(
          id: widget.orderId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _selectedCustomer!.userId!,
          userName: _selectedCustomer!.name ??
              _selectedCustomer!.userName ??
              'Unknown',
          items: _cartItems,
          totalAmount: totalAmount,
          status: _selectedStatus,
          orderDate: DateTime.now(),
          orderTakenBy: userId,
          storeId: _selectedStoreId,
          lastUpdatedBy: userId,
          billNumber: billNumber,
        );
        await orderService.placeOrder(order);
      } else {
        if (widget.orderId != null) {
          final originalOrder =
              (await orderService.getOrderById(widget.orderId!))!;
          for (var item in originalOrder.items) {
            final currentItem = _cartItems.firstWhere(
              (i) => i.productId == item.productId,
              orElse: () => item.copyWith(quantity: 0),
            );
            final returnQuantity = item.quantity - currentItem.quantity;
            if (returnQuantity > 0) {
              final stock = stockState is StockLoaded
                  ? stockState.stockItems.firstWhere(
                      (stock) =>
                          stock.productId == item.productId &&
                          stock.storeId == _selectedStoreId,
                      orElse: () => StockModel(
                        id: '${item.productId}_$_selectedStoreId',
                        productId: item.productId,
                        storeId: _selectedStoreId!,
                        quantity: 0,
                        lastUpdated: DateTime.now(),
                      ),
                    )
                  : null;
              if (stock != null) {
                await _stockCubit.updateStock(
                  stock.copyWith(
                    quantity: stock.quantity + returnQuantity,
                    lastUpdated: DateTime.now(),
                  ),
                  remarks:
                      'Return of $returnQuantity units of ${item.productName}',
                );
                final ledgerId = _selectedCustomer!.accountLedgerId;
                if (ledgerId != null) {
                  await ledgerCubit.addTransaction(
                    ledgerId: ledgerId,
                    amount: item.price * returnQuantity,
                    type: 'Credit',
                    billNumber: billNumber,
                    purpose: 'Return',
                    typeOfPurpose: _selectedBillType,
                    remarks:
                        'Return of $returnQuantity units of ${item.productName} for order ${widget.orderId}',
                    userType: UserType.Customer,
                  );
                }
              }
            }
          }
        }

        order = Order(
          id: widget.orderId!,
          userId: _selectedCustomer!.userId!,
          userName: _selectedCustomer!.name ??
              _selectedCustomer!.userName ??
              'Unknown',
          items: _cartItems,
          totalAmount: totalAmount,
          status: _selectedStatus,
          orderDate: DateTime.now(),
          orderTakenBy: userId,
          storeId: _selectedStoreId,
          lastUpdatedBy: userId,
          billNumber: billNumber,
        );
        await orderService.updateOrderStatus(widget.orderId!, _selectedStatus);
        await orderService.updateOrder(order);
      }

      final ledgerId = _selectedCustomer!.accountLedgerId;
      if (ledgerId != null) {
        if (_existingBillNumber == null) {
          await ledgerCubit.addTransaction(
            ledgerId: ledgerId,
            amount: totalAmount,
            type: 'Debit',
            billNumber: billNumber,
            purpose: 'Purchase',
            typeOfPurpose: _selectedBillType,
            remarks: 'Bill generated for order ${order.id}',
            userType: UserType.Customer,
          );
        }

        if (_selectedBillType == 'Cash' && _existingBillNumber == null) {
          await ledgerCubit.addTransaction(
            ledgerId: ledgerId,
            amount: totalAmount,
            type: 'Credit',
            billNumber: billNumber,
            purpose: 'Payment',
            typeOfPurpose: 'Cash',
            remarks: 'Payment received for bill $billNumber',
            userType: UserType.Customer,
          );
        }
      } else {
        print(
            'No ledger ID found for customer: ${_selectedCustomer!.name}, skipping ledger entries');
      }

      final pdf = await _generatePdf(order);

      await sl<Coordinator>()
          .navigateToBillPdfPage(pdf: pdf, billNumber: billNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_existingBillNumber == null
                ? 'Bill generated successfully'
                : 'Bill updated successfully')),
      );
    } catch (e) {
      print('Error in generateBill: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process bill: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildGenerateBillButton() {
    return ElevatedButton(
      onPressed: _generateBill,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        minimumSize: const Size(double.infinity, 50),
      ),
      child:
          Text(_existingBillNumber == null ? 'Generate Bill' : 'Update Bill'),
    );
  }

  Widget _buildStatusSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Order Status',
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
          value: _selectedStatus,
          items: _statuses.map((status) {
            return DropdownMenuItem(
                value: status, child: Text(status.capitalize()));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value ?? 'pending';
            });
          },
        ),
      ),
    );
  }

  Widget _buildCart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_cartItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No items in cart',
                  style:
                      TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
              )
            else
              ..._cartItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                print(
                    'Rendering buttons for ${item.productName}, quantity: ${item.quantity}');
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    title: Text(item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Price: ₹${item.price.toStringAsFixed(2)} | Quantity: ${item.quantity} | Tax: ₹${item.taxAmount.toStringAsFixed(2)}',
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
                                    _showQuantityInputDialog(item.productId),
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
                                onPressed: item.quantity > 0
                                    ? () {
                                  setState(() {
                                    _cartItems =
                                        _cartItems.map((cartItem) {
                                          if (cartItem.productId ==
                                              item.productId) {
                                            return cartItem.copyWith(
                                              quantity: 0,
                                              taxAmount: 0.0,
                                            );
                                          }
                                          return cartItem;
                                        }).toList();
                                    _cartItems.removeWhere((cartItem) =>
                                    cartItem.quantity == 0);
                                  });
                                }
                                    : null,
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
                                color:
                                    AppColors.textSecondary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: item.quantity > 0
                                      ? AppColors.red
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _updateQuantity(item.productId, -1),
                              ),
                              SizedBox(
                                width: 48,
                                child: Text(
                                  '${item.quantity}',
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
                                    _updateQuantity(item.productId, 1),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 8),
            Text(
              'Total: ₹${_cartItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity) + item.taxAmount).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelectionDialog(List<StockModel> products) {
    _productSearchController.clear();
    _searchProducts('', products);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Products',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _productSearchController,
                decoration: InputDecoration(
                  labelText: 'Search Products',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (query) => _searchProducts(query, products),
              ),
            ),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products available',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            title: Text(
                              product.name ?? 'Unknown',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Price: ₹${product.price?.toStringAsFixed(2) ?? '0.00'} | Stock: ${product.quantity}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add,
                                  color: AppColors.primary),
                              onPressed: () => _addToCart(product),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoreSelectionDialog(List<StoreDto> stores) {
    final uniqueStores = <String, StoreDto>{};
    for (var store in stores) {
      if (store.storeId != null) {
        uniqueStores[store.storeId!] = store;
      }
    }
    final storeList = uniqueStores.values.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Store',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: storeList.isEmpty
                  ? const Center(child: Text('No stores available'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: storeList.length,
                      itemBuilder: (context, index) {
                        final store = storeList[index];
                        return ListTile(
                          title: Text(
                            store.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedStoreId = store.storeId;
                              if (_selectedStoreId != null) {
                                _stockCubit.fetchStock(_selectedStoreId!);
                              }
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _generatePdf(Order order) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();

    String companyName = 'Abc Pvt. Ltd.';
    String issuerName = 'Unknown Issuer';
    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
      issuerName = userInfo?.name ?? userInfo?.userName ?? issuerName;
    } catch (e) {
      print('Error fetching company or issuer name: $e');
    }

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    final greyColor = PdfColors.grey300;

    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border:
                pw.Border(bottom: pw.BorderSide(width: 3, color: primaryColor)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 22, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '123 Business Street, City, Country',
                    style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 12,
                        color: textSecondaryColor),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 28, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Bill #: ${order.billNumber ?? 'N/A'}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Date: ${order.orderDate.toString().substring(0, 10)}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Issuer: $issuerName',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 24),
          pw.Text(
            'Bill To:',
            style: pw.TextStyle(
                font: boldFont, fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            order.userName ?? 'Unknown Customer',
            style:
                pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
          ),
          pw.Text(
            'Store ID: ${order.storeId ?? 'N/A'}',
            style: pw.TextStyle(
                font: regularFont, fontSize: 12, color: textSecondaryColor),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Items',
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: greyColor, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Product',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Qty',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Unit Price',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Tax',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Total',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                ],
              ),
              ...order.items.map((item) => pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                          bottom: pw.BorderSide(color: greyColor, width: 0.5)),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          item.productName,
                          style: pw.TextStyle(font: regularFont, fontSize: 12),
                          softWrap: true,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          item.quantity.toString(),
                          style: pw.TextStyle(font: regularFont, fontSize: 12),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          item.price.toStringAsFixed(2),
                          style: pw.TextStyle(font: regularFont, fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          item.taxAmount.toStringAsFixed(2),
                          style: pw.TextStyle(font: regularFont, fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          ((item.price * item.quantity) + item.taxAmount)
                              .toStringAsFixed(2),
                          style: pw.TextStyle(font: regularFont, fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              border: pw.Border.all(color: greyColor, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Subtotal: ${order.items.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Total Tax: ${order.items.fold<double>(0.0, (sum, item) => sum + item.taxAmount).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Total Amount: ${order.totalAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          font: boldFont, fontSize: 16, color: primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Generated by $companyName | Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
                font: regularFont, fontSize: 10, color: textSecondaryColor),
          ),
        ),
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _adminOrderCubit),
        BlocProvider.value(value: _stockCubit),
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Billing',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {},
                    ),
                    if (_cartItems.isNotEmpty)
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
                            '${_cartItems.length}',
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
            child: _isLoading
                ? const CustomLoadingDialog(message: 'Loading...')
                : SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            kToolbarHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BlocListener<AdminOrderCubit, AdminOrderState>(
                          listener: (context, state) {
                            if (state is AdminOrderFetchSuccess &&
                                widget.orderId != null) {
                              setState(() {
                                _cartItems = state.order.items;
                                _selectedStatus = state.normalizedStatus;
                                _selectedStoreId =
                                    state.order.storeId ?? _selectedStoreId;
                                _existingBillNumber = state.order.billNumber;
                                if (state.order.userId != null) {
                                  sl<UserServices>()
                                      .getUsersFromTenantCompany()
                                      .then((users) {
                                    final customer = users.firstWhere(
                                      (u) => u.userId == state.order.userId,
                                      orElse: () => UserInfo(
                                        userId: state.order.userId!,
                                        userName:
                                            state.order.userName ?? 'Unknown',
                                      ),
                                    );
                                    setState(() {
                                      _selectedCustomer = customer;
                                      _newCustomerLedgerId =
                                          customer.accountLedgerId;
                                    });
                                  });
                                }
                              });
                              if (_selectedStoreId != null) {
                                _stockCubit.fetchStock(_selectedStoreId!);
                              }
                            } else if (state is AdminOrderFetchError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                              );
                            }
                          },
                          child: BlocBuilder<StockCubit, StockState>(
                            builder: (context, stockState) {
                              final products = stockState is StockLoaded
                                  ? stockState.stockItems
                                  : <StockModel>[];
                              final stores = stockState is StockLoaded
                                  ? stockState.stores
                                  : <StoreDto>[];
                              if (stockState is StockError) {
                                return Center(
                                    child: Text('Error: ${stockState.error}'));
                              }
                              if (_filteredProducts.isEmpty &&
                                  products.isNotEmpty) {
                                _filteredProducts = products;
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSelectionButtons(products, stores),
                                  const SizedBox(height: 16),
                                  _buildCart(),
                                  const SizedBox(height: 16),
                                  _buildStatusSelector(),
                                  const SizedBox(height: 16),
                                  _buildGenerateBillButton(),
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
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool hasError = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: hasError ? Border.all(color: Colors.red) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: hasError ? Colors.red : AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
