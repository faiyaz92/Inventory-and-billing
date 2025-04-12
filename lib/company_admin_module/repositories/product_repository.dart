import 'package:requirment_gathering_app/company_admin_module/data/product/product_dto.dart';

abstract class ProductRepository {
  Future<List<ProductDTO>>  getProducts(String companyId);
  Future<void> addProduct(String companyId, ProductDTO product);
  Future<void> updateProduct(String companyId, ProductDTO product);
  Future<void> deleteProduct(String companyId, String productId);
}
