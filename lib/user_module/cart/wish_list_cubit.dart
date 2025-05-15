import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/user_product_model.dart';

class WishlistState {
  final List<UserProduct> items;
  WishlistState({this.items = const []});
}

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit() : super(WishlistState());

  void addToWishlist(UserProduct product) {
    final items = List<UserProduct>.from(state.items);
    if (!items.any((item) => item.id == product.id)) {
      items.add(product);
      emit(WishlistState(items: items));
    }
  }

  void removeFromWishlist(String productId) {
    final items = List<UserProduct>.from(state.items);
    items.removeWhere((item) => item.id == productId);
    emit(WishlistState(items: items));
  }
}