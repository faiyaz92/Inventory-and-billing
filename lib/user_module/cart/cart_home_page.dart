import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/user_module/cart/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/product_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/wish_list_cubit.dart';
@RoutePage()
class CartHomePage extends StatefulWidget {
  const CartHomePage({Key? key}) : super(key: key);

  @override
  _CartHomePageState createState() => _CartHomePageState();
}

class _CartHomePageState extends State<CartHomePage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProductCubit>()..fetchProducts()),
        BlocProvider(create: (_) => sl<CartCubit>()),
        BlocProvider(create: (_) => sl<WishlistCubit>()),
      ],
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Home',
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.pushNamed(context, '/wishlist'),
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Menu')),
              ListTile(
                title: const Text('Orders'),
                onTap: () => Navigator.pushNamed(context, '/order-list'),
              ),
              ListTile(
                title: const Text('Settings'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  labelText: 'Search Products',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is ProductLoaded) {
                    final products = state.products
                        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('₹${product.price}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () => context.read<WishlistCubit>().addToWishlist(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: () => context.read<CartCubit>().addToCart(product, 1),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No products found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}