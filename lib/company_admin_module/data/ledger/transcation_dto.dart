class TransactionDto {
  final String? transactionId;
  final String type; // "Debit" or "Credit"
  final double amount;
  final String? billNumber; // Only for Debit
  final String? receivedBy; // Only for Credit
  final DateTime createdAt;

  TransactionDto({
    this.transactionId,
    required this.type,
    required this.amount,
    this.billNumber,
    this.receivedBy,
    required this.createdAt,
  });

  factory TransactionDto.fromMap(Map<String, dynamic> map, String id) {
    return TransactionDto(
      transactionId: id,
      type: map['type'],
      amount: map['amount'].toDouble(),
      billNumber: map['billNumber'],
      receivedBy: map['receivedBy'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'billNumber': billNumber,
      'receivedBy': receivedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
