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
  final List<String> _statuses = [
    'pending',
    'processing',
    'shipped',
    'completed'
  ];
  bool _isLoading = false;
  String? _selectedBillType = 'Cash';
  String? _existingBillNumber;
  String? _selectedReturnMethod = 'Credit';
  double? _discount;

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
          taxRate: product.tax ?? 5,
          taxAmount: 0.0,
        ),
      );
      if (!_cartItems.contains(existingItem)) {
        _cartItems.add(existingItem.copyWith(
          quantity: 1,
          taxAmount: product.price! * 1 * (product.tax ?? 5) / 100,
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
          final newQuantity = (item.quantity + change).clamp(0, 9999999);
          if (change > 0 && _existingBillNumber != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cannot increase quantity for existing bill')),
            );
            return item;
          }
          return item.copyWith(
            quantity: newQuantity,
            taxAmount: item.price * newQuantity * item.taxRate / 100,
          );
        }
        return item;
      }).toList();
      _cartItems.removeWhere((item) => item.quantity == 0);
      if (_cartItems.isEmpty) {
        _discount = 0.0; // Reset discount when cart is empty
      }
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    if (_cartItems.isEmpty) {
                      _discount = 0.0; // Reset discount when cart is empty
                    }
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

  Future<bool> _showReviewDialog(Order order) async {
    final double subtotal = order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final double totalTax = order.items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final double total = subtotal + totalTax;
    List<double> itemDiscounts = order.items.map((item) => item.discountAmount).toList();
    double additionalDiscount = _discount ?? order.discount ?? 0.0;
    final TextEditingController discountController = TextEditingController(
      text: additionalDiscount.toStringAsFixed(2),
    );
    final TextEditingController initialPaymentController = TextEditingController(
      text: _initialPayment?.toStringAsFixed(2) ?? '0.00',
    );

    // Detect screen width for mobile adjustments
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Function to show discount input dialog
    Future<void> _showDiscountDialog(BuildContext dialogContext, int index, CartItem item, StateSetter setState) async {
      final TextEditingController itemDiscountController = TextEditingController(
        text: itemDiscounts[index].toStringAsFixed(2),
      );
      String? errorText;
      final itemTotal = item.price * item.quantity + item.taxAmount;

      await showDialog(
        context: dialogContext,
        builder: (context) => AlertDialog(
          title: Text('Edit Discount for ${item.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unit Price: ₹${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Item Total (Qty × Price + Tax): ₹${itemTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: itemDiscountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Discount (₹)',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (value) {
                  final disc = double.tryParse(value) ?? 0.0;
                  setState(() {
                    if (disc < 0) {
                      errorText = 'Discount cannot be negative';
                    } else if (disc > itemTotal) {
                      errorText = 'Discount cannot exceed item total';
                    } else {
                      errorText = null;
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final disc = double.tryParse(itemDiscountController.text) ?? 0.0;
                if (disc < 0) {
                  setState(() {
                    errorText = 'Discount cannot be negative';
                  });
                  return;
                }
                if (disc > itemTotal) {
                  setState(() {
                    errorText = 'Discount cannot exceed item total';
                  });
                  return;
                }
                setState(() {
                  itemDiscounts[index] = disc;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      );
    }

    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.white,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.orderId == null ? 'Order Summary' : 'Review Bill',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(dialogContext, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      columnWidths: {
                        0: FlexColumnWidth(isMobile ? 2.5 : 3), // Product
                        1: FlexColumnWidth(1), // Qty
                        2: FlexColumnWidth(1.2), // Subtotal
                        3: FlexColumnWidth(1.2), // Tax
                        4: FlexColumnWidth(1.5), // Discount (wider for tap target)
                        5: FlexColumnWidth(1.2), // Total
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                              child: const Text(
                                'Product',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                              child: const Text(
                                'Qty',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                              child: const Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                              child: const Text(
                                'Tax',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                              child: const Text(
                                'Discount',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                              child: const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...order.items.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final item = entry.value;
                          return TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                                child: Text(
                                  item.productName,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                                child: Text(
                                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                                child: Text(
                                  '₹${item.taxAmount.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showDiscountDialog(dialogContext, index, item, setState),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                                  color: Colors.transparent, // Ensures tap area is full cell
                                  child: Text(
                                    '₹${itemDiscounts[index].toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      color: AppColors.textSecondary,
                                      decoration: TextDecoration.underline, // Visual cue for tappable
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 12),
                                child: Text(
                                  '₹${((item.price * item.quantity) + item.taxAmount - itemDiscounts[index]).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: discountController,
                    decoration: InputDecoration(
                      labelText: 'Additional Discount (₹)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 12 : 16,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        additionalDiscount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  if (_selectedBillType == 'Credit') ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: initialPaymentController,
                      decoration: InputDecoration(
                        labelText: 'Initial Payment (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 12 : 16,
                        ),
                        errorText: double.tryParse(initialPaymentController.text) != null &&
                            double.parse(initialPaymentController.text) >
                                (total - itemDiscounts.fold(0.0, (sum, disc) => sum + disc) - additionalDiscount)
                            ? 'Initial payment cannot exceed final total'
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          _initialPayment = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
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
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                'Subtotal (All Items)',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                '₹${subtotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                'Total Tax',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                '₹${totalTax.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                '₹${total.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                'Item Discounts',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                '₹${itemDiscounts.fold(0.0, (sum, disc) => sum + disc).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                'Additional Discount',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                '₹${additionalDiscount.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: AppColors.textSecondary,
                                ),
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
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                'Final Total',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 12 : 16),
                              child: Text(
                                '₹${(total - itemDiscounts.fold(0.0, (sum, disc) => sum + disc) - additionalDiscount).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final sumItemDisc = itemDiscounts.fold(0.0, (sum, disc) => sum + disc);
                        final finalTotal = total - sumItemDisc - additionalDiscount;

                        // Validate item discounts
                        for (int i = 0; i < order.items.length; i++) {
                          final item = order.items[i];
                          final itemTotal = item.price * item.quantity + item.taxAmount;
                          if (itemDiscounts[i] < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item discount cannot be negative'),
                                backgroundColor: AppColors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          if (itemDiscounts[i] > itemTotal) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Discount for ${item.productName} cannot exceed item total'),
                                backgroundColor: AppColors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                        }
                        // Validate additional discount
                        if (additionalDiscount < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid additional discount'),
                              backgroundColor: AppColors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        final totalAfterItemDisc = total - sumItemDisc;
                        if (additionalDiscount > totalAfterItemDisc) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Additional discount cannot exceed total after item discounts'),
                              backgroundColor: AppColors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        // Validate initial payment
                        if (_selectedBillType == 'Credit') {
                          final initialPayment = double.tryParse(initialPaymentController.text) ?? 0.0;
                          if (initialPayment < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Initial payment cannot be negative'),
                                backgroundColor: AppColors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          if (initialPayment > finalTotal) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Initial payment cannot exceed final total'),
                                backgroundColor: AppColors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          _initialPayment = initialPayment;
                        }
                        // Update cart items with discounts
                        setState(() {
                          _cartItems = order.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final discount = itemDiscounts[index];
                            final itemTotal = item.price * item.quantity + item.taxAmount;
                            final discountPercentage = itemTotal > 0 ? (discount / itemTotal) * 100 : 0.0;
                            return item.copyWith(
                              discountAmount: discount,
                              discountPercentage: discountPercentage,
                            );
                          }).toList();
                          _discount = additionalDiscount; // Store only additional discount
                        });
                        Navigator.pop(dialogContext, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ) ?? false;
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
                    createdAt: DateTime.now(),
                  ),
                )
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
              onChanged: _existingBillNumber == null
                  ? (value) {
                setState(() {
                  _selectedBillType = value ?? 'Cash';
                });
              }
                  : null,
            ),
          ),
        ),
        if (_existingBillNumber != null && _selectedBillType == 'Cash') ...[
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Return Method',
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
                value: _selectedReturnMethod,
                items: ['Cash', 'Credit'].map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReturnMethod = value ?? 'Credit';
                  });
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
  double? _initialPayment;
  final TextEditingController _initialPaymentController = TextEditingController();

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

    final double subtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final double totalTax = _cartItems.fold(0.0, (sum, item) => sum + item.taxAmount);
    final double totalItemDiscount = _cartItems.fold(0.0, (sum, item) => sum + item.discountAmount);
    final double additionalDiscount = _discount ?? 0.0;
    final double finalDiscount = totalItemDiscount + additionalDiscount;
    final double totalAmount = subtotal + totalTax - finalDiscount;

    if (_selectedBillType == 'Credit') {
      final initialPayment = double.tryParse(_initialPaymentController.text) ?? 0.0;
      if (initialPayment < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initial payment cannot be negative')),
        );
        return;
      }
      if (initialPayment > totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initial payment cannot exceed total amount')),
        );
        return;
      }
      _initialPayment = initialPayment;
    } else {
      _initialPayment = 0.0;
    }

    if (_discount == null && widget.orderId == null) {
      _discount = 0.0;
    }

    final userInfo = await sl<AccountRepository>().getUserInfo();
    final userId = userInfo?.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    final customerLedgerId = _selectedCustomer!.accountLedgerId;
    if (customerLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer ledger ID not found')),
      );
      return;
    }

    Order order = Order(
      id: widget.orderId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _selectedCustomer!.userId!,
      userName: _selectedCustomer!.name ?? _selectedCustomer!.userName ?? 'Unknown',
      items: _cartItems,
      totalAmount: totalAmount,
      status: _selectedStatus,
      orderDate: DateTime.now(),
      orderTakenBy: userId,
      storeId: _selectedStoreId,
      lastUpdatedBy: userId,
      billNumber: _existingBillNumber ?? 'BILL-${DateTime.now().millisecondsSinceEpoch}',
      discount: _discount, // Stores only additional discount
      invoiceLastUpdatedBy: userId,
      invoiceGeneratedDate: DateTime.now(),
      invoiceType: _selectedBillType,
      paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : (_initialPayment! > 0 ? 'Partially Paid' : 'Not Paid'),
      amountReceived: _selectedBillType == 'Cash' ? totalAmount : _initialPayment,
      paymentDetails: [
        if (_initialPayment! > 0)
          {
            'date': DateTime.now(),
            'amount': _initialPayment,
            'method': 'Cash',
          },
      ],
      slipNumber: null,
      customerLedgerId: customerLedgerId,
    );

    final bool confirmed = await _showReviewDialog(order);
    if (!confirmed) {
      return;
    }

    final updatedSubtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final updatedTotalTax = _cartItems.fold(0.0, (sum, item) => sum + item.taxAmount);
    final updatedTotalItemDiscount = _cartItems.fold(0.0, (sum, item) => sum + item.discountAmount);
    final updatedFinalDiscount = updatedTotalItemDiscount + (_discount ?? 0.0);
    final updatedTotalAmount = updatedSubtotal + updatedTotalTax - updatedFinalDiscount;

    order = order.copyWith(
      items: _cartItems,
      totalAmount: updatedTotalAmount,
      discount: _discount, // Stores only additional discount
      amountReceived: _selectedBillType == 'Cash' ? updatedTotalAmount : _initialPayment,
    );

    setState(() => _isLoading = true);
    try {
      final orderService = sl<IOrderService>();
      final ledgerCubit = sl<UserLedgerCubit>();
      final billNumber = order.billNumber;

      final stores = await sl<StockRepository>().getStores(userInfo?.companyId ?? '');
      final store = stores.firstWhere(
            (store) => store.storeId == _selectedStoreId,
        orElse: () => StoreDto(
          storeId: _selectedStoreId!,
          name: 'Unknown',
          createdBy: '',
          createdAt: DateTime.now(),
          accountLedgerId: null,
        ),
      );
      final storeLedgerId = store.accountLedgerId;
      if (storeLedgerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store ledger ID not found')),
        );
        setState(() => _isLoading = false);
        return;
      }

      Order? existingInvoice;
      try {
        existingInvoice = await orderService.getInvoiceById(order.id);
      } catch (e) {
        existingInvoice = null;
      }

      if (_existingBillNumber == null) {
        if (_stockCubit.state is! StockLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock data not loaded')),
          );
          setState(() => _isLoading = false);
          return;
        }

        for (var item in _cartItems) {
          final stock = (_stockCubit.state as StockLoaded).stockItems.firstWhere(
                (stock) => stock.productId == item.productId && stock.storeId == _selectedStoreId,
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
              SnackBar(content: Text('Insufficient stock for ${item.productName}')),
            );
            setState(() => _isLoading = false);
            return;
          }
          await _stockCubit.generateBill(
            stock,
            item.quantity,
            _selectedCustomer!.userId!,
            remarks: 'Bill generated for $_selectedBillType sale (Order: ${order.id})',
          );
        }

        await ledgerCubit.addTransaction(
          ledgerId: customerLedgerId,
          amount: updatedTotalAmount,
          type: 'Debit',
          billNumber: billNumber,
          purpose: 'Purchase',
          typeOfPurpose: _selectedBillType,
          remarks: 'Bill generated for order ${order.id} with discount ${updatedFinalDiscount.toStringAsFixed(2)}',
          userType: UserType.Customer,
        );

        if (_selectedBillType == 'Cash' || _initialPayment! > 0) {
          final paymentAmount = _selectedBillType == 'Cash' ? updatedTotalAmount : _initialPayment!;
          await ledgerCubit.addTransaction(
            ledgerId: customerLedgerId,
            amount: paymentAmount,
            type: 'Credit',
            billNumber: billNumber,
            purpose: 'Payment',
            typeOfPurpose: 'Cash',
            remarks: 'Payment received for bill $billNumber',
            userType: UserType.Customer,
          );
        }

        await ledgerCubit.addTransaction(
          ledgerId: storeLedgerId,
          amount: updatedTotalAmount,
          type: 'Credit',
          billNumber: billNumber,
          purpose: 'Sale',
          typeOfPurpose: _selectedBillType,
          remarks: 'Sale for bill $billNumber to customer ${_selectedCustomer!.name ?? 'Unknown'}',
          userType: UserType.Store,
        );

        if (_selectedBillType == 'Cash' || _initialPayment! > 0) {
          final paymentAmount = _selectedBillType == 'Cash' ? updatedTotalAmount : _initialPayment!;
          await ledgerCubit.addTransaction(
            ledgerId: storeLedgerId,
            amount: paymentAmount,
            type: 'Debit',
            billNumber: billNumber,
            purpose: 'Cash Received',
            typeOfPurpose: 'Cash',
            remarks: 'Cash received for bill $billNumber',
            userType: UserType.Store,
          );
        }

        await orderService.placeOrder(order);
        if (existingInvoice == null) {
          await orderService.placeInvoice(order);
        }
      } else if (widget.orderId != null) {
        final originalOrder = (await orderService.getOrderById(widget.orderId!))!;
        final returnAmount = originalOrder.totalAmount - updatedTotalAmount;

        final processedProductIds = <String>{};
        for (var item in originalOrder.items) {
          if (processedProductIds.contains(item.productId)) continue;
          processedProductIds.add(item.productId);

          final currentItem = _cartItems.firstWhere(
                (i) => i.productId == item.productId,
            orElse: () => item.copyWith(quantity: 0),
          );
          final returnQuantity = item.quantity - currentItem.quantity;
          if (returnQuantity > 0) {
            final stock = _stockCubit.state is StockLoaded
                ? (_stockCubit.state as StockLoaded).stockItems.firstWhere(
                  (stock) => stock.productId == item.productId && stock.storeId == _selectedStoreId,
              orElse: () => StockModel(
                id: '${item.productId}_$_selectedStoreId',
                productId: item.productId,
                storeId: _selectedStoreId!,
                quantity: 0,
                lastUpdated: DateTime.now(),
              ),
            )
                : null;
            if (stock == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stock data not found for ${item.productName}')),
              );
              setState(() => _isLoading = false);
              return;
            }
            await _stockCubit.updateStock(
              stock.copyWith(
                quantity: stock.quantity + returnQuantity,
                lastUpdated: DateTime.now(),
              ),
              remarks: 'Return of $returnQuantity units of ${item.productName}',
              isReturn: true,
            );
          }
        }

        if (returnAmount > 0) {
          await ledgerCubit.addTransaction(
            ledgerId: customerLedgerId,
            amount: returnAmount,
            type: 'Credit',
            billNumber: billNumber,
            purpose: 'Return',
            typeOfPurpose: _selectedBillType,
            remarks: 'Return for order ${widget.orderId}',
            userType: UserType.Customer,
          );
          if (_selectedBillType == 'Cash' && _selectedReturnMethod == 'Cash') {
            await ledgerCubit.addTransaction(
              ledgerId: customerLedgerId,
              amount: returnAmount,
              type: 'Debit',
              billNumber: billNumber,
              purpose: 'Return Payment',
              typeOfPurpose: 'Cash',
              remarks: 'Cash paid back for return for order ${widget.orderId}',
              userType: UserType.Customer,
            );
          }
        }

        if (_cartItems.isNotEmpty) {
          await ledgerCubit.addTransaction(
            ledgerId: customerLedgerId,
            amount: updatedTotalAmount,
            type: 'Debit',
            billNumber: billNumber,
            purpose: 'Purchase',
            typeOfPurpose: _selectedBillType,
            remarks: 'Bill updated for order ${order.id}',
            userType: UserType.Customer,
          );
          if (_selectedBillType == 'Cash' || _initialPayment! > 0) {
            final paymentAmount = _selectedBillType == 'Cash' ? updatedTotalAmount : _initialPayment!;
            await ledgerCubit.addTransaction(
              ledgerId: customerLedgerId,
              amount: paymentAmount,
              type: 'Credit',
              billNumber: billNumber,
              purpose: 'Payment',
              typeOfPurpose: 'Cash',
              remarks: 'Payment received for updated bill $billNumber',
              userType: UserType.Customer,
            );
          }
        }

        if (_cartItems.isNotEmpty) {
          await ledgerCubit.addTransaction(
            ledgerId: storeLedgerId,
            amount: updatedTotalAmount,
            type: 'Credit',
            billNumber: billNumber,
            purpose: 'Sale',
            typeOfPurpose: _selectedBillType,
            remarks: 'Updated sale for bill $billNumber',
            userType: UserType.Store,
          );
          if (_selectedBillType == 'Cash' || _initialPayment! > 0) {
            final paymentAmount = _selectedBillType == 'Cash' ? updatedTotalAmount : _initialPayment!;
            await ledgerCubit.addTransaction(
              ledgerId: storeLedgerId,
              amount: paymentAmount,
              type: 'Debit',
              billNumber: billNumber,
              purpose: 'Cash Received',
              typeOfPurpose: 'Cash',
              remarks: 'Cash received for updated bill $billNumber',
              userType: UserType.Store,
            );
          }
        }

        if (returnAmount > 0) {
          await ledgerCubit.addTransaction(
            ledgerId: storeLedgerId,
            amount: returnAmount,
            type: 'Debit',
            billNumber: billNumber,
            purpose: 'Return',
            typeOfPurpose: _selectedBillType,
            remarks: 'Return of stock for bill $billNumber',
            userType: UserType.Store,
          );
          if (_selectedBillType == 'Cash' && _selectedReturnMethod == 'Cash') {
            await ledgerCubit.addTransaction(
              ledgerId: storeLedgerId,
              amount: returnAmount,
              type: 'Credit',
              billNumber: billNumber,
              purpose: 'Return Payment',
              typeOfPurpose: 'Cash',
              remarks: 'Cash paid back for return for bill $billNumber',
              userType: UserType.Store,
            );
          }
        }

        await orderService.updateOrderStatus(widget.orderId!, _selectedStatus);
        await orderService.updateOrder(order);
        await orderService.updateInvoice(order);
      }

      final pdf = await _generatePdf(order);
      await sl<Coordinator>().navigateToBillPdfPage(pdf: pdf, billNumber: billNumber ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existingBillNumber == null ? 'Bill generated successfully' : 'Bill updated successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process bill: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<pw.Document> _generatePdf(Order order) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();

    String companyName = 'Abc Pvt. Ltd.';
    String issuerName = 'Unknown Issuer';
    String companyAddress = '123 Business Street, City, Country';
    String companyPhone = ''; // Not in current, so empty
    String companyEmail = ''; // Not in current, so empty
    String companyWebsite = ''; // Not in current, so empty
    String currency = '₹'; // Keep from current code; example uses IQD, but no assumption
    double customerTotalBalance = 0.0; // Not in current, so 0

    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
      issuerName = userInfo?.name ?? userInfo?.userName ?? issuerName;
    } catch (e) {
      debugPrint('Error fetching company or issuer name: $e');
    }

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    final greyColor = PdfColors.grey300;
    final rowBackgroundColor = PdfColors.grey100; // Light gray for even rows

    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    final double subtotal = order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final double totalTax = order.items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final double totalItemDiscount = order.items.fold(0.0, (sum, item) => sum + item.discountAmount);
    final double totalDiscount = totalItemDiscount + (order.discount ?? 0.0);
    final double outstandingAmount = order.totalAmount - (order.amountReceived ?? 0.0);
    final double paymentsCredits = order.amountReceived ?? 0.0;

    final String billToAddress = order.storeId ?? 'N/A'; // Use storeId as placeholder for address
    final String deliveryToAddress = billToAddress; // Same as Bill To

    // Helper function for formatting numbers with commas and no decimals
    String formatNumber(double number) {
      return number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(font: boldFont, fontSize: 18, color: primaryColor),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                  pw.Text(
                    'Invoice',
                    style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.black),
                  ),
                  pw.SizedBox(width: 50, height: 50), // Space for logo
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                companyAddress,
                style: pw.TextStyle(font: regularFont, fontSize: 12, color: textSecondaryColor),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Table(
                    columnWidths: {
                      0: pw.FixedColumnWidth(80),
                      1: pw.FixedColumnWidth(100),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Text('Date', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                          pw.Text(order.orderDate.toString().substring(0, 10), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('Invoice #', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                          pw.Text(order.billNumber ?? 'N/A', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('Due Date', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                          pw.Text(order.orderDate.toString().substring(0, 10), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Bill To', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                        pw.Container(
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: greyColor)),
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(order.userName ?? 'Unknown Customer', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                              pw.Text(billToAddress, style: pw.TextStyle(font: regularFont, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Terms', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                        pw.Container(
                          decoration: pw.BoxDecoration(border: pw.Border.all(color: greyColor)),
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(order.invoiceType ?? '', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder(
                  top: pw.BorderSide(color: greyColor, width: 1),
                  bottom: pw.BorderSide(color: greyColor, width: 1),
                  left: pw.BorderSide.none,
                  right: pw.BorderSide.none,
                  horizontalInside: pw.BorderSide.none,
                  verticalInside: pw.BorderSide(color: greyColor, width: 1),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Item', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Qty', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Rate', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Tax', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Disc. Amt', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Disc. %', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Amount', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ),
                    ],
                  ),
                  ...order.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return pw.TableRow(
                      decoration: index.isEven ? null : pw.BoxDecoration(color: rowBackgroundColor),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(item.productName, style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(item.quantity.toString(), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(formatNumber(item.price), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(formatNumber(item.taxAmount), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(formatNumber(item.discountAmount), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(formatNumber(item.discountPercentage), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(formatNumber((item.price * item.quantity) + item.taxAmount - item.discountAmount), style: pw.TextStyle(font: regularFont, fontSize: 12)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: greyColor, width: 1),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Subtotal', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                          ),
                          if (totalTax != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Total Tax', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                            ),
                          if (totalTax != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Total with Tax', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                            ),
                          if (totalItemDiscount != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Item Discounts', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                            ),
                          if (order.discount != null && order.discount != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('Additional Discount', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                            ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Total', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Payments/Credits', style: pw.TextStyle(font: regularFont, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Balance Due', style: pw.TextStyle(font: boldFont, fontSize: 14)),
                          ),
                        ],
                      ),
                      pw.SizedBox(width: 16),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(formatNumber(subtotal), style: pw.TextStyle(font: regularFont, fontSize: 12), textAlign: pw.TextAlign.right),
                          ),
                          if (totalTax != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('+${formatNumber(totalTax)}', style: pw.TextStyle(font: regularFont, fontSize: 12), textAlign: pw.TextAlign.right),
                            ),
                          if (totalTax != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(formatNumber(subtotal + totalTax), style: pw.TextStyle(font: regularFont, fontSize: 12), textAlign: pw.TextAlign.right),
                            ),
                          if (totalItemDiscount != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('-${formatNumber(totalItemDiscount)}', style: pw.TextStyle(font: regularFont, fontSize: 12), textAlign: pw.TextAlign.right),
                            ),
                          if (order.discount != null && order.discount != 0)
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text('-${formatNumber(order.discount ?? 0.0)}', style: pw.TextStyle(font: regularFont, fontSize: 12), textAlign: pw.TextAlign.right),
                            ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(formatNumber(order.totalAmount), style: pw.TextStyle(font: boldFont, fontSize: 12), textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('-${formatNumber(paymentsCredits)}', style: pw.TextStyle(font: regularFont, fontSize: 12), textAlign: pw.TextAlign.right),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(formatNumber(outstandingAmount), style: pw.TextStyle(font: boldFont, fontSize: 14), textAlign: pw.TextAlign.right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (order.paymentDetails != null && order.paymentDetails!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Payment Details',
                      style: pw.TextStyle(font: boldFont, fontSize: 18),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder(
                        top: pw.BorderSide(color: greyColor, width: 1),
                        bottom: pw.BorderSide(color: greyColor, width: 1),
                        left: pw.BorderSide.none,
                        right: pw.BorderSide.none,
                        horizontalInside: pw.BorderSide.none,
                        verticalInside: pw.BorderSide(color: greyColor, width: 1),
                      ),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text(
                                'Date',
                                style: pw.TextStyle(font: boldFont, fontSize: 13),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text(
                                'Amount',
                                style: pw.TextStyle(font: boldFont, fontSize: 13),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(10),
                              child: pw.Text(
                                'Method',
                                style: pw.TextStyle(font: boldFont, fontSize: 13),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        ...order.paymentDetails!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final payment = entry.value;
                          return pw.TableRow(
                            decoration: index.isEven ? null : pw.BoxDecoration(color: rowBackgroundColor),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  payment['date']?.toString().substring(0, 10) ?? 'N/A',
                                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                                  textAlign: pw.TextAlign.left,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  formatNumber(payment['amount'] ?? 0.0),
                                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(10),
                                child: pw.Text(
                                  payment['method'] ?? 'N/A',
                                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                                  textAlign: pw.TextAlign.left,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (companyEmail.isNotEmpty) pw.Text(companyEmail, style: pw.TextStyle(font: regularFont, fontSize: 12)),
                      if (companyWebsite.isNotEmpty) pw.Text(companyWebsite, style: pw.TextStyle(font: regularFont, fontSize: 12)),
                      if (companyPhone.isNotEmpty) pw.Text(companyPhone, style: pw.TextStyle(font: regularFont, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }  Widget _buildGenerateBillButton() {
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
    final total = _cartItems.fold<double>(0.0,
            (sum, item) => sum + (item.price * item.quantity) + item.taxAmount);
    final finalTotal = total - (_discount ?? 0.0);

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
                final item = entry.value;
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Price: ₹${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Tax Rate: ${(item.taxRate).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
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
                                    border: Border.all(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.3)),
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _showQuantityInputDialog(
                                          item.productId),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                      ),
                                      child: const Text(
                                        'Enter Manual Qty',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                                      taxAmount: 0.0);
                                                }
                                                return cartItem;
                                              }).toList();
                                          _cartItems.removeWhere(
                                                  (cartItem) =>
                                              cartItem.quantity == 0);
                                          if (_cartItems.isEmpty) {
                                            _discount = 0.0;
                                          }
                                        });
                                      }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
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
                              ],
                            ),
                          ],
                        ),
                        if (item.quantity > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                  AppColors.textSecondary.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Table(
                              border: TableBorder(
                                verticalInside: BorderSide(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.3)),
                                horizontalInside: BorderSide(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.3)),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(3),
                                1: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Text(
                                        'Subtotal (₹${item.price.toStringAsFixed(2)} x ${item.quantity})',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Text(
                                        '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Text(
                                        'Tax (${(item.taxRate).toStringAsFixed(0)}%)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Text(
                                        '₹${item.taxAmount.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      child: Text(
                                        '₹${((item.price * item.quantity) + item.taxAmount).toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
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
            const SizedBox(height: 8),
            if (_discount != null && _discount! > 0) ...[
              Text(
                'Discount: ₹${_discount!.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Total: ₹${finalTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _searchProducts(String query, List<StockModel> products,
      ValueNotifier<List<StockModel>> filteredProducts) {
    debugPrint('Dialog: Searching for "$query"');
    filteredProducts.value = query.isEmpty
        ? List.from(products)
        : products
        .where((product) =>
    product.name?.toLowerCase().contains(query.toLowerCase()) ??
        false)
        .toList();
    debugPrint('Dialog: Filtered ${filteredProducts.value.length} products');
  }

  void _showProductSelectionDialog(List<StockModel> products) {
    _productSearchController.clear();
    debugPrint('Dialog: Opening product selection dialog');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (dialogContext, scrollController) => StatefulBuilder(
          builder: (dialogContext, setState) {
            final ValueNotifier<List<StockModel>> filteredProducts =
            ValueNotifier([]);
            bool isDialogInitialized = false;

            if (!isDialogInitialized &&
                filteredProducts.value.isEmpty &&
                products.isNotEmpty) {
              setState(() {
                filteredProducts.value = List.from(products);
                isDialogInitialized = true;
              });
              debugPrint(
                  'Dialog: Initialized filteredProducts with ${filteredProducts.value.length} items');
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _productSearchController,
                    decoration: InputDecoration(
                      labelText: 'Search Products',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textSecondary),
                      hintStyle:
                      const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.textSecondary, width: 0.3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.textSecondary, width: 0.3),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: (query) =>
                        _searchProducts(query, products, filteredProducts),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<List<StockModel>>(
                    valueListenable: filteredProducts,
                    builder: (context, productsList, child) {
                      if (productsList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No products available',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textSecondary),
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: productsList.length,
                        itemBuilder: (context, index) {
                          final product = productsList[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              title: Text(
                                product.name ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Price: ₹${product.price?.toStringAsFixed(2) ?? '0.00'} | Stock: ${product.quantity}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add,
                                    color: AppColors.primary),
                                onPressed: () {
                                  _addToCart(product);
                                  setState(() {
                                    _productSearchController.clear();
                                    filteredProducts.value =
                                        List.from(products);
                                  });
                                  debugPrint(
                                      'Dialog: Added product "${product.name}"');
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
          },
        ),
      ),
    ).whenComplete(() {
      debugPrint('Dialog: Dialog closed');
    });
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
                  const Text(
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
                          _discount = state.order.discount;
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
      await showModalBottomSheet(
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
                        const Text(
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
                            borderRadius: BorderRadius.circular(8)),
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
                            await sl<UserServices>()
                                .addUserToCompany(userInfo, '');
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
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
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
      // Update parent state after dialog closes
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error')),
      );
    }
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