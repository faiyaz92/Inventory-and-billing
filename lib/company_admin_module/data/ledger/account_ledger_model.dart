import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';

class AccountLedger {
  final String? ledgerId;
  final String? entityType;
  final double totalOutstanding;
  final double? currentDue;
  final double? currentPayable;
  final double? promiseAmount;
  final DateTime? promiseDate;
  final List<TransactionModel>? transactions;
  final double? baseConstructionCost;
  final double? totalConstructionCost;
  final double? currentBaseDue;
  final double? currentTotalDue;
  final double? serviceChargePercentage;
  final double? estimatedProfit;
  final double? currentProfit;
  final double? totalPaymentReceived;

  AccountLedger({
    this.ledgerId,
    this.entityType,
    required this.totalOutstanding,
    this.currentDue,
    this.currentPayable,
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
      entityType: dto.entityType,
      totalOutstanding: dto.totalOutstanding,
      currentDue: dto.currentDue,
      currentPayable: dto.currentPayable,
      promiseAmount: dto.promiseAmount,
      promiseDate: dto.promiseDate != null ? DateTime.parse(dto.promiseDate!) : null,
      transactions: dto.transactions?.map((txn) => TransactionModel.fromDto(txn)).toList() ?? [],
      baseConstructionCost: dto.baseConstructionCost ?? 0.0,
      totalConstructionCost: dto.totalConstructionCost ?? 0.0,
      currentBaseDue: dto.currentBaseDue ?? dto.totalOutstanding,
      currentTotalDue: dto.currentTotalDue ?? (dto.totalOutstanding * (1 + (dto.serviceChargePercentage ?? 25.0) / 100)),
      serviceChargePercentage: dto.serviceChargePercentage ?? 25.0,
      estimatedProfit: dto.estimatedProfit ?? 0.0,
      currentProfit: dto.currentProfit ?? 0.0,
      totalPaymentReceived: dto.totalPaymentReceived ?? 0.0,
    );
  }

  AccountLedgerDto toDto() {
    return AccountLedgerDto(
      ledgerId: ledgerId,
      entityType: entityType,
      totalOutstanding: totalOutstanding,
      currentDue: currentDue,
      currentPayable: currentPayable,
      promiseAmount: promiseAmount,
      promiseDate: promiseDate?.toIso8601String(),
      transactions: transactions?.map((txn) => txn.toDto()).toList(),
      baseConstructionCost: baseConstructionCost,
      totalConstructionCost: totalConstructionCost,
      currentBaseDue: currentBaseDue,
      currentTotalDue: currentTotalDue,
      serviceChargePercentage: serviceChargePercentage,
      estimatedProfit: estimatedProfit,
      currentProfit: currentProfit,
      totalPaymentReceived: totalPaymentReceived,
    );
  }

  AccountLedger copyWith({
    String? ledgerId,
    String? entityType,
    double? totalOutstanding,
    double? currentDue,
    double? currentPayable,
    double? promiseAmount,
    DateTime? promiseDate,
    List<TransactionModel>? transactions,
    double? baseConstructionCost,
    double? totalConstructionCost,
    double? currentBaseDue,
    double? currentTotalDue,
    double? serviceChargePercentage,
    double? estimatedProfit,
    double? currentProfit,
    double? totalPaymentReceived,
  }) {
    return AccountLedger(
      ledgerId: ledgerId ?? this.ledgerId,
      entityType: entityType ?? this.entityType,
      totalOutstanding: totalOutstanding ?? this.totalOutstanding,
      currentDue: currentDue ?? this.currentDue,
      currentPayable: currentPayable ?? this.currentPayable,
      promiseAmount: promiseAmount ?? this.promiseAmount,
      promiseDate: promiseDate ?? this.promiseDate,
      transactions: transactions ?? this.transactions,
      baseConstructionCost: baseConstructionCost ?? this.baseConstructionCost,
      totalConstructionCost: totalConstructionCost ?? this.totalConstructionCost,
      currentBaseDue: currentBaseDue ?? this.currentBaseDue,
      currentTotalDue: currentTotalDue ?? this.currentTotalDue,
      serviceChargePercentage: serviceChargePercentage ?? this.serviceChargePercentage,
      estimatedProfit: estimatedProfit ?? this.estimatedProfit,
      currentProfit: currentProfit ?? this.currentProfit,
      totalPaymentReceived: totalPaymentReceived ?? this.totalPaymentReceived,
    );
  }
}