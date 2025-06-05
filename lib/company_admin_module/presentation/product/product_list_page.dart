import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/admin_product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final Coordinator _coordinator = sl<Coordinator>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminProductCubit>(
      create: (_) => sl<AdminProductCubit>()..loadProducts(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Product List'),
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
            child: BlocBuilder<AdminProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return Container(
                    height: 10, // Compact height for loading card
                    padding: const EdgeInsets.all(16.0),
                    child:
                        const Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is ProductError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (state is ProductLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.products.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListTile(
                              title: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                '₹${product.price}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      _coordinator
                                          .navigateToAddEditProductPage(
                                              product: product)
                                          .then((value) {
                                        if (value) {
                                          context
                                              .read<AdminProductCubit>()
                                              .loadProducts();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => context
                                        .read<AdminProductCubit>()
                                        .deleteProduct(product.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No Products Available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
          onPressed: () {
            _coordinator.navigateToAddEditProductPage();
          },
        ),
      ),
    );
  }
}
