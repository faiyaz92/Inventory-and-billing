import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';

class AccountLedger {
  final String? ledgerId;
  final double totalOutstanding;
  final double? promiseAmount;
  final DateTime? promiseDate;
  final List<TransactionModel>? transactions; // 🛑 Missing Transactions Added

  AccountLedger({
    this.ledgerId,
    required this.totalOutstanding,
    this.promiseAmount,
    this.promiseDate,
     this.transactions, // 🟢 Initialize in constructor
  });

  factory AccountLedger.fromDto(AccountLedgerDto dto) {
    return AccountLedger(
      ledgerId: dto.ledgerId,
      totalOutstanding: dto.totalOutstanding,
      promiseAmount: dto.promiseAmount,
      promiseDate: dto.promiseDate != null ? DateTime.parse(dto.promiseDate!) : null,
      transactions: dto.transactions?.map((txn) => TransactionModel.fromDto(txn)).toList() ?? [], // 🟢 Convert DTO transactions
    );
  }

  AccountLedgerDto toDto() {
    return AccountLedgerDto(
      ledgerId: ledgerId,
      totalOutstanding: totalOutstanding,
      promiseAmount: promiseAmount,
      promiseDate: promiseDate?.toIso8601String(),
      transactions: transactions?.map((txn) => txn.toDto()).toList(), // 🟢 Convert transactions back to DTO
    );
  }
}
