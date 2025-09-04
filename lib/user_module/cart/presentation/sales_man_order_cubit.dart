import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_user_product_service.dart';

// State for SalesmanOrderCubit
abstract class SalesmanOrderState {}

class SalesmanOrderInitial extends SalesmanOrderState {}

class SalesmanOrderLoading extends SalesmanOrderState {
final String dialogMessage;

SalesmanOrderLoading({this.dialogMessage = 'Loading...'});
}

class SalesmanOrderLoaded extends SalesmanOrderState {
final List<UserInfo> customers;
final List<UserProduct> products;
final List<UserProduct> filteredProducts;
final Map<String, int> productQuantities;
final UserInfo? selectedCustomer;
final String searchQuery;
final bool? isLoading;

SalesmanOrderLoaded({
required this.customers,
required this.products,
required this.filteredProducts,
required this.productQuantities,
this.selectedCustomer,
this.searchQuery = '',
this.isLoading = false,
});
}

class SalesmanOrderError extends SalesmanOrderState {
final String message;

SalesmanOrderError(this.message);
}

class SalesmanOrderPlaced extends SalesmanOrderState {}

// Cubit for handling salesman order logic
class SalesmanOrderCubit extends Cubit<SalesmanOrderState> {
final UserServices employeeServices;
final IUserProductService productService;
final AccountRepository accountRepository;
final CartCubit cartCubit;
final OrderCubit orderCubit;
double discount = 0.0; // Additional discount
Map<String, double> itemDiscounts = {}; // Item-wise discounts

SalesmanOrderCubit({
required this.employeeServices,
required this.productService,
required this.accountRepository,
required this.cartCubit,
required this.orderCubit,
}) : super(SalesmanOrderInitial()) {
_initialize();
}

List<UserInfo> _customers = [];
List<UserProduct> _products = [];
List<UserProduct> _filteredProducts = [];
Map<String, int> _productQuantities = {};
UserInfo? _selectedCustomer;
String _searchQuery = '';

Future<void> _initialize() async {
emit(SalesmanOrderLoading());
try {
_customers = await employeeServices.getUsersFromTenantCompany();
_customers = _customers.where((user) => user.userType == UserType.Customer).toList();

_products = await productService.getProducts();
_filteredProducts = _products;
_productQuantities = {for (var product in _products) product.id: 0};
itemDiscounts = {for (var product in _products) product.id: 0.0};

emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
isLoading: true,
));
} catch (e) {
emit(SalesmanOrderError('Failed to load data: $e'));
}
}

Future<void> refreshCustomers() async {
emit(SalesmanOrderLoading(dialogMessage: 'Refreshing customers...'));
try {
_customers = await employeeServices.getUsersFromTenantCompany();
_customers = _customers.where((user) => user.userType == UserType.Customer).toList();
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
} catch (e) {
emit(SalesmanOrderError('Failed to refresh customers: $e'));
}
}

void selectCustomer(UserInfo? customer) {
emit(SalesmanOrderInitial());
_selectedCustomer = customer;
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
}

void updateProductQuantity(String productId, bool increment) {
if (increment) {
_productQuantities[productId] = _productQuantities[productId]! + 1;
} else {
if (_productQuantities[productId]! > 0) {
_productQuantities[productId] = _productQuantities[productId]! - 1;
}
}
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
}

void setProductQuantity(String productId, int quantity) {
_productQuantities[productId] = quantity.clamp(0, double.maxFinite.toInt());
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
}

void setDiscount(double discount) {
this.discount = discount.clamp(0, double.maxFinite);
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
}

void setItemDiscounts(Map<String, double> discounts) {
discounts.forEach((productId, disc) {
itemDiscounts[productId] = disc.clamp(0, double.maxFinite);
});
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
}

void searchProducts(String query) {
_searchQuery = query;
if (query.isEmpty) {
_filteredProducts = _products;
} else {
_filteredProducts = _products
    .where((product) =>
product.name.toLowerCase().contains(query.toLowerCase()))
    .toList();
}
emit(SalesmanOrderLoaded(
customers: _customers,
products: _products,
filteredProducts: _filteredProducts,
productQuantities: _productQuantities,
selectedCustomer: _selectedCustomer,
searchQuery: _searchQuery,
));
}

double calculateProductSubtotal(String productId) {
final product = _products.firstWhere((p) => p.id == productId);
final quantity = _productQuantities[productId] ?? 0;
return product.price * quantity;
}

double calculateProductTax(String productId) {
final product = _products.firstWhere((p) => p.id == productId);
final quantity = _productQuantities[productId] ?? 0;
return ((product.price * product.taxRate)) * quantity;
}

double calculateProductTotal(String productId) {
return calculateProductSubtotal(productId) + calculateProductTax(productId);
}

double calculateOverallSubtotal() {
double subtotal = 0.0;
for (var product in _products) {
if (_productQuantities[product.id]! > 0) {
subtotal += calculateProductSubtotal(product.id);
}
}
return subtotal;
}

double calculateOverallTax() {
double totalTax = 0.0;
for (var product in _products) {
if (_productQuantities[product.id]! > 0) {
totalTax += calculateProductTax(product.id);
}
}
return totalTax;
}

double calculateOverallTotal() {
return calculateOverallSubtotal() + calculateOverallTax();
}

double calculateFinalTotal() {
final totalItemDiscounts =
itemDiscounts.values.fold<double>(0.0, (sum, disc) => sum + disc);
return calculateOverallTotal() - (totalItemDiscounts + (discount > 0 ? discount : 0));
}

Future<void> placeOrder() async {
if (_selectedCustomer == null) {
emit(SalesmanOrderError('Please select a customer'));
return;
}

emit(SalesmanOrderLoading(dialogMessage: 'Wait...'));
try {
await cartCubit.clearCart();
for (var product in _products) {
final quantity = _productQuantities[product.id]!;
if (quantity > 0) {
final discountAmount = itemDiscounts[product.id] ?? 0.0;
final itemTotal = calculateProductTotal(product.id);
final discountPercentage =
itemTotal > 0 ? (discountAmount / itemTotal) * 100 : 0.0;
final cartItem = CartItem(
productId: product.id,
productName: product.name,
price: product.price,
quantity: quantity,
taxRate: product.taxRate,
taxAmount: calculateProductTax(product.id),
discountAmount: discountAmount,
discountPercentage: discountPercentage,
);
await cartCubit.addToCartWithDiscount(cartItem);
}
}

final totalAmount = calculateFinalTotal();
final items = cartCubit.state.items;
final userInfo = await accountRepository.getUserInfo();
final salesmanId = userInfo?.userId;
final storeId = userInfo?.storeId;
final order = Order(
id: DateTime.now().millisecondsSinceEpoch.toString(),
userId: _selectedCustomer!.userId!,
userName: _selectedCustomer!.name ?? 'Unknown',
items: items,
totalAmount: totalAmount,
discount: discount > 0 ? discount : null,
status: 'pending',
orderDate: DateTime.now(),
orderTakenBy: salesmanId,
storeId: storeId,
);

await orderCubit.placeOrderBySalesMan(order);

await cartCubit.clearCart();
emit(SalesmanOrderPlaced());
} catch (e) {
emit(SalesmanOrderError('Failed to place order: $e'));
}
}
}
