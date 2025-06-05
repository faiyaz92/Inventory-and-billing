import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class StoreService {
  Future<List<StoreDto>> getStores();
  Future<String> getDefaultStoreId();
  Future<void> addStore(StoreDto store);
}

class StoreServiceImpl implements StoreService {
  final StockRepository stockRepository;
  final AccountRepository accountRepository;

  StoreServiceImpl({
    required this.stockRepository,
    required this.accountRepository,
  });

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
  Future<String> getDefaultStoreId() async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    return await stockRepository.getDefaultStoreId(companyId);
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