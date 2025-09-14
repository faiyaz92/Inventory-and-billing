import 'package:requirment_gathering_app/accounting_module/data/TransactionModel.dart';
import 'package:requirment_gathering_app/accounting_module/data/account_model_dto.dart';

class AccountModel {
  final String id;
  final String name;
  final String type; // Real, Nominal, Personal
  final String subtype; // General, Subsidiary
  final String? storeId;
  final double balance;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subtype,
    this.storeId,
    required this.balance,
    required this.createdAt,
  });

  AccountDto toDto(String companyId) => AccountDto(
    id: id,
    name: name,
    type: type,
    subtype: subtype,
    storeId: storeId,
    balance: balance,
    companyId: companyId,
    createdAt: createdAt,
  );

  factory AccountModel.fromDto(AccountDto dto) => AccountModel(
    id: dto.id,
    name: dto.name,
    type: dto.type,
    subtype: dto.subtype,
    storeId: dto.storeId,
    balance: dto.balance,
    createdAt: dto.createdAt,
  );
}