import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/i_cart_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_cart_service.dart';

class CartService implements ICartService {
  final ICartRepository cartRepository;
  final AccountRepository accountRepository;

  CartService({
    required this.cartRepository,
    required this.accountRepository,
  });

  Future<String> _getCompanyId() async {
    final userInfo = await accountRepository.getUserInfo();
    return userInfo?.companyId ?? '';
  }

  Future<String> _getUserId() async {
    final userInfo = await accountRepository.getUserInfo();
    return userInfo?.userId ?? '';
  }

  @override
  Future<List<CartItem>> getItems() async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    return await cartRepository.getCart(companyId, userId);
  }

  @override
  Future<void> addToCart(UserProduct product, int quantity) async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    final items = await cartRepository.getCart(companyId, userId);
    final existingItemIndex = items.indexWhere((item) => item.productId == product.id);
    final subtotal = product.price * quantity;
    final taxAmount = subtotal * product.taxRate;

    if (existingItemIndex != -1) {
      final existingQuantity = items[existingItemIndex].quantity;
      final newQuantity = existingQuantity + quantity;
      final newSubtotal = product.price * newQuantity;
      final newTaxAmount = newSubtotal * product.taxRate;
      items[existingItemIndex] = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: newQuantity,
        taxRate: product.taxRate,
        taxAmount: newTaxAmount,
      );
    } else {
      items.add(CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        taxRate: product.taxRate,
        taxAmount: taxAmount,
      ));
    }
    await cartRepository.saveCart(companyId, userId, items);
  }

  @override
  Future<void> updateQuantity(String productId, int quantity) async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    final items = await cartRepository.getCart(companyId, userId);
    final index = items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        final item = items[index];
        final subtotal = item.price * quantity;
        final taxAmount = subtotal * item.taxRate;
        items[index] = CartItem(
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: quantity,
          taxRate: item.taxRate,
          taxAmount: taxAmount,
        );
      }
      await cartRepository.saveCart(companyId, userId, items);
    }
  }
  @override
  Future<void> removeFromCart(String productId) async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    final items = await cartRepository.getCart(companyId, userId);
    items.removeWhere((item) => item.productId == productId);
    await cartRepository.saveCart(companyId, userId, items);
  }

  @override
  Future<double> getTotalAmount() async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    final items = await cartRepository.getCart(companyId, userId);
    double total = 0.0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Future<void> clearCart() async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    await cartRepository.clearCart(companyId, userId);
  }

  @override
  Future<Order> createOrder() async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    final items = await cartRepository.getCart(companyId, userId);
    final userInfo = await accountRepository.getUserInfo();
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userInfo?.name ?? 'Unknown',
      items: items,
      totalAmount: items.fold(0.0, (sum, item) => sum + (item.price * item.quantity) + item.taxAmount),
      status: 'pending',
      orderDate: DateTime.now(),
    );
    await clearCart(); // Clear cart after creating order
    return order;
  }
}