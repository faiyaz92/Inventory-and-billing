import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

import '../data/ledger/account_ledger_model.dart';

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
  final IAccountLedgerService accountLedgerService;

  StockServiceImpl( {
    required this.stockRepository,
    required this.accountRepository,
   required this.accountLedgerService,
  });

  @override
  Future<List<StockModel>> getStock(String storeId) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    final stockDtos = await stockRepository.getStock(
        companyId, storeId.isEmpty ? userInfo?.storeId : storeId); // if not store id then it will fetch from own store
    return stockDtos
        .map((dto) => StockModel(
              id: dto.id,
              productId: dto.productId,
              storeId: dto.storeId,
              quantity: dto.quantity,
              lastUpdated: dto.lastUpdated,
              price: dto.price,
              subcategoryId: dto.subcategoryId,
              tax: dto.tax,
              categoryId: dto.categoryId,
              name: dto.name,
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
      name: stock.name,
      price: stock.price,
      stock: null,
      // Explicitly ignore Product.stock
      category: stock.category,
      categoryId: stock.categoryId,
      subcategoryId: stock.subcategoryId,
      subcategoryName: stock.subcategoryName,
      tax: stock.tax,
    );

    await stockRepository.addStock(companyId, stockDto);
  }

  /// Updates an existing stock entry in Firestore.
  /// Maps all StockModel fields, including nullable Product fields, to StockDto.
  /// Sets stock field to null as Product.stock is ignored.
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
      name: stock.name,
      price: stock.price,
      stock: null,
      // Explicitly ignore Product.stock
      category: stock.category,
      categoryId: stock.categoryId,
      subcategoryId: stock.subcategoryId,
      subcategoryName: stock.subcategoryName,
      tax: stock.tax,
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
    final ledgerId = await accountLedgerService.createLedger(AccountLedger(
      totalOutstanding: 0,
      promiseAmount: null,
      promiseDate: null,
      transactions: [],
      entityType: UserType.Store,
    ));
    await stockRepository.addStore(
        companyId, store.copyWith(createdBy: userInfo?.userId ?? '',accountLedgerId: ledgerId));
  }
}
