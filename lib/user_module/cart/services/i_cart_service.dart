import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';

abstract class ICartService {
  Future<List<CartItem>> getItems();
  Future<void> addToCart(UserProduct product, int quantity);
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> removeFromCart(String productId);
  Future<double> getTotalAmount();
  Future<void> clearCart();
  Future<Order> createOrder();
}