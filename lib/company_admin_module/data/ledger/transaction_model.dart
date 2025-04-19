import 'package:requirment_gathering_app/company_admin_module/data/ledger/transcation_dto.dart';

class TransactionModel {
  final String? transactionId;
  final String type; // "Debit" or "Credit"
  final double amount;
  final String? billNumber;
  final String? receivedBy;
  final DateTime createdAt;
  final String? purpose; // New: Material, Labor, etc.
  final String? typeOfPurpose; // New: Cement, Electrician, etc.
  final String? remarks; // New: 500-char remarks

  TransactionModel({
    this.transactionId,
    required this.type,
    required this.amount,
    this.billNumber,
    this.receivedBy,
    required this.createdAt,
    this.purpose,
    this.typeOfPurpose,
    this.remarks,
  });

  factory TransactionModel.fromDto(TransactionDto dto) {
    return TransactionModel(
      transactionId: dto.transactionId,
      type: dto.type,
      amount: dto.amount,
      billNumber: dto.billNumber,
      receivedBy: dto.receivedBy,
      createdAt: dto.createdAt,
      purpose: dto.purpose,
      typeOfPurpose: dto.typeOfPurpose,
      remarks: dto.remarks,
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
      purpose: purpose,
      typeOfPurpose: typeOfPurpose,
      remarks: remarks,
    );
  }

  TransactionModel copyWith({
    String? transactionId,
    String? type,
    double? amount,
    String? billNumber,
    String? receivedBy,
    DateTime? createdAt,
    String? purpose,
    String? typeOfPurpose,
    String? remarks,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      billNumber: billNumber ?? this.billNumber,
      receivedBy: receivedBy ?? this.receivedBy,
      createdAt: createdAt ?? this.createdAt,
      purpose: purpose ?? this.purpose,
      typeOfPurpose: typeOfPurpose ?? this.typeOfPurpose,
      remarks: remarks ?? this.remarks,
    );
  }
}