// New Cubit: AdminPurchaseCubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/i_purchase_order.dart';

abstract class AdminPurchaseState {}

class AdminPurchaseInitial extends AdminPurchaseState {}

class AdminPurchaseLoading extends AdminPurchaseState {}

class AdminPurchaseSuccess extends AdminPurchaseState {
  final AdminPurchaseOrder purchaseOrder;
  AdminPurchaseSuccess(this.purchaseOrder);
}

class AdminPurchaseError extends AdminPurchaseState {
  final String message;
  AdminPurchaseError(this.message);
}

class AdminPurchaseCubit extends Cubit<AdminPurchaseState> {
  final IPurchaseOrderService purchaseOrderService;

  AdminPurchaseCubit({
    required this.purchaseOrderService,
  }) : super(AdminPurchaseInitial());

  Future<void> createPurchaseOrder(AdminPurchaseOrder order) async {
    emit(AdminPurchaseLoading());
    try {
      await purchaseOrderService.placePurchaseOrder(order);
      await purchaseOrderService.placePurchaseInvoice(order);
      emit(AdminPurchaseSuccess(order));
    } catch (e) {
      emit(AdminPurchaseError('Failed to create purchase order: $e'));
    }
  }

// Add more methods if needed for panel, e.g., fetchAllPurchaseInvoices
}