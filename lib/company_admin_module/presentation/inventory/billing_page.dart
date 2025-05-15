import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_drop_down_widget.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_state.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';

@RoutePage()
class BillingPage extends StatefulWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStoreId;
  String? _selectedProductId;
  String? _selectedCustomerId;
  int _quantity = 0;
  double _totalPrice = 0.0;
  late TransactionCubit _transactionCubit;
  late PartnerCubit _partnerCubit;
  late StockCubit _stockCubit;
  late ProductCubit _productCubit;

  @override
  void initState() {
    _transactionCubit = sl<TransactionCubit>();
    _partnerCubit = sl<PartnerCubit>()..loadCompanies();
    _stockCubit = sl<StockCubit>()..fetchStock('');
    _productCubit = sl<ProductCubit>()..loadProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _transactionCubit),
        BlocProvider(create: (_) => _partnerCubit),
        BlocProvider(create: (_) => _stockCubit),
        BlocProvider(create: (_) => _productCubit),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Billing'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: BlocConsumer<TransactionCubit, TransactionState>(
              listener: (context, state) {
                if (state is TransactionLoaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Billing completed successfully')),
                  );
                  sl<Coordinator>().navigateBack(isUpdated: true);
                } else if (state is TransactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.error),
                        backgroundColor: AppColors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stores = context.read<StockCubit>().state is StockLoaded
                    ? (context.read<StockCubit>().state as StockLoaded).stores
                    : [];
                final products =
                    context.read<ProductCubit>().state is ProductLoaded
                        ? (context.read<ProductCubit>().state as ProductLoaded)
                            .products
                        : [];
                final customers = _partnerCubit.state is CompaniesLoadedState
                    ? (_partnerCubit.state as CompaniesLoadedState).companies
                    : [];

                return Column(
                  children: [
                    CustomDropdown(
                      labelText: 'Store',
                      selectedValue: _selectedStoreId,
                      items: stores.map((store) => store.storeId).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedStoreId = value),
                      validator: (value) =>
                          value == null ? 'Please select a store' : null,
                    ),
                    CustomDropdown(
                      labelText: 'Product',
                      selectedValue: _selectedProductId,
                      items: products.map((product) => product.id).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value;
                          if (value != null) {
                            final product = products.firstWhere(
                              (p) => p.id == value,
                              orElse: () => Product(
                                  id: value!,
                                  name: '',
                                  price: 0.0,
                                  stock: 0,
                                  category: '',
                                  categoryId: '',
                                  subcategoryId: '',
                                  subcategoryName: ''), // Fallback
                            );
                            _totalPrice = product.price * _quantity;
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a product' : null,
                    ),
                    CustomDropdown(
                      labelText: 'Customer',
                      selectedValue: _selectedCustomerId,
                      items: customers.map((customer) => customer.id).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCustomerId = value),
                      validator: (value) =>
                          value == null ? 'Please select a customer' : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _quantity = int.tryParse(value) ?? 0;
                          if (_selectedProductId != null) {
                            final product = products.firstWhere(
                              (p) => p.id == _selectedProductId,
                              orElse: () => Product(
                                  id: _selectedProductId!,
                                  name: '',
                                  price: 0.0,
                                  stock: 0,
                                  category: '',
                                  categoryId: '',
                                  subcategoryId: '',
                                  subcategoryName: ''), // Fallback
                            );
                            _totalPrice = product.price * _quantity;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Total Price: \$$_totalPrice'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final transaction = TransactionModel(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            type: 'billing',
                            productId: _selectedProductId!,
                            quantity: _quantity,
                            fromStoreId: _selectedStoreId!,
                            customerId: _selectedCustomerId,
                            timestamp: DateTime.now(),
                            userName: '',
                            userId: '',
                          );
                          _transactionCubit.createBilling(transaction);
                        }
                      },
                      child: const Text(AppLabels.saveButtonText),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
