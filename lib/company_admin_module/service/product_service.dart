import 'package:requirment_gathering_app/company_admin_module/data/product/product_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';

abstract class ProductService {
  Future<List<Product>>  fetchProducts();

  Future<void> addNewProduct( Product product);

  Future<void> editProduct( Product product);

  Future<void> removeProduct(String productId);
}
