import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class CustomerOrderListPage extends StatelessWidget {
  const CustomerOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderCubit>()..fetchOrders(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Customer Orders'),
        body: BlocBuilder<AdminOrderCubit, AdminOrderState>(
          builder: (context, state) {
            if (state is AdminOrderListFetchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminOrderListFetchSuccess) {
              final customerOrders = _groupOrdersByCustomer(state.orders, state.users);
              return ListView.builder(
                itemCount: customerOrders.length,
                itemBuilder: (context, index) {
                  final customer = customerOrders.keys.elementAt(index);
                  final orders = customerOrders[customer]!;
                  final lastOrder = orders.first; // Latest order
                  final daysSinceLastOrder = _daysSinceLastOrder(lastOrder);
                  return ListTile(
                    title: Text(customer.userName ?? 'Unknown'),
                    subtitle: Text('Orders: ${orders.length} | Last Order: ₹${lastOrder.totalAmount.toStringAsFixed(2)} ($daysSinceLastOrder)'),
                    onTap: () {
                      sl<Coordinator>().navigateToPerformanceDetailsPage(
                        entityType: 'customer',
                        entityId: customer.userId!,
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

  Map<UserInfo, List<Order>> _groupOrdersByCustomer(List<Order> orders, List<UserInfo> users) {
    final Map<UserInfo, List<Order>> grouped = {};
    for (var order in orders) {
      if (order.userId != null) {
        final customer = users.firstWhere(
              (user) => user.userId == order.userId,
          orElse: () => UserInfo(userId: order.userId, userName: 'Unknown'),
        );
        grouped.putIfAbsent(customer, () => []).add(order);
      }
    }
    return grouped;
  }

  String _daysSinceLastOrder(Order order) {
    final diff = DateTime.now().difference(order.orderDate);
    return '${diff.inDays} days ago';
  }
}