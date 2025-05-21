import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_wishlist_service.dart';

class WishlistState {
  final List<UserProduct> items;
  WishlistState({this.items = const []});
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  WishlistLoaded(List<UserProduct> items) : super(items: items);
}

class WishlistError extends WishlistState {
  final String message;
  WishlistError(this.message);
}

class WishlistCubit extends Cubit<WishlistState> {
  final IWishlistService wishlistService;

  WishlistCubit({
    required this.wishlistService,
  }) : super(WishlistInitial()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    emit(WishlistLoading());
    try {
      final items = await wishlistService.getItems();
      emit(WishlistLoaded(items));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> addToWishlist(UserProduct product) async {
    emit(WishlistLoading());
    try {
      await wishlistService.addToWishlist(product);
      final updatedItems = await wishlistService.getItems();
      emit(WishlistLoaded(updatedItems));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    emit(WishlistLoading());
    try {
      await wishlistService.removeFromWishlist(productId);
      final updatedItems = await wishlistService.getItems();
      emit(WishlistLoaded(updatedItems));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> clearWishlist() async {
    emit(WishlistLoading());
    try {
      await wishlistService.clearWishlist();
      emit(WishlistLoaded([]));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }
}