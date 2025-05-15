import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';

@RoutePage()
class StoreDetailsPage extends StatefulWidget {
  final String storeId;

  const StoreDetailsPage({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> {
  late StockCubit _stockCubit;

  @override
  void initState() {
    _stockCubit = sl<StockCubit>()..fetchStock(widget.storeId);
    super.initState();
  }

  // Dialog to add stock
  void _showAddStockDialog(BuildContext context, StockModel stock) {
    int quantity = 0;
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
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Quantity to Add',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  );
                  _stockCubit.updateStock(updatedStock);
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

  // Dialog to transfer stock to another store
  void _showTransferStockDialog(
      BuildContext context, StockModel stock, List<StoreDto> stores) {
    String? selectedStoreId;
    int quantity = 0;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Transfer Stock'),
          content: Form(
            key: _formKey,
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
                      .where((store) => store.storeId != stock.storeId)
                      .map((store) => DropdownMenuItem(
                            value: store.storeId,
                            child: Text(store.name),
                          ))
                      .toList(),
                  onChanged: (value) => selectedStoreId = value,
                  validator: (value) =>
                      value == null ? 'Please select a store' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity to Transfer',
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
                  _stockCubit.transferStock(stock, selectedStoreId!, quantity);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _stockCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Store Details'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  BlocBuilder<StockCubit, StockState>(
                    builder: (context, state) {
                      String storeName = 'Store';
                      if (state is StockLoaded) {
                        final store = state.stores.firstWhere(
                          (s) => s.storeId == widget.storeId,
                          orElse: () => StoreDto(
                              storeId: widget.storeId,
                              name: 'Store',
                              createdBy: '', createdAt: DateTime.timestamp()),
                        );
                        storeName = store.name;
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Store Name: $storeName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Stock List
                  Expanded(
                    child: BlocConsumer<StockCubit, StockState>(
                      listener: (context, state) {
                        if (state is StockError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is StockLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is StockError) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Error: ${state.error}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () => _stockCubit
                                          .fetchStock(widget.storeId),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final stockItems =
                            (state is StockLoaded) ? state.stockItems : [];
                        final stores =
                            (state is StockLoaded) ? state.stores : [];

                        if (stockItems.isEmpty) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No stock found for this store',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: stockItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final stock = stockItems[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.inventory,
                                  color: Theme.of(context).primaryColor,
                                  size: 36,
                                ),
                                title: Text(
                                  'Product ID: ${stock.productId}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Quantity: ${stock.quantity}\nLast Updated: ${stock.lastUpdated.toString().substring(0, 16)}',
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
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () =>
                                          _showAddStockDialog(context, stock),
                                      tooltip: 'Add Stock',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.swap_horiz,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () => _showTransferStockDialog(
                                          context, stock, stores as List<StoreDto>),
                                      tooltip: 'Transfer Stock',
                                    ),
                                  ],
                                ),
                              ),
                            );
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
      ),
    );
  }
}
