import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
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
  List<StockModel> _filteredProducts = [];
  List<CartItem> _cartItems = [];
  String? _selectedStoreId;
  String _selectedStatus = 'pending';
  UserInfo? _selectedCustomer; // New state for selected customer
  final List<String> _statuses = [
    'pending',
    'processing',
    'shipped',
    'completed'
  ];
  bool _isLoading = false;

// Initialize cubits using service locator
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

    if (_stockCubit.state is StockLoaded) {
      final stores = (_stockCubit.state as StockLoaded).stores;
      print(
          'Stores fetched: ${stores.map((s) => "${s.storeId}: ${s.name}").toList()}');
    }

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
    setState(() {
      _cartItems = _cartItems.map((item) {
        if (item.productId == productId) {
          final newQuantity = (item.quantity + change).clamp(0, 100);
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

  Future<void> _showCustomerSelectionDialog() async {
    final userServices = sl<UserServices>();
    try {
      final users = await userServices.getUsersFromTenantCompany();
      if (users.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No customers available')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Customer'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(
                    user.name ?? user.userName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('ID: ${user.userId}'),
                  onTap: () {
                    setState(() {
                      _selectedCustomer = user;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch customers: $e')),
      );
    }
  }

  Future<pw.Document> _generatePdf(Order order) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();

    // Fetch company and issuer name
    String companyName = 'Abc Pvt. Ltd.';
    String issuerName = 'Unknown Issuer';
    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
      issuerName = userInfo?.name ?? userInfo?.userName ?? issuerName;
    } catch (e) {
      print('Error fetching company or issuer name: $e');
    }

    // Map AppColors to PdfColors
    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    final greyColor = PdfColors.grey300;

    // Use built-in Times font
    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 2, color: primaryColor)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(font: boldFont, fontSize: 20, color: primaryColor),
                  ),
                  pw.Text(
                    '123 Business Street, City, Country',
                    style: pw.TextStyle(font: regularFont, fontSize: 12, color: textSecondaryColor),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(font: boldFont, fontSize: 24, color: primaryColor),
                  ),
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
          pw.SizedBox(height: 20),
          pw.Text(
            'Bill To:',
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.black),
          ),
          pw.Text(
            order.userName ?? 'Unknown Customer',
            style: pw.TextStyle(font: boldFont, fontSize: 14, color: primaryColor),
          ),
          pw.Text(
            'Store ID: ${order.storeId ?? 'N/A'}',
            style: pw.TextStyle(font: regularFont, fontSize: 12, color: textSecondaryColor),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Items',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: greyColor),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Product', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Quantity', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Unit Price', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Tax', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Total', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  ),
                ],
              ),
              ...order.items.map((item) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(item.productName, style: pw.TextStyle(font: regularFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(item.quantity.toString(), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('₹${item.price.toStringAsFixed(2)}', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('₹${item.taxAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '₹${((item.price * item.quantity) + item.taxAmount).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 12),
                    ),
                  ),
                ],
              )),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Subtotal: ₹${order.items.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Total Tax: ₹${order.items.fold<double>(0.0, (sum, item) => sum + item.taxAmount).toStringAsFixed(2)}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Total Amount: ₹${order.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Generated by $companyName | Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: textSecondaryColor),
          ),
        ),
      ),
    );

    return pdf;
  }
  Future<void> _generateBill() async {
    if (_cartItems.isEmpty) {
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

    setState(() => _isLoading = true);
    try {
      final userServices = sl<UserServices>();
      final orderService = sl<IOrderService>();
      final userId = (await sl<AccountRepository>().getUserInfo())?.userId;
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final stockState = _stockCubit.state;
      if (stockState is StockLoaded) {
        for (var item in _cartItems) {
          final stock = stockState.stockItems.firstWhere(
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
          );
          if (stock.quantity < item.quantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Insufficient stock for ${item.productName}')),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        for (var item in _cartItems) {
          final stock = stockState.stockItems.firstWhere(
            (stock) =>
                stock.productId == item.productId &&
                stock.storeId == _selectedStoreId,
          );
          await _stockCubit.subtractStock(
            stock,
            item.quantity,
            remarks:
                'Stock deducted for bill generation (Order: ${widget.orderId ?? 'New'})',
          );
        }
      } else if (stockState is StockError) {
        throw Exception(stockState.error);
      } else {
        throw Exception('Stock data not loaded');
      }

      final totalAmount = _cartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity) + item.taxAmount,
      );

      final billNumber = 'BILL-${DateTime.now().millisecondsSinceEpoch}';
      Order order;
      if (widget.orderId == null) {
        order = Order(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _selectedCustomer!.userId!,
          // Use selected customer's userId
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
        order = Order(
          id: widget.orderId!,
          userId: _selectedCustomer!.userId!,
          // Use selected customer's userId
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
        await orderService.updateOrder(order); // Update based on IOrderService
      }

      final pdf = await _generatePdf(order);

      await sl<Coordinator>()
          .navigateToBillPdfPage(pdf: pdf, billNumber: billNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate bill: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _adminOrderCubit),
        BlocProvider.value(value: _stockCubit),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Billing'),
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
            child: _isLoading
                ? const CustomLoadingDialog(message: 'Loading...')
                : SingleChildScrollView(
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
// Try to set customer from order
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
                                _buildCustomerSelector(),
                                const SizedBox(height: 16),
                                _buildStoreSelector(stores),
                                const SizedBox(height: 16),
                                _buildSearchBar(products),
                                const SizedBox(height: 16),
                                _buildProductList(products),
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
    );
  }

  Widget _buildCustomerSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: InkWell(
          onTap: _showCustomerSelectionDialog,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select Customer',
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
              errorText: _selectedCustomer == null && !_isLoading
                  ? 'Please select a customer'
                  : null,
            ),
            child: Text(
              _selectedCustomer?.name ??
                  _selectedCustomer?.userName ??
                  'Tap to select a customer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedCustomer != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreSelector(List<StoreDto> stores) {
    final uniqueStores = <String, StoreDto>{};
    for (var store in stores) {
      if (store.storeId != null) {
        uniqueStores[store.storeId!] = store;
      }
    }
    final storeList = uniqueStores.values.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Store',
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
            errorText:
                storeList.isEmpty && !_isLoading ? 'No stores available' : null,
          ),
          value: _selectedStoreId != null &&
                  uniqueStores.containsKey(_selectedStoreId)
              ? _selectedStoreId
              : null,
          items: storeList.isEmpty
              ? [
                  const DropdownMenuItem(
                      value: null,
                      child: Text('No stores available'),
                      enabled: false)
                ]
              : [
                  const DropdownMenuItem(
                      value: null, child: Text('Select a store')),
                  ...storeList.map((store) => DropdownMenuItem(
                      value: store.storeId, child: Text(store.name))),
                ],
          onChanged: storeList.isEmpty || _isLoading
              ? null
              : (value) {
                  setState(() {
                    _selectedStoreId = value;
                    if (value != null) {
                      _stockCubit.fetchStock(value);
                    }
                  });
                },
          hint: const Text('Select a store'),
        ),
      ),
    );
  }

  Widget _buildSearchBar(List<StockModel> products) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search Products',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            errorStyle: const TextStyle(color: Colors.red),
          ),
          onChanged: (query) => _searchProducts(query, products),
        ),
      ),
    );
  }

  Widget _buildProductList(List<StockModel> products) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 300,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products available',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
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
                      IconButton(
                        icon:
                            const Icon(Icons.remove, color: AppColors.primary),
                        onPressed: () => _updateQuantity(item.productId, -1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        onPressed: () => _updateQuantity(item.productId, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
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

  Widget _buildGenerateBillButton() {
    return ElevatedButton(
      onPressed: _generateBill,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: const Text('Generate Bill'),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
