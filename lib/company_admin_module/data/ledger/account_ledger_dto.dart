
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transcation_dto.dart';

class AccountLedgerDto {
  final String? ledgerId;
  final double totalOutstanding;
  final double? promiseAmount;
  final String? promiseDate;
  final List<TransactionDto>? transactions; // 🔥 Added Transactions

  AccountLedgerDto({
    this.ledgerId,
    required this.totalOutstanding,
    this.promiseAmount,
    this.promiseDate,
    this.transactions,
  });

  /// 🔹 Convert Firestore Map to `AccountLedgerDto`
  factory AccountLedgerDto.fromMap(Map<String, dynamic> map, String id, List<TransactionDto> transactions) {
    return AccountLedgerDto(
      ledgerId: id,
      totalOutstanding: map['totalOutstanding']?.toDouble() ?? 0.0,
      promiseAmount: map['promiseAmount']?.toDouble(),
      promiseDate: map['promiseDate'],
      transactions: transactions, // 🔥 Transactions list ab alag se pass hogi
    );
  }


  /// 🔹 Convert DTO to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'totalOutstanding': totalOutstanding,
      'promiseAmount': promiseAmount,
      'promiseDate': promiseDate,
      'transactions': transactions?.map((txn) => txn.toMap()).toList(), // 🔥 Convert transactions list to Firestore
    };
  }
}
