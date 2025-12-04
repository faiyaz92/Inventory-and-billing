import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_cart_service.dart';

abstract class CartState {
  final List<CartItem> items;

  CartState({this.items = const []});
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  CartLoaded(List<CartItem> items) : super(items: items);
}

class CartUpdated extends CartState {
  CartUpdated(List<CartItem> items) : super(items: items);
}

class CartCleared extends CartState {
  CartCleared() : super(items: []);
}

class OrderCreated extends CartState {
  final Order order;

  OrderCreated(this.order) : super(items: []);
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}

class CartCubit extends Cubit<CartState> {
  final ICartService cartService;

  CartCubit({
    required this.cartService,
  }) : super(CartInitial()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    emit(CartLoading());
    try {
      final items = await cartService.getItems();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> addToCart(UserProduct product, int quantity) async {
    emit(CartLoading());
    try {
      await cartService.addToCart(product, quantity);
      final updatedItems = await cartService.getItems();
      emit(CartUpdated(updatedItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> addToCartWithDiscount(CartItem cartItem) async {
    emit(CartLoading());
    try {
      await cartService.addCartItem(cartItem);
      final updatedItems = await cartService.getItems();
      emit(CartUpdated(updatedItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    emit(CartLoading());
    try {
      await cartService.updateQuantity(productId, quantity);
      final updatedItems = await cartService.getItems();
      emit(CartUpdated(updatedItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> removeFromCart(String productId) async {
    emit(CartLoading());
    try {
      await cartService.removeFromCart(productId);
      final updatedItems = await cartService.getItems();
      emit(CartUpdated(updatedItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  double calculateProductSubtotal(CartItem item) {
    return item.price * item.quantity;
  }

  double calculateProductTax(CartItem item) {
    final subtotal = calculateProductSubtotal(item);
    return subtotal * item.taxRate;
  }

  double calculateProductTotal(CartItem item) {
    final subtotal = calculateProductSubtotal(item);
    final tax = calculateProductTax(item);
    return subtotal + tax - item.discountAmount;
  }

  double calculateOverallSubtotal() {
    return state.items
        .fold(0.0, (sum, item) => sum + calculateProductSubtotal(item));
  }

  double calculateOverallTax() {
    return state.items
        .fold(0.0, (sum, item) => sum + calculateProductTax(item));
  }

  double calculateTotalItemDiscounts() {
    return state.items.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  double calculateOverallTotal() {
    final subtotal = calculateOverallSubtotal();
    final tax = calculateOverallTax();
    final discounts = calculateTotalItemDiscounts();
    return subtotal + tax - discounts;
  }

  Future<double> get totalAmount async {
    try {
      final total = calculateOverallTotal();
      return total;
    } catch (e) {
      emit(CartError(e.toString()));
      rethrow;
    }
  }

  Future<void> clearCart() async {
    emit(CartLoading());
    try {
      await cartService.clearCart();
      emit(CartCleared());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> createOrder() async {
    emit(CartLoading());
    try {
      final order = await cartService.createOrder();
      emit(OrderCreated(order));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
