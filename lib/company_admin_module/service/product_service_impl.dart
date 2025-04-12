import 'package:requirment_gathering_app/company_admin_module/data/product/product_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/product_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/product_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

class ProductServiceImpl implements ProductService {
  final ProductRepository productRepository;
  final AccountRepository _accountRepository;

  ProductServiceImpl(this._accountRepository,
      {required this.productRepository});

  Future<List<Product>> fetchProducts() async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }

    final productsDTO = await productRepository.getProducts(userInfo.companyId!);
    // Mapping from DTO to Domain Model in the service layer
    return productsDTO.map((dto) => dto.toDomainModel()).toList();
  }


  @override
  Future<void> addNewProduct(Product product) async {
    final userInfo = await _accountRepository.getUserInfo();

    final dto = ProductDTO.fromDomainModel(product);
    return productRepository.addProduct(userInfo?.companyId ?? '', dto);
  }

  @override
  Future<void> editProduct(Product product) async {
    final userInfo = await _accountRepository.getUserInfo();
    final dto = ProductDTO.fromDomainModel(product);
    return productRepository.updateProduct(userInfo?.companyId ?? '', dto);
  }

  @override
  Future<void> removeProduct(String productId) async {
    final userInfo = await _accountRepository.getUserInfo();

    return productRepository.deleteProduct(
        userInfo?.companyId ?? '', productId);
  }
}
