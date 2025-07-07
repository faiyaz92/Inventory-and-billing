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
class StockListPage extends StatefulWidget {
  const StockListPage({Key? key}) : super(key: key);

  @override
  _StockListPageState createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  String? _selectedStoreId;
  late StockCubit _stockCubit;

  @override
  void initState() {
    _stockCubit = sl<StockCubit>()..fetchStock('');
    super.initState();
  }

  void _showAddStockDialog(BuildContext context, StockModel stock) {
    int quantity = 0;
    String? remarks;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Add Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity to Add',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter quantity';
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Subtract Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity to Subtract',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter quantity';
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  void _showTransferStockDialog(BuildContext context, StockModel stock, List<StoreDto> stores) {
    String? selectedStoreId;
    int quantity = 0;
    String? remarks;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Transfer Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Transfer to Store',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  validator: (value) => value == null ? 'Please select a store' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity to Transfer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter quantity';
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _stockCubit.transferStock(stock, selectedStoreId!, quantity, remarks: remarks);
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
                      SnackBar(content: Text(state.error), backgroundColor: AppColors.red),
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
                      final stockItems = (state is StockLoaded) ? state.stockItems : [];

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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  errorStyle: const TextStyle(color: Colors.red),
                                ),
                                value: _selectedStoreId,
                                items: stores.map((store) => DropdownMenuItem<String>(
                                  value: store.storeId,
                                  child: Text(store.name),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedStoreId = value);
                                  if (value != null) {
                                    context.read<StockCubit>().fetchStock(value);
                                  }
                                },
                                validator: (value) => value == null ? 'Please select a store' : null,
                              ),
                            ),
                          ),
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
                                : stockItems.isEmpty
                                ? Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No stock available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : ListView.separated(
                              itemCount: stockItems.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () => _showAddStockDialog(context, stock),
                                          tooltip: 'Add Stock',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () => _showSubtractStockDialog(context, stock),
                                          tooltip: 'Subtract Stock',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.swap_horiz,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () => _showTransferStockDialog(context, stock, stores as List<StoreDto>),
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