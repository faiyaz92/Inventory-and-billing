import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';

abstract class ICartRepository {
  Future<void> saveCart(String companyId, String userId, List<CartItem> items);
  Future<List<CartItem>> getCart(String companyId, String userId);
  Future<void> clearCart(String companyId, String userId);
}