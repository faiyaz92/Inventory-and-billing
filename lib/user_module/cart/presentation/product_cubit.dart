import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_cart_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_user_product_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_wishlist_service.dart';

abstract class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<UserProduct> products;
  final List<UserProduct> wishlistItems;
  final List<CartItem> cartItems;

  const ProductLoaded({
    required this.products,
    required this.wishlistItems,
    required this.cartItems,
  });
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}

class OptimisticCartAdded extends ProductState {
  final List<UserProduct> products;
  final List<UserProduct> wishlistItems;
  final List<CartItem> cartItems;

  const OptimisticCartAdded({
    required this.products,
    required this.wishlistItems,
    required this.cartItems,
  });
}

class OptimisticCartUpdated extends ProductState {
  final List<UserProduct> products;
  final List<UserProduct> wishlistItems;
  final List<CartItem> cartItems;

  const OptimisticCartUpdated({
    required this.products,
    required this.wishlistItems,
    required this.cartItems,
  });
}

class OptimisticWishlistToggled extends ProductState {
  final List<UserProduct> products;
  final List<UserProduct> wishlistItems;
  final List<CartItem> cartItems;

  const OptimisticWishlistToggled({
    required this.products,
    required this.wishlistItems,
    required this.cartItems,
  });
}

class ProductCubit extends Cubit<ProductState> {
  final IUserProductService productService;
  final IWishlistService wishlistService;
  final ICartService cartService;

  ProductCubit({
    required this.productService,
    required this.wishlistService,
    required this.cartService,
  }) : super(const ProductInitial());

  Future<void> fetchProducts() async {
    emit(const ProductLoading());
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

  Future<bool> addToCart(UserProduct product, int quantity) async {
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
        return true;
      } catch (e) {
        emit(ProductError('Cart Error: $e'));
        return false;
      }
    }
    return false;
  }

  Future<bool> updateCartQuantity(String productId, int quantity) async {
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
        return true;
      } catch (e) {
        emit(ProductError('Cart Error: $e'));
        return false;
      }
    }
    return false;
  }


  Future<void> optimisticAddToCart(UserProduct product, int quantity) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final previousCartItems = List<CartItem>.from(currentState.cartItems);

      final newItem = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        taxRate: 0,
        taxAmount: 0,
      );
      final updatedCartItems = [
        ...currentState.cartItems.where((item) => item.productId != product.id),
        newItem,
      ];

      emit(OptimisticCartAdded(
        products: currentState.products,
        wishlistItems: currentState.wishlistItems,
        cartItems: updatedCartItems,
      ));

      try {
        await cartService.addToCart(product, quantity);
        final updatedItems = await cartService.getItems();
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: currentState.wishlistItems,
          cartItems: updatedItems,
        ));
      } catch (e) {
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: currentState.wishlistItems,
          cartItems: previousCartItems,
        ));
        emit(ProductError('Failed to add to cart: $e'));
      }
    }
  }

  Future<void> optimisticUpdateQuantity(String productId, int newQuantity) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final previousCartItems = List<CartItem>.from(currentState.cartItems);

      final updatedCartItems = currentState.cartItems.map((item) {
        if (item.productId == productId) {
          return CartItem(
            productId: item.productId,
            productName: item.productName,
            price: item.price,
            quantity: newQuantity >= 0 ? newQuantity : 0,
            taxRate: item.taxRate,
            taxAmount: item.taxAmount,
          );
        }
        return item;
      }).toList();

      final filteredCartItems =
      updatedCartItems.where((item) => item.quantity > 0).toList();

      emit(OptimisticCartUpdated(
        products: currentState.products,
        wishlistItems: currentState.wishlistItems,
        cartItems: filteredCartItems,
      ));

      try {
        if (newQuantity <= 0) {
          await cartService.removeFromCart(productId);
        } else {
          await cartService.updateQuantity(productId, newQuantity);
        }
        final updatedItems = await cartService.getItems();
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: currentState.wishlistItems,
          cartItems: updatedItems,
        ));
      } catch (e) {
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: currentState.wishlistItems,
          cartItems: previousCartItems,
        ));
        emit(ProductError('Failed to update quantity: $e'));
      }
    }
  }

  Future<void> optimisticToggleWishlist(UserProduct product) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final previousWishlistItems = List<UserProduct>.from(currentState.wishlistItems);

      final updatedWishlistItems = currentState.wishlistItems.any((item) => item.id == product.id)
          ? currentState.wishlistItems.where((item) => item.id != product.id).toList()
          : [...currentState.wishlistItems, product];

      emit(OptimisticWishlistToggled(
        products: currentState.products,
        wishlistItems: updatedWishlistItems,
        cartItems: currentState.cartItems,
      ));

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
        emit(ProductLoaded(
          products: currentState.products,
          wishlistItems: previousWishlistItems,
          cartItems: currentState.cartItems,
        ));
        emit(ProductError('Failed to update wishlist: $e'));
      }
    }
  }
}
