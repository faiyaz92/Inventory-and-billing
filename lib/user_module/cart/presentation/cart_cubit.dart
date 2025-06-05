import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_cart_service.dart';

abstract class CartState {
  final List<CartItem> items;
  CartState({this.items = const []});
}

// Initial state
class CartInitial extends CartState {}

// Loading state
class CartLoading extends CartState {}

// Loaded state (after fetching cart items)
class CartLoaded extends CartState {
  CartLoaded(List<CartItem> items) : super(items: items);
}

// Updated state (after adding, updating, or removing items)
class CartUpdated extends CartState {
  CartUpdated(List<CartItem> items) : super(items: items);
}

// Cleared state (after clearing cart)
class CartCleared extends CartState {
  CartCleared() : super(items: []);
}

// Order created state (after creating an order)
class OrderCreated extends CartState {
  final Order order;
  OrderCreated(this.order) : super(items: []);
}

// Error state
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

  // Calculate subtotal for a single product (without tax)
  double calculateProductSubtotal(CartItem item) {
    return item.price * item.quantity;
  }

  // Calculate tax for a single product
  double calculateProductTax(CartItem item) {
    final subtotal = calculateProductSubtotal(item);
    return subtotal * item.taxRate;
  }

  // Calculate total for a single product (with tax)
  double calculateProductTotal(CartItem item) {
    final subtotal = calculateProductSubtotal(item);
    final tax = calculateProductTax(item);
    return subtotal + tax;
  }

  // Calculate subtotal for all products (without tax)
  double calculateOverallSubtotal() {
    return state.items.fold(0.0, (sum, item) => sum + calculateProductSubtotal(item));
  }

  // Calculate total tax for all products
  double calculateOverallTax() {
    return state.items.fold(0.0, (sum, item) => sum + calculateProductTax(item));
  }

  // Calculate final total for all products (with tax)
  double calculateOverallTotal() {
    return state.items.fold(0.0, (sum, item) => sum + calculateProductTotal(item));
  }

  // Updated totalAmount getter to return the total with tax
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