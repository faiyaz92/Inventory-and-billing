import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class DeliveryManOrderListPage extends StatelessWidget {
  const DeliveryManOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderCubit>()..fetchOrders(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Delivery Man Orders'),
        body: BlocBuilder<AdminOrderCubit, AdminOrderState>(
          builder: (context, state) {
            if (state is AdminOrderListFetchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminOrderListFetchSuccess) {
              final deliveryManOrders = _groupOrdersByDeliveryMan(state.orders, state.users);
              return ListView.builder(
                itemCount: deliveryManOrders.length,
                itemBuilder: (context, index) {
                  final deliveryMan = deliveryManOrders.keys.elementAt(index);
                  final orders = deliveryManOrders[deliveryMan]!;
                  return ListTile(
                    title: Text(deliveryMan.userName ?? 'Unknown'),
                    subtitle: Text('Orders: ${orders.length} | Total: ₹${orders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(2)}'),
                    onTap: () {
                      sl<Coordinator>().navigateToPerformanceDetailsPage(
                        entityType: 'deliveryman',
                        entityId: deliveryMan.userId!,
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Error loading data'));
          },
        ),
      ),
    );
  }

  Map<UserInfo, List<Order>> _groupOrdersByDeliveryMan(List<Order> orders, List<UserInfo> users) {
    final Map<UserInfo, List<Order>> grouped = {};
    for (var order in orders) {
      if (order.orderDeliveredBy != null) {
        final deliveryMan = users.firstWhere(
              (user) => user.userId == order.orderDeliveredBy,
          orElse: () => UserInfo(userId: order.orderDeliveredBy, userName: 'Unknown'),
        );
        grouped.putIfAbsent(deliveryMan, () => []).add(order);
      }
    }
    return grouped;
  }
}