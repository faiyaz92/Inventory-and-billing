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
    final double subtotal = order.items
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final double totalTax =
    order.items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final double total = subtotal + totalTax;
    List<double> itemDiscounts = List.filled(order.items.length, 0.0);
    double additionalDiscount = (_discount ?? order.discount ?? 0.0);
    final TextEditingController discountController = TextEditingController(
      text: additionalDiscount.toStringAsFixed(2),
    );

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
                        widget.orderId == null
                            ? 'Order Summary'
                            : 'Review Bill',
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
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
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
                      border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Table(
                      border: TableBorder(
                        verticalInside: BorderSide(
                            color:
                            AppColors.textSecondary.withOpacity(0.3)),
                        horizontalInside: BorderSide(
                            color:
                            AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1),
                        5: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                          ),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Text(
                                'Product',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Text(
                                'Qty',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Text(
                                'Tax',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: Text(
                                'Discount',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
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
                          ],
                        ),
                        ...order.items.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final item = entry.value;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
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
                                    color: AppColors.textPrimary,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: TextFormField(
                                  initialValue: itemDiscounts[index].toStringAsFixed(2),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.right,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  onChanged: (value) {
                                    final disc = double.tryParse(value) ?? 0.0;
                                    itemDiscounts[index] = disc;
                                    setState(() {});
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Text(
                                  '₹${((item.price * item.quantity) + item.taxAmount - itemDiscounts[index]).toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      additionalDiscount = double.tryParse(value) ?? 0.0;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Table(
                      border: TableBorder(
                        verticalInside: BorderSide(
                            color:
                            AppColors.textSecondary.withOpacity(0.3)),
                        horizontalInside: BorderSide(
                            color:
                            AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                'Subtotal (All Items)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                '₹${subtotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                'Total Tax',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                '₹${totalTax.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                '₹${total.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                'Item Discounts',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                '₹${itemDiscounts.fold<double>(0.0, (sum, disc) => sum + disc).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                'Additional Discount',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                '₹${additionalDiscount.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
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
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                'Final Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(
                                '₹${(total - itemDiscounts.fold<double>(0.0, (sum, disc) => sum + disc) - additionalDiscount).toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 18,
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
                        final sumItemDisc = itemDiscounts.fold<double>(0.0, (sum, disc) => sum + disc);
                        // Validate item discounts
                        for (int i = 0; i < order.items.length; i++) {
                          final item = order.items[i];
                          final itemTotal = item.price * item.quantity + item.taxAmount;
                          if (itemDiscounts[i] < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Item discount cannot be negative',
                                  style: TextStyle(color: AppColors.white),
                                ),
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
                                content: Text(
                                  'Discount for ${item.productName} cannot exceed item total',
                                  style: TextStyle(color: AppColors.white),
                                ),
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
                              content: Text(
                                'Invalid additional discount',
                                style: TextStyle(color: AppColors.white),
                              ),
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
                              content: Text(
                                'Additional discount cannot exceed total after item discounts',
                                style: TextStyle(color: AppColors.white),
                              ),
                              backgroundColor: AppColors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        // Set total discount
                        this.setState(() {
                          _discount = sumItemDisc + additionalDiscount;
                        });
                        Navigator.pop(dialogContext, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    ) ??
        false;
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

    // Initialize discount for fresh orders
    if (_discount == null && widget.orderId == null) {
      setState(() {
        _discount = 0.0;
      });
    }

    // Set discount to 0 if cart is empty (full return)
    if (_cartItems.isEmpty) {
      setState(() {
        _discount = 0.0;
      });
    }

    final double subtotal =
    _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final double totalTax =
    _cartItems.fold(0.0, (sum, item) => sum + item.taxAmount);
    final double totalAmount = subtotal + totalTax - (_discount ?? 0.0);

    // Get current user ID for invoiceLastUpdatedBy
    final userInfo = await sl<AccountRepository>().getUserInfo();
    final userId = userInfo?.userId;
    if (userId == null) {
      throw Exception('User ID not found');
    }

    // Get customer ledger ID
    final customerLedgerId = _selectedCustomer!.accountLedgerId;
    if (customerLedgerId == null) {
      print('No ledger ID found for customer: ${_selectedCustomer!.name}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer ledger ID not found')),
      );
      return;
    }

    // Create a temporary Order object for review dialog
    Order tempOrder;
    if (_existingBillNumber != null && widget.orderId != null) {
      final state = _adminOrderCubit.state;
      if (state is AdminOrderFetchSuccess) {
        tempOrder = state.order.copyWith(
          items: _cartItems,
          totalAmount: totalAmount,
          status: _selectedStatus,
          orderDate: DateTime.now(),
          storeId: _selectedStoreId,
          billNumber: _existingBillNumber,
          discount: _discount ?? state.order.discount ?? 0.0,
          invoiceLastUpdatedBy: userId,
          invoiceGeneratedDate: state.order.invoiceGeneratedDate ?? DateTime.now(),
          invoiceType: _selectedBillType,
          paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : 'Not Paid',
          amountReceived: _selectedBillType == 'Cash' ? totalAmount : 0.0,
          paymentDetails: state.order.paymentDetails ?? [],
          slipNumber: state.order.slipNumber,
          customerLedgerId: customerLedgerId,
        );
      } else {
        tempOrder = Order(
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
          billNumber: _existingBillNumber,
          discount: _discount ?? 0.0,
          invoiceLastUpdatedBy: userId,
          invoiceGeneratedDate: DateTime.now(),
          invoiceType: _selectedBillType,
          paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : 'Not Paid',
          amountReceived: _selectedBillType == 'Cash' ? totalAmount : 0.0,
          paymentDetails: [],
          slipNumber: null,
          customerLedgerId: customerLedgerId,
        );
      }
    } else {
      tempOrder = Order(
        id: widget.orderId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _selectedCustomer!.userId!,
        userName:
        _selectedCustomer!.name ?? _selectedCustomer!.userName ?? 'Unknown',
        items: _cartItems,
        totalAmount: totalAmount,
        status: _selectedStatus,
        orderDate: DateTime.now(),
        orderTakenBy: userId,
        storeId: _selectedStoreId,
        lastUpdatedBy: userId,
        billNumber: 'BILL-${DateTime.now().millisecondsSinceEpoch}',
        discount: _discount ?? 0.0,
        invoiceLastUpdatedBy: userId,
        invoiceGeneratedDate: DateTime.now(),
        invoiceType: _selectedBillType,
        paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : 'Not Paid',
        amountReceived: _selectedBillType == 'Cash' ? totalAmount : 0.0,
        paymentDetails: [],
        slipNumber: null,
        customerLedgerId: customerLedgerId,
      );
    }

    // Show review dialog before generating bill
    final bool confirmed = await _showReviewDialog(tempOrder);
    if (!confirmed) {
      return;
    }

    // Recreate Order object with updated discount and invoice fields after dialog confirmation
    Order order;
    final updatedTotalAmount = subtotal + totalTax - (_discount ?? 0.0);
    if (_existingBillNumber != null && widget.orderId != null) {
      final state = _adminOrderCubit.state;
      if (state is AdminOrderFetchSuccess) {
        order = state.order.copyWith(
          items: _cartItems,
          totalAmount: updatedTotalAmount,
          status: _selectedStatus,
          orderDate: DateTime.now(),
          storeId: _selectedStoreId,
          billNumber: _existingBillNumber,
          discount: _discount ?? state.order.discount ?? 0.0,
          invoiceLastUpdatedBy: userId,
          invoiceGeneratedDate: state.order.invoiceGeneratedDate ?? DateTime.now(),
          invoiceType: _selectedBillType,
          paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : 'Not Paid',
          amountReceived: _selectedBillType == 'Cash' ? updatedTotalAmount : 0.0,
          paymentDetails: state.order.paymentDetails ?? [],
          slipNumber: state.order.slipNumber,
          customerLedgerId: customerLedgerId,
        );
      } else {
        order = Order(
          id: widget.orderId!,
          userId: _selectedCustomer!.userId!,
          userName: _selectedCustomer!.name ??
              _selectedCustomer!.userName ??
              'Unknown',
          items: _cartItems,
          totalAmount: updatedTotalAmount,
          status: _selectedStatus,
          orderDate: DateTime.now(),
          orderTakenBy: userId,
          storeId: _selectedStoreId,
          lastUpdatedBy: userId,
          billNumber: _existingBillNumber,
          discount: _discount ?? 0.0,
          invoiceLastUpdatedBy: userId,
          invoiceGeneratedDate: DateTime.now(),
          invoiceType: _selectedBillType,
          paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : 'Not Paid',
          amountReceived: _selectedBillType == 'Cash' ? updatedTotalAmount : 0.0,
          paymentDetails: [],
          slipNumber: null,
          customerLedgerId: customerLedgerId,
        );
      }
    } else {
      order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _selectedCustomer!.userId!,
        userName:
        _selectedCustomer!.name ?? _selectedCustomer!.userName ?? 'Unknown',
        items: _cartItems,
        totalAmount: updatedTotalAmount,
        status: _selectedStatus,
        orderDate: DateTime.now(),
        orderTakenBy: userId,
        storeId: _selectedStoreId,
        lastUpdatedBy: userId,
        billNumber: 'BILL-${DateTime.now().millisecondsSinceEpoch}',
        discount: _discount ?? 0.0,
        invoiceLastUpdatedBy: userId,
        invoiceGeneratedDate: DateTime.now(),
        invoiceType: _selectedBillType,
        paymentStatus: _selectedBillType == 'Cash' ? 'Paid' : 'Not Paid',
        amountReceived: _selectedBillType == 'Cash' ? updatedTotalAmount : 0.0,
        paymentDetails: [],
        slipNumber: null,
        customerLedgerId: customerLedgerId,
      );
    }

    setState(() => _isLoading = true);
    try {
      final orderService = sl<IOrderService>();
      final ledgerCubit = sl<UserLedgerCubit>();
      final billNumber = _existingBillNumber ??
          'BILL-${DateTime.now().millisecondsSinceEpoch}';
      final customerLedgerId = _selectedCustomer!.accountLedgerId;

      // Validate customer ledger ID
      if (customerLedgerId == null) {
        print('No ledger ID found for customer: ${_selectedCustomer!.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Customer ledger ID not found. Cannot process bill.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Fetch store's ledger ID
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

      // Validate store ledger ID
      if (storeLedgerId == null) {
        print('No ledger ID found for store: ${store.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Store ledger ID not found. Cannot process bill.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      print('Processing bill: billNumber=$billNumber, cartItems=${_cartItems.length}, totalAmount=$updatedTotalAmount, discount=${_discount ?? 0.0}, store=${store.name}');

      // Start PDF generation in parallel
      final pdfFuture = _generatePdf(order); // Start PDF generation immediately

      // Check if invoice already exists
      Order? existingInvoice;
      try {
        existingInvoice = await orderService.getInvoiceById(order.id);
      } catch (e) {
        existingInvoice = null; // Invoice doesn't exist
      }

      if (_existingBillNumber == null) {
        // New order: Validate and update stock
        if (_stockCubit.state is! StockLoaded) {
          print('Stock state is not StockLoaded: ${_stockCubit.state.runtimeType}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock data not loaded')),
          );
          setState(() => _isLoading = false);
          return;
        }

        for (var item in _cartItems) {
          final stock = (_stockCubit.state as StockLoaded).stockItems.firstWhere(
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
          print('Validating stock for ${item.productName}: available=${stock.quantity}, required=${item.quantity}, stockId=${stock.id}');
          if (stock.quantity < item.quantity) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Insufficient stock for ${item.productName}')),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        // Update stock for new order
        for (var item in _cartItems) {
          final stock = (_stockCubit.state as StockLoaded).stockItems.firstWhere(
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
          print('Generating bill for ${item.productName}, quantity=${item.quantity}, stockId=${stock.id}, currentStock=${stock.quantity}');
          await _stockCubit.generateBill(
            stock,
            item.quantity,
            _selectedCustomer!.userId!,
            remarks:
            'Bill generated for $_selectedBillType sale (Order: ${order.id})',
          );
        }

        // Customer ledger entries
        await ledgerCubit.addTransaction(
          ledgerId: customerLedgerId,
          amount: updatedTotalAmount,
          type: 'Debit',
          billNumber: billNumber,
          purpose: 'Purchase',
          typeOfPurpose: _selectedBillType,
          remarks: 'Bill generated for order ${order.id} with discount ₹${(_discount ?? 0.0).toStringAsFixed(2)}',
          userType: UserType.Customer,
        );

        if (_selectedBillType == 'Cash') {
          await ledgerCubit.addTransaction(
            ledgerId: customerLedgerId,
            amount: updatedTotalAmount,
            type: 'Credit',
            billNumber: billNumber,
            purpose: 'Payment',
            typeOfPurpose: 'Cash',
            remarks: 'Payment received for bill $billNumber with discount ₹${(_discount ?? 0.0).toStringAsFixed(2)}',
            userType: UserType.Customer,
          );
        }

        // Store ledger entries for new order
        await ledgerCubit.addTransaction(
          ledgerId: storeLedgerId,
          amount: updatedTotalAmount,
          type: 'Credit',
          billNumber: billNumber,
          purpose: 'Sale',
          typeOfPurpose: _selectedBillType,
          remarks: 'Sale of stock for bill $billNumber to customer ${_selectedCustomer!.name ?? 'Unknown'} with discount ₹${(_discount ?? 0.0).toStringAsFixed(2)}',
          userType: UserType.Store,
        );

        if (_selectedBillType == 'Cash') {
          await ledgerCubit.addTransaction(
            ledgerId: storeLedgerId,
            amount: updatedTotalAmount,
            type: 'Debit',
            billNumber: billNumber,
            purpose: 'Cash Received',
            typeOfPurpose: 'Cash',
            remarks: 'Cash received for bill $billNumber from customer ${_selectedCustomer!.name ?? 'Unknown'}',
            userType: UserType.Store,
          );
        }

        order = order.copyWith(billNumber: billNumber);
        await orderService.placeOrder(order);
        if (existingInvoice == null) {
          await orderService.placeInvoice(order);
        }
      } else {
        if (widget.orderId != null) {
          final originalOrder = (await orderService.getOrderById(widget.orderId!))!;
          final returnAmount = originalOrder.totalAmount - updatedTotalAmount;

          final processedProductIds = <String>{};
          print('Starting return processing for order ${widget.orderId}, originalItems=${originalOrder.items.length}, currentItems=${_cartItems.length}');

          for (var item in originalOrder.items) {
            if (processedProductIds.contains(item.productId)) {
              print('Skipping duplicate item ${item.productName}, productId=${item.productId}');
              continue;
            }
            processedProductIds.add(item.productId);

            final currentItem = _cartItems.firstWhere(
                  (i) => i.productId == item.productId,
              orElse: () => item.copyWith(quantity: 0),
            );
            final returnQuantity = item.quantity - currentItem.quantity;
            if (returnQuantity > 0) {
              final stock = _stockCubit.state is StockLoaded
                  ? (_stockCubit.state as StockLoaded).stockItems.firstWhere(
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
              if (stock == null) {
                print('Stock not found for ${item.productName}, productId=${item.productId}, storeId=$_selectedStoreId');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                      Text('Stock data not found for ${item.productName}')),
                );
                setState(() => _isLoading = false);
                return;
              }
              print('Returning stock for ${item.productName}, returnQuantity=$returnQuantity, stockId=${stock.id}, currentStock=${stock.quantity}, newStock=${stock.quantity + returnQuantity}');
              await _stockCubit.updateStock(
                stock.copyWith(
                  quantity: stock.quantity + returnQuantity,
                  lastUpdated: DateTime.now(),
                ),
                remarks: 'Return of $returnQuantity units of ${item.productName}',
                isReturn: true,
              );
              print('Stock updated for ${item.productName}, newStock=${stock.quantity + returnQuantity}');
            } else {
              print('No return for ${item.productName}, returnQuantity=$returnQuantity');
            }
          }
          print('Completed return processing, processed ${processedProductIds.length} items');

          final totalOriginalQuantity = originalOrder.items.fold<int>(
              0, (sum, item) => sum + item.quantity);
          final totalCurrentQuantity =
          _cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
          if (totalOriginalQuantity > totalCurrentQuantity && returnAmount > 0) {
            await ledgerCubit.addTransaction(
              ledgerId: customerLedgerId,
              amount: returnAmount,
              type: 'Credit',
              billNumber: billNumber,
              purpose: 'Return',
              typeOfPurpose: _selectedBillType,
              remarks:
              'Return for order ${widget.orderId} (credited ₹${returnAmount.toStringAsFixed(2)} after discount ₹${(_discount ?? 0.0).toStringAsFixed(2)})',
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
                remarks:
                'Cash paid back for return for order ${widget.orderId} (₹${returnAmount.toStringAsFixed(2)})',
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
              remarks: 'Bill updated for order ${order.id} with discount ₹${(_discount ?? 0.0).toStringAsFixed(2)}',
              userType: UserType.Customer,
            );
            if (_selectedBillType == 'Cash') {
              await ledgerCubit.addTransaction(
                ledgerId: customerLedgerId,
                amount: updatedTotalAmount,
                type: 'Credit',
                billNumber: billNumber,
                purpose: 'Payment',
                typeOfPurpose: 'Cash',
                remarks: 'Payment received for updated bill $billNumber with discount ₹${(_discount ?? 0.0).toStringAsFixed(2)}',
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
              remarks: 'Updated sale for bill $billNumber to customer ${_selectedCustomer!.name ?? 'Unknown'} with discount ₹${(_discount ?? 0.0).toStringAsFixed(2)}',
              userType: UserType.Store,
            );

            if (_selectedBillType == 'Cash') {
              await ledgerCubit.addTransaction(
                ledgerId: storeLedgerId,
                amount: updatedTotalAmount,
                type: 'Debit',
                billNumber: billNumber,
                purpose: 'Cash Received',
                typeOfPurpose: 'Cash',
                remarks: 'Cash received for updated bill $billNumber from customer ${_selectedCustomer!.name ?? 'Unknown'}',
                userType: UserType.Store,
              );
            }
          }

          if (totalOriginalQuantity > totalCurrentQuantity && returnAmount > 0) {
            await ledgerCubit.addTransaction(
              ledgerId: storeLedgerId,
              amount: returnAmount,
              type: 'Debit',
              billNumber: billNumber,
              purpose: 'Return',
              typeOfPurpose: _selectedBillType,
              remarks: 'Return of stock for bill $billNumber (debited ₹${returnAmount.toStringAsFixed(2)})',
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
                remarks: 'Cash paid back for return for bill $billNumber (₹${returnAmount.toStringAsFixed(2)})',
                userType: UserType.Store,
              );
            }
          }

          await orderService.updateOrderStatus(widget.orderId!, _selectedStatus);
          await orderService.updateOrder(order);
          await orderService.updateInvoice(order);
        }
      }

      // Await the PDF generation that was started earlier
      final pdf = await pdfFuture;

      await sl<Coordinator>()
          .navigateToBillPdfPage(pdf: pdf, billNumber: billNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existingBillNumber == null
              ? 'Bill generated successfully'
              : 'Bill updated successfully'),
        ),
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

    final double subtotal = order.items
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final double totalTax =
    order.items.fold(0.0, (sum, item) => sum + item.taxAmount);

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
                  pw.Text(
                    'Invoice Type: ${order.invoiceType ?? 'N/A'}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Payment Status: ${order.paymentStatus ?? 'N/A'}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  if (order.amountReceived != null)
                    pw.Text(
                      'Amount Received: ${order.amountReceived!.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                  if (order.slipNumber != null)
                    pw.Text(
                      'Slip Number: ${order.slipNumber}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                  if (order.invoiceLastUpdatedBy != null)
                    pw.Text(
                      'Last Updated By: ${order.invoiceLastUpdatedBy}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                  if (order.invoiceGeneratedDate != null)
                    pw.Text(
                      'Invoice Generated: ${order.invoiceGeneratedDate!.toString().substring(0, 10)}',
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
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
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
          if (order.paymentDetails != null && order.paymentDetails!.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Details',
                  style: pw.TextStyle(font: boldFont, fontSize: 18),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: greyColor, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text('Date',
                              style: pw.TextStyle(font: boldFont, fontSize: 13)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text('Amount',
                              style: pw.TextStyle(font: boldFont, fontSize: 13)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text('Method',
                              style: pw.TextStyle(font: boldFont, fontSize: 13)),
                        ),
                      ],
                    ),
                    ...order.paymentDetails!.map((payment) => pw.TableRow(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                            bottom:
                            pw.BorderSide(color: greyColor, width: 0.5)),
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            payment['date']?.toString().substring(0, 10) ??
                                'N/A',
                            style:
                            pw.TextStyle(font: regularFont, fontSize: 12),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            payment['amount']?.toStringAsFixed(2) ?? '0.00',
                            style:
                            pw.TextStyle(font: regularFont, fontSize: 12),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            payment['method'] ?? 'N/A',
                            style:
                            pw.TextStyle(font: regularFont, fontSize: 12),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
                pw.SizedBox(height: 24),
              ],
            ),
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
                      'Subtotal: ${subtotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Total Tax: ${totalTax.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Discount: ${(order.discount ?? 0.0).toStringAsFixed(2)}',
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