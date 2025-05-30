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
class SalesmanOrderListPage extends StatelessWidget {
  const SalesmanOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderCubit>()..fetchOrders(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Salesman Orders'),
        body: BlocBuilder<AdminOrderCubit, AdminOrderState>(
          builder: (context, state) {
            if (state is AdminOrderListFetchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminOrderListFetchSuccess) {
              // Group orders by salesman
              final salesmanOrders = _groupOrdersBySalesman(state.orders, state.users);
              return ListView.builder(
                itemCount: salesmanOrders.length,
                itemBuilder: (context, index) {
                  final salesman = salesmanOrders.keys.elementAt(index);
                  final orders = salesmanOrders[salesman]!;
                  return ListTile(
                    title: Text(salesman.userName ?? 'Unknown'),
                    subtitle: Text('Orders: ${orders.length} | Total: ₹${orders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(2)}'),
                    onTap: () {
                      sl<Coordinator>().navigateToPerformanceDetailsPage(
                        entityType: 'salesman',
                        entityId: salesman.userId!,
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

  Map<UserInfo, List<Order>> _groupOrdersBySalesman(List<Order> orders, List<UserInfo> users) {
    final Map<UserInfo, List<Order>> grouped = {};
    for (var order in orders) {
      if (order.orderTakenBy != null) {
        final salesman = users.firstWhere((user) => user.userId == order.orderTakenBy, orElse: () => UserInfo(userId: order.orderTakenBy, userName: 'Unknown'));
        grouped.putIfAbsent(salesman, () => []).add(order);
      }
    }
    return grouped;
  }
}