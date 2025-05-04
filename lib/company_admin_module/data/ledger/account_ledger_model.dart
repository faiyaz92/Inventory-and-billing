import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';

class AccountLedger {
  final String? ledgerId;
  final double totalOutstanding;
  final double? promiseAmount;
  final DateTime? promiseDate;
  final List<TransactionModel>? transactions;
  final double? baseConstructionCost; // Presentation only
  final double? totalConstructionCost; // Presentation only
  final double? currentBaseDue; // Presentation only
  final double? currentTotalDue; // Presentation only
  final double? serviceChargePercentage; // Presentation only
  final double? estimatedProfit; // Presentation only
  final double? currentProfit; // Presentation only
  final double? totalPaymentReceived; // Presentation only

  AccountLedger({
    this.ledgerId,
    required this.totalOutstanding,
    this.promiseAmount,
    this.promiseDate,
    this.transactions,
    this.baseConstructionCost,
    this.totalConstructionCost,
    this.currentBaseDue,
    this.currentTotalDue,
    this.serviceChargePercentage,
    this.estimatedProfit,
    this.currentProfit,
    this.totalPaymentReceived,
  });

  factory AccountLedger.fromDto(AccountLedgerDto dto) {
    return AccountLedger(
      ledgerId: dto.ledgerId,
      totalOutstanding: dto.totalOutstanding,
      promiseAmount: dto.promiseAmount,
      promiseDate: dto.promiseDate != null ? DateTime.parse(dto.promiseDate!) : null,
      transactions: dto.transactions?.map((txn) => TransactionModel.fromDto(txn)).toList() ?? [],
      baseConstructionCost: 0.0, // Default, calculated in cubit
      totalConstructionCost: 0.0, // Default, calculated in cubit
      currentBaseDue: dto.totalOutstanding, // Default, calculated in cubit
      currentTotalDue: dto.totalOutstanding * (1 + 25.0 / 100), // Default 25%
      serviceChargePercentage: 25.0, // Default
      estimatedProfit: 0.0, // Default, calculated in cubit
      currentProfit: 0.0, // Default, calculated in cubit
      totalPaymentReceived: 0.0, // Default, calculated in cubit
    );
  }

  AccountLedgerDto toDto() {
    return AccountLedgerDto(
      ledgerId: ledgerId,
      totalOutstanding: totalOutstanding,
      promiseAmount: promiseAmount,
      promiseDate: promiseDate?.toIso8601String(),
      transactions: transactions?.map((txn) => txn.toDto()).toList(),
    );
  }
}