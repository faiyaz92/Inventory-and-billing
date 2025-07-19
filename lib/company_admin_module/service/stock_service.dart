import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

abstract class StockService {
  Future<List<StockModel>> getStock(String storeId);

  Future<void> addStock(StockModel stock);

  Future<void> updateStock(StockModel stock);

  Future<List<StoreDto>> getStores();

  Future<void> addStore(StoreDto store);

  Future<void> updateStore(StoreDto store); // New method

  Future<void> addSalesmanAsStore(UserInfo? employee);
}

class StockServiceImpl implements StockService {
  final StockRepository stockRepository;
  final AccountRepository accountRepository;
  final IAccountLedgerService accountLedgerService;
  final UserServices userServices;

  StockServiceImpl({
    required this.stockRepository,
    required this.accountRepository,
    required this.accountLedgerService,
    required this.userServices,
  });

  @override
  Future<void> addSalesmanAsStore(UserInfo? employee) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }

    final storeDto = StoreDto(
      storeId: employee?.userId ?? '',
      name: employee?.userName ?? '',
      createdBy: userInfo?.userId ?? 'system',
      createdAt: DateTime.now(),
      accountLedgerId: employee?.accountLedgerId ?? '',
      storeType: StoreType.salesman,
    );

    // Check if store with this name already exists
    final existingStore = await stockRepository.getStoreByName(companyId, storeDto.name);
    if (existingStore != null) {
      throw Exception('Store with name "${storeDto.name}" already exists');
    }

    await stockRepository.addStore(companyId, storeDto);

    if (employee != null) {
      final updatedUser = UserInfo(
        userId: employee.userId ?? '',
        companyId: employee.companyId ?? '',
        name: employee.name ?? '',
        email: employee.email ?? '',
        userName: employee.userName ?? '',
        role: employee.role ?? Role.SALES_MAN,
        userType: UserType.Employee,
        latitude: employee.latitude,
        longitude: employee.longitude,
        dailyWage: employee.dailyWage,
        storeId: employee.userName ?? '',
        accountLedgerId: employee.accountLedgerId ?? '',
      );
      await userServices.updateUser(updatedUser);
    } else {
      throw Exception('User not found');
    }
  }

  @override
  Future<List<StockModel>> getStock(String storeId) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }
    final stockDtos = await stockRepository.getStock(
        companyId,
        storeId.isEmpty ? userInfo?.storeId : storeId);
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
      category: stock.category,
      categoryId: stock.categoryId,
      subcategoryId: stock.subcategoryId,
      subcategoryName: stock.subcategoryName,
      tax: stock.tax,
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
      name: stock.name,
      price: stock.price,
      stock: null,
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

    // Check if store with this name already exists
    final existingStore = await stockRepository.getStoreByName(companyId, store.name);
    if (existingStore != null) {
      throw Exception('Store with name "${store.name}" already exists');
    }

    final ledgerId = await accountLedgerService.createLedger(AccountLedger(
      totalOutstanding: 0,
      promiseAmount: null,
      promiseDate: null,
      transactions: [],
      entityType: UserType.Store,
    ));
    await stockRepository.addStore(
        companyId,
        store.copyWith(
            createdBy: userInfo?.userId ?? '', accountLedgerId: ledgerId));
  }

  @override
  Future<void> updateStore(StoreDto store) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    if (companyId.isEmpty) {
      throw Exception('Company ID not found');
    }

    // Check if store exists
    final existingStore = await stockRepository.getStoreByName(companyId, store.name);
    if (existingStore == null) {
      throw Exception('Store with name "${store.name}" does not exist');
    }

    // Update only provided fields while preserving existing ones
    final updatedStore = existingStore.copyWith(
      storeId: store.storeId,
      name: store.name,
      createdBy: store.createdBy ?? existingStore.createdBy,
      createdAt: store.createdAt ?? existingStore.createdAt,
      accountLedgerId: store.accountLedgerId ?? existingStore.accountLedgerId,
      storeType: store.storeType,
    );

    await stockRepository.updateStore(companyId, updatedStore);
  }
}