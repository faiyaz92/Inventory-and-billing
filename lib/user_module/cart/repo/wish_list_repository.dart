import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/i_wish_list_repository.dart';

class WishlistRepositoryImpl implements IWishlistRepository {
  final IFirestorePathProvider firestorePathProvider;

  WishlistRepositoryImpl({
    required this.firestorePathProvider,
  });

  @override
  Future<List<UserProductDto>> getWishlist(String companyId, String userId) async {
    try {
      final ref = firestorePathProvider.getUserWishlistRef(companyId, userId);
      final snapshot = await ref.get();
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final items = data['items'] as List<dynamic>? ?? [];
      return items.map((item) => UserProductDto.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  @override
  Future<void> addToWishlist(String companyId, String userId, UserProductDto product) async {
    try {
      final ref = firestorePathProvider.getUserWishlistRef(companyId, userId);
      final snapshot = await ref.get();
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      if (!items.any((item) => item['id'] == product.id)) {
        items.add(product.toMap());
        await ref.set({'items': items});
      }
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(String companyId, String userId, String productId) async {
    try {
      final ref = firestorePathProvider.getUserWishlistRef(companyId, userId);
      final snapshot = await ref.get();
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

      items.removeWhere((item) => item['id'] == productId);
      await ref.set({'items': items});
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  @override
  Future<void> clearWishlist(String companyId, String userId) async {
    try {
      final ref = firestorePathProvider.getUserWishlistRef(companyId, userId);
      await ref.set({'items': []});
    } catch (e) {
      throw Exception('Failed to clear wishlist: $e');
    }
  }
}