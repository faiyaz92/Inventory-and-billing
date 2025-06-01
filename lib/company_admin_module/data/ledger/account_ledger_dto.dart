
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transcation_dto.dart';

class AccountLedgerDto {
  final String? ledgerId;
  final String? entityType; // New: "Partner" or "User"
  final double totalOutstanding;
  final double? currentDue; // New: For CUSTOMER
  final double? currentPayable; // New: For SUPPLIER, EMPLOYEE, etc.
  final double? promiseAmount;
  final String? promiseDate;
  final List<TransactionDto>? transactions;

  // Civil site-specific fields
  final double? baseConstructionCost;
  final double? totalConstructionCost;
  final double? currentBaseDue;
  final double? currentTotalDue;
  final double? serviceChargePercentage;
  final double? estimatedProfit;
  final double? currentProfit;
  final double? totalPaymentReceived;

  AccountLedgerDto({
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

  factory AccountLedgerDto.fromMap(
      Map<String, dynamic> map, String id, List<TransactionDto> transactions) {
    return AccountLedgerDto(
      ledgerId: id,
      entityType: map['entityType'],
      totalOutstanding: map['totalOutstanding']?.toDouble() ?? 0.0,
      currentDue: map['currentDue']?.toDouble(),
      currentPayable: map['currentPayable']?.toDouble(),
      promiseAmount: map['promiseAmount']?.toDouble(),
      promiseDate: map['promiseDate'],
      transactions: transactions,
      baseConstructionCost: map['baseConstructionCost']?.toDouble(),
      totalConstructionCost: map['totalConstructionCost']?.toDouble(),
      currentBaseDue: map['currentBaseDue']?.toDouble(),
      currentTotalDue: map['currentTotalDue']?.toDouble(),
      serviceChargePercentage: map['serviceChargePercentage']?.toDouble(),
      estimatedProfit: map['estimatedProfit'].toDouble(),
      currentProfit: map['currentProfit']?.toDouble(),
      totalPaymentReceived: map['totalPaymentReceived']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entityType': entityType,
      'totalOutstanding': totalOutstanding,
      'currentDue': currentDue,
      'currentPayable': currentPayable,
      'promiseAmount': promiseAmount,
      'promiseDate': promiseDate,
      'transactions': transactions?.map((txn) => txn.toMap()).toList(),
      'baseConstructionCost': baseConstructionCost,
      'totalConstructionCost': totalConstructionCost,
      'currentBaseDue': currentBaseDue,
      'currentTotalDue': currentTotalDue,
      'serviceChargePercentage': serviceChargePercentage,
      'estimatedProfit': estimatedProfit,
      'currentProfit': currentProfit,
      'totalPaymentReceived': totalPaymentReceived,
    };
  }
}
