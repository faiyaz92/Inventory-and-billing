import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/user_product_model.dart';

class CartState {
  final List<CartItem> items;
  CartState({this.items = const []});
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState());

  void addToCart(UserProduct product, int quantity) {
    final items = List<CartItem>.from(state.items);
    final existingItemIndex = items.indexWhere((item) => item.productId == product.id);
    if (existingItemIndex != -1) {
      items[existingItemIndex] = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: items[existingItemIndex].quantity + quantity,
      );
    } else {
      items.add(CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
      ));
    }
    emit(CartState(items: items));
  }

  void updateQuantity(String productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = CartItem(
          productId: items[index].productId,
          productName: items[index].productName,
          price: items[index].price,
          quantity: quantity,
        );
      }
      emit(CartState(items: items));
    }
  }

  void removeFromCart(String productId) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere((item) => item.productId == productId);
    emit(CartState(items: items));
  }

  double get totalAmount => state.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void clearCart() {
    emit(CartState(items: []));
  }
}