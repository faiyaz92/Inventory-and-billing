import 'package:requirment_gathering_app/accounting_module/data/TransactionModel.dart';

class TransactionDto {
  final String id;
  final String firmId;
  final String? storeId;
  final String type;
  final String? customerId;
  final String? supplierId;
  final double amount;
  final String paymentType;
  final DateTime date;
  final List<TransactionItem>? items;
  final DateTime createdAt;

  TransactionDto({
    required this.id,
    required this.firmId,
    this.storeId,
    required this.type,
    this.customerId,
    this.supplierId,
    required this.amount,
    required this.paymentType,
    required this.date,
    this.items,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'firmId': firmId,
    'storeId': storeId,
    'type': type,
    'customerId': customerId,
    'supplierId': supplierId,
    'amount': amount,
    'paymentType': paymentType,
    'date': date.toIso8601String(),
    'items': items?.map((item) => item.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory TransactionDto.fromMap(Map<String, dynamic> map, String id) => TransactionDto(
    id: id,
    firmId: map['firmId'],
    storeId: map['storeId'],
    type: map['type'],
    customerId: map['customerId'],
    supplierId: map['supplierId'],
    amount: map['amount'],
    paymentType: map['paymentType'],
    date: DateTime.parse(map['date']),
    items: (map['items'] as List<dynamic>?)?.map((item) => TransactionItem.fromMap(item)).toList(),
    createdAt: DateTime.parse(map['createdAt']),
  );
}