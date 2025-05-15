import 'package:cloud_firestore/cloud_firestore.dart';

class StockDto {
  final String id;
  final String productId;
  final String storeId;
  final int quantity;
  final DateTime lastUpdated;

  StockDto({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.lastUpdated,
  });

  factory StockDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockDto(
      id: doc.id,
      productId: data['productId'] ?? '',
      storeId: data['storeId'] ?? '',
      quantity: data['quantity'] ?? 0,
      lastUpdated: DateTime.parse(data['lastUpdated']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'storeId': storeId,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}