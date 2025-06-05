import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';

abstract class IUserProductService {
  Future<List<UserProduct>> getProducts();
}