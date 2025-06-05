import 'package:requirment_gathering_app/user_module/cart/data/user_product_dto.dart';

abstract class IWishlistRepository {
  Future<List<UserProductDto>> getWishlist(String companyId, String userId);
  Future<void> addToWishlist(String companyId, String userId, UserProductDto product);
  Future<void> removeFromWishlist(String companyId, String userId, String productId);
  Future<void> clearWishlist(String companyId, String userId);
}