import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/features/products/models/order_model.dart';
import 'package:agri_connect/features/products/presentation/providers/order_provider.dart';
import 'package:agri_connect/features/products/presentation/widgets/hoovable_order_items_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailsPage extends ConsumerWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(orderItemsProvider(order.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: asyncItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items in this order.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return HoverableOrderItemTile(
                item: item,
                onConfirm:
                    item.status != 'confirmed'
                        ? () async {
                          final supabase = ref.read(supabaseClientProvider);

                          // 1. Confirm the item
                          await supabase
                              .from('order_items')
                              .update({
                                'status': 'confirmed',
                                'confirmed_at':
                                    DateTime.now().toIso8601String(),
                              })
                              .eq('id', item.id);

                          // 2. Check if all are confirmed
                          final response = await supabase
                              .from('order_items')
                              .select('status')
                              .eq('order_id', order.id);

                          final statuses = response as List;
                          final allConfirmed = statuses.every(
                            (row) => row['status'] == 'confirmed',
                          );

                          // 3. If all confirmed, update order status
                          if (allConfirmed) {
                            await supabase
                                .from('orders')
                                .update({'status': 'confirmed'})
                                .eq('id', order.id);
                          }

                          // 4. Refresh
                          ref.invalidate(orderItemsProvider(order.id));
                        }
                        : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
