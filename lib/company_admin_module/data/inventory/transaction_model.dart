import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_dto.dart';

class TransactionModel {
  final String id;
  final String type;
  final String productId;
  final int quantity;
  final String fromStoreId;
  final String? toStoreId;
  final String? customerId;
  final DateTime timestamp;
  final String userName;
  final String userId;
  final String? remarks; // Added

  TransactionModel({
    required this.id,
    required this.type,
    required this.productId,
    required this.quantity,
    required this.fromStoreId,
    this.toStoreId,
    this.customerId,
    required this.timestamp,
    required this.userName,
    required this.userId,
    this.remarks,
  });

  factory TransactionModel.fromDto(TransactionDto dto) {
    return TransactionModel(
      id: dto.id,
      type: dto.type,
      productId: dto.productId,
      quantity: dto.quantity,
      fromStoreId: dto.fromStoreId,
      toStoreId: dto.toStoreId,
      customerId: dto.customerId,
      timestamp: dto.timestamp,
      userName: dto.userName,
      userId: dto.userId,
      remarks: dto.remarks, // Added
    );
  }

  TransactionDto toDto() {
    return TransactionDto(
      id: id,
      type: type,
      productId: productId,
      quantity: quantity,
      fromStoreId: fromStoreId,
      toStoreId: toStoreId,
      customerId: customerId,
      timestamp: timestamp,
      userName: userName,
      userId: userId,
      remarks: remarks, // Added
    );
  }
}