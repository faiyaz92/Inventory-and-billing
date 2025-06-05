import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';

@RoutePage()
class AddStorePage extends StatefulWidget {
  const AddStorePage({Key? key}) : super(key: key);

  @override
  _AddStorePageState createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final _formKey = GlobalKey<FormState>();
  String? _storeName;
  String? _selectedStoreAdminId;
  late StockCubit _stockCubit;

  @override
  void initState() {
    _stockCubit = sl<StockCubit>(); // Fetch data on init
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _stockCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Add Store'),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: BlocConsumer<StockCubit, StockState>(
                      listener: (context, state) {
                        if (state is StockLoaded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Store added successfully')),
                          );
                          // sl<Coordinator>().navigateBack(isUpdated: true);
                        } else if (state is StockError) {
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
                          return const Center(child: CircularProgressIndicator());
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Store Name',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.0,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.grey[400]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.grey[400]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16.0),
                                onChanged: (value) => setState(() => _storeName = value),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a store name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 12.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final storeId =
                                    DateTime.now().millisecondsSinceEpoch.toString();
                                    final store = StoreDto(
                                      storeId: storeId,
                                      name: _storeName!,
                                      createdAt: DateTime.now(),
                                      createdBy: '',
                                    );
                                    _stockCubit.addStore(store);
                                  }
                                },
                                child: const Text(AppLabels.saveButtonText),
                              ),
                            ),
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
}