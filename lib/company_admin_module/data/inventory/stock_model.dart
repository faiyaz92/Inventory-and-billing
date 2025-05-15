
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';

class StockModel {
  final String id;
  final String productId;
  final String storeId;
  final int quantity;
  final DateTime lastUpdated;

  StockModel({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.lastUpdated,
  });

  factory StockModel.fromDto(StockDto dto) {
    return StockModel(
      id: dto.id,
      productId: dto.productId,
      storeId: dto.storeId,
      quantity: dto.quantity,
      lastUpdated: dto.lastUpdated,
    );
  }

  StockDto toDto() {
    return StockDto(
      id: id,
      productId: productId,
      storeId: storeId,
      quantity: quantity,
      lastUpdated: lastUpdated,
    );
  }
}