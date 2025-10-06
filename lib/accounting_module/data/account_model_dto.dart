class AccountDto {
  final String id;
  final String name;
  final String type;
  final String subtype;
  final String? storeId;
  final double balance;
  final String? companyId;
  final DateTime createdAt;

  AccountDto({
    required this.id,
    required this.name,
    required this.type,
    required this.subtype,
    this.storeId,
    required this.balance,
    this.companyId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'subtype': subtype,
    'storeId': storeId,
    'balance': balance,
    'companyId': companyId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AccountDto.fromMap(Map<String, dynamic> map, String id) => AccountDto(
    id: id,
    name: map['name'],
    type: map['type'],
    subtype: map['subtype'],
    storeId: map['storeId'],
    balance: map['balance'],
    companyId: map['companyId'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}