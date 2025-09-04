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
    final existingItemIndex =
        items.indexWhere((item) => item.productId == product.id);
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
        discountAmount: items[existingItemIndex].discountAmount,
        discountPercentage: items[existingItemIndex].discountPercentage,
      );
    } else {
      items.add(CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: quantity,
        taxRate: product.taxRate,
        taxAmount: taxAmount,
        discountAmount: 0.0,
        discountPercentage: 0.0,
      ));
    }
    await cartRepository.saveCart(companyId, userId, items);
  }

  @override
  Future<void> addCartItem(CartItem cartItem) async {
    final companyId = await _getCompanyId();
    final userId = await _getUserId();
    final items = await cartRepository.getCart(companyId, userId);
    final existingItemIndex =
        items.indexWhere((item) => item.productId == cartItem.productId);

    if (existingItemIndex != -1) {
      final existingItem = items[existingItemIndex];
      final newQuantity = existingItem.quantity + cartItem.quantity;
      final newSubtotal = cartItem.price * newQuantity;
      final newTaxAmount = newSubtotal * cartItem.taxRate;
      final newDiscountAmount = cartItem.discountAmount; // Use new discount
      final newDiscountPercentage = newSubtotal + newTaxAmount > 0
          ? (newDiscountAmount / (newSubtotal + newTaxAmount)) * 100
          : 0.0;
      items[existingItemIndex] = CartItem(
        productId: cartItem.productId,
        productName: cartItem.productName,
        price: cartItem.price,
        quantity: newQuantity,
        taxRate: cartItem.taxRate,
        taxAmount: newTaxAmount,
        discountAmount: newDiscountAmount,
        discountPercentage: newDiscountPercentage,
      );
    } else {
      items.add(cartItem);
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
        final discountAmount =
            item.discountAmount; // Preserve existing discount
        final discountPercentage = subtotal + taxAmount > 0
            ? (discountAmount / (subtotal + taxAmount)) * 100
            : 0.0;
        items[index] = CartItem(
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: quantity,
          taxRate: item.taxRate,
          taxAmount: taxAmount,
          discountAmount: discountAmount,
          discountPercentage: discountPercentage,
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
    double subtotal = 0.0;
    double totalTax = 0.0;
    double totalDiscount = 0.0;
    for (var item in items) {
      final itemSubtotal = item.price * item.quantity;
      subtotal += itemSubtotal;
      totalTax += item.taxAmount;
      totalDiscount += item.discountAmount;
    }
    return subtotal + totalTax - totalDiscount;
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
    final subtotal =
        items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final totalTax = items.fold(0.0, (sum, item) => sum + item.taxAmount);
    final totalItemDiscounts =
        items.fold(0.0, (sum, item) => sum + item.discountAmount);
    final additionalDiscount =
        items.isNotEmpty && items.first.discountAmount > 0
            ? items.first.discountAmount // Use Order.discount if provided
            : 0.0;
    final totalAmount =
        subtotal + totalTax - (totalItemDiscounts + additionalDiscount);

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userInfo?.name ?? 'Unknown',
      items: items,
      totalAmount: totalAmount,
      discount: additionalDiscount > 0 ? additionalDiscount : null,
      status: 'pending',
      orderDate: DateTime.now(),
    );
    await clearCart(); // Clear cart after creating order
    return order;
  }
}
