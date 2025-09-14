import 'package:requirment_gathering_app/accounting_module/data/TransactionModelDto.dart';

class TransactionModel {
  final String id;
  final String firmId;
  final String? storeId;
  final String type; // Sale, Purchase, Expense, Investment, Withdrawal, Deposit
  final String? customerId;
  final String? supplierId;
  final double amount;
  final String paymentType; // Cash, Credit
  final DateTime date;
  final List<TransactionItem>? items;
  final DateTime createdAt;

  TransactionModel({
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

  TransactionDto toDto() => TransactionDto(
    id: id,
    firmId: firmId,
    storeId: storeId,
    type: type,
    customerId: customerId,
    supplierId: supplierId,
    amount: amount,
    paymentType: paymentType,
    date: date,
    items: items,
    createdAt: createdAt,
  );

  factory TransactionModel.fromDto(TransactionDto dto) => TransactionModel(
    id: dto.id,
    firmId: dto.firmId,
    storeId: dto.storeId,
    type: dto.type,
    customerId: dto.customerId,
    supplierId: dto.supplierId,
    amount: dto.amount,
    paymentType: dto.paymentType,
    date: dto.date,
    items: dto.items,
    createdAt: dto.createdAt,
  );
}

class TransactionItem {
  final String itemId;
  final String name;
  final int quantity;
  final double cost;

  TransactionItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.cost,
  });

  Map<String, dynamic> toMap() => {
    'itemId': itemId,
    'name': name,
    'quantity': quantity,
    'cost': cost,
  };

  factory TransactionItem.fromMap(Map<String, dynamic> map) => TransactionItem(
    itemId: map['itemId'],
    name: map['name'],
    quantity: map['quantity'],
    cost: map['cost'],
  );
}