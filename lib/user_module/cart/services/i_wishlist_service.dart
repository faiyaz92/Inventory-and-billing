import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';

abstract class IWishlistService {
  Future<List<UserProduct>> getItems();
  Future<void> addToWishlist(UserProduct product);
  Future<void> removeFromWishlist(String productId);
  Future<void> clearWishlist();
}