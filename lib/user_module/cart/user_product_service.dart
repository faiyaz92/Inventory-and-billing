import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/user_module/cart/user_product_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/user_product_model.dart';

class UserProductService {
  final StockService stockService;

  UserProductService({required this.stockService});

  Future<List<UserProduct>> getProducts() async {
    try {
      final stores = await stockService.getStores();
      final allStockItems = <StockModel>[];
      for (final store in stores) {
        final stockItems = await stockService.getStock(store.storeId);
        allStockItems.addAll(stockItems);
      }

      final uniqueProducts = <String, StockModel>{};
      for (var stock in allStockItems) {
        uniqueProducts[stock.productId] = stock;
      }

      return uniqueProducts.values
          .map((stock) => UserProduct.fromDto(UserProductDto.fromStock(stock)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}