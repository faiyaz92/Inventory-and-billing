class TransactionDto {
  final String? transactionId;
  final String type; // "Debit" or "Credit"
  final double amount;
  final String? billNumber; // Only for Debit
  final String? receivedBy; // Only for Credit
  final DateTime createdAt;
  final String? purpose; // New: Material, Labor, etc.
  final String? typeOfPurpose; // New: Cement, Electrician, etc.
  final String? remarks; // New: 500-char remarks

  TransactionDto({
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

  factory TransactionDto.fromMap(Map<String, dynamic> map, String id) {
    return TransactionDto(
      transactionId: id,
      type: map['type'],
      amount: map['amount'].toDouble(),
      billNumber: map['billNumber'],
      receivedBy: map['receivedBy'],
      createdAt: DateTime.parse(map['createdAt']),
      purpose: map['purpose'],
      typeOfPurpose: map['typeOfPurpose'],
      remarks: map['remarks'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'billNumber': billNumber,
      'receivedBy': receivedBy,
      'createdAt': createdAt.toIso8601String(),
      'purpose': purpose,
      'typeOfPurpose': typeOfPurpose,
      'remarks': remarks,
    };
  }
}