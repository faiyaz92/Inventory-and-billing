import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/over_all_stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/product_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';

@RoutePage()
class OverallStockPage extends StatelessWidget {
  const OverallStockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OverallStockCubit(
        stockService: sl<StockService>(),
        productService: sl<ProductService>(),
      )..loadOverallStock(),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppLabels.overallStockTitle,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      onChanged: (query) {
                        context.read<OverallStockCubit>().searchProducts(query);
                      },
                      decoration: InputDecoration(
                        labelText: AppLabels.searchProducts,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.white.withOpacity(0.9),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<OverallStockCubit, OverallStockState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        if (state.error != null) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '${AppLabels.error}: ${state.error}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (state.productStocks.isEmpty) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  AppLabels.noStockAvailable,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        final filteredProducts = state.productStocks.where((product) {
                          final query = state.searchQuery?.toLowerCase() ?? '';
                          return product.productName.toLowerCase().contains(query) ||
                              product.productId.toLowerCase().contains(query);
                        }).toList();
                        if (filteredProducts.isEmpty) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  AppLabels.noProductsFound,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: filteredProducts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                leading: Icon(
                                  Icons.inventory,
                                  color: Theme.of(context).primaryColor,
                                  size: 36,
                                ),
                                title: Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  '${AppLabels.totalStock}: ${product.totalStock}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                                children: [
                                  Table(
                                    border: TableBorder.all(
                                      color: AppColors.grey.withOpacity(0.3),
                                    ),
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(1),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              AppLabels.store,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              AppLabels.stock,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ...product.storeStocks.entries.map((entry) {
                                        final storeName = product.storeNames[entry.key] ?? entry.key;
                                        return TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text(
                                                storeName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.black87,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text(
                                                entry.value.toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ],
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