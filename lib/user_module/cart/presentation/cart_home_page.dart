import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/product_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/wish_list_page.dart';

@RoutePage()
class CartHomePage extends StatefulWidget {
  const CartHomePage({Key? key}) : super(key: key);

  @override
  _CartHomePageState createState() => _CartHomePageState();
}

class _CartHomePageState extends State<CartHomePage> {
  String _searchQuery = '';
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _selectedIndex == 0
            ? 'Home'
            : _selectedIndex == 1
            ? 'Wishlist'
            : _selectedIndex == 2
            ? 'Cart'
            : 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BlocProvider(
            create: (_) => sl<ProductCubit>()..fetchProducts(),
            child: Container(
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: const InputDecoration(
                            labelText: 'Search Products',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: BlocConsumer<ProductCubit, ProductState>(
                          buildWhen: (previous, current) =>
                          current is ProductLoading ||
                              current is ProductLoaded ||
                              current is ProductError ||
                              current is OptimisticCartAdded ||
                              current is OptimisticCartUpdated ||
                              current is OptimisticWishlistToggled,
                          listener: (context, state) {
                            if (state is ProductError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is ProductLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is ProductError) {
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
                                          'Error: ${state.message}',
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
                                          onPressed: () => context
                                              .read<ProductCubit>()
                                              .fetchProducts(),
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            // Handle states with products
                            List<UserProduct> products = [];
                            List<UserProduct> wishlistItems = [];
                            List<CartItem> cartItems = [];

                            if (state is ProductLoaded) {
                              products = state.products;
                              wishlistItems = state.wishlistItems;
                              cartItems = state.cartItems;
                            } else if (state is OptimisticCartAdded) {
                              products = state.products;
                              wishlistItems = state.wishlistItems;
                              cartItems = state.cartItems;
                            } else if (state is OptimisticCartUpdated) {
                              products = state.products;
                              wishlistItems = state.wishlistItems;
                              cartItems = state.cartItems;
                            } else if (state is OptimisticWishlistToggled) {
                              products = state.products;
                              wishlistItems = state.wishlistItems;
                              cartItems = state.cartItems;
                            }

                            final filteredProducts = products
                                .where((p) => p.name
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase()))
                                .toList();

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
                                      'No products found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12.0,
                                mainAxisSpacing: 12.0,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final isInWishlist =
                                wishlistItems.any((item) => item.id == product.id);
                                final cartItem = cartItems.firstWhere(
                                      (item) => item.productId == product.id,
                                  orElse: () => CartItem(
                                    productId: product.id,
                                    productName: product.name,
                                    price: product.price,
                                    quantity: 0,
                                    taxRate: 0,
                                    taxAmount: 0,
                                  ),
                                );
                                final quantity = cartItem.quantity;

                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://via.placeholder.com/100',
                                            width: double.infinity,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                Container(
                                                  width: double.infinity,
                                                  height: 100,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '₹${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isInWishlist
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isInWishlist
                                                    ? Colors.red
                                                    : Colors.grey[600],
                                                size: 24,
                                              ),
                                              onPressed: () => context
                                                  .read<ProductCubit>()
                                                  .optimisticToggleWishlist(product),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                            Container(
                                              width: 110,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[700],
                                                borderRadius:
                                                BorderRadius.circular(16),
                                              ),
                                              child: quantity == 0
                                                  ? InkWell(
                                                onTap: () => context
                                                    .read<ProductCubit>()
                                                    .optimisticAddToCart(
                                                    product, 1),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Add',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  : Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () => context
                                                        .read<ProductCubit>()
                                                        .optimisticUpdateQuantity(
                                                        product.id,
                                                        quantity - 1),
                                                    child: const Padding(
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      child: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '$quantity',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => context
                                                        .read<ProductCubit>()
                                                        .optimisticUpdateQuantity(
                                                        product.id,
                                                        quantity + 1),
                                                    child: const Padding(
                                                      padding:
                                                      EdgeInsets.all(8),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
          const WishlistPage(),
          const CartPage(),
          Container(
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
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Name: John Doe',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Email: johndoe@example.com',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.receipt,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              title: const Text(
                                'My Orders',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () =>
                                  sl<Coordinator>().navigateToOrderListPage(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.settings,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              title: const Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () =>
                                  sl<Coordinator>().navigateToSettingsPage(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.logout,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              title: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Theme.of(context).primaryColor,
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Logged out')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}