import 'package:requirment_gathering_app/company_admin_module/data/product/product_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/product_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/product_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

class ProductServiceImpl implements ProductService {
  final ProductRepository productRepository;
  final StockRepository stockRepository; // Add StockRepository
  final AccountRepository _accountRepository;

  ProductServiceImpl(this._accountRepository, {
    required this.productRepository,
    required this.stockRepository, // Inject StockRepository
  });

  @override
  Future<List<Product>> fetchProducts() async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }

    final productsDTO = await productRepository.getProducts(userInfo.companyId!);
    return productsDTO.map((dto) => dto.toDomainModel()).toList();
  }

  @override
  Future<void> addNewProduct(Product product) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    final existingProducts = await productRepository.getProducts(userInfo.companyId!);
    if (existingProducts.any((dto) => dto.name == product.name)) {
      throw Exception("Product with this name already exists.");
    }
    final dto = ProductDTO.fromDomainModel(product);
    return productRepository.addProduct(userInfo.companyId!, dto);
  }

  @override
  Future<void> editProduct(Product product) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    final companyId = userInfo.companyId!;
    final dto = ProductDTO.fromDomainModel(product);

    // Update the product in the product collection
    await productRepository.updateProduct(companyId, dto);

    // Fetch all stores
    final stores = await stockRepository.getStores(companyId);

    // Update stock entries for this product across all stores
    for (final store in stores) {
      final stock = await stockRepository.getStockByProduct(companyId, store.storeId, product.id);
      if (stock != null) {
        final updatedStock = stock.copyWith(
          name: product.name,
          price: product.price,
          category: product.category,
          categoryId: product.categoryId,
          subcategoryId: product.subcategoryId,
          subcategoryName: product.subcategoryName,
          tax: product.tax,
        );
        await stockRepository.updateStock(companyId, updatedStock);
      }
    }
  }

  @override
  Future<void> removeProduct(String productId) async {
    final userInfo = await _accountRepository.getUserInfo();
    return productRepository.deleteProduct(userInfo?.companyId ?? '', productId);
  }
}