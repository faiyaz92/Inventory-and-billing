import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';

abstract class IOrderRepository {
  Future<void> addOrder(String companyId, OrderDto order);
  Future<List<OrderDto>> getOrdersByUser(String companyId, String userId);
  Future<List<OrderDto>> getAllOrders(String companyId);
  Future<void> updateOrderStatus(String companyId, String orderId, String status);
  Future<void> setExpectedDeliveryDate(String companyId, String orderId, DateTime date);
  Future<OrderDto> getOrderById(String companyId, String orderId);
}

class OrderRepositoryImpl implements IOrderRepository {
  final IFirestorePathProvider firestorePathProvider;

  OrderRepositoryImpl({
    required this.firestorePathProvider,
  });

  @override
  Future<void> addOrder(String companyId, OrderDto order) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore());
    } catch (e) {
      throw Exception('Failed to add order: $e');
    }
  }

  @override
  Future<List<OrderDto>> getOrdersByUser(String companyId, String userId) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      final snapshot = await ref.where('userId', isEqualTo: userId).get();
      return snapshot.docs.map((doc) => OrderDto.fromFirestore(doc.data() as Map<String,dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<OrderDto>> getAllOrders(String companyId) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) => OrderDto.fromFirestore(doc.data() as Map<String,dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String companyId, String orderId, String status) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> setExpectedDeliveryDate(String companyId, String orderId, DateTime date) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'expectedDeliveryDate': Timestamp.fromDate(date),
      });
    } catch (e) {
      throw Exception('Failed to set delivery date: $e');
    }
  }

  @override
  Future<OrderDto> getOrderById(String companyId, String orderId) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId).doc(orderId);
      final doc = await ref.get();
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      return OrderDto.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }
}