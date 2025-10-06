import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/wish_list_cubit.dart';

@RoutePage()
class WishlistPage extends StatelessWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<WishlistCubit>()),
        BlocProvider(create: (context) => sl<CartCubit>()),
      ],
      child: Builder(
        builder: (newContext) {
          return Scaffold(
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
                  child: BlocListener<CartCubit, CartState>(
                    listener: (context, state) {
                      if (state is CartUpdated) {
                        // Refresh wishlist after adding to cart
                        newContext.read<WishlistCubit>().loadWishlist();
                      } else if (state is CartError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${AppLabels.error}: ${state.message}'),
                            backgroundColor: AppColors.red,
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<WishlistCubit, WishlistState>(
                      builder: (context, state) {
                        if (state is WishlistLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state.items.isEmpty && state is! WishlistInitial) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  AppLabels.yourWishlistIsEmpty,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (state is WishlistError) {
                          return Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Error: ${state.message}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.red,
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
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'IQD ${item.price}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_shopping_cart,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                          onPressed: () async {
                                            await newContext
                                                .read<CartCubit>()
                                                .addToCart(item, 1);
                                            await newContext
                                                .read<WishlistCubit>()
                                                .removeFromWishlist(item.id);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: AppColors.red,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            newContext
                                                .read<WishlistCubit>()
                                                .removeFromWishlist(item.id);
                                          },
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
