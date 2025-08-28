import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

// Loading overlay widget for single loader
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({Key? key, required this.isLoading, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

@RoutePage()
class StockListPage extends StatefulWidget {
  const StockListPage({Key? key}) : super(key: key);

  @override
  _StockListPageState createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  String? _selectedStoreId;
  late StockCubit _stockCubit;
  String _searchQuery = '';

  @override
  void initState() {
    _stockCubit = sl<StockCubit>()..fetchStock('');
    super.initState();
  }

  @override
  void dispose() {
    _stockCubit.close();
    super.dispose();
  }

  double _calculateStockValue(List<StockModel> stockItems) {
    return stockItems.fold(0.0, (sum, item) {
      final price = item.price ?? 0.0;
      return sum + (price * item.quantity);
    });
  }

  void _showAddStockDialog(BuildContext context, StockModel stock) {
    int quantity = 0;
    String? remarks;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Add Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity to Add',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter quantity';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => remarks = value.isEmpty ? null : value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedStock = StockModel(
                    id: stock.id,
                    productId: stock.productId,
                    storeId: stock.storeId,
                    quantity: stock.quantity + quantity,
                    lastUpdated: DateTime.now(),
                    name: stock.name,
                    price: stock.price,
                    stock: stock.stock,
                    category: stock.category,
                    categoryId: stock.categoryId,
                    subcategoryId: stock.subcategoryId,
                    subcategoryName: stock.subcategoryName,
                    tax: stock.tax,
                  );
                  _stockCubit.updateStock(updatedStock, remarks: remarks);
                  Navigator.pop(context);
                }
              },
              child: const Text(AppLabels.saveButtonText),
            ),
          ],
        );
      },
    );
  }

  void _showSubtractStockDialog(BuildContext context, StockModel stock) {
    int quantity = 0;
    String? remarks;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Subtract Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity to Subtract',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter quantity';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    if (int.parse(value) > stock.quantity) {
                      return 'Quantity exceeds available stock';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => remarks = value.isEmpty ? null : value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _stockCubit.subtractStock(stock, quantity, remarks: remarks);
                  Navigator.pop(context);
                }
              },
              child: const Text(AppLabels.saveButtonText),
            ),
          ],
        );
      },
    );
  }

  void _showTransferStockDialog(BuildContext context,
      List<StockModel> stockItems, List<StoreDto> stores) {
    String? selectedStoreId;
    String? remarks;
    bool generatePdf = true;
    List<Map<String, dynamic>> transferEntries = [];
    bool isLoading = false;
    String? selectedStockId;
    final _formKey = GlobalKey<FormState>();

    void addToTransferEntries(StockModel stock, int quantity) {
      if (quantity <= 0 || quantity > stock.quantity) return;
      final existingEntry = transferEntries.firstWhere(
            (entry) => entry['stock'].id == stock.id,
        orElse: () => {'stock': stock, 'quantity': 0},
      );
      if (!transferEntries.contains(existingEntry)) {
        transferEntries.add({'stock': stock, 'quantity': quantity});
      } else {
        transferEntries = transferEntries.map((entry) {
          if (entry['stock'].id == stock.id) {
            return {'stock': stock, 'quantity': quantity};
          }
          return entry;
        }).toList();
      }
      transferEntries.removeWhere((entry) => entry['quantity'] <= 0);
    }

    void updateTransferEntryQuantity(String stockId, int change) {
      transferEntries = transferEntries.map((entry) {
        if (entry['stock'].id == stockId) {
          final newQuantity =
          (entry['quantity'] + change).clamp(0, entry['stock'].quantity);
          return {'stock': entry['stock'], 'quantity': newQuantity};
        }
        return entry;
      }).toList();
      transferEntries.removeWhere((entry) => entry['quantity'] <= 0);
    }

    void clearTransferEntry(String stockId) {
      transferEntries.removeWhere((entry) => entry['stock'].id == stockId);
    }

    void showQuantityInputDialog(StockModel stock, {int initialQuantity = 1}) {
      final TextEditingController quantityController =
      TextEditingController(text: initialQuantity.toString());
      final _dialogFormKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Set Quantity for ${stock.name ?? 'Unknown'}'),
          content: Form(
            key: _dialogFormKey,
            child: TextFormField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                if (parsedValue > stock.quantity) {
                  return 'Quantity exceeds available stock (${stock.quantity})';
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
                  addToTransferEntries(stock, quantity);
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return LoadingOverlay(
              isLoading: isLoading,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Transfer Stock'),
                content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Transfer to Store',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          value: selectedStoreId,
                          items: stores
                              .where((store) => !stockItems.any(
                                  (stock) => stock.storeId == store.storeId))
                              .map((store) => DropdownMenuItem(
                            value: store.storeId,
                            child: Text(store.name),
                          ))
                              .toList(),
                          onChanged: (value) =>
                              setDialogState(() => selectedStoreId = value),
                          validator: (value) =>
                          value == null ? 'Please select a store' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Add Stock Item',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          value: null,
                          hint: const Text('Select a product to add'),
                          items: stockItems
                              .where((stock) => stock.quantity > 0)
                              .map((stock) => DropdownMenuItem(
                            value: stock.id,
                            child: Text(stock.name ?? 'Unknown'),
                          ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              final selectedStock = stockItems
                                  .firstWhere((stock) => stock.id == value);
                              setDialogState(() {
                                addToTransferEntries(selectedStock, 1);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transfer Entries',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (transferEntries.isEmpty)
                              const Text(
                                'No stock items selected',
                                style:
                                TextStyle(fontSize: 16, color: Colors.grey),
                              )
                            else
                              ...transferEntries.asMap().entries.map((entry) {
                                final stock =
                                entry.value['stock'] as StockModel;
                                final quantity = entry.value['quantity'] as int;
                                final double price = stock.price ?? 0.0;
                                final double taxRate = stock.tax ?? 0.0;
                                final double subtotal = price * quantity;
                                final double taxAmount =
                                    subtotal * (taxRate / 100);
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stock.name ?? 'Unknown',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Price: ₹${price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                  Text(
                                                    'Tax: ${taxRate.toStringAsFixed(0)}%',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        24),
                                                    border: Border.all(
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.remove,
                                                          color: quantity > 0
                                                              ? Colors.red
                                                              : Colors.grey,
                                                          size: 20,
                                                        ),
                                                        onPressed: () =>
                                                            setDialogState(() =>
                                                                updateTransferEntryQuantity(
                                                                    stock.id,
                                                                    -1)),
                                                      ),
                                                      SizedBox(
                                                        width: 48,
                                                        child: Text(
                                                          '$quantity',
                                                          textAlign:
                                                          TextAlign.center,
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w600),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.add,
                                                            color: Colors.green,
                                                            size: 20),
                                                        onPressed: () =>
                                                            setDialogState(() =>
                                                                updateTransferEntryQuantity(
                                                                    stock.id,
                                                                    1)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          showQuantityInputDialog(
                                                              stock,
                                                              initialQuantity:
                                                              quantity),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8)),
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                      ),
                                                      child: const Text(
                                                        'Enter Qty',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          setDialogState(() =>
                                                              clearTransferEntry(
                                                                  stock.id)),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                        Colors.red,
                                                        shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8)),
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                      ),
                                                      child: const Text(
                                                        'Clear',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
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
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.3)),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Table(
                                              border: TableBorder(
                                                verticalInside: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.3)),
                                                horizontalInside: BorderSide(
                                                    color: Colors.grey
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
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      child: Text(
                                                        'Subtotal (₹${price.toStringAsFixed(2)} x $quantity)',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      child: Text(
                                                        '₹${subtotal.toStringAsFixed(2)}',
                                                        textAlign:
                                                        TextAlign.right,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      child: Text(
                                                        'Tax (${taxRate.toStringAsFixed(0)}%)',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      child: Text(
                                                        '₹${taxAmount.toStringAsFixed(2)}',
                                                        textAlign:
                                                        TextAlign.right,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.05),
                                                    borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                      Radius.circular(12),
                                                      bottomRight:
                                                      Radius.circular(12),
                                                    ),
                                                  ),
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      child: Text(
                                                        'Total',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .w700),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 12),
                                                      child: Text(
                                                        '₹${(subtotal + taxAmount).toStringAsFixed(2)}',
                                                        textAlign:
                                                        TextAlign.right,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight
                                                                .w700),
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
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Remarks (Optional)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: (value) =>
                          remarks = value.isEmpty ? null : value,
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Generate PDF Report'),
                          value: generatePdf,
                          onChanged: (value) =>
                              setDialogState(() => generatePdf = value ?? true),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: transferEntries.isEmpty || selectedStoreId == null
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setDialogState(() => isLoading = true);
                        final userInfo =
                        await sl<AccountRepository>().getUserInfo();
                        final companyId =
                            userInfo?.companyId ?? 'Unknown';
                        final transferId = DateTime.now()
                            .millisecondsSinceEpoch
                            .toString();
                        final ledgerCubit = sl<UserLedgerCubit>();
                        final storesList = await sl<StockRepository>()
                            .getStores(companyId);

                        final fromStore = storesList.firstWhere(
                              (store) =>
                          store.storeId == stockItems.first.storeId,
                          orElse: () => StoreDto(
                            storeId: stockItems.first.storeId,
                            name: 'Unknown',
                            createdBy: '',
                            createdAt: DateTime.now(),
                            accountLedgerId: null,
                          ),
                        );
                        final toStore = storesList.firstWhere(
                              (store) => store.storeId == selectedStoreId,
                          orElse: () => StoreDto(
                            storeId: selectedStoreId!,
                            name: 'Unknown',
                            createdBy: '',
                            createdAt: DateTime.now(),
                            accountLedgerId: null,
                          ),
                        );

                        if (fromStore.accountLedgerId == null ||
                            toStore.accountLedgerId == null) {
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ledger ID missing for ${fromStore.accountLedgerId == null ? 'source' : 'destination'} store',
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          for (var entry in transferEntries) {
                            final stock = entry['stock'] as StockModel;
                            final quantity = entry['quantity'] as int;
                            final price = stock.price ?? 0.0;
                            final taxRate = stock.tax ?? 0.0;
                            final amount = (price * quantity) +
                                (price * quantity * (taxRate / 100));

                            await _stockCubit.transferStock(
                              stock,
                              selectedStoreId!,
                              quantity,
                              remarks: remarks,
                            );

                            await ledgerCubit.addTransaction(
                              ledgerId: fromStore.accountLedgerId!,
                              amount: amount,
                              type: 'Credit',
                              billNumber: 'TRANSFER-$transferId',
                              purpose: 'Stock Transfer Out',
                              typeOfPurpose: 'Transfer',
                              remarks:
                              'Transferred $quantity units of ${stock.name ?? 'Unknown'} to store ${toStore.name} (Transfer ID: $transferId)',
                              userType: UserType.Store,
                            );

                            await ledgerCubit.addTransaction(
                              ledgerId: toStore.accountLedgerId!,
                              amount: amount,
                              type: 'Debit',
                              billNumber: 'TRANSFER-$transferId',
                              purpose: 'Stock Transfer In',
                              typeOfPurpose: 'Transfer',
                              remarks:
                              'Received $quantity units of ${stock.name ?? 'Unknown'} from store ${fromStore.name} (Transfer ID: $transferId)',
                              userType: UserType.Store,
                            );
                          }

                          if (generatePdf) {
                            final pdf = await _generateTransferPdf(
                              transferId,
                              stockItems.first.storeId,
                              selectedStoreId!,
                              transferEntries,
                              userInfo?.userName ?? 'Unknown',
                              companyId,
                            );
                            await sl<Coordinator>().navigateToBillPdfPage(
                              pdf: pdf,
                              billNumber: 'TRANSFER-$transferId',
                            );
                          }

                          await _stockCubit
                              .fetchStock(stockItems.first.storeId);
                          setDialogState(() => isLoading = false);
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Stock transferred successfully')),
                          );
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text('Failed to transfer stock: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(AppLabels.saveButtonText),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<pw.Document> _generateTransferPdf(
      String transferId,
      String fromStoreId,
      String toStoreId,
      List<Map<String, dynamic>> transferEntries,
      String issuerName,
      String companyId) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();
    String companyName = 'Abc Pvt. Ltd.';
    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
    } catch (e) {
      print('Error fetching company name: $e');
    }

    final stores = await sl<StockRepository>().getStores(companyId);
    final fromStore = stores.firstWhere(
          (store) => store.storeId == fromStoreId,
      orElse: () => StoreDto(
          storeId: fromStoreId,
          name: 'Unknown',
          createdBy: '',
          createdAt: DateTime.now()),
    );
    final toStore = stores.firstWhere(
          (store) => store.storeId == toStoreId,
      orElse: () => StoreDto(
          storeId: toStoreId,
          name: 'Unknown',
          createdBy: '',
          createdAt: DateTime.now()),
    );

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    final greyColor = PdfColors.grey300;

    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    final double subtotal = transferEntries.fold(
      0.0,
          (sum, entry) =>
      sum +
          ((entry['stock'] as StockModel).price ?? 0.0) * entry['quantity'],
    );
    final double totalTax = transferEntries.fold(
      0.0,
          (sum, entry) {
        final stock = entry['stock'] as StockModel;
        final price = stock.price ?? 0.0;
        final taxRate = stock.tax ?? 0.0;
        return sum + (price * entry['quantity'] * (taxRate / 100));
      },
    );

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
                    'STOCK TRANSFER',
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 28, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Transfer #: TRANSFER-$transferId',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Date: ${DateTime.now().toString().substring(0, 10)}',
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
            'Transfer Details:',
            style: pw.TextStyle(
                font: boldFont, fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'From Store: ${fromStore.name}',
            style:
            pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
          ),
          pw.Text(
            'To Store: ${toStore.name}',
            style:
            pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
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
              ...transferEntries.map((entry) {
                final stock = entry['stock'] as StockModel;
                final quantity = entry['quantity'] as int;
                final price = stock.price ?? 0.0;
                final taxRate = stock.tax ?? 0.0;
                final taxAmount = price * quantity * (taxRate / 100);
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(color: greyColor, width: 0.5)),
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        stock.name ?? 'Unknown',
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                        softWrap: true,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        quantity.toString(),
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        price.toStringAsFixed(2),
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        taxAmount.toStringAsFixed(2),
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        ((price * quantity) + taxAmount).toStringAsFixed(2),
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                );
              }).toList(),
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
                      'Total Amount: ${(subtotal + totalTax).toStringAsFixed(2)}',
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

  Widget _buildStockValueCard(double totalStockValue, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final state = _stockCubit.state;
                    if (state is StockLoaded && _selectedStoreId != null) {
                      final pdf = await _generateStockValuePdf(
                        totalStockValue,
                        _selectedStoreId!,
                        state.stores,
                      );
                      sl<Coordinator>().navigateToBillPdfPage(
                        pdf: pdf,
                        billNumber:
                        'Stock_Value_${_selectedStoreId}_${DateTime.now().millisecondsSinceEpoch}',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(40, 40),
                  ),
                  child: const Text(
                    'Export as PDF',
                    style: TextStyle(fontSize: 12, color: AppColors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                border:
                Border.all(color: AppColors.textSecondary.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory,
                    color: AppColors.primary,
                    size: kIsWeb ? 28 : 24,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Stock Value',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${totalStockValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _generateStockValuePdf(
      double totalStockValue, String storeId, List<StoreDto> stores) async {
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

    final store = stores.firstWhere(
          (s) => s.storeId == storeId,
      orElse: () => StoreDto(
        storeId: storeId,
        name: 'Unknown Store',
        createdBy: '',
        createdAt: DateTime.now(),
        accountLedgerId: null,
      ),
    );

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    const greyColor = PdfColors.grey300;

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
                    'STOCK VALUE REPORT',
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 28, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Store: ${store.name}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Date: ${DateTime.now().toString().substring(0, 10)}',
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
            'Stock Value',
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: greyColor, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(6),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Label',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Value',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Total Stock Value',
                        style: pw.TextStyle(font: regularFont, fontSize: 12)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      '₹${totalStockValue.toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
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
    return BlocProvider(
      create: (_) => _stockCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Stock List'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocConsumer<StockCubit, StockState>(
                listener: (context, state) {
                  if (state is StockError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.error),
                          backgroundColor: AppColors.red),
                    );
                  }
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
                      }

                      final stores = (state is StockLoaded) ? state.stores : [];
                      final stockItems =
                      (state is StockLoaded) ? state.stockItems : [];
                      final totalStockValue = _calculateStockValue(stockItems as List<StockModel>);

                      final filteredItems = stockItems
                          .where((item) =>
                      item.name?.toLowerCase().contains(_searchQuery) ??
                          false)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Store',
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  errorStyle:
                                  const TextStyle(color: Colors.red),
                                ),
                                value: _selectedStoreId,
                                items: stores
                                    .map((store) => DropdownMenuItem<String>(
                                  value: store.storeId,
                                  child: Text(store.name),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedStoreId = value);
                                  if (value != null) {
                                    context
                                        .read<StockCubit>()
                                        .fetchStock(value);
                                  }
                                },
                                validator: (value) => value == null
                                    ? 'Please select a store'
                                    : null,
                              ),
                            ),
                          ),
                          if (_selectedStoreId != null) ...[
                            const SizedBox(height: 16),
                            _buildStockValueCard(totalStockValue, context),
                          ],
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _selectedStoreId == null
                                ? Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Please select a store',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : filteredItems.isEmpty
                                ? Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    _searchQuery.isEmpty
                                        ? 'No stock available'
                                        : 'No products found matching "$_searchQuery"',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : ListView.separated(
                              itemCount: filteredItems.length,
                              separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final stock = filteredItems[index];
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.inventory,
                                      color: Theme.of(context)
                                          .primaryColor,
                                      size: 36,
                                    ),
                                    title: Text(
                                      stock.name ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Quantity: ${stock.quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          ),
                                          onPressed: () =>
                                              _showAddStockDialog(
                                                  context, stock),
                                          tooltip: 'Add Stock',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          ),
                                          onPressed: () =>
                                              _showSubtractStockDialog(
                                                  context, stock),
                                          tooltip: 'Subtract Stock',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.swap_horiz,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          ),
                                          onPressed: () =>
                                              _showTransferStockDialog(
                                                  context,
                                                  filteredItems as List<StockModel>,
                                                  stores as List<StoreDto>),
                                          tooltip: 'Transfer Stock',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
    );
  }
}