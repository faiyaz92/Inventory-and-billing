import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
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
                _selectedIndex = 2; // Switch to Cart tab
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home Page (Original UI)
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
                            if (state is ProductLoaded) {
                              final products = state.products
                                  .where((p) => p.name
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()))
                                  .toList();
                              if (products.isEmpty) {
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
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final isInWishlist = state.wishlistItems
                                      .any((item) => item.id == product.id);
                                  final cartItem = state.cartItems.firstWhere(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '₹${product.price}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                    .toggleWishlist(product),
                                              ),
                                              const SizedBox(width: 8),
                                              if (quantity == 0)
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.add_shopping_cart,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 24,
                                                  ),
                                                  onPressed: () => context
                                                      .read<ProductCubit>()
                                                      .addToCart(product, 1),
                                                )
                                              else
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.remove_circle,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 24,
                                                      ),
                                                      onPressed: () => context
                                                          .read<ProductCubit>()
                                                          .updateCartQuantity(
                                                              product.id,
                                                              quantity - 1),
                                                    ),
                                                    Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.add_circle,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 24,
                                                      ),
                                                      onPressed: () => context
                                                          .read<ProductCubit>()
                                                          .updateCartQuantity(
                                                              product.id,
                                                              quantity + 1),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return const Center(
                                child: Text('No products found'));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Wishlist Page
          const WishlistPage(),
          // Cart Page
          const CartPage(),
          // Profile Page
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
                    // User Details
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
                              'Name: John Doe', // Placeholder for user name
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Email: johndoe@example.com',
                              // Placeholder for user email
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
                    // Options List
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
                                // Add logout logic here
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
