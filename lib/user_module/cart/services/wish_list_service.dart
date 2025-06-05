import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/i_wish_list_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_wishlist_service.dart';

class WishlistService implements IWishlistService {
  final IWishlistRepository wishlistRepository;
  final AccountRepository accountRepository;

  WishlistService({
    required this.wishlistRepository,
    required this.accountRepository,
  });

  @override
  Future<List<UserProduct>> getItems() async {
    final userInfo = await accountRepository.getUserInfo();
    final dtos = await wishlistRepository.getWishlist(userInfo?.companyId ?? '', userInfo?.userId ?? '');
    return dtos.map((dto) => UserProduct.fromDto(dto)).toList();
  }

  @override
  Future<void> addToWishlist(UserProduct product) async {
    final userInfo = await accountRepository.getUserInfo();
    final dto = UserProductDto(
      id: product.id,
      name: product.name,
      price: product.price,
    );
    await wishlistRepository.addToWishlist(userInfo?.companyId ?? '', userInfo?.userId ?? '', dto);
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    final userInfo = await accountRepository.getUserInfo();
    await wishlistRepository.removeFromWishlist(userInfo?.companyId ?? '', userInfo?.userId ?? '', productId);
  }

  @override
  Future<void> clearWishlist() async {
    final userInfo = await accountRepository.getUserInfo();
    await wishlistRepository.clearWishlist(userInfo?.companyId ?? '', userInfo?.userId ?? '');
  }
}