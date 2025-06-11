import 'package:agri_connect/core/utils/order_query.dart';
import 'package:agri_connect/features/products/presentation/providers/order_provider.dart';
import 'package:agri_connect/features/products/presentation/widgets/hoovable_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderListTab extends ConsumerWidget {
  final String userId;
  final String status;

  const OrderListTab({super.key, required this.userId, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = OrderQuery(buyer: userId, status: status);
    final asyncOrders = ref.watch(ordersByBuyerProvider(query));

    return asyncOrders.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No orders found.'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return HoverableOrderTile(order: order);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
