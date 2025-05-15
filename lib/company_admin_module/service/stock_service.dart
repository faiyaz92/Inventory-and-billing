import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class StockService {
  Future<List<StockModel>> getStock(String storeId);

  Future<void> addStock(StockModel stock);

  Future<void> updateStock(StockModel stock);

  Future<List<StoreDto>> getStores();

  Future<void> addStore(StoreDto store); // New method
}

class StockServiceImpl implements StockService {
  final StockRepository stockRepository;
  final AccountRepository accountRepository;

  StockServiceImpl({
    required this.stockRepository,
    required this.accountRepository,
  });

  @override
  Future<List<StockModel>> getStock(String storeId) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    final stockDtos = await stockRepository.getStock(companyId, storeId);
    return stockDtos
        .map((dto) => StockModel(
              id: dto.id,
              productId: dto.productId,
              storeId: dto.storeId,
              quantity: dto.quantity,
              lastUpdated: dto.lastUpdated,
            ))
        .toList();
  }

  @override
  Future<void> addStock(StockModel stock) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    final stockDto = StockDto(
      id: stock.id,
      productId: stock.productId,
      storeId: stock.storeId,
      quantity: stock.quantity,
      lastUpdated: stock.lastUpdated,
    );
    await stockRepository.addStock(companyId, stockDto);
  }

  @override
  Future<void> updateStock(StockModel stock) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    final stockDto = StockDto(
      id: stock.id,
      productId: stock.productId,
      storeId: stock.storeId,
      quantity: stock.quantity,
      lastUpdated: stock.lastUpdated,
    );
    await stockRepository.updateStock(companyId, stockDto);
  }

  @override
  Future<List<StoreDto>> getStores() async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    return await stockRepository.getStores(companyId);
  }

  @override
  Future<void> addStore(StoreDto store) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';

    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    await stockRepository.addStore(
        companyId, store.copyWith(createdBy: userInfo?.userId ?? ''));
  }
}
