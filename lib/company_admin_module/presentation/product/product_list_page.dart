import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_state.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart'; // For GetIt injection

@RoutePage()
class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final Coordinator _coordinator = sl<Coordinator>(); // Inject Coordinator

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductCubit>(
      create: (_) =>
          sl<ProductCubit>()..loadProducts(), // Use GetIt for ProductCubit
      child: Scaffold(
        appBar: AppBar(title: const Text('Product List')),
        body: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is ProductLoaded) {
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('₹${product.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _coordinator
                                .navigateToAddEditProductPage(product: product)
                                .then((value) {
                              if (value) {
                                context.read<ProductCubit>().loadProducts();
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context
                              .read<ProductCubit>()
                              .deleteProduct(product.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('No Products Available'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            _coordinator.navigateToAddEditProductPage();
          },
        ),
      ),
    );
  }
}
