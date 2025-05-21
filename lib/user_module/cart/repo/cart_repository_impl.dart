import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/user_module/cart/data/cart_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/i_cart_repository.dart';

class CartRepositoryImpl implements ICartRepository {
  final IFirestorePathProvider _firestoreProvider;

  CartRepositoryImpl(this._firestoreProvider);

  @override
  Future<void> saveCart(String companyId, String userId, List<CartItem> items) async {
    final cartDto = CartDto(
      userId: userId,
      items: items.map((item) => CartItemDto.fromModel(item)).toList(),
    );
    await _firestoreProvider.getUserCartRef(companyId, userId).set(cartDto.toMap());
  }

  @override
  Future<List<CartItem>> getCart(String companyId, String userId) async {
    final snapshot = await _firestoreProvider.getUserCartRef(companyId, userId).get();
    if (!snapshot.exists) {
      return [];
    }
    final cartDto = CartDto.fromMap(snapshot.data() as Map<String, dynamic>);
    return cartDto.toModel();
  }

  @override
  Future<void> clearCart(String companyId, String userId) async {
    await _firestoreProvider.getUserCartRef(companyId, userId).delete();
  }
}