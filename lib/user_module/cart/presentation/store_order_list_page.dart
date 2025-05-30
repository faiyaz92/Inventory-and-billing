import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class StoreOrderListPage extends StatelessWidget {
  const StoreOrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderCubit>()..fetchOrders(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Store Orders'),
        body: BlocBuilder<AdminOrderCubit, AdminOrderState>(
          builder: (context, state) {
            if (state is AdminOrderListFetchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminOrderListFetchSuccess) {
              final storeOrders = _groupOrdersByStore(state.orders, state.stores);
              return ListView.builder(
                itemCount: storeOrders.length,
                itemBuilder: (context, index) {
                  final store = storeOrders.keys.elementAt(index);
                  final orders = storeOrders[store]!;
                  return ListTile(
                    title: Text(store.name),
                    subtitle: Text('Orders: ${orders.length} | Total: ₹${orders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(2)}'),
                    onTap: () {
                      sl<Coordinator>().navigateToPerformanceDetailsPage(
                        entityType: 'store',
                        entityId: store.storeId,
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

  Map<StoreDto, List<Order>> _groupOrdersByStore(List<Order> orders, List<StoreDto> stores) {
    final Map<StoreDto, List<Order>> grouped = {};
    for (var order in orders) {
      if (order.storeId != null) {
        final store = stores.firstWhere(
              (store) => store.storeId == order.storeId,
          orElse: () => StoreDto(storeId: order.storeId??'', name: 'Unknown', createdBy: '', createdAt: DateTime.timestamp()),
        );
        grouped.putIfAbsent(store, () => []).add(order);
      }
    }
    return grouped;
  }
}