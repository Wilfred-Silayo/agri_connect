import 'package:agri_connect/core/enums/order_status_enum.dart';
import 'package:agri_connect/core/shared/widgets/show_loading_dialog.dart';
import 'package:agri_connect/core/shared/widgets/show_snackbar.dart';
import 'package:agri_connect/core/utils/order_query.dart';
import 'package:agri_connect/features/products/presentation/providers/order_provider.dart';
import 'package:agri_connect/features/products/presentation/providers/order_state.dart';
import 'package:agri_connect/features/products/presentation/widgets/hoovable_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesPage extends ConsumerWidget {
  final String userId;

  const SalesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = OrderQuery(
      buyer: userId,
      status: OrderStatus.delivered.value,
    );
    final asyncOrders = ref.watch(ordersBySellerProvider(query));

    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next is OrderLoading) {
        showLoadingDialog(context, message: 'Applying changes...');
      } else {
        hideLoadingDialog(context);
      }

      if (next is OrderFailure) {
        showSnackBar(context, next.message);
      } else if (next is OrderSuccess) {
        showSnackBar(context, 'Success');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Delivered Sales')),
      body: asyncOrders.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No delivered sales found.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return HoverableOrderTile(
                order: order,
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: const Text(
                            "Are you sure you want to delete this order?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(orderNotifierProvider.notifier)
                        .deleteOrderAndItems(order.id);
                    ref.invalidate(ordersBySellerProvider(query));
                  }
                },
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
