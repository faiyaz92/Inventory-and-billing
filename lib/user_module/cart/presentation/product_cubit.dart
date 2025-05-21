import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_cart_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_user_product_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_wishlist_service.dart';

class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<UserProduct> products;
  final List<UserProduct> wishlistItems;
  final List<CartItem> cartItems;

  ProductLoaded({
    required this.products,
    required this.wishlistItems,
    required this.cartItems,
  });
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductCubit extends Cubit<ProductState> {
  final IUserProductService productService;
  final IWishlistService wishlistService;
  final ICartService cartService;

  ProductCubit({
    required this.productService,
    required this.wishlistService,
    required this.cartService,
  }) : super(ProductInitial());

  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await productService.getProducts();
      final wishlistItems = await wishlistService.getItems();
      final cartItems = await cartService.getItems();
      emit(ProductLoaded(
        products: products,
        wishlistItems: wishlistItems,
        cartItems: cartItems,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> toggleWishlist(UserProduct product) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      try {
        final isInWishlist = currentState.wishlistItems.any((item) => item.id == product.id);
        if (isInWishlist) {
          await wishlistService.removeFromWishlist(product.id);
        } else {
          await wishlistService.addToWishlist(product);
        }
        final updatedWishlistItems = await wishlistService.getItems();
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: updatedWishlistItems,
          cartItems: currentState.cartItems,
        ));
      } catch (e) {
        emit(ProductError('Wishlist Error: $e'));
      }
    }
  }

  Future<void> addToCart(UserProduct product, int quantity) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      try {
        await cartService.addToCart(product, quantity);
        final updatedCartItems = await cartService.getItems();
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: currentState.wishlistItems,
          cartItems: updatedCartItems,
        ));
      } catch (e) {
        emit(ProductError('Cart Error: $e'));
      }
    }
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      try {
        if (quantity <= 0) {
          await cartService.removeFromCart(productId);
        } else {
          await cartService.updateQuantity(productId, quantity);
        }
        final updatedCartItems = await cartService.getItems();
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: currentState.wishlistItems,
          cartItems: updatedCartItems,
        ));
      } catch (e) {
        emit(ProductError('Cart Error: $e'));
      }
    }
  }
}