import 'package:requirment_gathering_app/company_admin_module/data/transcation_dto.dart';

class TransactionModel {
  final String? transactionId;
  final String type; // "Debit" or "Credit"
  final double amount;
  final String? billNumber;
  final String? receivedBy;
  final DateTime createdAt;

  TransactionModel({
    this.transactionId,
    required this.type,
    required this.amount,
    this.billNumber,
    this.receivedBy,
    required this.createdAt,
  });

  factory TransactionModel.fromDto(TransactionDto dto) {
    return TransactionModel(
      transactionId: dto.transactionId,
      type: dto.type,
      amount: dto.amount,
      billNumber: dto.billNumber,
      receivedBy: dto.receivedBy,
      createdAt: dto.createdAt,
    );
  }

  TransactionDto toDto() {
    return TransactionDto(
      transactionId: transactionId,
      type: type,
      amount: amount,
      billNumber: billNumber,
      receivedBy: receivedBy,
      createdAt: createdAt,
    );
  }
}
