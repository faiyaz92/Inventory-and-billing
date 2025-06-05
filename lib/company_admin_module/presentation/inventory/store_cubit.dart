import 'package:bloc/bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/store_services.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreService storeService;

  StoreCubit(this.storeService) : super(StoreInitial());

  Future<void> fetchStores() async {
    try {
      emit(StoreLoading());
      final stores = await storeService.getStores();
      final defaultStoreId = await storeService.getDefaultStoreId();
      emit(StoreLoaded(stores: stores, defaultStoreId: defaultStoreId));
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }
}

abstract class StoreState {}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<StoreDto> stores;
  final String defaultStoreId;

  StoreLoaded({required this.stores, required this.defaultStoreId});
}

class StoreError extends StoreState {
  final String error;

  StoreError(this.error);
}
