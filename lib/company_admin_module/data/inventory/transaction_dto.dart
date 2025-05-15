import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDto {
  final String id;
  final String type;
  final String productId;
  final int quantity;
  final String fromStoreId;
  final String? toStoreId;
  final String? customerId;
  final DateTime timestamp;
  final String userName; // Added
  final String userId;   // Added

  TransactionDto({
    required this.id,
    required this.type,
    required this.productId,
    required this.quantity,
    required this.fromStoreId,
    this.toStoreId,
    this.customerId,
    required this.timestamp,
    required this.userName,
    required this.userId,
  });

  factory TransactionDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionDto(
      id: doc.id,
      type: data['type'] ?? '',
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 0,
      fromStoreId: data['fromStoreId'] ?? '',
      toStoreId: data['toStoreId'],
      customerId: data['customerId'],
      timestamp: DateTime.parse(data['timestamp']),
      userName: data['userName'] ?? 'Unknown User', // Added with default
      userId: data['userId'] ?? 'unknown',          // Added with default
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'productId': productId,
      'quantity': quantity,
      'fromStoreId': fromStoreId,
      'toStoreId': toStoreId,
      'customerId': customerId,
      'timestamp': timestamp.toIso8601String(),
      'userName': userName, // Added
      'userId': userId,     // Added
    };
  }
}